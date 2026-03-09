# Posted Invoices Query API

Query posted (finalized) sales invoices from Business Central via a read-only OData V4 API.

## Endpoint Configuration

**Web Service ID:** Query 50255 "Posted Invoices"  
**Service Name:** `postedInvoices`  
**HTTP Method:** GET  
**Protocol:** OData V4  
**Access Level:** Read-Only  
**Authentication:** Business Central credentials required

## Request Format

**Base URL:**
```
[BC Environment]/ODataV4/Company('{company-id}')/postedInvoices
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer [auth-token]
```

## Exposed Fields

| AL Field Name | API Field Name | Data Type | Description |
|---------------|----------------|-----------|-------------|
| No. | invoiceNumber | Code[20] | Posted invoice document number |
| Bill-to Name | customerName | Text[100] | Customer name on the invoice |
| Bill-to Customer No. | customerId | Code[20] | Customer number |
| Amount Including VAT | amount | Decimal | Total amount including VAT |
| Amount | amountExcludingVat | Decimal | Total amount excluding VAT |
| Due Date | dueDate | Date | Payment due date |
| Document Date | documentDate | Date | Invoice document date |
| Your Reference | description | Text[35] | Your Reference / description field |
| Currency Code | currencyCode | Code[10] | Currency code |
| Payment Terms Code | paymentTermsCode | Code[10] | Payment terms code |

## Query Operations

### 1. Get All Posted Invoices

**Request:**
```
GET /ODataV4/Company('{company-id}')/postedInvoices
```

**Response:**
```json
{
  "value": [
    {
      "invoiceNumber": "PSI-1001",
      "customerName": "Example Company Ltd.",
      "customerId": "C00100",
      "amount": 12500.00,
      "amountExcludingVat": 10000.00,
      "dueDate": "2026-03-15",
      "documentDate": "2026-02-15",
      "description": "February services",
      "currencyCode": "DKK",
      "paymentTermsCode": "NET30"
    },
    {
      "invoiceNumber": "PSI-1002",
      "customerName": "Nordic Solutions A/S",
      "customerId": "C00200",
      "amount": 25000.00,
      "amountExcludingVat": 20000.00,
      "dueDate": "2026-03-30",
      "documentDate": "2026-02-28",
      "description": "Consulting services",
      "currencyCode": "DKK",
      "paymentTermsCode": "NET30"
    }
  ]
}
```

### 2. Get Posted Invoice by Number

**Request:**
```
GET /ODataV4/Company('{company-id}')/postedInvoices?$filter=invoiceNumber eq 'PSI-1001'
```

**Response:**
```json
{
  "value": [
    {
      "invoiceNumber": "PSI-1001",
      "customerName": "Example Company Ltd.",
      "customerId": "C00100",
      "amount": 12500.00,
      "amountExcludingVat": 10000.00,
      "dueDate": "2026-03-15",
      "documentDate": "2026-02-15",
      "description": "February services",
      "currencyCode": "DKK",
      "paymentTermsCode": "NET30"
    }
  ]
}
```

### 3. Filter by Customer

**Request:**
```
GET /ODataV4/Company('{company-id}')/postedInvoices?$filter=customerId eq 'C00100'
```

### 4. Filter by Customer Name (Substring)

**Request:**
```
GET /ODataV4/Company('{company-id}')/postedInvoices?$filter=contains(customerName, 'Nordic')
```

### 5. Filter by Due Date Range

**Request:**
```
GET /ODataV4/Company('{company-id}')/postedInvoices?$filter=dueDate ge 2026-03-01 and dueDate le 2026-03-31
```

### 6. Filter by Amount Range

**Request:**
```
GET /ODataV4/Company('{company-id}')/postedInvoices?$filter=amount ge 10000 and amount le 50000
```

### 7. Sort by Document Date (Most Recent First)

**Request:**
```
GET /ODataV4/Company('{company-id}')/postedInvoices?$orderby=documentDate desc
```

### 8. Paginated Results

**Request:**
```
GET /ODataV4/Company('{company-id}')/postedInvoices?$top=25&$skip=0
```

## OData Standard Operators

| Operator | Syntax | Example | Description |
|----------|--------|---------|-------------|
| Equality | `eq` | `customerId eq 'C00100'` | Exact match |
| Inequality | `ne` | `currencyCode ne 'DKK'` | Not equal |
| Greater/Equal | `ge` | `dueDate ge 2026-03-01` | Greater than or equal |
| Less/Equal | `le` | `amount le 50000` | Less than or equal |
| Substring | `contains` | `contains(customerName, 'Nordic')` | Contains substring |
| Starts With | `startswith` | `startswith(invoiceNumber, 'PSI-')` | Field starts with value |
| Logical AND | `and` | `customerId eq 'C00100' and amount ge 10000` | Both conditions must be true |
| Logical OR | `or` | `customerId eq 'C00100' or customerId eq 'C00200'` | Either condition can be true |
| Sorting | `$orderby` | `$orderby=documentDate desc` | Sort results |
| Pagination | `$top` | `$top=25` | Limit result count |
| — | `$skip` | `$skip=50` | Skip first N records |

## Implementation Details

- **Read-Only Access:** Query is configured with `DataAccessIntent = ReadOnly` for security
- **Source Table:** Sales Invoice Header (posted/finalized sales invoices)
- **No Status Field:** Posted invoices do not include a status column (they are always finalized)
- **All Fields Filterable:** All exposed columns support filtering via OData operators
- **Performance:** Query designed for efficient retrieval on BC cloud environments
- **Standard OData V4:** Implementation follows OData V4 specification for broad compatibility

## Related Endpoints

- **Draft Invoices Query (50254):** Query unposted (draft) sales invoices
- **Sales Invoice API (50152):** Get detailed invoice data with line items and dimensions
