# Sales Invoice API

Process sales invoice operations via a RESTful JSON API. Supports retrieving detailed invoice data (with line items and dimensions) and creating draft invoices with optional line items.

## Endpoint Configuration

**Web Service ID:** Codeunit 50152 "Sales Invoice Handler"  
**Service Name:** `processInvoice`  
**HTTP Method:** POST  
**Protocol:** REST/JSON  
**Authentication:** Business Central credentials required

## Request Format

**Base URL:**
```
[BC Environment]/api/businesses([Company ID])/codeunits/processInvoice
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
| `getDraftDetails` | Get full details of a draft invoice including line items |
| `getPostedDetails` | Get full details of a posted invoice including line items |
| `createDraft` | Create a new draft sales invoice with optional line items |

---

## Action: getDraftDetails

Retrieves complete details of a draft (unposted) invoice, including all line items with quantities/prices. Optionally includes specific dimension values for line-level and header-level dimensions.

### Request

```json
{
  "action": "getDraftDetails",
  "invoiceId": "SI-1001",
  "dimensions": ["ACTPERIOD", "CONTRACT"]
}
```

### Request Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `action` | Text | Yes | Must be `getDraftDetails` |
| `invoiceId` | Code[20] | Yes | Draft invoice number |
| `dimensions` | Array | No | Array of dimension codes to include in the response. If omitted, dimensions are not returned. |

### Response

```json
{
  "systemId": "d4e5f6a7-b8c9-0123-defg-hijklmnopqrs",
  "invoiceNumber": "SI-1001",
  "customerName": "Example Company Ltd.",
  "customerId": "C00100",
  "amount": 12500.00,
  "amountExcludingVat": 10000.00,
  "vat": 2500.00,
  "dueDate": "2026-04-15",
  "documentDate": "2026-03-09",
  "status": "Open",
  "description": "March services",
  "currencyCode": "DKK",
  "paymentTermsCode": "NET30",
  "pdfUrl": "",
  "lines": [
    {
      "systemId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "lineNumber": 10000,
      "lineType": "Item",
      "itemNumber": "ITEM-001",
      "description": "Consulting services - March",
      "quantity": 10,
      "unitOfMeasureCode": "HOUR",
      "unitPrice": 1000.00,
      "lineAmount": 10000.00,
      "lineDimensions": [
        { "code": "ACTPERIOD", "value": "2026-Q1", "dimensionId": "a1b2c3d4-0000-0000-0000-000000000001" },
        { "code": "CONTRACT", "value": "PROJ-001", "dimensionId": "a1b2c3d4-0000-0000-0000-000000000002" }
      ]
    }
  ],
  "dimensions": [
    { "code": "ACTPERIOD", "value": "2026-Q1", "dimensionId": "a1b2c3d4-0000-0000-0000-000000000001" },
    { "code": "CONTRACT", "value": "PROJ-001", "dimensionId": "a1b2c3d4-0000-0000-0000-000000000002" }
  ]
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `systemId` | GUID | Unique system identifier for the invoice (lowercase format) |
| `invoiceNumber` | Code[20] | Invoice number |
| `customerName` | Text | Bill-to customer name |
| `customerId` | Code[20] | Bill-to customer number |
| `amount` | Decimal | Total amount including VAT |
| `amountExcludingVat` | Decimal | Total amount excluding VAT |
| `vat` | Decimal | VAT amount (amount - amountExcludingVat) |
| `dueDate` | Text | Due date in ISO 8601 format (YYYY-MM-DD) |
| `documentDate` | Text | Document date in ISO 8601 format |
| `status` | Text | Invoice status (Open, Released) |
| `description` | Text | Your Reference field |
| `currencyCode` | Code[10] | Currency code |
| `paymentTermsCode` | Code[10] | Payment terms code |
| `pdfUrl` | Text | Empty for draft invoices |
| `lines` | Array | Invoice line items (see below) |
| `dimensions` | Array | Header dimensions (only if requested) |

### Line Item Fields

| Field | Type | Description |
|-------|------|-------------|
| `systemId` | GUID | Unique system identifier for the line (lowercase format) |
| `lineNumber` | Integer | Line number |
| `lineType` | Text | Line type (Item, G/L Account, Resource, etc.) |
| `itemNumber` | Code[20] | Item/account number |
| `description` | Text | Line description |
| `quantity` | Decimal | Quantity |
| `unitOfMeasureCode` | Code[10] | Unit of measure |
| `unitPrice` | Decimal | Unit price |
| `lineAmount` | Decimal | Total line amount |
| `lineDimensions` | Array | Line-level dimensions (only if requested) |

### Dimension Object Fields

| Field | Type | Description |
|-------|------|-------------|
| `code` | Code[20] | Dimension code (e.g. ACTPERIOD, CONTRACT) |
| `value` | Code[20] | Dimension value code |
| `dimensionId` | GUID | Dimension record SystemId — use for Standard API PATCH/POST operations |

---

## Action: getPostedDetails

Retrieves complete details of a posted (finalized) invoice, including all line items. Optionally includes specific dimension values. Includes a PDF download URL.

### Request

```json
{
  "action": "getPostedDetails",
  "invoiceId": "PSI-1001",
  "dimensions": ["ACTPERIOD"]
}
```

### Request Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `action` | Text | Yes | Must be `getPostedDetails` |
| `invoiceId` | Code[20] | Yes | Posted invoice number |
| `dimensions` | Array | No | Array of dimension codes to include |

### Response

```json
{
  "systemId": "e5f6a7b8-c9d0-1234-efgh-ijklmnopqrst",
  "invoiceNumber": "PSI-1001",
  "customerName": "Example Company Ltd.",
  "customerId": "C00100",
  "amount": 12500.00,
  "amountExcludingVat": 10000.00,
  "vat": 2500.00,
  "dueDate": "2026-03-15",
  "documentDate": "2026-02-15",
  "status": "Released",
  "description": "February services",
  "currencyCode": "DKK",
  "paymentTermsCode": "NET30",
  "pdfUrl": "SalesInvoices/SalesInvoiceDocument/PSI-1001",
  "lines": [
    {
      "systemId": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
      "lineNumber": 10000,
      "lineType": "Item",
      "itemNumber": "ITEM-001",
      "description": "Consulting services - February",
      "quantity": 8,
      "unitOfMeasureCode": "HOUR",
      "unitPrice": 1250.00,
      "lineAmount": 10000.00,
      "lineDimensions": [
        { "code": "ACTPERIOD", "value": "2026-Q1", "dimensionId": "a1b2c3d4-0000-0000-0000-000000000001" }
      ]
    }
  ],
  "dimensions": [
    { "code": "ACTPERIOD", "value": "2026-Q1", "dimensionId": "a1b2c3d4-0000-0000-0000-000000000001" }
  ]
}
```

The response structure is identical to `getDraftDetails` except:
- `status` is always `Released`
- `pdfUrl` contains the PDF download URL path

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
- **Dimension Filtering:** When requesting details via `getDraftDetails`/`getPostedDetails`, pass specific dimension codes in the `dimensions` array to filter; if omitted, no dimensions are returned
- **System IDs:** Invoice and line items include `systemId` (GUID) for cross-referencing with the BC Standard API v2.0
- **Date Format:** All dates use ISO 8601 (YYYY-MM-DD) format
- **PDF URL:** Posted invoices include a `pdfUrl` field; draft invoices return an empty string

## Related Endpoints

- **[Sales Invoice Draft Query API](Sales%20Invoice%20Draft%20Query%20API.md)** (50254): List/filter draft invoices via OData
- **[Sales Invoice Posted Query API](Sales%20Invoice%20Posted%20Query%20API.md)** (50255): List/filter posted invoices via OData
- **Dimension Management API (50151):** Create dimension codes and values
