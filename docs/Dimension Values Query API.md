# Dimension Values Query API

Query dimension values across Business Central via a read-only OData V4 API. Filter by dimension code to retrieve values for a specific dimension group.

## Endpoint Configuration

**Web Service ID:** Query 50253 "Dimension Values"  
**Service Name:** `dimensionValues`  
**HTTP Method:** GET  
**Protocol:** OData V4  
**Access Level:** Read-Only  
**Authentication:** Business Central credentials required

## Request Format

**Base URL:**
```
[BC Environment]/ODataV4/Company('{company-id}')/dimensionValues
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer [auth-token]
```

## Exposed Fields

| AL Field Name | API Field Name | Data Type | Description |
|---------------|----------------|-----------|-------------|
| Dimension Code | dimensionCode | Code[20] | Dimension group identifier (filterable) |
| Code | valueCode | Code[20] | Dimension value code |
| Name | valueName | Text[100] | Dimension value display name |

## Query Operations

### 1. Get All Dimension Values for a Dimension Group

**Request:**
```
GET /ODataV4/Company('{company-id}')/dimensionValues?$filter=dimensionCode eq 'ACTPERIOD'
```

**Response:**
```json
{
  "value": [
    {
      "dimensionCode": "ACTPERIOD",
      "valueCode": "2025-Q1",
      "valueName": "2025 - Quarter 1"
    },
    {
      "dimensionCode": "ACTPERIOD",
      "valueCode": "2025-Q2",
      "valueName": "2025 - Quarter 2"
    },
    {
      "dimensionCode": "ACTPERIOD",
      "valueCode": "2025-Q3",
      "valueName": "2025 - Quarter 3"
    },
    {
      "dimensionCode": "ACTPERIOD",
      "valueCode": "2025-Q4",
      "valueName": "2025 - Quarter 4"
    }
  ]
}
```

### 2. Get Specific Dimension Value by Code and Dimension

**Request:**
```
GET /ODataV4/Company('{company-id}')/dimensionValues?$filter=dimensionCode eq 'CONTRACT' and valueCode eq 'PROJ-001'
```

**Response:**
```json
{
  "value": [
    {
      "dimensionCode": "CONTRACT",
      "valueCode": "PROJ-001",
      "valueName": "Project Alpha"
    }
  ]
}
```

### 3. Filter Dimension Values by Name (Substring)

**Request:**
```
GET /ODataV4/Company('{company-id}')/dimensionValues?$filter=dimensionCode eq 'CONTRACT' and contains(valueName, 'Project')
```

**Response:**
```json
{
  "value": [
    {
      "dimensionCode": "CONTRACT",
      "valueCode": "PROJ-001",
      "valueName": "Project Alpha"
    },
    {
      "dimensionCode": "CONTRACT",
      "valueCode": "PROJ-002",
      "valueName": "Project Beta"
    }
  ]
}
```

### 4. Get Dimension Values with Pagination

**Request (Get 50 values for a dimension, skip first 100):**
```
GET /ODataV4/Company('{company-id}')/dimensionValues?$filter=dimensionCode eq 'ACTPERIOD'&$top=50&$skip=100
```

### 5. Sort Dimension Values by Name

**Request (List values for a dimension sorted alphabetically by name):**
```
GET /ODataV4/Company('{company-id}')/dimensionValues?$filter=dimensionCode eq 'CONTRACT'&$orderby=valueName asc
```

### 6. Get All Values Across All Dimensions (Unfiltered)

**Request:**
```
GET /ODataV4/Company('{company-id}')/dimensionValues
```

**Response:**
```json
{
  "value": [
    {
      "dimensionCode": "ACTPERIOD",
      "valueCode": "2025-Q1",
      "valueName": "2025 - Quarter 1"
    },
    {
      "dimensionCode": "CONTRACT",
      "valueCode": "PROJ-001",
      "valueName": "Project Alpha"
    },
    {
      "dimensionCode": "CONTRACT",
      "valueCode": "PROJ-002",
      "valueName": "Project Beta"
    }
  ]
}
```

## OData Standard Operators

| Operator | Syntax | Example | Description |
|----------|--------|---------|-------------|
| Equality | `eq` | `dimensionCode eq 'CONTRACT'` | Exact match |
| Inequality | `ne` | `valueCode ne 'PROJ-001'` | Not equal |
| Substring | `contains` | `contains(valueName, 'Project')` | Contains substring |
| Starts With | `startswith` | `startswith(valueCode, 'PROJ')` | Field starts with value |
| Ends With | `endswith` | `endswith(valueCode, '-001')` | Field ends with value |
| Logical AND | `and` | `dimensionCode eq 'CONTRACT' and valueCode eq 'PROJ-001'` | Both conditions must be true |
| Logical OR | `or` | `valueCode eq 'PROJ-001' or valueCode eq 'PROJ-002'` | Either condition can be true |
| Sorting | `$orderby` | `$orderby=valueName asc` | Sort results |
| Pagination | `$top` | `$top=50` | Limit result count |
| — | `$skip` | `$skip=100` | Skip first N records |

## Implementation Details

- **Read-Only Access:** Query is configured with `DataAccessIntent = ReadOnly` for security
- **Automatic OData Exposure:** Query objects are automatically exposed as OData endpoints
- **Filterable by Dimension:** Use `dimensionCode` filter to retrieve values for specific dimension groups
- **All Fields Filterable:** All exposed columns support filtering via OData operators
- **Performance:** Query designed for efficient retrieval on BC cloud environments
- **Standard OData V4:** Implementation follows OData V4 specification for broad compatibility

## Related Queries

- **Dimensions Query (50252):** Query dimension groups/codes themselves
- **Dimension Values Query (50253):** Query dimension values (this query)
