# Troubleshooting

Common issues and their solutions for the DataExchange extension.

## API Access Issues

### "Object not found" error when calling endpoint

**Symptoms:**
- API requests return 404 Not Found
- Web service endpoint not accessible

**Causes:**
- Web service not published in Business Central
- Incorrect Object ID or Service Name
- Extension not installed or compiled with errors

**Solutions:**
1. Verify web service is published:
   - Go to **Search** → "Web Services"
   - Check that both services are listed:
     - Codeunit 50151 "Dimension Handler"
     - Query 50250 "Customers"

2. Verify correct endpoint URL format:
   - For Dimension API: `[BC URL]/api/codeunits/createDimensions`
   - For Customer API: `[BC URL]/ODataV4/Company('[id]')/customers`

3. Confirm extension installation:
   - Go to **Search** → "Extensions"
   - Verify "DataExchange" is listed and installed

4. Check compilation:
   - In VS Code, verify no errors in Al Problem panel
   - Rebuild and redeploy if necessary

---

### "Invalid JSON" error for Dimension API

**Symptoms:**
- Dimension API returns: `Invalid JSON in requestBody`
- Request parsing fails before processing

**Causes:**
- Malformed JSON syntax
- Missing required fields
- Incorrect data types in JSON

**Solutions:**
1. Validate JSON formatting:
   - Use a JSON validator tool
   - Ensure all quotes are properly escaped
   - Check for missing commas between fields

2. Example valid request:
   ```json
   {
     "name": "MYDIMENSION",
     "values": [
       {"code": "VAL1", "name": "Value 1"},
       {"code": "VAL2", "name": "Value 2"}
     ]
   }
   ```

3. Verify required fields:
   - `name` must be present and non-empty
   - `values` must be an array (even if empty)
   - Each value needs `code` field

---

### "Missing or invalid 'name' field" error

**Symptoms:**
- Dimension API returns: `Missing or invalid "name" field`
- Dimension code not passed or empty

**Solutions:**
1. Ensure `name` field is included in request
2. Verify the dimension code:
   - Must be 1-20 characters
   - Use alphanumeric and underscores
   - Example valid codes: `ACTPERIOD`, `CONTRACT_TYPE`, `REGION`

3. Example minimal request:
   ```json
   {
     "name": "MYCODE",
     "values": [{"code": "V1"}]
   }
   ```

---

### "Missing or invalid 'values' array" error

**Symptoms:**
- Dimension API returns: `Missing or invalid "values" array`
- Values array is missing or not properly formatted

**Solutions:**
1. Ensure `values` field is an array (enclosed in brackets `[]`)
2. Array must contain at least one dimension value object
3. Each object must have at minimum:
   - `code` field with the value code
   - Optionally `name` field for description

4. Valid examples:
   ```json
   {
     "name": "DIM",
     "values": [{"code": "V1"}]
   }
   ```
   
   ```json
   {
     "name": "DIM",
     "values": [
       {"code": "V1", "name": "Value 1"},
       {"code": "V2", "name": "Value 2"}
     ]
   }
   ```

---

## Authentication & Authorization

### "Unauthorized" (401) error

**Symptoms:**
- API requests fail with 401 status
- Cannot authenticate to Business Central

**Solutions:**
1. Verify credentials are correct
2. Confirm user account is active in Business Central
3. Check password hasn't expired
4. Ensure OAuth token is still valid (tokens expire)

---

### "Forbidden" (403) error

**Symptoms:**
- API requests fail with 403 status
- Authentication succeeds but access denied

**Causes:**
- User lacks required permissions
- Missing permission sets for API access

**Solutions:**
1. **For Dimension API:** User needs `Modify` permission on Table 120
2. **For Customer API:** User needs `Read` permission on Table 18

3. To grant permissions:
   - Go to **Search** → "Users"
   - Select the user account
   - Click **Manage Permission Sets**
   - Add appropriate permission sets
   - Save and verify access

---

## Customer Query Issues

### Customer API returns no results

**Symptoms:**
- Query endpoint returns empty value array
- Expected customer records not found

**Causes:**
- No customers exist in instance
- Filter criteria too restrictive
- Customer records are blocked

**Solutions:**
1. Verify customers exist:
   - Go to **Search** → "Customer List"
   - Check at least one customer record exists

2. Try listing all customers (no filter):
   ```
   GET /ODataV4/Company('{id}')/customers
   ```

3. If getting results, verify filter syntax:
   - Check OData V4 operator documentation
   - Ensure field names match API names (not AL field names)

4. Valid field names for filtering:
   - `customerNo`
   - `customerName`
   - `lastDateModified`
   - `vatRegistrationNumber`
   - `registrationNumber`

---

### Filter syntax error

**Symptoms:**
- Query returns error on filter expression
- OData filter parameter not recognized

**Valid OData Filter Examples:**
```
?$filter=customerNo eq 'CUST-001'

?$filter=contains(customerName, 'ABC')

?$filter=startswith(customerName, 'ABC')

?$filter=customerNo ne 'CUST-001'
```

---

## Performance Issues

### Dimension API slow response

**Symptoms:**
- Dimension creation takes >5 seconds
- Timeout on large requests

**Solutions:**
1. Reduce values per request:
   - API designed for ~10-50 values at once
   - For 100+ values, split into multiple requests

2. Check Business Central load:
   - Extension performance depends on environment capacity
   - Try during lower-usage times

---

### Customer query slow results

**Symptoms:**
- OData query returns slowly
- Pagination required for large result sets

**Solutions:**
1. Use pagination parameters:
   ```
   ?$top=50&$skip=0
   ```

2. Add filters to reduce result set:
   ```
   ?$filter=startswith(customerName, 'A')&$top=100
   ```

3. Avoid sorting large result sets if latency-sensitive

---

## Event Log Troubleshooting

### Check Business Central Event Log

To see detailed error information:

1. Go to **Search** → Type "Event Log"
2. Filter for recent entries
3. Look for entries from:
   - "Dimension Handler" (CodeUnit 50151)
   - "DataExchange" extension name

This log shows:
- Authentication failures
- Permission violations
- JSON parsing errors
- Database constraint violations

---

## Deployment Issues

### Extension fails to install

**Solutions:**
1. Check for compilation errors:
   - Open project in VS Code
   - Verify AL Problem panel for errors
   - Add symbols if missing: AL: Download Symbols

2. Verify version compatibility:
   - Confirm app.json platform version matches your BC version
   - Current target: BC 23.0+, Runtime AL 11.0

3. Check app file is valid:
   - File should be .app extension
   - Size should be reasonable (>100 KB)
   - File not corrupted

### Web services don't appear after installation

**Solutions:**
1. Wait 1-2 minutes for extension to complete initialization
2. Refresh the browser page
3. Restart Business Central (cloud: not required, On-Premises: may need restart)
4. Go to Web Services and manually add endpoints if needed

---

## Getting More Help

### Debug Information
- **Event Log:** Business Central Event Log for error messages
- **AL Debugger:** Use VS Code AL Debugger to step through code
- **Console Output:** Check VS Code Output panel for compilation messages

### Support Resources
- Check extension version in **Search** → "Extensions"
- Review this documentation thoroughly
- Contact extension publisher: Northern Partners ApS

---

**Last Updated:** March 3, 2026  
**Extension Version:** 1.0.0.2
