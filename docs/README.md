# DataExchange

A unified Business Central AL extension exposing data via web service APIs for external system integration.

**Publisher:** Northern Partners ApS  
**Platform:** Business Central 23.0+ | Runtime: AL 11.0  
**Target:** Cloud  
**ID Range:** 50150-50299  
**Latest Version:** 1.0.0.1

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
| Query | 50250 | Customers | queryCustomers | GET | OData V4 | Query and filter customer data (core fields) |
| Query | 50251 | Customer Details | customerDetails | GET | OData V4 | Query comprehensive customer data with address/contact/invoicing details |

---

## FEATURES

### Customer Data APIs
Query and filter Business Central customer records via OData V4. Two query endpoints provide different levels of detail:
- **Customers Query** (50250): Core customer fields with fast filtering
- **Customer Details Query** (50251): Comprehensive customer data including address, contact, invoicing, and payment information

Both support filtering, sorting, and pagination with standard OData operators.
- [Customer Data API](Customer%20Data%20API.md)

### Dimension Management API
Create Business Central dimensions and dimension values programmatically via REST/JSON. The API is idempotent and automatically skips existing values.
- [Dimension Management API](Dimension%20Management%20API.md)

---

## SETUP & CONFIGURATION

### Web Services Configuration
Step-by-step guide to configure web services in Business Central, set up user permissions, and verify API endpoints.
- [Web Services Configuration](Web%20Services%20Configuration.md)

### Building & Deployment
Instructions for building the extension package and deploying to Business Central cloud and on-premises environments.
- [Building & Deployment](Building%20%26%20Deployment.md)

---

## SUPPORT

### Troubleshooting
Common issues and solutions including API access problems, authentication errors, performance optimization, and event log diagnostics.
- [Troubleshooting](Troubleshooting.md)

---

## Quick Start

1. Deploy the extension to your Business Central environment
2. Configure web services following the [Web Services Configuration](Web%20Services%20Configuration.md) guide
3. Add API permissions to your integration user
4. Start using the endpoints:
   - **Create dimensions:** POST to the Dimension Management API
   - **Query customers:** GET from the Customer Data API

---

**Format:** GitBook Cloud-compatible flat structure  
**Version:** 1.0.0.1  
**Publisher:** Northern Partners ApS  
**Last Updated:** March 5, 2026
