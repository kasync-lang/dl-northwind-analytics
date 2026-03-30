# Northwind Analytics - Data Lake & Warehouse Project

A comprehensive data analytics pipeline that transforms raw Northwind database data into clean, analytics-ready tables for business intelligence using **dbt** and **BigQuery**.

## 📋 Project Overview

This project implements a modern **ELT (Extract, Load, Transform)** architecture, processing Northwind OLTP data into a dimensional data warehouse with three analytical layers:

1. **Staging Layer** - Direct source mappings with minimal transformation
2. **Warehouse Layer** - Dimensional and fact tables following star schema
3. **One Big Table Layer** - Denormalized tables optimized for specific business use cases

### Architecture Approach

```
Raw OLTP Data (dl_northwind)
        ↓
   Staging (stg_northwind) - 20+ conformed tables
        ↓
   Warehouse (wh_northwind) - Dimensional modeling
   ├── Dimensions (customer, employee, product, date)
   └── Facts (sales, inventory, purchase orders)
        ↓
   Analytics (obt_northwind) - Denormalized views
   ├── Sales overview
   ├── Customer reporting
   └── Product inventory
```

## 🏗️ System Design

### Technology Stack

- **Data Transformation**: dbt (data build tool)
- **Data Warehouse**: Google BigQuery
- **Data Source**: Northwind OLTP Database
- **Infrastructure as Code**: YAML and SQL

### Data Model Layers

#### Staging Layer (`stg_northwind`)
- **Purpose**: Direct mapping from source systems with minimal transformation
- **Tables**: 20+ staging tables including:
  - Core entities: `stg_customer`, `stg_employees`, `stg_products`, `stg_orders`
  - Transactions: `stg_order_details`, `stg_invoices`, `stg_purchase_orders`
  - Reference data: `stg_suppliers`, `stg_shippers`, and status lookups
- **Key Feature**: All records include `ingestion_timestamp` for data lineage

#### Warehouse Layer (`wh_northwind`)
**Dimension Tables:**
- `dim_customer`: Customer master with deduplication (1.0M rows estimated)
- `dim_employee`: Employee hierarchy and attributes
- `dim_product`: Product catalog with supplier relationships
- `dim_date`: Time dimension (view-based for flexibility)

**Fact Tables:**
- `fact_sales`: Order transactions grain (Order ID + Product ID)
- `fact_inventory`: Inventory movements and transactions
- `fact_purchase_order`: Purchase order tracking (Order ID + Product ID)

#### Analytics Layer (`obt_northwind`)
Denormalized tables optimized for specific business questions:

**`obt_sales_overview`**
- Combines customer, employee, and product dimensions with sales facts
- Supports: revenue analysis, sales trends, customer value metrics
- Grain: Order detail level with full context

**`obt_customer_reporting`**
- Customer-centric view with aggregated metrics
- Supports: customer segmentation, lifetime value, purchase patterns
- Key metrics: order count, total revenue, preferred products

**`obt_product_inventory`**
- Product-centric inventory and sales analysis
- Supports: inventory management, reorder planning, sales velocity
- Combines stock levels with historical transactions

## 📊 Data Model

### Entity Relationships

```
Dimensions:
├── dim_customer
├── dim_employee
├── dim_product
│   └── linked to Suppliers (from source)
└── dim_date

Facts:
├── fact_sales
│   └── FK: customer_id, employee_id, product_id, date_id
├── fact_inventory
│   └── FK: product_id, date_id
└── fact_purchase_order
    └── FK: product_id, supplier_id, date_id
```

### Source System Integration

**Source Schema**: `dl_northwind`

**Operational Tables (10)**:
- `customer`, `employees`, `products`, `suppliers`, `shippers`
- `orders`, `order_details`, `purchase_orders`, `purchase_order_details`, `invoices`

**Reference Tables (10)**:
- Status codes: `order_details_status`, `orders_status`, `orders_tax_status`, `purchase_order_status`
- Reference data: `inventory_transaction_types`, `inventory_transactions`, `employee_privileges`, `privileges`, `sales_reports`, `strings`

## 🔍 Key Design Decisions

### 1. Three-Layer Architecture
- **Staging**: Reduces risk of source system changes breaking downstream logic
- **Warehouse**: Enables reusability across multiple analytical use cases
- **Analytics**: Optimizes for specific business needs without compromising warehouse

### 2. View vs. Table Strategy
- Most models as **tables** for query performance
- `dim_date` as **view** to allow dynamic date generation without storage overhead
- Other dimensions as tables with deduplication logic

### 3. Denormalization in OBT Layer
- Combines multiple dimensions with facts for single-query analytics
- Reduces join complexity for BI tools and end-users
- Maintains data integrity through dbt lineage

### 4. Ingestion Timestamp Tracking
- All staging tables include `ingestion_timestamp` from current_timestamp()
- Enables data freshness monitoring and audit trails
- Supports SCD (Slowly Changing Dimensions) if needed

### 5. Data Quality Framework
- dbt tests on unique and not-null constraints
- Referential integrity checks via dbt tests
- Model dependencies explicitly defined in YAML

## 📈 Analytical Capabilities

### Sales Analysis
- Revenue by customer, employee, product, and time period
- Sales trends and seasonality
- Customer acquisition cost vs. lifetime value
- Employee performance metrics

### Inventory Management
- Current stock levels by product and location
- Inventory turnover and movement history
- Reorder requirements and safety stock analysis
- Supplier performance metrics

### Customer Intelligence
- Customer segmentation by value and behavior
- Product affinity analysis
- Churn risk identification
- Geographic market analysis

## 🏢 Business Value

1. **Single Source of Truth**: Conformed dimensions ensure consistent metrics across analytics
2. **Time-to-Insight**: OBT layer enables direct visualization without complex joins
3. **Scalability**: BigQuery handles billions of rows efficiently
4. **Data Governance**: dbt provides lineage, documentation, and version control
5. **Maintainability**: SQL-based transformations are easier to understand and modify than procedural code

## 📁 Project Structure

```
northwind/
├── dbt_project.yml                  # Project configuration
├── models/
│   ├── staging/
│   │   ├── source.yml               # Source definitions
│   │   └── stg_*.sql                # 20+ staging models
│   ├── warehouse/
│   │   ├── dim_customer.sql
│   │   ├── dim_employee.sql
│   │   ├── dim_product.sql
│   │   ├── dim_date.sql
│   │   ├── fact_sales.sql
│   │   ├── fact_inventory.sql
│   │   └── fact_purchase_order.sql
│   └── one_big_table/
│       ├── obt_sales_overview.sql
│       ├── obt_customer_reporting.sql
│       └── obt_product_inventory.sql
├── tests/                           # Data quality tests
├── seeds/                           # Static reference data
├── macros/                          # dbt macros and utilities
└── target/                          # Compiled artifacts
```

## 🎯 Key Metrics

### Staging Layer
- **20+ tables** covering all source system entities
- **Deduplication** logic applied to customer and employee masters
- **Audit trail** with ingestion timestamps

### Warehouse Layer
- **7 core tables** (4 dimensions + 3 facts)
- **Star schema** design supporting multiple analytical questions
- **Referential integrity** maintained through fact-dimension relationships

### Analytics Layer
- **3 specialized views** for high-impact business questions
- **Pre-joined data** eliminating need for complex analytics queries
- **Optimized for BI tool integration**

## 📚 Resources & References

- **dbt**: Data transformation using SQL and YAML
- **BigQuery**: Cloud data warehouse with standard SQL
- **Northwind**: Microsoft sample database for retail operations
- **Entity Relationship Diagrams**: Available in `/resource/` directory (conceptual, logical, and physical models)

---

**Version**: 1.0  
**Last Updated**: March 2026

