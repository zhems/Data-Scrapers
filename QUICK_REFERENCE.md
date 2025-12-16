# Quick Reference: Data Pipeline with dbt

## Common Commands

### Load Data
```bash
# Scrape and load raw data to PostgreSQL
uv run scrape_data_gov_sg.py
```

### dbt Commands
```bash
# Using the convenience script (from project root)
./run_dbt.sh debug      # Test connection
./run_dbt.sh run        # Run all models
./run_dbt.sh test       # Run data tests
./run_dbt.sh docs generate && ./run_dbt.sh docs serve  # View docs

# Or manually (from dbt_project/)
cd dbt_project
DBT_PROFILES_DIR=. uv run dbt <command>
```

### Run Specific Models
```bash
./run_dbt.sh run --select stg_cea_property_transactions
./run_dbt.sh run --select marts.*
./run_dbt.sh test --select stg_cea_property_transactions
```

## Project Structure

```
Data-Scrapers/
├── .env                              # Environment variables
├── scrape_data_gov_sg.py            # Scraper (Extract & Load)
├── data_gov_sg.py                   # API client
├── run_dbt.sh                        # dbt convenience script
└── dbt_project/                      # dbt project root
    ├── dbt_project.yml              # Project config
    ├── profiles.yml                 # Database connection
    └── models/
        ├── staging/                 # Staging layer (views)
        │   └── data_gov_sg/
        │       ├── sources.yml      # Source definitions
        │       ├── schema.yml       # Tests & docs
        │       └── stg_cea_property_transactions.sql
        └── marts/                   # Analytics layer (tables)
            └── fct_property_sales.sql
```

## Data Flow

```
1. API → scraper → raw_cea_property_transactions (table in public schema)
2. dbt reads from public.raw_* → creates staging.stg_* (views)
3. dbt transforms staging.stg_* → creates marts.fct_* (tables)
```

## Adding a New Dataset

1. **Create scraper function**:
   ```python
   dataset_id = "d_xxxxx"
   df = load_dataset(dataset_id)
   load_to_postgres(df, 'raw_<name>', connection_string)
   ```

2. **Add to sources.yml**:
   ```yaml
   - name: raw_<name>
     description: Description
   ```

3. **Create staging model** `stg_<name>.sql`:
   ```sql
   select
       md5(concat(id1, id2)) as unique_id,
       column1,
       column2
   from {{ source('data_gov_sg', 'raw_<name>') }}
   ```

4. **Add tests** in schema.yml

5. **Run**: `./run_dbt.sh run`

## Model Materialization Types

- **view**: Fast to build, always fresh, slower to query
  - Use for: Staging models, lightweight transforms

- **table**: Slower to build, faster to query, needs refresh
  - Use for: Marts, aggregations, final outputs

- **incremental**: Only processes new/changed records
  - Use for: Large datasets, fact tables

- **ephemeral**: Not materialized, used as CTEs
  - Use for: Reusable logic, intermediate steps

## Config in Model

```sql
{{
    config(
        materialized='table',  -- view, table, incremental, ephemeral
        schema='marts'         -- Target schema
    )
}}
```

## Jinja in dbt

```sql
-- Reference other models
from {{ ref('stg_model_name') }}

-- Reference source tables
from {{ source('source_name', 'table_name') }}

-- Reference environment variables (in profiles.yml)
"{{ env_var('POSTGRES_HOST') }}"
```

## Common Tests

```yaml
columns:
  - name: id
    tests:
      - unique
      - not_null
      - relationships:
          to: ref('other_table')
          field: id
      - accepted_values:
          values: ['A', 'B', 'C']
```

## Troubleshooting

**Python 3.14 issue**: Downgrade to Python 3.12
```bash
echo "3.12" > .python-version
rm -rf .venv
uv venv
uv add dbt-postgres psycopg2-binary python-dotenv sqlalchemy
```

**Connection failed**: Check `.env` has all POSTGRES_* variables

**Model not found**: Ensure you're running from `dbt_project/` or using `DBT_PROFILES_DIR=.`

**Source not found**: Check sources.yml defines the raw table

## Documentation

View your data lineage and docs:
```bash
./run_dbt.sh docs generate
./run_dbt.sh docs serve
```
Then open http://localhost:8080
