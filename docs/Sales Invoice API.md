# Sales Invoice API

Process sales invoice operations via a RESTful JSON API. Supports retrieving detailed invoice data (with line items and dimensions) and creating draft invoices.

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
| `createDraft` | Create a new draft sales invoice |

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
  "id": "SI-1001",
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
      "lineNumber": 10000,
      "lineType": "Item",
      "itemNumber": "ITEM-001",
      "description": "Consulting services - March",
      "quantity": 10,
      "unitOfMeasureCode": "HOUR",
      "unitPrice": 1000.00,
      "lineAmount": 10000.00,
      "lineDimensions": [
        { "code": "ACTPERIOD", "value": "2026-Q1" },
        { "code": "CONTRACT", "value": "PROJ-001" }
      ]
    }
  ],
  "dimensions": [
    { "code": "ACTPERIOD", "value": "2026-Q1" },
    { "code": "CONTRACT", "value": "PROJ-001" }
  ]
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | Code[20] | Invoice number |
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
| `lineNumber` | Integer | Line number |
| `lineType` | Text | Line type (Item, G/L Account, Resource, etc.) |
| `itemNumber` | Code[20] | Item/account number |
| `description` | Text | Line description |
| `quantity` | Decimal | Quantity |
| `unitOfMeasureCode` | Code[10] | Unit of measure |
| `unitPrice` | Decimal | Unit price |
| `lineAmount` | Decimal | Total line amount |
| `lineDimensions` | Array | Line-level dimensions (only if requested) |

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
  "id": "PSI-1001",
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
      "lineNumber": 10000,
      "lineType": "Item",
      "itemNumber": "ITEM-001",
      "description": "Consulting services - February",
      "quantity": 8,
      "unitOfMeasureCode": "HOUR",
      "unitPrice": 1250.00,
      "lineAmount": 10000.00,
      "lineDimensions": [
        { "code": "ACTPERIOD", "value": "2026-Q1" }
      ]
    }
  ],
  "dimensions": [
    { "code": "ACTPERIOD", "value": "2026-Q1" }
  ]
}
```

The response structure is identical to `getDraftDetails` except:
- `status` is always `Released`
- `pdfUrl` contains the PDF download URL path

---

## Action: createDraft

Creates a new draft sales invoice with the specified customer, dates, and currency.

### Request

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

### Request Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `action` | Text | Yes | Must be `createDraft` |
| `customerId` | Code[20] | Yes | Customer number (must exist in BC) |
| `documentDate` | Text | Yes | Document date in YYYY-MM-DD format |
| `dueDate` | Text | No | Due date in YYYY-MM-DD format. If omitted, calculated from payment terms. |
| `currencyCode` | Code[10] | Yes | Currency code |
| `paymentTermsCode` | Code[10] | No | Payment terms code |

### Response - Success

```json
{
  "invoiceNumber": "SI-1003",
  "customerId": "C00100",
  "dueDate": "2026-04-09",
  "documentDate": "2026-03-09",
  "currencyCode": "DKK",
  "paymentTermsCode": "NET30",
  "status": "Open",
  "amount": 0.00,
  "amountExcludingVat": 0.00,
  "vat": 0.00
}
```

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

## Implementation Details

- **Action-Based Dispatch:** Single endpoint routes requests via the `action` field
- **Dimension Filtering:** When requesting details, pass specific dimension codes in the `dimensions` array to include only those dimensions in the response
- **Line-Level Dimensions:** When dimensions are requested, each line item includes its own `lineDimensions` array
- **Date Format:** All dates use ISO 8601 (YYYY-MM-DD) format
- **PDF URL:** Posted invoices include a `pdfUrl` field; draft invoices return an empty string

## Related Endpoints

- **Draft Invoices Query (50254):** List/filter draft invoices via OData
- **Posted Invoices Query (50255):** List/filter posted invoices via OData
- **Dimension Management API (50151):** Create dimension codes and values
