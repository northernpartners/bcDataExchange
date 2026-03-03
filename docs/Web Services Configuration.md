# Web Services Configuration

Configure the DataExchange extension web services in Business Central to enable API access.

## Setup in Business Central

### 1. Open Web Services Administration

**Method 1: Via Search**
- Go to **Search** → Type "Web Services"
- Press Enter

**Method 2: Via Settings**
- Go to **Settings** → **Setup** → **Web Services**

### 2. Configure Dimension Creation (CodeUnit 50151)

1. Click **+ New** to add a new web service
2. Fill in the following fields:
   - **Object Type:** `CodeUnit`
   - **Object ID:** `50151`
   - **Object Name:** `Dimension Handler`
   - **Service Name:** `createDimensions`
3. Set **Publish** to `Yes`
4. Click **Save**

### 3. Configure Customer Query (Query 50250)

1. Click **+ New** to add a new web service
2. Fill in the following fields:
   - **Object Type:** `Query`
   - **Object ID:** `50250`
   - **Object Name:** `Customers`
   - **Service Name:** `queryCustomers`
3. Set **Publish** to `Yes`
4. Click **Save**

### 4. Access the Services

After publishing, you can access the web services using the URLs shown in the Web Services list:

- **Dimension API:** `[BC URL]/api/businesses([company-id])/codeunits/createDimensions`
- **Customer API:** `[BC URL]/ODataV4/Company('{company-id}')/customers`

Replace `[BC URL]`, `[company-id]`, and `{company-id}` with your actual Business Central environment details.

## API Authentication

All endpoints require Business Central user credentials:

- **Method:** Basic Authentication or OAuth 2.0
- **User:** BC user account with appropriate permissions
- **Access Control:** Managed through Business Central security and permission sets

### Required Permissions

| Feature | Object | Permission | Description |
|---------|--------|-----------|-------------|
| Dimension API | Table 120 "Dimension" | `Modify` | Required to create dimensions and values |
| Customer API | Table 18 "Customer" | `Read` | Required to query customer data |

### Setting Up User Permissions

1. **Open User Security**
   - Go to **Search** → Type "Users"
   - Select the user account

2. **Assign Permission Sets**
   - Click **Manage Permission Sets**
   - Add appropriate permission sets for your integration user
   - For API access, ensure the user has:
     - `Read` permission on Table 18 (Customer)
     - `Modify` permission on Table 120 (Dimension)

3. **Verify Permissions**
   - Test the API endpoints to confirm access
   - Check Business Central Event Log for access issues

## Network & Security Considerations

- **HTTPS:** All API connections use HTTPS encryption (automatic in Business Central cloud)
- **Rate Limiting:** Business Central enforces standard API rate limits
- **Session Management:** Authentication tokens have limited lifetime; requests may need re-authentication
- **IP Allowlisting:** Configure as needed in your Business Central setup

## Verification

### Test Dimension API

```bash
curl -X POST \
  'https://[environment].dynamics.com/api/businesses([id])/codeunits/createDimensions' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer [token]' \
  -d '{"name": "TEST", "values": [{"code": "V1"}]}'
```

### Test Customer API

```bash
curl -X GET \
  'https://[environment].dynamics.com/ODataV4/Company('\''[id]'\'')/customers' \
  -H 'Authorization: Bearer [token]'
```

Both requests should return success responses without errors.
