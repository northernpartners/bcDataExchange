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

## Quick Links

- **[Dimension Management API](features/dimension-api.md)** - Create dimensions and values programmatically
- **[Customer Data API](features/customer-api.md)** - Query customer records with filtering and sorting
- **[Configuration Guide](setup/configuration.md)** - Set up web services in Business Central
- **[Deployment](setup/deployment.md)** - Build and deploy the extension
- **[Architecture](architecture/overview.md)** - System design and data flow
- **[Troubleshooting](troubleshooting.md)** - Common issues and solutions

---

**Last Updated:** March 3, 2026  
**Version:** 1.0.0.0  
**Publisher:** Northern Partners ApS
