# DataExchange

A unified Business Central AL extension exposing data via web service APIs for external system integration.

**Publisher:** Northern Partners ApS  
**Platform:** Business Central 23.0+ | Runtime: AL 11.0  
**Target:** Cloud  
**ID Range:** 50150-50299  
**Latest Version:** 1.0.0.7

---

## Overview

The DataExchange extension combines multiple data integration capabilities into a single, cohesive package:

- **Dimension Management API** - Create dimensions and dimension values via CodeUnit POST endpoint
- **Dimensions Query API** - Query and filter dimensions via OData GET endpoint
- **Customer Data APIs** - Query and filter customer records via OData GET endpoints
- **Sales Invoice APIs** - Query draft and posted sales invoices via OData GET endpoints

---

## Web Service Endpoints

| Object Type | Object ID | Object Name | Service Name | HTTP Method | Protocol | Description |
|-------------|-----------|-------------|--------------|------------|----------|-------------|
| Codeunit | 50151 | Dimension Handler | createDimensions | POST | REST/JSON | Create dimensions and dimension values |
| Codeunit | 50152 | Sales Invoice Handler | processInvoice | POST | REST/JSON | Sales invoice operations (details, create) |
| Query | 50250 | Customers | queryCustomers | GET | OData V4 | Query and filter customer data (core fields) |
| Query | 50251 | Customer Details | customerDetails | GET | OData V4 | Query comprehensive customer data with address/contact/invoicing details |
| Query | 50252 | Dimensions | dimensions | GET | OData V4 | Query dimension groups/codes |
| Query | 50253 | Dimension Values | dimensionValues | GET | OData V4 | Query dimension values filtered by dimension group |
| Query | 50254 | Draft Invoices | draftInvoices | GET | OData V4 | Query draft sales invoices |
| Query | 50255 | Posted Invoices | postedInvoices | GET | OData V4 | Query posted sales invoices |

---

## FEATURES

### Customer Data APIs
Query and filter Business Central customer records via OData V4. Two query endpoints provide different levels of detail:
- **Customers Query** (50250): Core customer fields with fast filtering
- **Customer Details Query** (50251): Comprehensive customer data including address, contact, invoicing, and payment information

Both support filtering, sorting, and pagination with standard OData operators.
- [Customer Data API](Customer%20Data%20API.md)

### Dimension Management APIs
Create Business Central dimensions and dimension values programmatically via REST/JSON. Query and filter dimension groups and their values via OData with support for filtering, sorting, and pagination.
- **Create Dimensions** (50151): POST endpoint for creating new dimensions and values
- **Query Dimensions** (50252): GET endpoint for listing dimension groups/codes
- **Query Dimension Values** (50253): GET endpoint for listing dimension values within dimension groups
- [Dimension Management API](Dimension%20Management%20API.md)
- [Dimensions Query API](Dimensions%20Query%20API.md)
- [Dimension Values Query API](Dimension%20Values%20Query%20API.md)

### Sales Invoice APIs
Query draft and posted sales invoices via OData V4. Two query endpoints separate unposted (draft) invoices from posted invoices. A REST/JSON endpoint provides detailed invoice data including line items and dimensions.
- **Sales Invoice Handler** (50152): POST endpoint for invoice operations (getDraftDetails, getPostedDetails, createDraft)
- **Draft Invoices** (50254): GET endpoint for querying unposted sales invoices with status and document type filters
- **Posted Invoices** (50255): GET endpoint for querying posted sales invoices
- [Sales Invoice API](Sales%20Invoice%20API.md)
- [Draft Invoices Query API](Draft%20Invoices%20Query%20API.md)
- [Posted Invoices Query API](Posted%20Invoices%20Query%20API.md)

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
**Version:** 1.0.0.7  
**Publisher:** Northern Partners ApS  
**Last Updated:** March 9, 2026
