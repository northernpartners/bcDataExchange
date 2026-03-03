# DataExchange

A unified Business Central AL extension exposing data via web service APIs for external system integration.

**Publisher:** Northern Partners ApS  
**Platform:** Business Central 23.0+ | Runtime: AL 11.0  
**Target:** Cloud  
**ID Range:** 50150-50299  
**Latest Version:** 1.0.0.0

---

## Quick Start

The DataExchange extension exposes two web service endpoints:

| Object | ID | Service Name | Method | Purpose |
|--------|----|----|--------|---------|
| Codeunit | 50151 | createDimensions | POST | Create dimensions and dimension values |
| Query | 50250 | queryCustomers | GET | Query and filter customer data |

### Building the Extension

1. **Download Symbols** (VS Code: `AL: Download Symbols`)
2. **Build Package** (VS Code: `AL: Package`)
3. **Deploy** to Business Central environment

### Enabling Web Services

1. Search "Web Services" in Business Central
2. Add new services:
   - **createDimensions:** Codeunit 50151 "Dimension Handler"
   - **queryCustomers:** Query 50250 "Customers"
3. Publish and test

---

## Documentation

For detailed information, see the [./docs](./docs) folder.

---

## Quick API Examples

**Dimension Creation:**
```bash
curl -X POST https://[env].dynamics.com/api/businesses([id])/codeunits/createDimensions \
  -H 'Content-Type: application/json' \
  -d '{"name":"DEPT","values":[{"code":"SALES","name":"Sales"}]}'
```

**Customer Query:**
```bash
GET https://[env].dynamics.com/ODataV4/Company('[id]')/customers?$filter=customerNo eq 'CUST-001'
```

**See [./docs](./docs) for complete documentation.**

---

## Project Structure

```
DataExchange/
├── app.json                      # Extension metadata
├── README.md                     # This file
├── codeunits/
│   ├── DimensionHandler.al       # REST API (50151)
│   └── DimensionHelpers.al       # Helper functions (50150)
├── queries/
│   └── CustomersQuery.al         # OData endpoint (50250)
└── .vscode/                      # VS Code configuration
```

---

**Last Updated:** March 3, 2026  
**Published by:** Northern Partners ApS
