# GitHub Actions Secrets Reference

All secrets used by `.github/workflows/deploy.yml`.

Set them at: **Repository → Settings → Secrets and variables → Actions → New repository secret**

## ABAP / SAP secrets

| Secret | Required | Example | Description |
|--------|----------|---------|-------------|
| `SAP_DEV_HOST` | Yes | `https://s4dev.corp.com:44300` | SAP dev system full URL including port |
| `SAP_RFC_USER` | Yes | `RFC_COF_DEPLOY` | Technical ABAP user for abapGit REST API |
| `SAP_RFC_PASS` | Yes | | Password for SAP_RFC_USER |
| `SAP_CLIENT` | Yes | `100` | SAP logon client number |

## Cloud Foundry / BTP secrets

| Secret | Required | Example | Description |
|--------|----------|---------|-------------|
| `CF_API` | Yes | `https://api.cf.eu10.hana.ondemand.com` | BTP CF API endpoint (from subaccount overview) |
| `CF_USER` | Yes | `deploy@yourcompany.com` | BTP platform user for dev/qa deploy |
| `CF_PASS` | Yes | | Password for CF_USER |
| `CF_USER_PROD` | Yes | `deploy-prod@yourcompany.com` | BTP platform user for production |
| `CF_PASS_PROD` | Yes | | Password for CF_USER_PROD |
| `CF_ORG` | Yes | `abc123-your-org` | CF org name (subaccount ID or alias) |

## Cloud Connector / Backend connection secrets

| Secret | Required | Example | Description |
|--------|----------|---------|-------------|
| `SCC_VIRTUAL_HOST` | Yes | `vcofdev.corp.com` | Virtual hostname defined in SCC for dev |
| `SCC_VIRTUAL_PORT` | Yes | `44300` | Virtual port defined in SCC |
| `SAP_RFC_PASS_DEV` | Yes | | Password for the SAP user in dev BTP destination |
| `SCC_VIRTUAL_HOST_PROD` | Yes | `vcofprod.corp.com` | Virtual hostname for production SCC |
| `SCC_VIRTUAL_PORT_PROD` | Yes | `44300` | Virtual port for production SCC |
| `SAP_CLIENT_PROD` | Yes | `200` | SAP client for production system |
| `SAP_RFC_USER_PROD` | Yes | `RFC_COF_PROD` | SAP technical user for production destination |
| `SAP_RFC_PASS_PROD` | Yes | | Password for production SAP user |

## How to find CF_API and CF_ORG

1. Log in to **BTP cockpit** → Select your subaccount
2. **Cloud Foundry** section → shows **API Endpoint** = `CF_API`
3. **Cloud Foundry** section → shows **Org Name** = `CF_ORG`

## How to find SCC_VIRTUAL_HOST / SCC_VIRTUAL_PORT

1. Open **SAP Cloud Connector admin** at `https://localhost:8443`
2. **Cloud To On-Premise** → **Access Control**
3. The **Virtual Host** and **Virtual Port** columns show the values

## Creating a dedicated BTP platform user (recommended)

Rather than using a personal user for CI/CD:

1. **BTP cockpit → Security → Users** → Add a new user `deploy@yourcompany.com`
2. Assign **Platform roles**: `Org Manager` for dev space, limited roles for prod
3. Use this user's credentials as `CF_USER` / `CF_PASS`
