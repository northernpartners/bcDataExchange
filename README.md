# DataExchange

A unified Business Central AL extension exposing data via web service APIs for external system integration.

**Publisher:** Northern Partners ApS  
**Platform:** Business Central 23.0+ | Runtime: AL 11.0  
**Target:** Cloud  
**ID Range:** 50150-50299  
**Latest Version:** 1.0.1.2

---

## Quick Start

The DataExchange extension exposes eight web service endpoints:

| Object | ID | Service Name | Method | Purpose |
|--------|----|----|--------|----------|
| Codeunit | 50151 | dxCreateDimensions | POST | Create dimensions and dimension values |
| Codeunit | 50152 | dxSalesInvoice | POST | Sales invoice operations (details, create with lines & dimensions) |
| Query | 50250 | dxCustomers | GET | Query and filter customer data (core fields) |
| Query | 50251 | dxCustomerDetails | GET | Query comprehensive customer details with address/contact/invoicing |
| Query | 50252 | dxDimensions | GET | Query dimension groups/codes |
| Query | 50253 | dxDimensionValues | GET | Query dimension values filtered by dimension group |
| Query | 50254 | dxDraftInvoices | GET | Query draft sales invoices |
| Query | 50255 | dxPostedInvoices | GET | Query posted sales invoices |

### Building the Extension

1. **Download Symbols** (VS Code: `AL: Download Symbols`)
2. **Build Package** (VS Code: `AL: Package`)
3. **Deploy** to Business Central environment

### Enabling Web Services

1. Search "Web Services" in Business Central
2. Add new services:
   - **dxCreateDimensions:** Codeunit 50151 "Dimension Handler"
   - **dxSalesInvoice:** Codeunit 50152 "Sales Invoice Handler"
   - **dxCustomers:** Query 50250 "Customers"
   - **dxCustomerDetails:** Query 50251 "Customer Details"
   - **dxDimensions:** Query 50252 "Dimensions"
   - **dxDimensionValues:** Query 50253 "Dimension Values"
   - **dxDraftInvoices:** Query 50254 "Draft Invoices"
   - **dxPostedInvoices:** Query 50255 "Posted Invoices"
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
│   ├── DimensionHelpers.al       # Helper functions (50150)
│   ├── SalesInvoiceHandler.al    # REST API (50152)
│   └── SalesInvoiceHelpers.al    # Helper functions (50153)
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

**Last Updated:** March 10, 2026  
**Published by:** Northern Partners ApS
