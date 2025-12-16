# ✅ dbt + PostgreSQL Setup Complete!

## What's Working

Your dbt project is now fully operational and successfully managing your PostgreSQL database schemas!

### 🎯 Successfully Created

1. **Raw Data Table**: `public.raw_cea_property_transactions` (1,256,836 rows)
2. **Staging View**: `public_staging.stg_cea_property_transactions`
3. **Mart View**: `public_marts.fct_property_sales`

### ✅ Test Results

All 6 data quality tests passing:
- ✓ Unique transaction IDs
- ✓ No null values in critical fields (transaction_id, transaction_date, property_type, etc.)
- ✓ Data integrity validated

## Data Pipeline

```
data.gov.sg API
      ↓
scrape_data_gov_sg.py
      ↓
PostgreSQL: raw_cea_property_transactions (1.25M rows)
      ↓
dbt staging layer
      ↓
PostgreSQL: stg_cea_property_transactions (view with cleaned data)
      ↓
dbt marts layer
      ↓
PostgreSQL: fct_property_sales (view with enriched analytics data)
```

## Schema Structure

### Raw Table: `raw_cea_property_transactions`
Columns from data.gov.sg:
- salesperson_name
- transaction_date
- salesperson_reg_num
- property_type
- transaction_type
- represented (BUYER/SELLER)
- town
- district
- general_location
- loaded_at

### Staging View: `stg_cea_property_transactions`
Cleaned and standardized with:
- **transaction_id** (MD5 hash surrogate key)
- All raw columns
- Organized by category (salesperson info, transaction details, location)

### Mart View: `fct_property_sales`
Analytics-ready with enrichments:
- **Time dimensions**: year, month, quarter, year_month, day_of_week
- **Categorizations**:
  - transaction_category (Resale/Rental/Sale/Other)
  - property_category (HDB/Condo/Landed/Other)

## How to Use

### Load New Data
```bash
uv run scrape_data_gov_sg.py
```

### Transform with dbt
```bash
./run_dbt.sh run    # Build all models
./run_dbt.sh test   # Run data quality tests
```

### Run Specific Operations
```bash
./run_dbt.sh run --select stg_cea_property_transactions
./run_dbt.sh run --select marts.*
./run_dbt.sh test --select stg_cea_property_transactions
./run_dbt.sh docs generate && ./run_dbt.sh docs serve
```

## Database Schemas Created

- **public**: Raw tables from scrapers
- **public_staging**: Cleaned staging views
- **public_marts**: Analytics-ready views

## Key Files

- [scrape_data_gov_sg.py](scrape_data_gov_sg.py) - Data scraper with PostgreSQL loading
- [run_dbt.sh](run_dbt.sh) - Convenience script for dbt commands
- [dbt_project/](dbt_project/) - dbt project root
  - [profiles.yml](dbt_project/profiles.yml) - Database connection config
  - [models/staging/](dbt_project/models/staging/) - Staging layer
  - [models/marts/](dbt_project/models/marts/) - Analytics layer

## Documentation

- [DBT_SETUP_GUIDE.md](DBT_SETUP_GUIDE.md) - Complete setup guide
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Quick command reference

## Notes

### Database Storage
The free Neon tier has a 512 MB limit. That's why the mart model is materialized as a **view** instead of a **table**. Views don't use storage but query the underlying data each time.

If you upgrade your database plan, you can change marts to tables:
```sql
{{ config(materialized='table') }}
```

### Adding New Datasets

Follow this pattern:

1. **Scraper** loads to `raw_<name>`
2. **Source** defined in `sources.yml`
3. **Staging model** creates `stg_<name>` view
4. **Tests** in `schema.yml`
5. **Mart models** for analytics

See [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for examples.

## What You Can Do Now

1. **Query your data**:
   ```sql
   SELECT * FROM public_staging.stg_cea_property_transactions LIMIT 10;
   SELECT * FROM public_marts.fct_property_sales WHERE transaction_year = 2024;
   ```

2. **View documentation**:
   ```bash
   ./run_dbt.sh docs generate
   ./run_dbt.sh docs serve
   # Open http://localhost:8080
   ```

3. **Add more datasets** following the same pattern

4. **Build custom mart models** for specific analytics needs

5. **Schedule automated runs** with cron, Airflow, or GitHub Actions

## Success! 🎉

Your data pipeline is production-ready:
- ✅ Data extraction and loading working
- ✅ Schema management with dbt
- ✅ Data quality tests passing
- ✅ Organized schema layers (raw → staging → marts)
- ✅ Documentation and lineage tracking

You now have a scalable foundation for managing your data warehouse with dbt!
