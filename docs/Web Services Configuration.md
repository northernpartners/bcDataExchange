# Web Services Configuration

Configure the DataExchange extension web services in Business Central to enable API access.

Version scope: v1.0.1.10

## Setup

1. Go to **Search** → Type **"Web Services"** → Press Enter
2. For each **required** service below, click **+ New**, fill in the fields, set **Publish** to `Yes`, and save

| Object Type | Object ID | Object Name | Service Name |
|-------------|-----------|-------------|--------------|
| Codeunit | 50151 | Dimension Handler | dxCreateDimensions |
| Codeunit | 50152 | Sales Invoice Handler | dxSalesInvoice |
| Query | 50250 | Customers | dxCustomers |
| Query | 50251 | Customer Details | dxCustomerDetails |
| Query | 50252 | Dimensions | dxDimensions |
| Query | 50253 | Dimension Values | dxDimensionValues |

Optional (legacy compatibility only):

| Object Type | Object ID | Object Name | Service Name |
|-------------|-----------|-------------|--------------|
| Query | 50254 | Draft Invoices | dxDraftInvoices |
| Query | 50255 | Posted Invoices | dxPostedInvoices |

Not required as Web Services rows (API pages are served by API metadata):

| Object Type | Object ID | Object Name |
|-------------|-----------|-------------|
| Page (API) | 50260 | DX Draft Invoice API |
| Page (API) | 50261 | DX Draft Invoice Line API |
| Page (API) | 50262 | DX Posted Invoice API |
| Page (API) | 50263 | DX Posted Invoice Line API |

Important: `dxDraftInvoiceLines` (50261) and `dxPostedInvoiceLines` (50263) are consumed through `$expand` from header APIs. They should generally not be configured as separate Web Services rows.

## Endpoint URLs

After publishing, access the services at:

| Type | URL Pattern |
|------|-------------|
| Codeunit (POST) | `https://{environment}.dynamics.com/api/businesses({company-id})/codeunits/{serviceName}` |
| Query (GET) | `https://{environment}.dynamics.com/ODataV4/Company('{company-name}')/{serviceName}` |
| API Page (GET) | `https://api.businesscentral.dynamics.com/v2.0/{tenant}/{environment}/api/np/dx/v1.0/companies({company-id})/{entitySet}` |

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
  'https://{environment}.dynamics.com/api/businesses({id})/codeunits/dxCreateDimensions' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer {token}' \
  -d '{"name": "TEST", "values": [{"code": "V1"}]}'
```

Test a Query endpoint:
```bash
curl -X GET \
  'https://{environment}.dynamics.com/ODataV4/Company('\''{company-name}'\'')/dxCustomers?$top=1' \
  -H 'Authorization: Bearer {token}'
```

Both should return JSON responses without errors.
