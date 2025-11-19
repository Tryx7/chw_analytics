/*
Model: chw_activity_monthly
Description: Monthly aggregation of CHW activities for dashboard performance metrics

Business Logic:
- Aggregates CHW activities by CHW and month
- Uses special month assignment logic (26th cutoff rule)
- Calculates key performance metrics for dashboard reporting
- Handles late-arriving data with delete+insert strategy

Grain: One row per CHW per month
Primary Key: (chv_id, report_month)

Author: Data Analytics Team
Last Updated: 2025-11-19
*/

-- ============================================
-- dbt Configuration
-- ============================================
{{
    config(
        materialized='incremental',
        unique_key=['chv_id', 'report_month'],
        incremental_strategy='delete+insert',
        on_schema_change='sync_all_columns',
        tags=['monthly', 'metrics', 'chw']
    )
}}

-- ============================================
-- Main Query
-- ============================================

with source_data as (
    -- Pull raw activity data from fact table
    select
        activity_id,
        chv_id,
        activity_date,
        activity_type,
        household_id,
        patient_id,
        is_deleted,
        created_at,
        updated_at
    from {{ ref('fct_chv_activity') }}
    
    where 1=1
        -- Filter out invalid records per business requirements
        and chv_id is not null          -- Data quality: exclude NULL CHW IDs
        and activity_date is not null   -- Data quality: exclude NULL dates
        and is_deleted = false          -- Exclude soft-deleted records

    {% if is_incremental() %}
        -- For incremental runs, only process new or updated records
        -- Look back 2 months to catch late-arriving data
        and (
            created_at > (select max(updated_at) from {{ this }})
            or updated_at > (select max(updated_at) from {{ this }})
            or activity_date >= date_trunc('month', current_date) - interval '2 months'
        )
    {% endif %}
),

with_report_month as (
    -- Apply month assignment logic using the custom macro
    -- Activities on/after 26th are assigned to NEXT month
    select
        activity_id,
        chv_id,
        activity_date,
        activity_type,
        household_id,
        patient_id,
        created_at,
        updated_at,
        {{ month_assignment('activity_date') }}::date as report_month
    from source_data
),

aggregated as (
    -- Calculate all required metrics per CHW per month
    select
        chv_id,
        report_month,
        
        -- Metric 1: Total activities count
        count(*) as total_activities,
        
        -- Metric 2: Unique households visited (distinct count)
        -- Same household visited multiple times = counted once
        count(distinct household_id) as unique_households_visited,
        
        -- Metric 3: Unique patients served (distinct count)
        -- NULLs are ignored automatically by count(distinct)
        -- Same patient seen multiple times = counted once
        count(distinct patient_id) as unique_patients_served,
        
        -- Metric 4-6: Activity type breakdowns using FILTER clause
        count(*) filter (where activity_type = 'pregnancy_visit') as pregnancy_visits,
        count(*) filter (where activity_type = 'child_assessment') as child_assessments,
        count(*) filter (where activity_type = 'family_planning') as family_planning_visits,
        
        -- Metadata: track most recent update timestamp
        max(updated_at) as updated_at
        
    from with_report_month
    group by 
        chv_id,
        report_month
)

-- Final select with explicit column ordering
select 
    chv_id,
    report_month,
    total_activities,
    unique_households_visited,
    unique_patients_served,
    pregnancy_visits,
    child_assessments,
    family_planning_visits,
    updated_at
from aggregated

-- Order by CHW and month for readability
order by chv_id, report_month