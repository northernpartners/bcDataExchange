# DataExchange

A unified Business Central AL extension exposing data via web service APIs for external system integration.

**Publisher:** Northern Partners ApS  
**Platform:** Business Central 23.0+ | Runtime: AL 11.0  
**Target:** Cloud  
**ID Range:** 50150-50299  
**Latest Version:** 1.0.1.6

---

## Quick Start

For v1.0.1.6, define the following **required** rows in Business Central Web Services:

| Object | ID | Service Name | Method | Purpose |
|--------|----|----|--------|----------|
| Codeunit | 50151 | dxCreateDimensions | POST | Create dimensions and dimension values |
| Codeunit | 50152 | dxSalesInvoice | POST | Sales invoice operations (`createDraft` only) |
| Query | 50250 | dxCustomers | GET | Query and filter customer data (core fields) |
| Query | 50251 | dxCustomerDetails | GET | Query comprehensive customer details with address/contact/invoicing |
| Query | 50252 | dxDimensions | GET | Query dimension groups/codes |
| Query | 50253 | dxDimensionValues | GET | Query dimension values filtered by dimension group |

Optional legacy compatibility rows (only keep if existing clients still call them):

| Object | ID | Service Name | Method | Purpose |
|--------|----|----|--------|----------|
| Query | 50254 | dxDraftInvoices | GET | Legacy draft invoice query |
| Query | 50255 | dxPostedInvoices | GET | Legacy posted invoice query |

API Pages for invoice reads are available via `/api/np/dx/v1.0/...` and do not require manual Web Services rows:

| API Page | ID | Entity Set | Notes |
|---------|----|------------|-------|
| DX Draft Invoice API | 50260 | dxDraftInvoices | Supports `$expand` for lines and dimensions |
| DX Draft Invoice Line API | 50261 | dxDraftInvoiceLines | Used via `$expand` from headers |
| DX Posted Invoice API | 50262 | dxPostedInvoices | Supports `$expand` for lines and dimensions |
| DX Posted Invoice Line API | 50263 | dxPostedInvoiceLines | Used via `$expand` from headers |

### Building the Extension

1. **Download Symbols** (VS Code: `AL: Download Symbols`)
2. **Build Package** (VS Code: `AL: Package`)
3. **Deploy** to Business Central environment

### Enabling Web Services

1. Search "Web Services" in Business Central
2. Add required services:
   - **dxCreateDimensions:** Codeunit 50151 "Dimension Handler"
   - **dxSalesInvoice:** Codeunit 50152 "Sales Invoice Handler"
   - **dxCustomers:** Query 50250 "Customers"
   - **dxCustomerDetails:** Query 50251 "Customer Details"
   - **dxDimensions:** Query 50252 "Dimensions"
   - **dxDimensionValues:** Query 50253 "Dimension Values"
3. Optional: keep Query 50254/50255 only for legacy clients.
4. Publish and test

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
├── pages/
│   ├── DraftInvoiceAPI.al        # API page (50260)
│   ├── DraftInvoiceLineAPI.al    # API page (50261)
│   ├── PostedInvoiceAPI.al       # API page (50262)
│   ├── PostedInvoiceLineAPI.al   # API page (50263)
│   └── InvoiceDimensionAPI.al    # API page (50264)
└── .vscode/                      # VS Code configuration
```

---

**Last Updated:** June 18, 2026  
**Published by:** Northern Partners ApS
