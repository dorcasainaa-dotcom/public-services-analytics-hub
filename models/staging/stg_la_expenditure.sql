with source as (

    select * from {{ source('psah_raw', 'la_revenue_expenditure') }}

),

renamed as (

    select
        authority_code,
        authority_name,
        authority_class,
        financial_year,
        net_exp_education,
        net_exp_adult_social_care,
        net_exp_housing,
        net_exp_childrens_social_care,
        net_exp_transport,
        net_exp_total

    from source
    where authority_code is not null

)

select * from renamed