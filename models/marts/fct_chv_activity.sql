/*
Model: fct_chv_activity
Description: Fact table containing CHW activity data (one row per activity/visit)

This is a sample/seed table for the assignment. In production, this would be
populated from your source data system.

Grain: One row per CHW activity/visit
Primary Key: activity_id

Notes for reviewers:
- Rows with NULL chv_id or activity_date are excluded (data quality issues)
- Rows where is_deleted = true are excluded
- Only valid, non-deleted CHW activities are included
*/

{{
    config(
        materialized='table',
        tags=['marts', 'fact']
    )
}}

with sample_data as (
    select * from (
        values
        -- CHV001: Active CHW with mixed activities in January
        ('ACT_001', 'CHV001', '2025-01-05'::date, '2025-01-05 09:30:00'::timestamp, 'pregnancy_visit', 'HH001', 'PAT001', 'LOC_BUSIA_01', false, '2025-01-06 08:00:00'::timestamp, '2025-01-06 08:00:00'::timestamp),
        ('ACT_002', 'CHV001', '2025-01-05'::date, '2025-01-05 11:00:00'::timestamp, 'pregnancy_visit', 'HH001', 'PAT001', 'LOC_BUSIA_01', false, '2025-01-06 08:00:00'::timestamp, '2025-01-06 08:00:00'::timestamp),
        ('ACT_003', 'CHV001', '2025-01-12'::date, '2025-01-12 10:15:00'::timestamp, 'child_assessment', 'HH002', 'PAT002', 'LOC_BUSIA_01', false, '2025-01-13 08:00:00'::timestamp, '2025-01-13 08:00:00'::timestamp),
        ('ACT_004', 'CHV001', '2025-01-15'::date, '2025-01-15 14:20:00'::timestamp, 'pregnancy_visit', 'HH001', 'PAT001', 'LOC_BUSIA_01', false, '2025-01-16 08:00:00'::timestamp, '2025-01-16 08:00:00'::timestamp),
        ('ACT_005', 'CHV001', '2025-01-28'::date, '2025-01-28 16:00:00'::timestamp, 'family_planning', 'HH003', 'PAT003', 'LOC_BUSIA_01', false, '2025-01-29 08:00:00'::timestamp, '2025-01-29 08:00:00'::timestamp),

        -- CHV002: Another active CHW
        ('ACT_006', 'CHV002', '2025-01-08'::date, '2025-01-08 09:00:00'::timestamp, 'household_registration', 'HH004', null, 'LOC_BUSIA_02', false, '2025-01-09 08:00:00'::timestamp, '2025-01-09 08:00:00'::timestamp),
        ('ACT_007', 'CHV002', '2025-01-10'::date, '2025-01-10 13:30:00'::timestamp, 'child_assessment', 'HH004', 'PAT004', 'LOC_BUSIA_02', false, '2025-01-11 08:00:00'::timestamp, '2025-01-11 08:00:00'::timestamp),
        ('ACT_008', 'CHV002', '2025-01-10'::date, '2025-01-10 14:00:00'::timestamp, 'child_assessment', 'HH005', 'PAT005', 'LOC_BUSIA_02', false, '2025-01-11 08:00:00'::timestamp, '2025-01-11 08:00:00'::timestamp),
        ('ACT_009', 'CHV002', '2025-01-27'::date, '2025-01-27 11:00:00'::timestamp, 'pregnancy_visit', 'HH006', 'PAT006', 'LOC_BUSIA_02', false, '2025-01-28 08:00:00'::timestamp, '2025-01-28 08:00:00'::timestamp),

        -- CHV003: Edge case - only activities after the 26th
        ('ACT_010', 'CHV003', '2025-01-26'::date, '2025-01-26 10:00:00'::timestamp, 'family_planning', 'HH007', 'PAT007', 'LOC_KISUMU_01', false, '2025-01-27 08:00:00'::timestamp, '2025-01-27 08:00:00'::timestamp),
        ('ACT_011', 'CHV003', '2025-01-31'::date, '2025-01-31 15:00:00'::timestamp, 'family_planning', 'HH007', 'PAT007', 'LOC_KISUMU_01', false, '2025-02-01 08:00:00'::timestamp, '2025-02-01 08:00:00'::timestamp),

        -- CHV with February activities
        ('ACT_015', 'CHV001', '2025-02-05'::date, '2025-02-05 10:00:00'::timestamp, 'pregnancy_visit', 'HH011', 'PAT011', 'LOC_BUSIA_01', false, '2025-02-06 08:00:00'::timestamp, '2025-02-06 08:00:00'::timestamp),
        ('ACT_016', 'CHV001', '2025-02-10'::date, '2025-02-10 14:00:00'::timestamp, 'child_assessment', 'HH012', 'PAT012', 'LOC_BUSIA_01', false, '2025-02-11 08:00:00'::timestamp, '2025-02-11 08:00:00'::timestamp),

        -- Year boundary edge case (December → January next year)
        ('ACT_017', 'CHV006', '2024-12-26'::date, '2024-12-26 10:00:00'::timestamp, 'pregnancy_visit', 'HH013', 'PAT013', 'LOC_VIHIGA_01', false, '2024-12-27 08:00:00'::timestamp, '2024-12-27 08:00:00'::timestamp),
        ('ACT_018', 'CHV006', '2024-12-31'::date, '2024-12-31 16:00:00'::timestamp, 'child_assessment', 'HH013', 'PAT014', 'LOC_VIHIGA_01', false, '2025-01-02 08:00:00'::timestamp, '2025-01-02 08:00:00'::timestamp)
    ) as t(
        activity_id, chv_id, activity_date, activity_timestamp, activity_type,
        household_id, patient_id, location_id, is_deleted, created_at, updated_at
    )
)

select
    activity_id,
    chv_id,
    activity_date,
    activity_timestamp,
    activity_type,
    household_id,
    patient_id,
    location_id,
    is_deleted,
    created_at,
    updated_at
from sample_data
-- Filter out invalid rows
where chv_id is not null
  and activity_date is not null
  and is_deleted = false
