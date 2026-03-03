# Code Structure

Organization of the DataExchange extension source code.

## Directory Layout

```
DataExchange/
├── docs/                          # Documentation (this folder)
│   ├── index.md                   # Overview and introduction
│   ├── SUMMARY.md                 # Gitbook table of contents
│   ├── features/
│   │   ├── dimension-api.md       # Dimension API documentation
│   │   └── customer-api.md        # Customer API documentation
│   ├── setup/
│   │   ├── configuration.md       # Web services configuration
│   │   └── deployment.md          # Build and deployment guide
│   ├── architecture/
│   │   ├── overview.md            # Architecture and design
│   │   ├── code-structure.md      # This file
│   │   └── al-patterns.md         # AL coding patterns reference
│   └── troubleshooting.md         # Common issues and solutions
├── app.json                       # Extension metadata and configuration
├── README.md                      # Quick reference (legacy)
├── codeunits/
│   ├── DimensionHandler.al        # REST API handler (CodeUnit 50151)
│   └── DimensionHelpers.al        # Dimension helper functions (CodeUnit 50150)
├── queries/
│   └── CustomersQuery.al          # Customer data query (Query 50250)
└── .vscode/
    ├── settings.json              # VS Code project settings
    └── launch.json                # Debugging configuration
```

## AL Source Files

### Codeunits

#### DimensionHandler.al (CodeUnit 50151)
- **Purpose:** Main REST API endpoint for dimension creation
- **Type:** Service-enabled CodeUnit
- **Key Export Procedure:** Handles incoming JSON with dimension name and values array
- **Capabilities:**
  - JSON validation
  - Dimension creation
  - Response formatting (success/error)
- **References:** Calls Codeunit 50150 for business logic

#### DimensionHelpers.al (CodeUnit 50150)
- **Purpose:** Business logic support for dimension operations
- **Type:** Library CodeUnit (not exposed as service)
- **Key Internal Procedures:**
  - Dimension creation
  - Dimension value creation
  - Access level verification
  - Error handling
- **References:** Called by Codeunit 50151

### Queries

#### CustomersQuery.al (Query 50250)
- **Purpose:** OData endpoint for customer data retrieval
- **Type:** Query object with ReadOnly access
- **Exposed Columns:**
  - Customer No. (customerNo)
  - Name (customerName)
  - VAT Registration No. (vatRegistrationNumber)
  - Registration Number (registrationNumber)
- **Source Table:** Table 18 (Customer)
- **Features:**
  - Automatic OData exposure
  - Standard filtering and sorting
  - Pagination support

## Configuration Files

### app.json
Defines extension metadata:
- **ID:** Unique GUID for the extension
- **Name:** "DataExchange"
- **Publisher:** Northern Partners ApS
- **Version:** 1.0.0.0
- **Platform:** BC 23.0
- **Runtime:** AL 11.0
- **ID Range:** 50150-50299
- **Features:** NoImplicitWith
- **Resource Exposure Policy:** Debug and source download enabled

### .vscode/settings.json
VS Code project configuration:
- AL language settings
- Debugging settings
- Symbol download paths
- Format on save settings

### .vscode/launch.json
Debugging configuration:
- Server configuration
- Debug port settings
- Authentication settings

## Naming Conventions

| Item | Pattern | Example |
|------|---------|---------|
| CodeUnit | PascalCase | DimensionHandler |
| Query | PascalCase | CustomersQuery |
| Procedure | camelCase | createDimensions |
| Variable | camelCase | dimensionCode, dimensionValues |
| Parameter | camelCase | customerNo, filterText |
| Constant | UPPER_CASE | MAX_CODE_LENGTH |
| Table Reference | NumberAndName | 120 "Dimension" |

## Object ID Ranges

| Object Type | ID Range | Purpose |
|-------------|----------|---------|
| CodeUnit | 50150-50151 | Dimension handling |
| Query | 50250 | Customer data query |
| Reserved | 50151-50249 | Future expansion |

## Dependencies

### Business Central Tables
- **Table 18:** Customer (Read for Customer API)
- **Table 120:** Dimension (Create/Read/Modify for Dimension API)
- **Table 349:** Dimension Value (Create/Read for Dimension API)

### AL Language Features Used
- Service-enabled CodeUnits
- Query objects with OData exposure
- JsonObject and JsonArray for request/response handling
- Text field processing
- Code field handling

## Build Artifacts

### Generated Files (not source-controlled)
- `.alpackages/` - Downloaded AL symbols
- `*.app` - Compiled extension package
- `.snapshots/` - Code snapshot files

### Version Control
- Source files tracked in git
- Configuration in version control
- Documentation maintained in git
- Build outputs excluded via .gitignore

## Extension Activation

The extension activates when:
1. Installed in a Business Central environment
2. Web services configured (see [configuration guide](../setup/configuration.md))
3. External systems make API requests

No activation events or triggers required.
