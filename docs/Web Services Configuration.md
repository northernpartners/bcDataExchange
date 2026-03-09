# Web Services Configuration

Configure the DataExchange extension web services in Business Central to enable API access.

## Setup

1. Go to **Search** → Type **"Web Services"** → Press Enter
2. For each service below, click **+ New**, fill in the fields, set **Publish** to `Yes`, and save

| Object Type | Object ID | Object Name | Service Name |
|-------------|-----------|-------------|--------------|
| Codeunit | 50151 | Dimension Handler | createDimensions |
| Codeunit | 50152 | Sales Invoice Handler | processInvoice |
| Query | 50250 | Customers | queryCustomers |
| Query | 50251 | Customer Details | customerDetails |
| Query | 50252 | Dimensions | dimensions |
| Query | 50253 | Dimension Values | dimensionValues |
| Query | 50254 | Draft Invoices | draftInvoices |
| Query | 50255 | Posted Invoices | postedInvoices |

## Endpoint URLs

After publishing, access the services at:

| Type | URL Pattern |
|------|-------------|
| Codeunit (POST) | `https://{environment}.dynamics.com/api/businesses({company-id})/codeunits/{serviceName}` |
| Query (GET) | `https://{environment}.dynamics.com/ODataV4/Company('{company-name}')/{serviceName}` |

Replace `{environment}`, `{company-id}`, and `{company-name}` with your Business Central environment details.

## Authentication

All endpoints require Business Central credentials:

- **OAuth 2.0** (recommended) or **Basic Authentication**
- User must have appropriate BC permission sets for the underlying tables
- All connections use HTTPS (automatic in Business Central cloud)

## Verification

Test a Codeunit endpoint:
```bash
curl -X POST \
  'https://{environment}.dynamics.com/api/businesses({id})/codeunits/createDimensions' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer {token}' \
  -d '{"name": "TEST", "values": [{"code": "V1"}]}'
```

Test a Query endpoint:
```bash
curl -X GET \
  'https://{environment}.dynamics.com/ODataV4/Company('\''{company-name}'\'')/queryCustomers?$top=1' \
  -H 'Authorization: Bearer {token}'
```

Both should return JSON responses without errors.
