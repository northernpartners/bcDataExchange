# Architecture Overview

System design and data flow for the DataExchange extension.

## System Design

The DataExchange extension uses a hybrid architecture combining REST and OData endpoints:

### REST CodeUnit API (Dimension Creation)

```
External Client
    ↓
POST /api/codeunits/createDimensions
    ↓
Codeunit 50151 "Dimension Handler"
    ↓
Codeunit 50150 "Dimension Helpers"
    ↓
Business Central Tables
  - Dimension (120)
  - Dimension Value (349)
    ↓
JSON Response (Success/Error)
```

**Characteristics:**
- Service-enabled CodeUnit with `Procedure_Type = ServiceProcedure`
- Used for **write operations** (create/modify)
- Custom JSON request/response handling
- Synchronous execution
- Error handling returns JSON format

### OData Query API (Customer Data)

```
External Client
    ↓
GET /ODataV4/buyers?$filter=...
    ↓
Query 50250 "Customers"
    ↓
Business Central Tables
  - Customer (18)
    ↓
OData V4 Response (Filtered Data)
```

**Characteristics:**
- Query object with `DataAccessIntent = ReadOnly`
- Used for **read operations** (query/filter)
- Automatic OData exposure (no custom handling required)
- Built-in filtering, sorting, pagination
- Secured at table level

## Component Breakdown

### Web Service Layer

| Component | Type | ID | Purpose | Protocol |
|-----------|------|-----|---------|----------|
| Dimension Handler | Codeunit | 50151 | Dimension creation API | REST/JSON |
| Dimension Helpers | Codeunit | 50150 | Dimension creation logic | Internal |
| Customers | Query | 50250 | Customer data query | OData V4 |

### Data Flow: Dimension Creation Request

1. **Request arrives** at REST endpoint with JSON payload
2. **Codeunit 50151** receives request and validates JSON structure
3. **Helper functions** (Codeunit 50150) execute business logic:
   - Verify dimension code and values
   - Check for existing dimension/values
   - Create dimension if needed
   - Create each dimension value atomically
4. **Response compiled** with creation results and status
5. **JSON response** returned to caller

### Data Flow: Customer Query Request

1. **Request arrives** at OData endpoint with optional filters
2. **Query 50250** processes filter criteria
3. **Customer table (18)** data accessed with applied filters
4. **Field mapping** applies to expose only configured fields:
   - No. → customerNo
   - Name → customerName
   - VAT Registration No. → vatRegistrationNumber
   - Registration Number → registrationNumber
5. **OData response** with matched records returned

## Security Model

### Authentication
- All endpoints require Business Central user credentials
- Supports Basic Authentication or OAuth 2.0
- Session-based access control

### Authorization
- **Dimension API:** Requires `Modify` permission on Table 120
- **Customer API:** Requires `Read` permission on Table 18
- Enforced at the table level by Business Central

### Data Protection
- HTTPS encryption for all cloud communications
- No sensitive data stored in configuration
- Session tokens have limited lifetime
- API calls logged in Business Central Event Log

## Performance Considerations

### Dimension API
- **Latency:** Typically 200-500ms per create operation
- **Throughput:** Single dimension with up to 100 values per request
- **Atomicity:** Independent processing per value (skip existing)
- **Scaling:** Handles typical create scenarios; large batch operations recommended to use normal UI

### Customer API
- **Latency:** Typically 100-300ms per query
- **Throughput:** Pagination support via `$top` and `$skip`
- **Filtering:** Efficient filtered retrieval on BC cloud
- **Scaling:** Optimized for customer record queries

## Error Handling

### API-Level Errors
- Validation errors return `400 Bad Request`
- Missing authentication returns `401 Unauthorized`
- Permission errors return `403 Forbidden`
- Server errors return `500 Internal Server Error`

### Application-Level Errors
- JSON parsing errors caught and reported
- Database constraint violations handled gracefully
- Dimension/value conflicts skip without failing
- Error responses include descriptive messages

## Deployment Model

- **Target Environment:** Business Central Cloud (or On-Premises)
- **Installation:** Extension deployed via App Package (.app file)
- **Lifecycle:** Standard Business Central extension model
- **Updates:** New version deployed via package upload; automatic upgrade from previous version
- **Versioning:** Semantic versioning (Major.Minor.Build.Revision)

## Integration Points

The extension integrates with:
- **Business Central:** All data access via standard tables
- **External Systems:** REST/OData API clients (any language/platform)
- **Authentication:** Business Central security framework
- **Events:** Standard BC event logging and diagnostics

No external dependencies or third-party services required.
