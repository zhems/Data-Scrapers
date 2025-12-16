# dbt + PostgreSQL Setup Guide

This guide shows how to use dbt to create and manage PostgreSQL tables using your scraped data.

## Overview

The workflow consists of two main steps:
1. **Extract & Load**: Scrape data and load it into PostgreSQL as raw tables
2. **Transform**: Use dbt to transform raw data into clean, tested models

## Architecture

```
data.gov.sg API
      ↓
scrape_data_gov_sg.py (Extract & Load)
      ↓
PostgreSQL (public.raw_cea_property_transactions)
      ↓
dbt (Transform)
      ↓
PostgreSQL Views & Tables (staging.*, marts.*)
```

## Setup (Already Completed!)

✓ Dependencies installed (dbt-postgres, sqlalchemy, psycopg2-binary)
✓ dbt project initialized in `dbt_project/`
✓ Environment variables configured in `.env`
✓ Scraper updated to load data to PostgreSQL

## Quick Start

### Step 1: Load Raw Data

Run the scraper to fetch data from data.gov.sg and load it into PostgreSQL:

```bash
uv run scrape_data_gov_sg.py
```

This creates the `raw_cea_property_transactions` table with columns like:
- transaction_date
- address
- property_type
- market_segment
- transacted_price
- floor_area_sqm
- etc.

### Step 2: Transform with dbt

```bash
# Navigate to dbt project
cd dbt_project

# Test database connection
DBT_PROFILES_DIR=. uv run dbt debug

# Run transformations
DBT_PROFILES_DIR=. uv run dbt run

# Run data quality tests
DBT_PROFILES_DIR=. uv run dbt test

# Generate documentation
DBT_PROFILES_DIR=. uv run dbt docs generate
DBT_PROFILES_DIR=. uv run dbt docs serve
```

Or use the convenience script:

```bash
# From project root
./run_dbt.sh debug
./run_dbt.sh run
./run_dbt.sh test
```

## What dbt Does

### 1. Source Definitions ([sources.yml](dbt_project/models/staging/data_gov_sg/sources.yml))
Declares the raw tables that dbt will read from:

```yaml
sources:
  - name: data_gov_sg
    tables:
      - name: raw_cea_property_transactions
```

### 2. Staging Models ([stg_cea_property_transactions.sql](dbt_project/models/staging/data_gov_sg/stg_cea_property_transactions.sql))
Creates cleaned views with:
- Standardized column names
- Generated surrogate keys (transaction_id)
- Proper data types
- Organized structure

Materialized as **views** in the `staging` schema.

### 3. Data Tests ([schema.yml](dbt_project/models/staging/data_gov_sg/schema.yml))
Validates data quality:
- `unique`: Ensures no duplicate IDs
- `not_null`: Checks for missing critical data
- Custom tests for business logic

### 4. Documentation
Auto-generates documentation with:
- Column descriptions
- Lineage diagrams showing data flow
- Test results

## Database Schema Organization

```
neondb (database)
├── public (schema)
│   └── raw_cea_property_transactions (table)
│       - Raw data from scraper
│
├── staging (schema)
│   └── stg_cea_property_transactions (view)
│       - Cleaned, standardized data
│
└── marts (schema)
    └── [Your production tables]
        - Business-ready aggregations
```

## Adding More Datasets

When you add a new scraper (e.g., for traffic data):

1. **Update the scraper** to load to `raw_<dataset_name>`:
   ```python
   load_to_postgres(df, 'raw_traffic_data', connection_string)
   ```

2. **Add source definition** in `sources.yml`:
   ```yaml
   - name: raw_traffic_data
     description: Traffic volume data
   ```

3. **Create staging model** `stg_traffic_data.sql`:
   ```sql
   select
       md5(concat(location, timestamp::text)) as traffic_id,
       location,
       timestamp,
       vehicle_count
   from {{ source('data_gov_sg', 'raw_traffic_data') }}
   ```

4. **Add tests** in `schema.yml`

5. **Run dbt**:
   ```bash
   ./run_dbt.sh run
   ```

## Creating Mart Models

Marts are production-ready tables for specific use cases:

Create `dbt_project/models/marts/fct_property_sales.sql`:

```sql
{{
    config(
        materialized='table'
    )
}}

select
    transaction_id,
    transaction_date,
    address,
    property_type,
    transacted_price,
    floor_area_sqm,
    unit_price_psm,
    -- Add calculated fields
    extract(year from transaction_date) as transaction_year,
    extract(month from transaction_date) as transaction_month
from {{ ref('stg_cea_property_transactions') }}
where market_segment = 'Sale'
    and transacted_price is not null
```

This creates a materialized **table** in the `marts` schema, optimized for analytics.

## Troubleshooting

### Connection Issues

Test your PostgreSQL connection:
```bash
cd dbt_project
DBT_PROFILES_DIR=. uv run dbt debug
```

This will show connection status and any configuration issues.

## Next Steps

1. Fix Python version compatibility
2. Run the full pipeline: scrape → load → transform
3. Create mart models for your specific analytics needs
4. Set up automated scheduling (e.g., with Airflow or cron)
5. Add more data sources

## Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)
- [PostgreSQL dbt Adapter](https://docs.getdbt.com/reference/warehouse-setups/postgres-setup)
