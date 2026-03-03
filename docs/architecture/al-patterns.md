# AL Coding Patterns

This document references AL coding patterns and best practices used in the DataExchange extension.

## JSON Handling

The extension uses AL's `JsonObject` and `JsonArray` types for REST API communication while following best practices:

### Creating JSON Objects
```al
JsonObj := JsonObject.Create();
JsonObj.Add('name', 'VALUE');
JsonObj.Add('code', 'CODE123');
```

### Creating JSON Arrays
```al
JsonArray := JsonArray.Create();
JsonArray.Add('item1');
JsonArray.Add('item2');
```

### Parsing JSON Responses
```al
JsonContent.ReadFrom(RequestContent);
JsonObj := JsonContent.AsObject();
```

## Error Handling

### Validation at Entry Points
- Validate all incoming parameters before processing
- Return error responses in expected format (JSON for REST APIs)
- Use descriptive error messages for debugging

### Try-Catch Patterns
- Catch exceptions for database operations
- Handle parsing errors gracefully
- Log errors in Business Central Event Log

## CodeUnit Patterns

### Service-Enabled CodeUnit
```al
codeunit 50151 "Dimension Handler"
{
    Permissions = table 120 = Rim;
    
    trigger OnRun()
    begin
    end;
    
    procedure CreateDimensions(Json : JsonObject) ReturnJson : JsonObject
    begin
        // Service-enabled procedure accessible via REST API
    end;
}
```

**Key Elements:**
- **Permissions:** Explicitly declare table access needed
- **Procedure:** Must be marked as `ServiceProcedure`
- **Parameters:** Use suitable types for API (Text/JsonObject for JSON)
- **Return:** JsonObject for responses

### Library CodeUnit (Internal)
```al
codeunit 50150 "Dimension Helpers"
{
    Access = Internal;
    
    procedure DoSomething()
    begin
        // Internal helper procedure
    end;
}
```

**Key Elements:**
- **Access:** Set to Internal to prevent external access
- **No OnRun:** Library codeunits don't execute
- **Reusable:** Called by service codeunits

## Query Patterns

### Read-Only Query
```al
query 50250 "Customers"
{
    QueryType = Normal;
    ObjectFilter = Customer where(Blocked = filter(false));
    
    elements
    {
        dataitem(Customer; Customer)
        {
            column(customerNo; "No.") { }
            column(customerName; Name) { }
        }
    }
}
```

**Key Elements:**
- **DataAccessIntent:** Set to ReadOnly for security
- **Column Mapping:** Rename fields for API exposure
- **ObjectFilter:** Restrict results where appropriate
- **Normal QueryType:** Automatically exposed as OData

## Type Safety

### Use Proper Field Types
- **Code fields:** For dimension codes, customer numbers (fixed-length 20 or less)
- **Text fields:** For names and descriptions (appropriate max length)
- **Integer:** For computed counts or indices
- **Boolean:** For yes/no flags

### Avoid Generic Text
Use specific types even when text could work:
```al
// Good
procedure Create(DimensionCode: Code[20])

// Avoid - less type-safe
procedure Create(DimensionCode: Text)
```

## Response Formatting

### Success Response
```al
ResponseJson.Add('success', true);
ResponseJson.Add('dimension', DimensionCode);
ResponseJson.Add('processed', ProcessCount);
ResponseJson.Add('results', ResultsArray);
```

### Error Response
```al
ErrorJson.Add('success', false);
ErrorJson.Add('error', 'Error message describing the issue');
```

**Pattern:** Consistent response structure with `success` field indicates operation outcome.

## Naming Conventions

- **ProcedureNames:** Use PascalCase starting with action verb (CreateDimensions, ValidateInput)
- **VariableNames:** Use camelCase (dimensionCode, isValid)
- **ParameterNames:** Use camelCase (inputJson, processingMode)
- **ConstantNames:** Use UPPER_CASE (MAX_LENGTH, DEFAULT_CODE)

## Reference Materials

For complete AL language documentation, see:
- **AL Language Reference:** Official Microsoft documentation
- **Business Central Development:** AL development best practices
- **JSON Handling:** AL JsonObject and JsonArray documentation

## Best Practices Implemented

✓ Validation before processing  
✓ Descriptive error messages  
✓ Consistent JSON response format  
✓ Read-only queries for data retrieval  
✓ Service-enabled codeunits for API access  
✓ Internal library codeunits for code reuse  
✓ Proper permission declarations  
✓ Type-safe field handling  
✓ Atomic operations per record  
✓ Clear field mapping in queries  
