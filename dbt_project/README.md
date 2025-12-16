# dbt Project for Data Scrapers

This dbt project manages the transformation and modeling of scraped data in PostgreSQL.

## Setup

1. **Install dependencies** (already done via uv):
   ```bash
   uv add dbt-postgres psycopg2-binary python-dotenv sqlalchemy
   ```

2. **Environment variables** are configured in `.env` at the project root

3. **Install dbt packages**:
   ```bash
   cd dbt_project
   dbt deps
   ```

## Project Structure

```
dbt_project/
├── dbt_project.yml          # dbt project configuration
├── profiles.yml             # Database connection configuration
├── packages.yml             # dbt package dependencies
└── models/
    ├── staging/             # Staging models (views)
    │   └── data_gov_sg/
    │       ├── sources.yml  # Source table definitions
    │       ├── schema.yml   # Model documentation and tests
    │       └── stg_cea_property_transactions.sql
    └── marts/               # Production models (tables)
```

## Workflow

### 1. Load Raw Data
Run the scraper to load data into PostgreSQL:
```bash
cd ..
uv run scrape_data_gov_sg.py
```

This creates the `raw_cea_property_transactions` table in your PostgreSQL database.

### 2. Run dbt Models
Transform the raw data using dbt:
```bash
cd dbt_project

# Test connection
DBT_PROFILES_DIR=. dbt debug

# Install dependencies
DBT_PROFILES_DIR=. dbt deps

# Run models
DBT_PROFILES_DIR=. dbt run

# Run tests
DBT_PROFILES_DIR=. dbt test

# Generate documentation
DBT_PROFILES_DIR=. dbt docs generate
DBT_PROFILES_DIR=. dbt docs serve
```

### 3. Schema Organization

- **public schema**: Raw tables (e.g., `raw_cea_property_transactions`)
- **staging schema**: Cleaned and standardized views
- **marts schema**: Production-ready tables

## Key Features

1. **Source definitions**: Track raw data tables
2. **Staging models**: Clean and standardize column names
3. **Data tests**: Ensure data quality with uniqueness, not-null, and range checks
4. **Documentation**: Self-documenting models with descriptions
5. **Surrogate keys**: Generate unique IDs using `dbt_utils`

## Adding New Datasets

1. Update the scraper to load data to a new `raw_*` table
2. Add the source definition in `models/staging/<source>/sources.yml`
3. Create a staging model `stg_<table_name>.sql`
4. Add tests and documentation in `schema.yml`
5. Run `dbt run` and `dbt test`

## Example: Creating a Mart Model

Create `models/marts/fct_property_sales.sql`:
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
    market_segment,
    transacted_price,
    floor_area_sqm,
    unit_price_psm
from {{ ref('stg_cea_property_transactions') }}
where market_segment = 'Sale'
```
