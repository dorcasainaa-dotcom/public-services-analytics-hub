{{ config(materialized='table') }}

with expenditure as (
    select * from {{ ref('stg_la_expenditure') }}
),

claimant as (
    select * from {{ ref('stg_claimant_count') }}
),

ks4_deduped as (
    select
        authority_code,
        authority_name,
        academic_year,
       round(avg(attainment8_avg), 2)             as attainment8_avg,
        avg(pct_grade5_english_maths)    as pct_grade5_english_maths,
        avg(pct_entering_ebacc)          as pct_entering_ebacc,
        avg(pct_grade5_ebacc)            as pct_grade5_ebacc
    from {{ ref('stg_ks4_attainment') }}
    group by authority_code, authority_name, academic_year
),

ks4_latest as (
    select *
    from ks4_deduped
    qualify row_number() over (
        partition by authority_code
        order by academic_year desc
    ) = 1
),

imd as (
    select * from {{ ref('stg_imd') }}
),

fact as (
    select
        exp.authority_code,
        exp.authority_name,
        exp.authority_class,
        exp.financial_year,

        -- Expenditure (£ thousands)
        exp.net_exp_education,
        exp.net_exp_adult_social_care,
        exp.net_exp_housing,
        exp.net_exp_childrens_social_care,
        exp.net_exp_transport,
        exp.net_exp_total,

        -- Claimant count (Feb 2026 snapshot)
        cl.claimant_count,
        cl.claimant_rate,

        -- KS4 attainment (latest available year per LA)
        ks4.academic_year               as ks4_academic_year,
        ks4.attainment8_avg,
        ks4.pct_grade5_english_maths,
        ks4.pct_entering_ebacc,
        ks4.pct_grade5_ebacc,

        -- Deprivation (IMD 2019)
        imd.imd_average_score,
        imd.imd_average_rank,
        imd.imd_pct_lsoas_most_deprived

    from expenditure exp
    left join claimant cl
        on exp.authority_code = cl.authority_code
    left join ks4_latest ks4
        on exp.authority_code = ks4.authority_code
    left join imd
        on exp.authority_code = imd.authority_code
)

select * from fact