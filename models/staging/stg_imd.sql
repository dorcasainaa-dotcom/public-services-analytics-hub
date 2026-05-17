with source as (

    select * from {{ source('psah_raw', 'imd') }}

),

renamed as (

    select
        authority_code,
        authority_name,
        imd_average_score,
        imd_average_rank,
        imd_pct_lsoas_most_deprived

    from source
    where authority_code is not null

)

select * from renamed