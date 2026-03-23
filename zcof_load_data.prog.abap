# ABAP Objects — COF NEXUS Dashboard

All ABAP objects for the DashForge COF NEXUS dashboard. Deployed via **abapGit** — no manual SE38/SE80 editing required after initial setup.

## Object inventory

| Object | Type | Description |
|--------|------|-------------|
| `ZTCOF_DATA` | Transparent table | Stores all 377 COF report records |
| `ZI_COF_REPORT` | CDS Root View Entity | RAP interface view over ZTCOF_DATA |
| `ZC_COF_REPORT` | CDS Projection View | UI annotations, RAP transactional query |
| `ZI_COF_REPORT` | Behavior Definition | Read-only RAP behavior (no SEGW) |
| `ZBP_I_COF_REPORT` | Behavior Pool class | Abstract behavior implementation class |
| `ZCOF_DASHBOARD_SRV` | Service Definition | Exposes ZC_COF_REPORT as CofReport entity |
| `ZCOF_DASHBOARD_O4` | Service Binding | OData V4 Web API binding |
| `ZCOF_LOAD_DATA` | ABAP Report | Loads 377 COF records into ZTCOF_DATA |

## Activation order

abapGit activates objects alphabetically. The objects are named so they activate in dependency order:

```
1. ZTCOF_DATA          (table — no dependencies)
2. ZI_COF_REPORT CDS  (reads table)
3. ZC_COF_REPORT CDS  (projection on ZI_COF_REPORT)
4. ZI_COF_REPORT BDEF (references ZI_COF_REPORT CDS)
5. ZBP_I_COF_REPORT   (behavior pool for BDEF)
6. ZCOF_DASHBOARD_SRV (references ZC_COF_REPORT)
7. ZCOF_DASHBOARD_O4  (binding — references SRV)
```

If activation fails on a CDS view due to order, activate manually in ADT: right-click the view → Activate.

## Service binding URL pattern

After publishing `ZCOF_DASHBOARD_O4` in the ADT Service Binding editor (or via `/IWBEP/V4_ADMIN`):

```
/sap/opu/odata4/sap/zcof_dashboard_o4/sap/0001/
/sap/opu/odata4/sap/zcof_dashboard_o4/sap/0001/CofReport
/sap/opu/odata4/sap/zcof_dashboard_o4/sap/0001/$metadata
```

Test in browser (SAP logon required):
```
GET https://your-sap.corp.com:44300/sap/opu/odata4/sap/zcof_dashboard_o4/sap/0001/CofReport?$top=5&$format=json
```

## Running the data load

After abapGit pull and service activation:

```
Transaction: SE38
Program:     ZCOF_LOAD_DATA
Execute:     F8 (or press Execute button)
```

The report:
1. Deletes all existing rows from `ZTCOF_DATA`
2. Inserts all 377 records in a single `MODIFY ... FROM TABLE` statement
3. Commits work
4. Prints count confirmation

Run this report on every system (DEV, QA, PROD) after transport import.

## Adding new COF records

1. Edit `abap/src/zcof_load_data.prog.abap`
2. Add new entries to the `lt_cof = VALUE #( ... )` block
3. Each entry requires a unique `txn_id` (six-digit padded sequence, e.g. `000378`)
4. Commit and push → CI/CD deploys the updated program to SAP
5. Execute `ZCOF_LOAD_DATA` in SE38 on the target system

## Required authorizations for technical RFC user

The user configured in GitHub secret `SAP_RFC_USER` needs:

```
S_RFC      RFC_TYPE = FUGR, RFC_NAME = SYST, ACTVT = 16
S_DEVELOP  ACTVT = 01,02,06,16 — for abapGit pull
S_TRANSPRT ACTVT = 01,02,03 — for transport assignment
S_PROGRAM  P_GROUP = * , ACTVT = 16 — for report execution
```
