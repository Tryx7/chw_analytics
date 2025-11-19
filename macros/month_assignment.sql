{% macro month_assignment(date_column) %}
{#
Macro: month_assignment
Description: Assigns activities to the correct reporting month based on the 26th cutoff rule

Business Rule:
- If activity_date is on or after the 26th of the month → assign to NEXT month
- If activity_date is before the 26th → assign to CURRENT month

Examples:
- 2025-01-15 → 2025-01-01 (January)
- 2025-01-26 → 2025-02-01 (February - on/after 26th)
- 2025-01-31 → 2025-02-01 (February)
- 2025-12-26 → 2026-01-01 (January of next year)

Parameters:
- date_column: The name of the date column to process (e.g., 'activity_date')

Returns:
- DATE: The first day of the assigned reporting month (YYYY-MM-01 format)

Usage:
    {{ month_assignment('activity_date') }}
#}

    case
        -- If day is 26 or later, shift to next month and truncate to first day
        when extract(day from {{ date_column }}) >= 26 then
            date_trunc('month', {{ date_column }} + interval '1 month')
        -- Otherwise, truncate to first day of current month
        else
            date_trunc('month', {{ date_column }})
    end

{% endmacro %}