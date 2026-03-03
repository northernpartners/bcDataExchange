# DataExchange

A unified Business Central AL extension exposing data via web service APIs for external system integration.

**Publisher:** Northern Partners ApS  
**Platform:** Business Central 23.0+ | Runtime: AL 11.0  
**Target:** Cloud  
**ID Range:** 50150-50299  
**Latest Version:** 1.0.0.0

---

## Overview

The DataExchange extension combines multiple data integration capabilities into a single, cohesive package:

- **Dimension Management API** - Create dimensions and dimension values via CodeUnit POST endpoint
- **Customer Data API** - Query and filter customer records via OData GET endpoint

Both endpoints expose Business Central data in JSON format, enabling seamless integration with external systems.

---

## Web Service Endpoints

| Object Type | Object ID | Object Name | Service Name | HTTP Method | Protocol | Description |
|-------------|-----------|-------------|--------------|------------|----------|-------------|
| Codeunit | 50151 | Dimension Handler | createDimensions | POST | REST/JSON | Create dimensions and dimension values |
| Query | 50250 | Customers | queryCustomers | GET | OData V4 | Query and filter customer data |

---

## Feature 1: Dimension Management API (CodeUnit)

### Overview

Create Business Central dimensions and dimension values programmatically via a RESTful JSON API. The API handles dimension creation, dimension value creation, and automatically skips existing values to prevent errors.

### Endpoint Configuration

**Web Service ID:** Codeunit 50151 "Dimension Handler"  
**Service Name:** `createDimensions`  
**HTTP Method:** POST  
**Protocol:** REST/JSON  
**Authentication:** Business Central credentials required

### Request Format

**Base URL:**
```
[BC Environment]/api/businesses([Company ID])/codeunits/createDimensions
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer [auth-token]
```

**Request Body:**
```json
{
  "name": "DIMENSION_CODE",
  "values": [
    {
      "code": "VALUE_CODE_1",
      "name": "Value Name 1"
    },
    {
      "code": "VALUE_CODE_2",
      "name": "Value Name 2"
    }
  ]
}
```

### Request Parameters

| Field | Type | Required | Max Length | Description |
|-------|------|----------|-----------|-------------|
| `name` | Text | Yes | 100 | Dimension code/name (e.g., 'ACTPERIOD', 'CONTRACT', 'PROJECT') |
| `values` | Array | Yes | — | Array of dimension value objects to create |
| `values[].code` | Code | Yes | 20 | Dimension value code (unique within dimension) |
| `values[].name` | Text | No | 50 | Dimension value name; if omitted, code will be used as name |

### Response Format - Success

**HTTP Status:** 200 OK

```json
{
  "success": true,
  "dimension": "ACTPERIOD",
  "processed": 3,
  "results": [
    {
      "code": "202501",
      "status": "created"
    },
    {
      "code": "202502",
      "status": "skipped"
    },
    {
      "code": "202503",
      "status": "created"
    }
  ]
}
```

### Response Format - Error

**HTTP Status:** 400 Bad Request or 200 OK (with success: false)

```json
{
  "success": false,
  "error": "Missing or invalid \"name\" field."
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `success` | Boolean | `true` if operation completed without errors; `false` if validation or processing failed |
| `dimension` | Text | The dimension code that was processed (only in success responses) |
| `processed` | Integer | Total count of dimension values processed (only in success responses) |
| `results` | Array | Array of result objects showing each value's processing outcome (only in success responses) |
| `results[].code` | Code | The dimension value code |
| `results[].status` | Text | Either `"created"` (newly added) or `"skipped"` (already existed) |
| `error` | Text | Error message explaining what went wrong (only in error responses) |

### Error Responses

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `Missing or invalid "name" field.` | The `name` parameter is missing or empty | Provide a valid dimension code in the `name` field |
| `Missing or invalid "values" array.` | The `values` parameter is missing or not an array | Provide a valid array of dimension value objects |
| Invalid JSON in requestBody. | The request body could not be parsed as JSON | Check JSON syntax and formatting |

### Usage Examples

#### Example 1: Create Accounting Period Dimensions

**Request:**
```bash
curl -X POST \
  https://[environment].dynamics.com/api/businesses([id])/codeunits/createDimensions \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer [token]' \
  -d '{
    "name": "ACTPERIOD",
    "values": [
      {"code": "202501", "name": "2025-01"},
      {"code": "202502", "name": "2025-02"},
      {"code": "202503", "name": "2025-03"}
    ]
  }'
```

**Response:**
```json
{
  "success": true,
  "dimension": "ACTPERIOD",
  "processed": 3,
  "results": [
    {"code": "202501", "status": "created"},
    {"code": "202502", "status": "created"},
    {"code": "202503", "status": "created"}
  ]
}
```

#### Example 2: Create Contract Type Dimension with Some Existing Values

**Request:**
```bash
curl -X POST \
  https://[environment].dynamics.com/api/businesses([id])/codeunits/createDimensions \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer [token]' \
  -d '{
    "name": "CONTRACT",
    "values": [
      {"code": "FIXED", "name": "Fixed Price"},
      {"code": "HOURLY", "name": "Hourly Rate"},
      {"code": "RETAINER", "name": "Retainer"}
    ]
  }'
```

**Response (if FIXED already exists):**
```json
{
  "success": true,
  "dimension": "CONTRACT",
  "processed": 3,
  "results": [
    {"code": "FIXED", "status": "skipped"},
    {"code": "HOURLY", "status": "created"},
    {"code": "RETAINER", "status": "created"}
  ]
}
```

#### Example 3: Create Dimension with Minimal Data (Using Code as Name)

**Request:**
```bash
curl -X POST \
  https://[environment].dynamics.com/api/businesses([id])/codeunits/createDimensions \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer [token]' \
  -d '{
    "name": "REGION",
    "values": [
      {"code": "NORTH"},
      {"code": "SOUTH"},
      {"code": "EAST"},
      {"code": "WEST"}
    ]
  }'
```

**Response:**
```json
{
  "success": true,
  "dimension": "REGION",
  "processed": 4,
  "results": [
    {"code": "NORTH", "status": "created"},
    {"code": "SOUTH", "status": "created"},
    {"code": "EAST", "status": "created"},
    {"code": "WEST", "status": "created"}
  ]
}
```

### Implementation Details

- **Idempotent:** The API is safe to call multiple times; existing dimensions and values are skipped without error
- **Atomic per Dimension Value:** Each dimension value is processed independently; failures in one value don't prevent others from being created
- **Automatic Dimension Creation:** The parent dimension is automatically created if it doesn't exist
- **JSON Parsing:** Input validation ensures proper JSON structure; malformed requests return detailed error messages
- **Follows AL Patterns:** Implementation adheres to AL language best practices for JSON handling (see briefing documents)

---

## Feature 2: Customer Data API (OData Query)

### Overview

Query and filter Business Central customer records via a read-only OData V4 API. The endpoint exposes key customer fields and supports standard OData filtering, sorting, and pagination.

### Endpoint Configuration

**Web Service ID:** Query 50250 "Customers"  
**Service Name:** `queryCustomers`  
**HTTP Method:** GET  
**Protocol:** OData V4  
**Access Level:** Read-Only  
**Authentication:** Business Central credentials required

### Request Format

**Base URL:**
```
[BC Environment]/ODataV4/Company('{company-id}')/customers
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer [auth-token]
```

### Exposed Fields

| AL Field Name | API Field Name | Data Type | Length | Description |
|---------------|----------------|-----------|--------|-------------|
| No. | customerNo | Code | 20 | Customer identifier / account number |
| Name | customerName | Text | 100 | Customer display name |
| VAT Registration No. | vatRegistrationNumber | Text | 20 | Customer VAT registration number |
| Registration Number | registrationNumber | Text | 20 | Company registration number |

### Query Operations

#### 1. List All Customers

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
      "vatRegistrationNumber": "DK12345678",
      "registrationNumber": "REG123456"
    },
    {
      "customerNo": "CUST-002",
      "customerName": "XYZ International",
      "vatRegistrationNumber": "DK87654321",
      "registrationNumber": "REG654321"
    }
  ]
}
```

#### 2. Filter by Customer No. (Exact Match)

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
      "vatRegistrationNumber": "DK12345678",
      "registrationNumber": "REG123456"
    }
  ]
}
```

#### 3. Filter by Customer Name (Substring Match)

**Request:**
```
GET /ODataV4/Company('{company-id}')/customers?$filter=substringof('ABC', customerName)
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

#### 4. Filter by VAT Registration Number

**Request:**
```
GET /ODataV4/Company('{company-id}')/customers?$filter=vatRegistrationNumber eq 'DK12345678'
```

#### 5. Filter by Registration Number

**Request:**
```
GET /ODataV4/Company('{company-id}')/customers?$filter=registrationNumber eq 'REG123456'
```

#### 6. Pagination with $top and $skip

**Request (Get 50 records, skip first 100):**
```
GET /ODataV4/Company('{company-id}')/customers?$top=50&$skip=100
```

#### 7. Sorting and Ordering

**Request (Sort by customer name, ascending):**
```
GET /ODataV4/Company('{company-id}')/customers?$orderby=customerName asc
```

**Request (Sort by customer name, descending):**
```
GET /ODataV4/Company('{company-id}')/customers?$orderby=customerName desc
```

#### 8. Combined Filter, Sort, and Pagination

**Request:**
```
GET /ODataV4/Company('{company-id}')/customers?$filter=substringof('Corp', customerName)&$orderby=customerName asc&$top=25&$skip=0
```

### OData Standard Operators

| Operator | Syntax | Example | Description |
|----------|--------|---------|-------------|
| Equality | `eq` | `customerNo eq 'CUST-001'` | Exact match |
| Inequality | `ne` | `customerNo ne 'CUST-001'` | Not equal |
| Substring | `substringof` | `substringof('ABC', customerName)` | Contains substring |
| Starts With | `startswith` | `startswith(customerName, 'ABC')` | Field starts with value |
| Ends With | `endswith` | `endswith(customerName, 'Corp')` | Field ends with value |
| Sorting | `$orderby` | `$orderby=customerName asc` | Sort results (asc/desc) |
| Pagination | `$top` | `$top=50` | Limit result count |
| — | `$skip` | `$skip=100` | Skip first N records |

### Implementation Details

- **Read-Only Access:** Query is configured with `DataAccessIntent = ReadOnly` for security
- **Automatic OData Exposure:** Query objects are automatically exposed as OData endpoints; no additional configuration required
- **Filter Fields:** All exposed columns have associated filters for flexible searching
- **Performance:** Query designed for efficient filtering on BC cloud environments
- **Standard OData V4:** Implementation follows OData V4 specification for broad compatibility

---

## Web Services Configuration

### In Business Central

To expose these endpoints as web services:

1. **Open Web Services Administration**
   - Go to **Search** → Type "Web Services"
   - Or: **Settings** → **Setup** → **Web Services**

2. **For Dimension Creation (CodeUnit 50151):**
   - Click **+ New**
   - Object Type: `CodeUnit`
   - Object ID: `50151`
   - Object Name: `Dimension Handler`
   - Service Name: `createDimensions`
   - Publish: `Yes`
   - Click **Save**

3. **For Customer Query (Query 50250):**
   - Click **+ New**
   - Object Type: `Query`
   - Object ID: `50250`
   - Object Name: `Customers`
   - Service Name: `queryCustomers`
   - Publish: `Yes`
   - Click **Save**

4. **Access the Services:**
   - Copy the OData URL from the Web Services list (format: `[BC URL]/ODataV4/Company('[company-id]')/...`)
   - Use this URL with your API client or integration tool

### API Authentication

All endpoints require Business Central user credentials:

- **Method:** Basic Authentication or OAuth
- **User:** BC user account with appropriate permissions
- **Permissions Required:**
  - Create Dimensions: `Modify` table 120 "Dimension"
  - Query Customers: `Read` table 18 "Customer"

---

## Architecture Overview

The extension uses a hybrid approach:

### REST CodeUnit API (Dimension Creation)
```
External Client
    ↓
POST /api/codeunits/createDimensions
    ↓
Codeunit 50151 "Dimension Handler"
    ↓
Dimension Helpers (Codeunit 50150)
    ↓
Dimension & Dimension Value Tables
    ↓
JSON Response
```

### OData Query API (Customer Data)
```
External Client
    ↓
GET /ODataV4/customers?$filter=...
    ↓
Query 50250 "Customers"
    ↓
Customer Table (Read-Only)
    ↓
Filtered Result Set
    ↓
OData JSON Response
```

---

## Development & Deployment

### Building the Extension

1. **Download Symbols**
   - VS Code command palette: `AL: Download Symbols`
   - Or: `Ctrl+Shift+P` → Search "Download Symbols"

2. **Build the Package**
   - VS Code command palette: `AL: Package`
   - Or: `Ctrl+Shift+P` → Search "Package"

3. **Locate Package Output**
   - Default location: `[project-root]` directory
   - Package file: `Northern Partners ApS_DataExchange_1.0.0.0.app`

### Deploying to Business Central

**Cloud Environment:**
1. Go to **Dynamics 365 Business Central Admin Center**
2. Select your environment
3. Go to **Applications** → **Manage Extensions**
4. Click **Upload Extension**
5. Select the `.app` file
6. Follow prompts to complete installation

**On-Premises:**
1. Follow your organization's AL development deployment process
2. Publish the extension to your environment
3. Enable web services as described above

### Updating the Extension

1. Update version in `app.json`
2. Make code changes as needed
3. Rebuild the package
4. Upload new version to Business Central (auto-upgrades from previous version)

---

## Code Structure

```
DataExchange/
├── app.json                           # Extension metadata & configuration
├── README.md                          # This file
├── codeunits/
│   ├── DimensionHandler.al            # REST API handler (CodeUnit 50151)
│   └── DimensionHelpers.al            # Dimension helper functions (CodeUnit 50150)
├── queries/
│   └── CustomersQuery.al              # Customer data query (Query 50250)
└── .vscode/
    ├── settings.json                  # VS Code project settings
    └── launch.json                    # Debugging configuration
```

---

## AL Code Patterns Used

This extension follows AL best practices documented in the project briefing:

- **JSON Handling:** Proper use of `JsonObject` and `JsonArray` without unnecessary `.Create()` calls
- **Error Handling:** Validation at entry points with clear error messages
- **Query Design:** Read-only data access intenthintfor security
- **Codeunit Patterns:** Service-enabled procedures for external access
- **Type Safety:** Proper use of AL types (Code, Text, Boolean) with appropriate field lengths

See `../briefing/AL-PATTERNS.md` and `../briefing/AL-CONCEPTS.md` for detailed pattern documentation.

---

## Support & Troubleshooting

### Common Issues

**Q: "Object not found" error when calling endpoint**
- Ensure web service is published in Business Central
- Verify correct Object ID and Service Name in Web Services list
- Check that extension is installed and compiled without errors

**Q: "Invalid JSON" error for Dimension API**
- Validate JSON syntax (use JSON linter tool)
- Ensure all required fields (`name`, `values`) are present
- Check field value types and lengths

**Q: Customers query returns no results**
- Verify customers exist in Business Central
- Check filter syntax for OData compatibility
- Ensure user permissions include read access to Customer table

**Q: "Unauthorized" or authentication errors**
- Verify BC user credentials are correct
- Check user has appropriate table permissions
- Ensure web service is published in current environment

### Debugging

- Enable debugging in `app.json` (resourceExposurePolicy.allowDebugging = true)
- Use VS Code AL Language Debugger to step through code
- Check BC Event Log for error details: **Search** → Type "Event Log"

---

## Related Files

- [ARCHITECTURE.md](../briefing/ARCHITECTURE.md) - Extension architecture reference
- [AL-PATTERNS.md](../briefing/AL-PATTERNS.md) - AL coding patterns guide
- [AL-CONCEPTS.md](../briefing/AL-CONCEPTS.md) - AL language concepts

---

**Last Updated:** March 3, 2026  
**Version:** 1.0.0.0  
**Publisher:** Northern Partners ApS
