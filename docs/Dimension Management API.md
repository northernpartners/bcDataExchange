# Dimension Management API

Create Business Central dimensions and dimension values programmatically via a RESTful JSON API. The API handles dimension creation, dimension value creation, and automatically skips existing values to prevent errors.

## Endpoint Configuration

**Web Service ID:** Codeunit 50151 "Dimension Handler"  
**Service Name:** `dxCreateDimensions`  
**HTTP Method:** POST  
**Protocol:** REST/JSON  
**Authentication:** Business Central credentials required

## Request Format

**Base URL:**
```
[BC Environment]/api/businesses([Company ID])/codeunits/dxCreateDimensions
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

## Request Parameters

| Field | Type | Required | Max Length | Description |
|-------|------|----------|-----------|-------------|
| `name` | Text | Yes | 100 | Dimension code/name (e.g., 'ACTPERIOD', 'CONTRACT', 'PROJECT') |
| `values` | Array | Yes | — | Array of dimension value objects to create |
| `values[].code` | Code | Yes | 20 | Dimension value code (unique within dimension) |
| `values[].name` | Text | No | 50 | Dimension value name; if omitted, code will be used as name |

## Response Format - Success

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

## Response Format - Error

**HTTP Status:** 400 Bad Request or 200 OK (with success: false)

```json
{
  "success": false,
  "error": "Missing or invalid \"name\" field."
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `success` | Boolean | `true` if operation completed without errors; `false` if validation or processing failed |
| `dimension` | Text | The dimension code that was processed (only in success responses) |
| `processed` | Integer | Total count of dimension values processed (only in success responses) |
| `results` | Array | Array of result objects showing each value's processing outcome (only in success responses) |
| `results[].code` | Code | The dimension value code |
| `results[].status` | Text | Either `"created"` (newly added) or `"skipped"` (already existed) |
| `error` | Text | Error message explaining what went wrong (only in error responses) |

## Error Responses

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `Missing or invalid "name" field.` | The `name` parameter is missing or empty | Provide a valid dimension code in the `name` field |
| `Missing or invalid "values" array.` | The `values` parameter is missing or not an array | Provide a valid array of dimension value objects |
| Invalid JSON in requestBody. | The request body could not be parsed as JSON | Check JSON syntax and formatting |

## Usage Examples

### Example 1: Create Accounting Period Dimensions

**Request:**
```bash
curl -X POST \
  https://[environment].dynamics.com/api/businesses([id])/codeunits/dxCreateDimensions \
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

### Example 2: Create Contract Type Dimension with Some Existing Values

**Request:**
```bash
curl -X POST \
  https://[environment].dynamics.com/api/businesses([id])/codeunits/dxCreateDimensions \
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

### Example 3: Create Dimension with Minimal Data (Using Code as Name)

**Request:**
```bash
curl -X POST \
  https://[environment].dynamics.com/api/businesses([id])/codeunits/dxCreateDimensions \
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

## Implementation Details

- **Idempotent:** The API is safe to call multiple times; existing dimensions and values are skipped without error
- **Atomic per Dimension Value:** Each dimension value is processed independently; failures in one value don't prevent others from being created
- **Automatic Dimension Creation:** The parent dimension is automatically created if it doesn't exist
- **JSON Parsing:** Input validation ensures proper JSON structure; malformed requests return detailed error messages
- **Follows AL Patterns:** Implementation adheres to AL language best practices for JSON handling
