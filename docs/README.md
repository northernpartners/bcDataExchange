# DataExchange

A unified Business Central AL extension exposing data via web service APIs for external system integration.

**Publisher:** Northern Partners ApS  
**Platform:** Business Central 23.0+ | Runtime: AL 11.0  
**Target:** Cloud  
**ID Range:** 50150-50299  
**Latest Version:** 1.0.0.0

---

## Overview

The DataExchange extension combines multiple data integration capabilities into a single, cohesive package:

- **Dimension Management API** - Create dimensions and dimension values via CodeUnit POST endpoint
- **Customer Data API** - Query and filter customer records via OData GET endpoint

Both endpoints expose Business Central data in JSON format, enabling seamless integration with external systems.

---

## Web Service Endpoints

| Object Type | Object ID | Object Name | Service Name | HTTP Method | Protocol | Description |
|-------------|-----------|-------------|--------------|------------|----------|-------------|
| Codeunit | 50151 | Dimension Handler | createDimensions | POST | REST/JSON | Create dimensions and dimension values |
| Query | 50250 | Customers | queryCustomers | GET | OData V4 | Query and filter customer data |

---

## Documentation Structure

### [Features](features/dimension-api.md)

#### Dimension Management API
- RESTful endpoint for creating Business Central dimensions
- Request/response formats with examples
- Error handling and response codes
- **[Learn more →](features/dimension-api.md)**

#### Customer Data API
- OData V4 endpoint for querying customers
- Filtering, sorting, and pagination operations
- Standard OData operators reference
- **[Learn more →](features/customer-api.md)**

### Setup & Configuration

#### Web Services Configuration
- Step-by-step setup in Business Central
- User permissions and security
- API endpoint verification
- **[Learn more →](setup/configuration.md)**

#### Building & Deployment
- Building extension packages
- Cloud and On-Premises deployment
- Updating and rollback procedures
- **[Learn more →](setup/deployment.md)**

### Support

#### Troubleshooting
- Common issues and solutions
- Authentication and authorization
- Performance optimization tips
- Event log diagnostics
- **[Learn more →](troubleshooting.md)**

---

## Quick Links

- **[Dimension Management API](features/dimension-api.md)** - Create dimensions and values programmatically
- **[Customer Data API](features/customer-api.md)** - Query customer records with filtering and sorting
- **[Configuration Guide](setup/configuration.md)** - Set up web services in Business Central
- **[Deployment](setup/deployment.md)** - Build and deploy the extension
- **[Troubleshooting](troubleshooting.md)** - Common issues and solutions

---

**Format:** GitBook Cloud-compatible documentation  
**Version:** 1.0.0.0  
**Publisher:** Northern Partners ApS  
**Last Updated:** March 3, 2026
