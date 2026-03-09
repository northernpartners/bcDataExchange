# DataExchange

A unified Business Central AL extension exposing data via web service APIs for external system integration.

**Publisher:** Northern Partners ApS  
**Platform:** Business Central 23.0+ | Runtime: AL 11.0  
**Target:** Cloud  
**ID Range:** 50150-50299  
**Latest Version:** 1.0.0.6

---

## Quick Start

The DataExchange extension exposes seven web service endpoints:

| Object | ID | Service Name | Method | Purpose |
|--------|----|----|--------|----------|
| Codeunit | 50151 | createDimensions | POST | Create dimensions and dimension values |
| Query | 50250 | queryCustomers | GET | Query and filter customer data (core fields) |
| Query | 50251 | customerDetails | GET | Query comprehensive customer details with address/contact/invoicing |
| Query | 50252 | dimensions | GET | Query dimension groups/codes |
| Query | 50253 | dimensionValues | GET | Query dimension values filtered by dimension group |
| Query | 50254 | draftInvoices | GET | Query draft sales invoices |
| Query | 50255 | postedInvoices | GET | Query posted sales invoices |

### Building the Extension

1. **Download Symbols** (VS Code: `AL: Download Symbols`)
2. **Build Package** (VS Code: `AL: Package`)
3. **Deploy** to Business Central environment

### Enabling Web Services

1. Search "Web Services" in Business Central
2. Add new services:
   - **createDimensions:** Codeunit 50151 "Dimension Handler"
   - **queryCustomers:** Query 50250 "Customers"
   - **customerDetails:** Query 50251 "Customer Details"
   - **dimensions:** Query 50252 "Dimensions"
   - **dimensionValues:** Query 50253 "Dimension Values"
   - **draftInvoices:** Query 50254 "Draft Invoices"
   - **postedInvoices:** Query 50255 "Posted Invoices"
3. Publish and test

---

## Documentation

For detailed information, see the [DataExchange Gitbook](https://npgroup.gitbook.io/dataexchange).

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
│   ├── CustomersQuery.al         # OData endpoint (50250)
│   ├── CustomerDetailsQuery.al   # OData endpoint (50251)
│   ├── DimensionsQuery.al        # OData endpoint (50252)
│   ├── DimensionValuesQuery.al   # OData endpoint (50253)
│   ├── DraftInvoicesQuery.al     # OData endpoint (50254)
│   └── PostedInvoicesQuery.al    # OData endpoint (50255)
└── .vscode/                      # VS Code configuration
```

---

**Last Updated:** March 9, 2026  
**Published by:** Northern Partners ApS
