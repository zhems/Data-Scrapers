# Data-Scrapers
Modularized scraping code

| Full Name | Description | `dataset_id` |
|----------|----------|----------|
| [CEA Salespersons’ Property Transaction Records (residential)](https://data.gov.sg/datasets/d_ee7e46d3c57f7865790704632b0aef71/view) | Records of HDB resale flat transactions, HDB rentals, private rentals, and private sales closed by salespersons (from Jan 2017 to present). Records are updated monthly. | `d_ee7e46d3c57f7865790704632b0aef71` |


## Status
Setting up and testing `dbt` for this project with the existing scraper was a good learning exercise, but realised that it was unnecessary for my project aim. Am committing merging this branch for my own reference and but sunsetting it; will be working on a non-dbt setup instead.

## Installations

```bash
uv tool install cookiecutter
uv tool install pre-commit
```

## How to run

`uv run scrape_data_gov_sg.py`


### Remaining Components
- ECS/Fargate
    - ECSOperator
- Amazon Managed Workflows for Apache Airflow (MWAA)
- Postgresql linkage (Neon)
- Cookiecutter for jobs
- Viewer on personal website
