with source as (

    select * from {{ source('psah_raw', 'claimant_count') }}

),

renamed as (

    select
        authority_code,
        authority_name,
        claimant_count,
        claimant_rate

    from source
    where authority_code is not null

)

select * from renamed