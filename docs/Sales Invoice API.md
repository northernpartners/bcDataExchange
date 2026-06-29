# Sales Invoice API

Process sales invoice operations via a RESTful JSON API. In v1.0.1.9 this endpoint supports creating draft invoices only.

> **Change Notice:** As of v1.0.1.9, `getDraftDetails` and `getPostedDetails` have been removed from this endpoint. Use OData API Pages for reads:
> - Draft invoices: GET `/api/np/dx/v1.0/.../dxDraftInvoices` with `$expand`
> - Posted invoices: GET `/api/np/dx/v1.0/.../dxPostedInvoices` with `$expand`
>
> This CodeUnit endpoint now supports `createDraft` only.

## Endpoint Configuration

**Web Service ID:** Codeunit 50152 "Sales Invoice Handler"  
**Service Name:** `dxSalesInvoice`  
**HTTP Method:** POST  
**Protocol:** REST/JSON  
**Authentication:** Business Central credentials required

## Request Format

**Base URL:**
```
[BC Environment]/api/businesses([Company ID])/codeunits/dxSalesInvoice
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer [auth-token]
```

**Request Body:**
```json
{
  "action": "[action-name]",
  ...action-specific parameters
}
```

## Available Actions

| Action | Description |
|--------|-------------|
| `createDraft` | Create a new draft sales invoice with optional line items |

> **Status:** `getDraftDetails` and `getPostedDetails` are removed in v1.0.1.9. Use API Page endpoints `dxDraftInvoices` and `dxPostedInvoices` for invoice reads.

---

## Migration From Removed Actions

- `getDraftDetails` -> `GET /api/np/dx/v1.0/.../dxDraftInvoices?$expand=dxDraftInvoiceLines($expand=dxInvoiceDimensions),dxDraftInvoiceDimensions`
- `getPostedDetails` -> `GET /api/np/dx/v1.0/.../dxPostedInvoices?$expand=dxPostedInvoiceLines($expand=dxInvoiceDimensions),dxPostedInvoiceDimensions`
- `dxDraftInvoiceLines` and `dxPostedInvoiceLines` are returned through `$expand` and do not need separate Web Services rows.

---

## Action: createDraft

Creates a new draft sales invoice with the specified customer, dates, and currency. Optionally creates line items in the same request.

### Request (header only)

```json
{
  "action": "createDraft",
  "customerId": "C00100",
  "documentDate": "2026-03-09",
  "dueDate": "2026-04-09",
  "currencyCode": "DKK",
  "paymentTermsCode": "NET30"
}
```

### Request (with lines)

```json
{
  "action": "createDraft",
  "customerId": "C00100",
  "documentDate": "2026-03-09",
  "currencyCode": "DKK",
  "lines": [
    {
      "lineType": "Item",
      "itemNumber": "ITEM-001",
      "description": "Consulting services",
      "quantity": 10,
      "unitOfMeasureCode": "HOUR",
      "unitPrice": 1000.00
    },
    {
      "lineType": "G/L Account",
      "itemNumber": "6100",
      "description": "Travel expenses",
      "quantity": 1,
      "unitPrice": 2500.00
    }
  ]
}
```

### Request Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `action` | Text | Yes | Must be `createDraft` |
| `customerId` | Code[20] | Yes | Customer number (must exist in BC) |
| `documentDate` | Text | Yes | Document date in YYYY-MM-DD format |
| `dueDate` | Text | No | Due date in YYYY-MM-DD format. If omitted, calculated from payment terms. |
| `currencyCode` | Code[10] | Yes | Currency code |
| `paymentTermsCode` | Code[10] | No | Payment terms code |
| `lines` | Array | No | Array of line items to create (see below) |

### Line Item Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `lineType` | Text | Yes | `Item`, `G/L Account`, `Resource`, or `Charge (Item)` |
| `itemNumber` | Code[20] | No | Item number, G/L account, or resource code |
| `description` | Text | No | Line description |
| `quantity` | Decimal | No | Quantity (defaults to 0) |
| `unitOfMeasureCode` | Code[10] | No | Unit of measure code |
| `unitPrice` | Decimal | No | Unit price (defaults to 0) |

### Response - Success (with lines)

```json
{
  "systemId": "f6a7b8c9-d0e1-2345-fghi-jklmnopqrstu",
  "invoiceNumber": "SI-1003",
  "customerId": "C00100",
  "dueDate": "2026-04-09",
  "documentDate": "2026-03-09",
  "currencyCode": "DKK",
  "paymentTermsCode": "NET30",
  "status": "Open",
  "amount": 15625.00,
  "amountExcludingVat": 12500.00,
  "vat": 3125.00,
  "lines": [
    {
      "systemId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "lineNumber": 10000,
      "lineType": "Item",
      "itemNumber": "ITEM-001",
      "description": "Consulting services",
      "quantity": 10,
      "unitOfMeasureCode": "HOUR",
      "unitPrice": 1000.00,
      "lineAmount": 10000.00,
      "lineDimensions": [
        { "code": "ACTPERIOD", "value": "SIW", "dimensionId": "a1b2c3d4-0000-0000-0000-000000000001" }
      ]
    },
    {
      "systemId": "c3d4e5f6-a7b8-9012-cdef-123456789012",
      "lineNumber": 20000,
      "lineType": "G/L Account",
      "itemNumber": "6100",
      "description": "Travel expenses",
      "quantity": 1,
      "unitOfMeasureCode": "",
      "unitPrice": 2500.00,
      "lineAmount": 2500.00,
      "lineDimensions": []
    }
  ],
  "dimensions": [
    { "code": "ACTPERIOD", "value": "SIW", "dimensionId": "a1b2c3d4-0000-0000-0000-000000000001" }
  ]
}
```

When no `lines` are provided, the response omits the `lines` array and amounts will be zero.

The response includes all default dimensions applied by BC to both the header (`dimensions`) and each line (`lineDimensions`), along with the `dimensionId` GUID needed for Standard API PATCH/POST operations.

### Response - Error

```json
{
  "error": true,
  "code": "Customer not found",
  "message": "The customer with ID \"C99999\" does not exist."
}
```

---

## Error Responses

All actions return standardized error responses:

### Missing/Invalid Action

```json
{
  "success": false,
  "error": "Missing or invalid \"action\" field."
}
```

### Unknown Action

```json
{
  "success": false,
  "error": "Unknown action: invalidAction"
}
```

### Invalid JSON

```json
{
  "success": false,
  "error": "Invalid JSON in requestBody."
}
```

### Invoice Not Found

```json
{
  "error": true,
  "code": "Invoice not found",
  "message": "The requested draft invoice does not exist."
}
```

---

## Dimension Assignment Workflow

Dimensions are assigned via the BC Standard API v2.0 `dimensionSetLines` resource. The `createDraft` response includes default dimensions (with `dimensionId` GUIDs) so you can determine whether to PATCH existing or POST new dimensions without extra API calls.

### Steps

1. **Create draft with lines** via `createDraft` — returns `systemId` (invoice GUID), line `systemId` GUIDs, and default `dimensions`/`lineDimensions` with `dimensionId`

2. **For each header dimension**, check if it already exists in the `dimensions` array:
   - **Exists** → PATCH to update the value (requires `If-Match: *` header):
     ```
     PATCH /api/v2.0/companies({companyId})/salesInvoices({systemId})/dimensionSetLines({dimensionId})
     { "valueCode": "202602" }
     ```
   - **New** → POST to create:
     ```
     POST /api/v2.0/companies({companyId})/salesInvoices({systemId})/dimensionSetLines
     { "code": "CONTRACT", "valueCode": "DK-000703-SIW" }
     ```

3. **For each line dimension**, same PATCH/POST pattern using the line `systemId`:
   - **Exists** → `PATCH .../salesInvoiceLines({lineSystemId})/dimensionSetLines({dimensionId})`
   - **New** → `POST .../salesInvoiceLines({lineSystemId})/dimensionSetLines`

### Key Notes

- The `dimensionId` in the response is the Dimension record's `SystemId` — use it as the key for PATCH operations
- PATCH requires the `If-Match: *` header (or a valid ETag)
- Default dimensions are auto-applied by BC from customer/item setup — check before POSTing to avoid "dimension set line already exists" errors
- The invoice `systemId` is returned directly by `createDraft`, eliminating the need for a separate Standard API lookup

---

## Implementation Details

- **Action-Based Dispatch:** Single endpoint routes requests via the `action` field
- **Line Creation:** When `lines` are provided in `createDraft`, lines are numbered starting at 10000 with 10000 increments. `lineType` is required.
- **Error Handling:** Line validation errors are caught and returned as structured JSON identifying the failing line number
- **Default Dimensions:** `createDraft` returns all default dimensions auto-applied by BC (both header and per-line), including `dimensionId` GUIDs
- **System IDs:** Invoice and line items include `systemId` (GUID) for cross-referencing with the BC Standard API v2.0
- **Date Format:** All dates use ISO 8601 (YYYY-MM-DD) format

## Related Endpoints

- **[Sales Invoice Draft Query API](Sales%20Invoice%20Draft%20Query%20API.md)** (50254): List/filter draft invoices via OData
- **[Sales Invoice Posted Query API](Sales%20Invoice%20Posted%20Query%20API.md)** (50255): List/filter posted invoices via OData
- **Dimension Management API (50151):** Create dimension codes and values
