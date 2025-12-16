{{
    config(
        materialized='view'
    )
}}

with source as (
    select
        *,
        row_number() over (order by transaction_date, salesperson_reg_num) as source_row_num
    from {{ source('data_gov_sg', 'raw_cea_property_transactions') }}
),

renamed as (
    select
        -- Identifiers
        md5(concat(
            coalesce(transaction_date::text, ''),
            coalesce(salesperson_reg_num, ''),
            coalesce(general_location, ''),
            coalesce(property_type, ''),
            coalesce(represented, ''),
            source_row_num::text
        )) as transaction_id,

        -- Salesperson information
        salesperson_name,
        salesperson_reg_num,
        represented,  -- BUYER or SELLER

        -- Transaction details
        transaction_date,
        transaction_type,  -- RESALE, RENTAL, etc.
        property_type,     -- HDB, Condo, Landed, etc.

        -- Location
        town,
        district,
        general_location,

        -- Metadata
        loaded_at

    from source
)

select * from renamed
