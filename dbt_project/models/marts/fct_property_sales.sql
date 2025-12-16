{{
    config(
        materialized='view',
        schema='marts'
    )
}}

-- Example mart model: Property transaction facts
-- This creates a production-ready table for analyzing property transactions

with transactions as (
    select
        transaction_id,
        salesperson_name,
        salesperson_reg_num,
        represented,
        transaction_date,
        transaction_type,
        property_type,
        town,
        district,
        general_location,
        loaded_at
    from {{ ref('stg_cea_property_transactions') }}
),

enriched as (
    select
        *,
        -- Time dimensions
        extract(year from transaction_date) as transaction_year,
        extract(month from transaction_date) as transaction_month,
        extract(quarter from transaction_date) as transaction_quarter,
        to_char(transaction_date, 'YYYY-MM') as transaction_year_month,
        to_char(transaction_date, 'Day') as transaction_day_of_week,

        -- Categorizations
        case
            when transaction_type ilike '%resale%' then 'Resale'
            when transaction_type ilike '%rental%' then 'Rental'
            when transaction_type ilike '%sale%' then 'Sale'
            else 'Other'
        end as transaction_category,

        case
            when property_type = 'HDB' then 'HDB'
            when property_type ilike '%condo%' or property_type ilike '%apartment%' then 'Condo'
            when property_type ilike '%landed%' or property_type ilike '%terrace%' or property_type ilike '%bungalow%' then 'Landed'
            else 'Other'
        end as property_category

    from transactions
)

select * from enriched
