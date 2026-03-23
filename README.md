name: DashForge COF — Full CI/CD Pipeline

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        default: 'dev'
        type: choice
        options:
          - dev
          - qa
          - prod

env:
  NODE_VERSION: '20'
  MBT_VERSION: '1.2.25'

# ================================================================
jobs:
# ================================================================

  # ──────────────────────────────────────────────────────────────
  # JOB 1: Validate all files (runs on every push & PR)
  # ──────────────────────────────────────────────────────────────
  validate:
    name: Validate repository files
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Validate ABAP abapGit XML files
        run: |
          echo "Checking ABAP source files exist"
          REQUIRED=(
            "abap/.abapgit.xml"
            "abap/src/ztcof_data.tabl.xml"
            "abap/src/zi_cof_report.ddls.asddls"
            "abap/src/zc_cof_report.ddls.asddls"
            "abap/src/zi_cof_report.bdef.asbdef"
            "abap/src/zcof_dashboard_srv.srvd.asddls"
            "abap/src/zcof_dashboard_o4.srvb.xml"
            "abap/src/zbp_i_cof_report.clas.abap"
            "abap/src/zcof_load_data.prog.abap"
          )
          for f in "${REQUIRED[@]}"; do
            if [[ ! -f "$f" ]]; then
              echo "MISSING: $f"
              exit 1
            fi
            echo "  OK: $f"
          done

      - name: Validate BTP files
        run: |
          REQUIRED=(
            "btp/mta.yaml"
            "btp/xs-security.json"
            "btp/approuter/xs-app.json"
            "btp/approuter/package.json"
            "btp/webapp/index.html"
            "btp/webapp/manifest.json"
          )
          for f in "${REQUIRED[@]}"; do
            if [[ ! -f "$f" ]]; then
              echo "MISSING: $f"
              exit 1
            fi
            echo "  OK: $f"
          done

      - name: Validate JSON files
        run: |
          for f in btp/xs-security.json btp/approuter/xs-app.json btp/approuter/package.json btp/webapp/manifest.json; do
            python3 -c "import json; json.load(open('$f'))" && echo "  JSON OK: $f" || exit 1
          done

      - name: Validate YAML files
        run: |
          pip install pyyaml -q
          python3 -c "import yaml; yaml.safe_load(open('btp/mta.yaml'))" && echo "  YAML OK: btp/mta.yaml" || exit 1

      - name: Check index.html contains OData loader
        run: |
          grep -q "loadCOFData" btp/webapp/index.html && echo "  OK: OData loader present"
          grep -q "mapCofRecord" btp/webapp/index.html && echo "  OK: Field mapper present"
          grep -qv "var RAW_DATA = \[{" btp/webapp/index.html && echo "  OK: No hardcoded data"

  # ──────────────────────────────────────────────────────────────
  # JOB 2: Deploy ABAP objects via abapGit (main branch only)
  # ──────────────────────────────────────────────────────────────
  deploy-abap:
    name: Deploy ABAP to SAP (abapGit)
    runs-on: ubuntu-latest
    needs: validate
    if: github.ref == 'refs/heads/main'
    environment: abap-dev
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Deploy ABAP objects
        env:
          SAP_HOST:         ${{ secrets.SAP_DEV_HOST }}
          SAP_USER:         ${{ secrets.SAP_RFC_USER }}
          SAP_PASS:         ${{ secrets.SAP_RFC_PASS }}
          SAP_CLIENT:       ${{ secrets.SAP_CLIENT }}
          ABAP_PACKAGE:     ZCOF_DASHBOARD
          ABAPGIT_REPO_URL: ${{ github.server_url }}/${{ github.repository }}
        run: bash scripts/deploy_abap.sh

  # ──────────────────────────────────────────────────────────────
  # JOB 3: Build MTA archive (reusable artifact)
  # ──────────────────────────────────────────────────────────────
  build-btp:
    name: Build BTP MTA archive
    runs-on: ubuntu-latest
    needs: validate
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node.js ${{ env.NODE_VERSION }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}

      - name: Install MBT
        run: npm install -g mbt@${{ env.MBT_VERSION }}

      - name: Install Cloud Foundry CLI v8
        run: |
          curl -fsSL \
            "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=v8&source=github-rel" \
            -o cf.tgz
          tar -xzf cf.tgz
          sudo mv cf8 /usr/local/bin/cf
          cf version

      - name: Install MTA CF plugin
        run: |
          cf install-plugin \
            "https://github.com/cloudfoundry-incubator/multiapps-cli-plugin/releases/latest/download/multiapps-plugin.linux64" \
            -f
          cf multiapps --version

      - name: Install approuter dependencies
        run: npm ci --prefix btp/approuter --production

      - name: Create resources directory
        run: mkdir -p btp/resources

      - name: Build MTA archive
        working-directory: btp
        run: |
          mbt build -t ./ --mtar=dashforge-cof.mtar
          ls -lh dashforge-cof.mtar

      - name: Upload MTA artifact
        uses: actions/upload-artifact@v4
        with:
          name: dashforge-cof-mtar-${{ github.sha }}
          path: btp/dashforge-cof.mtar
          retention-days: 14
          if-no-files-found: error

  # ──────────────────────────────────────────────────────────────
  # JOB 4: Deploy to DEV space
  # ──────────────────────────────────────────────────────────────
  deploy-dev:
    name: Deploy to BTP dev space
    runs-on: ubuntu-latest
    needs:
      - deploy-abap
      - build-btp
    environment:
      name: btp-dev
      url: ${{ steps.get-url.outputs.app_url }}
    outputs:
      app_url: ${{ steps.get-url.outputs.app_url }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Download MTA artifact
        uses: actions/download-artifact@v4
        with:
          name: dashforge-cof-mtar-${{ github.sha }}
          path: btp/

      - name: Install CF CLI + MTA plugin
        run: |
          curl -fsSL \
            "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=v8&source=github-rel" \
            -o cf.tgz && tar -xzf cf.tgz && sudo mv cf8 /usr/local/bin/cf
          cf install-plugin \
            "https://github.com/cloudfoundry-incubator/multiapps-cli-plugin/releases/latest/download/multiapps-plugin.linux64" \
            -f

      - name: CF Login to dev space
        run: |
          cf api "${{ secrets.CF_API }}"
          cf auth "${{ secrets.CF_USER }}" "${{ secrets.CF_PASS }}"
          cf target -o "${{ secrets.CF_ORG }}" -s "dev"

      - name: Deploy to BTP dev
        working-directory: btp
        env:
          SCC_VIRTUAL_HOST: ${{ secrets.SCC_VIRTUAL_HOST }}
          SCC_VIRTUAL_PORT: ${{ secrets.SCC_VIRTUAL_PORT }}
          SAP_CLIENT:       ${{ secrets.SAP_CLIENT }}
          SAP_RFC_USER:     ${{ secrets.SAP_RFC_USER }}
          SAP_RFC_PASS:     ${{ secrets.SAP_RFC_PASS_DEV }}
        run: |
          sed -i \
            -e "s|\${SCC_VIRTUAL_HOST}|${SCC_VIRTUAL_HOST}|g" \
            -e "s|\${SCC_VIRTUAL_PORT}|${SCC_VIRTUAL_PORT}|g" \
            -e "s|\${SAP_RFC_USER}|${SAP_RFC_USER}|g" \
            -e "s|\${SAP_RFC_PASS}|${SAP_RFC_PASS}|g" \
            -e "s|\${SAP_CLIENT}|${SAP_CLIENT}|g" \
            mta.yaml
          cf deploy dashforge-cof.mtar \
            --strategy rolling \
            --retries 3 \
            --abort-on-error

      - name: Get deployed URL
        id: get-url
        run: |
          ROUTE=$(cf app dashforge-cof-approuter \
            | grep "routes:" | awk '{print $2}' | tr -d ',')
          echo "app_url=https://${ROUTE}" >> "${GITHUB_OUTPUT}"
          echo "Deployed to: https://${ROUTE}"

      - name: Smoke test
        run: |
          URL="${{ steps.get-url.outputs.app_url }}"
          CODE=$(curl -s -o /dev/null -w "%{http_code}" \
            --max-time 15 "${URL}/index.html")
          echo "HTTP ${CODE} — ${URL}/index.html"
          [[ "${CODE}" == "200" || "${CODE}" == "302" ]] || \
            (echo "Smoke test failed: HTTP ${CODE}" && exit 1)

  # ──────────────────────────────────────────────────────────────
  # JOB 5: Deploy to PROD (requires manual approval gate)
  # ──────────────────────────────────────────────────────────────
  deploy-prod:
    name: Deploy to BTP production
    runs-on: ubuntu-latest
    needs: deploy-dev
    environment:
      name: btp-prod
      url: ${{ steps.get-url-prod.outputs.app_url }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Download MTA artifact
        uses: actions/download-artifact@v4
        with:
          name: dashforge-cof-mtar-${{ github.sha }}
          path: btp/

      - name: Install CF CLI + MTA plugin
        run: |
          curl -fsSL \
            "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=v8&source=github-rel" \
            -o cf.tgz && tar -xzf cf.tgz && sudo mv cf8 /usr/local/bin/cf
          cf install-plugin \
            "https://github.com/cloudfoundry-incubator/multiapps-cli-plugin/releases/latest/download/multiapps-plugin.linux64" \
            -f

      - name: CF Login to production space
        run: |
          cf api "${{ secrets.CF_API }}"
          cf auth "${{ secrets.CF_USER_PROD }}" "${{ secrets.CF_PASS_PROD }}"
          cf target -o "${{ secrets.CF_ORG }}" -s "production"

      - name: Deploy to BTP production
        working-directory: btp
        env:
          SCC_VIRTUAL_HOST: ${{ secrets.SCC_VIRTUAL_HOST_PROD }}
          SCC_VIRTUAL_PORT: ${{ secrets.SCC_VIRTUAL_PORT_PROD }}
          SAP_CLIENT:       ${{ secrets.SAP_CLIENT_PROD }}
          SAP_RFC_USER:     ${{ secrets.SAP_RFC_USER_PROD }}
          SAP_RFC_PASS:     ${{ secrets.SAP_RFC_PASS_PROD }}
        run: |
          sed -i \
            -e "s|\${SCC_VIRTUAL_HOST}|${SCC_VIRTUAL_HOST}|g" \
            -e "s|\${SCC_VIRTUAL_PORT}|${SCC_VIRTUAL_PORT}|g" \
            -e "s|\${SAP_RFC_USER}|${SAP_RFC_USER}|g" \
            -e "s|\${SAP_RFC_PASS}|${SAP_RFC_PASS}|g" \
            -e "s|\${SAP_CLIENT}|${SAP_CLIENT}|g" \
            mta.yaml
          cf deploy dashforge-cof.mtar \
            --strategy rolling \
            --retries 3 \
            --abort-on-error

      - name: Get production URL
        id: get-url-prod
        run: |
          ROUTE=$(cf app dashforge-cof-approuter \
            | grep "routes:" | awk '{print $2}' | tr -d ',')
          echo "app_url=https://${ROUTE}" >> "${GITHUB_OUTPUT}"

      - name: Final smoke test — production
        run: |
          URL="${{ steps.get-url-prod.outputs.app_url }}"
          CODE=$(curl -s -o /dev/null -w "%{http_code}" \
            --max-time 15 "${URL}/index.html")
          echo "Production HTTP ${CODE} — ${URL}"
          [[ "${CODE}" == "200" || "${CODE}" == "302" ]] || exit 1
