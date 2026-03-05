# Customer Data API

Query and filter Business Central customer records via a read-only OData V4 API. The endpoint exposes key customer fields and supports standard OData filtering, sorting, and pagination.

## Endpoint Configuration

**Web Service ID:** Query 50250 "Customers"  
**Service Name:** `queryCustomers`  
**HTTP Method:** GET  
**Protocol:** OData V4  
**Access Level:** Read-Only  
**Authentication:** Business Central credentials required

## Request Format

**Base URL:**
```
[BC Environment]/ODataV4/Company('{company-id}')/customers
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer [auth-token]
```

## Exposed Fields

| AL Field Name | API Field Name | Data Type | Length | Description |
|---------------|----------------|-----------|--------|-------------|
| No. | customerNo | Code | 20 | Customer identifier / account number |
| Name | customerName | Text | 100 | Customer display name |
| Last Date Modified | lastDateModified | DateTime | — | Last modification timestamp |
| VAT Registration No. | vatRegistrationNumber | Text | 20 | Customer VAT registration number |
| Registration Number | registrationNumber | Text | 20 | Company registration number |

## Query Operations

### 1. List All Customers

**Request:**
```
GET /ODataV4/Company('{company-id}')/customers
```

**Response:**
```json
{
  "value": [
    {
      "customerNo": "CUST-001",
      "customerName": "ABC Corporation",
      "lastDateModified": "2026-03-05T10:30:00Z",
      "vatRegistrationNumber": "DK12345678",
      "registrationNumber": "REG123456"
    },
    {
      "customerNo": "CUST-002",
      "customerName": "XYZ International",
      "lastDateModified": "2026-02-28T14:15:00Z",
      "vatRegistrationNumber": "DK87654321",
      "registrationNumber": "REG654321"
    }
  ]
}
```

### 2. Filter by Customer No. (Exact Match)

**Request:**
```
GET /ODataV4/Company('{company-id}')/customers?$filter=customerNo eq 'CUST-001'
```

**Response:**
```json
{
  "value": [
    {
      "customerNo": "CUST-001",
      "customerName": "ABC Corporation",
      "lastDateModified": "2026-03-05T10:30:00Z",
      "vatRegistrationNumber": "DK12345678",
      "registrationNumber": "REG123456"
    }
  ]
}
```

### 3. Filter by Customer Name (Substring Match)

**Request:**
```
GET /ODataV4/Company('{company-id}')/customers?$filter=contains(customerName, 'ABC')
```

**Response:**
```json
{
  "value": [
    {
      "customerNo": "CUST-001",
      "customerName": "ABC Corporation",
      "vatRegistrationNumber": "DK12345678",
      "registrationNumber": "REG123456"
    }
  ]
}
```

### 4. Filter by VAT Registration Number

**Request:**
```
GET /ODataV4/Company('{company-id}')/customers?$filter=vatRegistrationNumber eq 'DK12345678'
```

### 5. Filter by Registration Number

**Request:**
```
GET /ODataV4/Company('{company-id}')/customers?$filter=registrationNumber eq 'REG123456'
```

### 6. Pagination with $top and $skip

**Request (Get 50 records, skip first 100):**
```
GET /ODataV4/Company('{company-id}')/customers?$top=50&$skip=100
```

### 7. Sorting and Ordering

**Request (Sort by customer name, ascending):**
```
GET /ODataV4/Company('{company-id}')/customers?$orderby=customerName asc
```

**Request (Sort by customer name, descending):**
```
GET /ODataV4/Company('{company-id}')/customers?$orderby=customerName desc
```

### 8. Combined Filter, Sort, and Pagination

**Request:**
```
GET /ODataV4/Company('{company-id}')/customers?$filter=contains(customerName, 'Corp')&$orderby=customerName asc&$top=25&$skip=0
```

## OData Standard Operators

| Operator | Syntax | Example | Description |
|----------|--------|---------|-------------|
| Equality | `eq` | `customerNo eq 'CUST-001'` | Exact match |
| Inequality | `ne` | `customerNo ne 'CUST-001'` | Not equal |
| Substring | `contains` | `contains(customerName, 'ABC')` | Contains substring |
| Starts With | `startswith` | `startswith(customerName, 'ABC')` | Field starts with value |
| Ends With | `endswith` | `endswith(customerName, 'Corp')` | Field ends with value |
| Sorting | `$orderby` | `$orderby=customerName asc` | Sort results (asc/desc) |
| Pagination | `$top` | `$top=50` | Limit result count |
| — | `$skip` | `$skip=100` | Skip first N records |

## Implementation Details

- **Read-Only Access:** Query is configured with `DataAccessIntent = ReadOnly` for security
- **Automatic OData Exposure:** Query objects are automatically exposed as OData endpoints; no additional configuration required
- **Filter Fields:** All exposed columns have associated filters for flexible searching
- **Performance:** Query designed for efficient filtering on BC cloud environments
- **Standard OData V4:** Implementation follows OData V4 specification for broad compatibility

---

# Customer Details API

Retrieve comprehensive customer data from Business Central including general information, address/contact details, invoicing, and payment terms via a read-only OData V4 API.

## Endpoint Configuration

**Web Service ID:** Query 50251 "Customer Details"  
**Service Name:** `customerDetails`  
**HTTP Method:** GET  
**Protocol:** OData V4  
**Access Level:** Read-Only  
**Authentication:** Business Central credentials required

## Request Format

**Base URL:**
```
[BC Environment]/ODataV4/Company('{company-id}')/customerDetails
```

## Exposed Fields

### General Information

| AL Field Name | API Field Name | Data Type | Description |
|---------------|----------------|-----------|-------------|
| No. | customerNo | Code[20] | Customer account number |
| Name | customerName | Text[100] | Customer display name |
| Last Date Modified | lastDateModified | DateTime | Last modification timestamp |
| Balance (LCY) | balance | Decimal | Outstanding balance in local currency |

### Address & Contact Information

| AL Field Name | API Field Name | Data Type | Description |
|---------------|----------------|-----------|-------------|
| Address | address | Text[100] | Primary street address |
| Address 2 | address2 | Text[50] | Secondary address line |
| Country/Region Code | countryCode | Code[10] | Country/region identifier |
| City | city | Text[30] | City name |
| Post Code | postCode | Code[20] | Postal code |
| Phone No. | phoneNo | Text[30] | Primary phone number |
| Mobile Phone No. | mobilePhoneNo | Text[30] | Mobile phone number |
| E-Mail | email | Text[80] | Email address |
| Language Code | languageCode | Code[10] | Preferred communication language |

### Invoicing Information

| AL Field Name | API Field Name | Data Type | Description |
|---------------|----------------|-----------|-------------|
| VAT Registration No. | vatRegistrationNo | Text[20] | VAT registration identifier |
| Registration Number | registrationNo | Text[20] | Company registration identifier |
| Currency Code | currencyCode | Code[10] | Default currency for invoicing |
| Prices Including VAT | pricesIncludingVAT | Boolean | Whether quoted prices include VAT |

### Payment Information

| AL Field Name | API Field Name | Data Type | Description |
|---------------|----------------|-----------|-------------|
| Payment Terms Code | paymentTermsCode | Code[10] | Default payment terms for customer |

## Query Operations

### 1. Get Single Customer with All Details

**Request:**
```
GET /ODataV4/Company('{company-id}')/customerDetails?$filter=customerNo eq 'CUST-9001'
```

**Response:**
```json
{
  "value": [
    {
      "customerNo": "CUST-9001",
      "customerName": "Example Company Ltd.",
      "lastDateModified": "2026-03-05T10:30:00Z",
      "balance": 15000.00,
      "address": "123 Main Street",
      "address2": "Suite 100",
      "countryCode": "US",
      "city": "New York",
      "postCode": "10001",
      "phoneNo": "+1 212 555 0100",
      "mobilePhoneNo": "+1 212 555 0101",
      "email": "contact@example.com",
      "languageCode": "ENG",
      "vatRegistrationNo": "US12345678",
      "registrationNo": "REG123456",
      "currencyCode": "USD",
      "pricesIncludingVAT": false,
      "paymentTermsCode": "NET30"
    }
  ]
}
```

### 2. Filter by Customer Name (Substring Match)

**Request:**
```
GET /ODataV4/Company('{company-id}')/customerDetails?$filter=contains(customerName, 'Kintech')
```

### 3. Filter by Country Code

**Request:**
```
GET /ODataV4/Company('{company-id}')/customerDetails?$filter=countryCode eq 'GB'
```

### 4. Filter by Payment Terms

**Request:**
```
GET /ODataV4/Company('{company-id}')/customerDetails?$filter=paymentTermsCode eq 'NET30'
```

### 5. Pagination and Sorting

**Request (Get 50 records, sorted by name):**
```
GET /ODataV4/Company('{company-id}')/customerDetails?$top=50&$skip=0&$orderby=customerName asc
```

### 6. Filter by Balance

**Request (Customers with outstanding balance):**
```
GET /ODataV4/Company('{company-id}')/customerDetails?$filter=balance gt 0
```

## Data Access

All fields are read-only and exposed directly from the Customer master table. Values reflect real-time customer data as stored in Business Central.

**Note:** Some calculated fields (e.g., overdue balance, fiscal year sales, profit) are not available via this query. These would require additional queries joining to transaction tables (Customer Ledger Entries, Sales Headers/Lines) for accurate calculation.
