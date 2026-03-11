# Sales Invoices Draft Query API

Query unposted (draft) sales invoices from Business Central via a read-only OData V4 API. Filter by document type and status to retrieve specific subsets of draft invoices.

## Endpoint Configuration

**Web Service ID:** Query 50254 "Draft Invoices"  
**Service Name:** `dxDraftInvoices`  
**HTTP Method:** GET  
**Protocol:** OData V4  
**Access Level:** Read-Only  
**Authentication:** Business Central credentials required

## Request Format

**Base URL:**
```
[BC Environment]/ODataV4/Company('{company-id}')/dxDraftInvoices
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer [auth-token]
```

## Exposed Fields

| AL Field Name | API Field Name | Data Type | Description |
|---------------|----------------|-----------|-------------|
| No. | invoiceNumber | Code[20] | Invoice document number |
| Bill-to Name | customerName | Text[100] | Customer name on the invoice |
| Bill-to Customer No. | customerId | Code[20] | Customer number |
| Amount Including VAT | amount | Decimal | Total amount including VAT |
| Amount | amountExcludingVat | Decimal | Total amount excluding VAT |
| Due Date | dueDate | Date | Payment due date |
| Document Date | documentDate | Date | Invoice document date |
| Status | status | Option | Invoice status (Open, Released, etc.) |
| Your Reference | description | Text[35] | Your Reference / description field |
| Currency Code | currencyCode | Code[10] | Currency code |
| Payment Terms Code | paymentTermsCode | Code[10] | Payment terms code |

## Filter Fields

These fields are available for filtering but are not returned in the response:

| Filter Name | AL Field | Description |
|-------------|----------|-------------|
| documentTypeFilter | Document Type | Filter by document type (Invoice, Order, etc.) |
| statusFilter | Status | Filter by invoice status |

## Query Operations

### 1. Get All Draft Invoices

**Request:**
```
GET /ODataV4/Company('{company-id}')/dxDraftInvoices
```

**Response:**
```json
{
  "value": [
    {
      "invoiceNumber": "SI-1001",
      "customerName": "Example Company Ltd.",
      "customerId": "C00100",
      "amount": 12500.00,
      "amountExcludingVat": 10000.00,
      "dueDate": "2026-04-15",
      "documentDate": "2026-03-09",
      "status": "Open",
      "description": "March services",
      "currencyCode": "DKK",
      "paymentTermsCode": "NET30"
    },
    {
      "invoiceNumber": "SI-1002",
      "customerName": "Nordic Solutions A/S",
      "customerId": "C00200",
      "amount": 7500.00,
      "amountExcludingVat": 6000.00,
      "dueDate": "2026-04-30",
      "documentDate": "2026-03-09",
      "status": "Open",
      "description": "Consulting Q1",
      "currencyCode": "DKK",
      "paymentTermsCode": "NET30"
    }
  ]
}
```

### 2. Get Draft Invoice by Number

**Request:**
```
GET /ODataV4/Company('{company-id}')/dxDraftInvoices?$filter=invoiceNumber eq 'SI-1001'
```

**Response:**
```json
{
  "value": [
    {
      "invoiceNumber": "SI-1001",
      "customerName": "Example Company Ltd.",
      "customerId": "C00100",
      "amount": 12500.00,
      "amountExcludingVat": 10000.00,
      "dueDate": "2026-04-15",
      "documentDate": "2026-03-09",
      "status": "Open",
      "description": "March services",
      "currencyCode": "DKK",
      "paymentTermsCode": "NET30"
    }
  ]
}
```

### 3. Filter by Customer

**Request:**
```
GET /ODataV4/Company('{company-id}')/dxDraftInvoices?$filter=customerId eq 'C00100'
```

### 4. Filter by Customer Name (Substring)

**Request:**
```
GET /ODataV4/Company('{company-id}')/dxDraftInvoices?$filter=contains(customerName, 'Nordic')
```

### 5. Filter by Due Date Range

**Request:**
```
GET /ODataV4/Company('{company-id}')/dxDraftInvoices?$filter=dueDate ge 2026-03-01 and dueDate le 2026-03-31
```

### 6. Sort by Amount (Descending)

**Request:**
```
GET /ODataV4/Company('{company-id}')/dxDraftInvoices?$orderby=amount desc
```

### 7. Paginated Results

**Request:**
```
GET /ODataV4/Company('{company-id}')/dxDraftInvoices?$top=25&$skip=0
```

## OData Standard Operators

| Operator | Syntax | Example | Description |
|----------|--------|---------|-------------|
| Equality | `eq` | `customerId eq 'C00100'` | Exact match |
| Inequality | `ne` | `status ne 'Released'` | Not equal |
| Greater/Equal | `ge` | `dueDate ge 2026-03-01` | Greater than or equal |
| Less/Equal | `le` | `amount le 10000` | Less than or equal |
| Substring | `contains` | `contains(customerName, 'Nordic')` | Contains substring |
| Starts With | `startswith` | `startswith(invoiceNumber, 'SI-')` | Field starts with value |
| Logical AND | `and` | `customerId eq 'C00100' and status eq 'Open'` | Both conditions must be true |
| Logical OR | `or` | `customerId eq 'C00100' or customerId eq 'C00200'` | Either condition can be true |
| Sorting | `$orderby` | `$orderby=dueDate asc` | Sort results |
| Pagination | `$top` | `$top=25` | Limit result count |
| — | `$skip` | `$skip=50` | Skip first N records |

## Implementation Details

- **Read-Only Access:** Query is configured with `DataAccessIntent = ReadOnly` for security
- **Source Table:** Sales Header (unposted sales documents)
- **Filter Support:** Document Type and Status available as filter parameters
- **All Fields Filterable:** All exposed columns support filtering via OData operators
- **Performance:** Query designed for efficient retrieval on BC cloud environments
- **Standard OData V4:** Implementation follows OData V4 specification for broad compatibility

## Related Endpoints

- **Posted Invoices Query (50255):** Query posted (finalized) sales invoices
- **Sales Invoice API (50152):** Get detailed invoice data with line items and dimensions
