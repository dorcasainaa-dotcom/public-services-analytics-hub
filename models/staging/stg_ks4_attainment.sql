with source as (

    select * from {{ source('psah_raw', 'ks4_attainment') }}

),

renamed as (

    select
        authority_code,
        authority_name,
        academic_year,
        attainment8_avg,
        pct_grade5_english_maths,
        pct_entering_ebacc,
        pct_grade5_ebacc

    from source
    where authority_code is not null

)

select * from renamed