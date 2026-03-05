# Dimensions Query API

Query and filter Business Central dimension groups (codes) via a read-only OData V4 API. Lists all available dimensions with support for filtering and sorting. To query the **values within a dimension**, see [Dimension Values Query API](Dimension%20Values%20Query%20API.md).

## Endpoint Configuration

**Web Service ID:** Query 50252 "Dimensions"  
**Service Name:** `dimensions`  
**HTTP Method:** GET  
**Protocol:** OData V4  
**Access Level:** Read-Only  
**Authentication:** Business Central credentials required

## Request Format

**Base URL:**
```
[BC Environment]/ODataV4/Company('{company-id}')/dimensions
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer [auth-token]
```

## Exposed Fields

| AL Field Name | API Field Name | Data Type | Description |
|---------------|----------------|-----------|-------------|
| Code | dimensionCode | Code[20] | Dimension identifier/code |
| Name | dimensionName | Text[100] | Dimension display name |


## Query Operations

### 1. List All Dimensions

**Request:**
```
GET /ODataV4/Company('{company-id}')/dimensions
```

**Response:**
```json
{
  "value": [
    {
      "dimensionCode": "COST_CENTER",
      "dimensionName": "Cost Centers"
    },
    {
      "dimensionCode": "DEPARTMENT",
      "dimensionName": "Departments"
    },
    {
      "dimensionCode": "PROJECT",
      "dimensionName": "Projects"
    }
  ]
}
```

### 2. Filter by Dimension Code

**Request:**
```
GET /ODataV4/Company('{company-id}')/dimensions?$filter=dimensionCode eq 'DEPARTMENT'
```

**Response:**
```json
{
  "value": [
    {
      "dimensionCode": "DEPARTMENT",
      "dimensionName": "Departments"
    }
  ]
}
```

### 3. Filter by Dimension Name (Substring Match)

**Request:**
```
GET /ODataV4/Company('{company-id}')/dimensions?$filter=contains(dimensionName, 'Cost')
```

**Response:**
```json
{
  "value": [
    {
      "dimensionCode": "COST_CENTER",
      "dimensionName": "Cost Centers"
    }
  ]
}
```

### 4. Pagination

**Request (Get 50 dimensions, skip first 100):**
```
GET /ODataV4/Company('{company-id}')/dimensions?$top=50&$skip=100
```

### 5. Sorting by Name

**Request (List dimensions sorted by name):**
```
GET /ODataV4/Company('{company-id}')/dimensions?$orderby=dimensionName asc
```

### 6. Combined Filter and Sort

**Request (Find dimensions containing 'Project', sorted by name):**
```
GET /ODataV4/Company('{company-id}')/dimensions?$filter=contains(dimensionName, 'Project')&$orderby=dimensionName asc&$top=25
```

## OData Standard Operators

| Operator | Syntax | Example | Description |
|----------|--------|---------|-------------|
| Equality | `eq` | `dimensionCode eq 'DEPARTMENT'` | Exact match |
| Inequality | `ne` | `dimensionCode ne 'DEPARTMENT'` | Not equal |
| Substring | `contains` | `contains(dimensionName, 'Cost')` | Contains substring |
| Starts With | `startswith` | `startswith(dimensionName, 'Cost')` | Field starts with value |
| Ends With | `endswith` | `endswith(dimensionName, 'Center')` | Field ends with value |
| Sorting | `$orderby` | `$orderby=dimensionName asc` | Sort results |
| Pagination | `$top` | `$top=50` | Limit result count |
| — | `$skip` | `$skip=100` | Skip first N records |

## Default Behavior

Results are returned without a specific default sort order. Use `$orderby` parameter to sort:

```
GET /ODataV4/Company('{company-id}')/dimensions?$orderby=dimensionCode asc
```

## Implementation Details

- **Read-Only Access:** Query is configured with `DataAccessIntent = ReadOnly` for security
- **Automatic OData Exposure:** Query objects are automatically exposed as OData endpoints
- **All Fields Filterable:** All exposed columns support filtering via OData operators
- **Performance:** Query designed for efficient dimension retrieval on BC cloud environments
- **Standard OData V4:** Implementation follows OData V4 specification for broad compatibility
