# Building & Deployment

Instructions for building the extension package and deploying to Business Central environments.

## Building the Extension

### 1. Download Symbols

Before building, ensure you have the latest AL symbols from Business Central.

**Via VS Code Command Palette:**
- Press `Ctrl+Shift+P`
- Search for `AL: Download Symbols`
- Select and execute

**Via Menu:**
- Open the AL command palette
- Choose "Download Symbols"

This creates the `.alpackages` folder with the latest symbol files.

### 2. Build the Package

**Via VS Code Command Palette:**
- Press `Ctrl+Shift+P`
- Search for `AL: Package`
- Select and execute

**Via Menu:**
- Open the AL command palette
- Choose "Package"

### 3. Locate the Package Output

The compiled extension will be saved in the project root directory with the naming convention:

```
Northern Partners ApS_DataExchange_1.0.0.6.app
```

The `.app` file is your deployment package.

## Deploying to Business Central Cloud

### 1. Access the Admin Center

1. Navigate to [Dynamics 365 Business Central Admin Center](https://admin.businesscentral.dynamics.com)
2. Sign in with your admin credentials

### 2. Select Your Environment

1. From the **Environments** list, select the target environment
2. Click on the environment name to open details

### 3. Upload the Extension

1. In the environment details, go to **Applications** → **Manage Extensions**
2. Click **Upload Extension**
3. Select your `.app` package file from the build output
4. Review the extension details
5. Click **Deploy**

### 4. Wait for Installation

The extension will be installed automatically. This may take several minutes depending on environment size.

**Status Indicators:**
- **Installing:** Installation in progress
- **Installed:** Successfully deployed and active
- **Upgrade:** Extension is being updated from a previous version

### 5. Configure Web Services

Once installed:
1. Go to **Search** → Type "Web Services"
2. Follow the configuration guide to publish the endpoints

## Deploying to On-Premises

For on-premises Business Central environments, follow your organization's AL deployment process:

1. Compile the extension to `.app`
2. Copy the package file to your deployment server
3. Use PowerShell or your deployment tool to publish the extension:
   ```powershell
   Publish-NAVApp -ServerInstance [instance-name] `
     -Path "Northern Partners ApS_DataExchange_1.0.0.6.app"
   ```
4. Sync and install the extension
5. Configure web services as described in the setup guide

## Updating the Extension

### Preparing an Update

1. **Update Version Number**
   - Edit `app.json`
   - Increment the version number:
     ```json
     "version": "1.0.1.0"
     ```

2. **Make Code Changes**
   - Edit codeunits, queries, or other AL objects as needed

3. **Rebuild the Package**
   - Follow the build steps above
   - New package will have updated version in filename:
     ```
     Northern Partners ApS_DataExchange_1.0.1.0.app
     ```

### Uploading the Update

**Cloud Environment:**
1. In Admin Center, go to **Applications** → **Manage Extensions**
2. Find the existing "DataExchange" extension
3. Select it and click **Upload Extension**
4. Choose the new `.app` file
5. The system will automatically upgrade from the previous version

**On-Premises:**
1. Use PowerShell with the `-Force` flag to overwrite:
   ```powershell
   Publish-NAVApp -ServerInstance [instance-name] `
     -Path "Northern Partners ApS_DataExchange_1.0.1.0.app" `
     -Force
   ```

## Troubleshooting Build Issues

### "Object not found" Errors
- Re-run: **AL: Download Symbols**
- Ensure Business Central version matches in `app.json` (platform version 23.0.0.0)

### Compilation Errors
- Check VS Code AL extension is updated
- Review error details in VS Code's Problems panel
- Verify AL files have correct syntax

### Package Not Created
- Check file permissions on project directory
- Ensure sufficient disk space for compilation
- Look for messages in VS Code Output panel

## Rollback Procedure

If issues occur after deployment:

**Cloud:**
1. Go to Admin Center → **Applications** → **Manage Extensions**
2. Find the extension and click the version number
3. Select the previous version to roll back to
4. Confirm the downgrade

**On-Premises:**
1. Use PowerShell to uninstall current version:
   ```powershell
   Uninstall-NAVApp -ServerInstance [instance-name] `
     -name DataExchange
   ```
2. Publish the previous `.app` file
3. Reinstall the extension

## Post-Deployment Verification

After deploying, verify the extension is working:

1. **Check Installation Status**
   - In Business Central, go to **Search** → Type "Extensions"
   - Find "DataExchange" in the list
   - Verify status shows "Installed"

2. **Test Web Services**
   - Follow test procedures in the configuration guide
   - Make test API calls to both endpoints

3. **Review Event Log**
   - Go to **Search** → Type "Event Log"
   - Check for any errors or warnings related to DataExchange

All tests passing indicates successful deployment and readiness for use.
