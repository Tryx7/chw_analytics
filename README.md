# CHW Analytics - Monthly Activity Aggregation

## Project Overview

This dbt project implements a monthly aggregation model for Community Health Worker (CHW) activities. The model calculates key performance metrics used in dashboards to track CHW productivity and identify high/low performers.

## Assignment Solution

This project fulfills Week 15's final assignment requirements by implementing:

1. **Monthly CHW Activity Aggregation Model** (`chw_activity_monthly.sql`)
2. **Month Assignment Macro** (`month_assignment.sql`)
3. **Comprehensive Testing & Documentation** (`schema.yml`)

### Key Business Rule Implemented

The model implements a special **26th cutoff rule** for month assignment:
- Activities **before the 26th** → assigned to **current month**
- Activities **on/after the 26th** → assigned to **next month**

This handles field data collection that often continues into the first days of the next month.

## Project Structure

```
chw_analytics/
├── dbt_project.yml           # Project configuration
├── packages.yml              # dbt package dependencies
├── profiles.yml.example      # Database connection template
│
├── macros/
│   └── month_assignment.sql  # Custom macro for month assignment logic
│
├── models/
│   ├── marts/
│   │   └── fct_chv_activity.sql      # Source fact table (sample data)
│   │
│   └── metrics/
│       ├── chw_activity_monthly.sql  # Main aggregation model
│       └── schema.yml                 # Tests and documentation
│
└── README.md                 # This file
```

## Setup Instructions

### 1. Prerequisites

- Python 3.8+
- PostgreSQL (or other supported database)
- dbt-core or dbt-postgres

### 2. Installation

```bash
# Clone or create the project directory
mkdir chw_analytics
cd chw_analytics

# Create Environment
python3 -m venv cap-dbt-env

# Install dbt
pip install dbt-postgres

# Install dbt packages
dbt deps
```

### 3. Configure Database Connection

Create `~/.dbt/profiles.yml` with your database credentials:

```yaml
chw_analytics:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5432
      user: your_username
      password: your_password
      database: chw_analytics
      schema: dev
      threads: 4
```

### 4. Run the Project

```bash
# Test connection
dbt debug

# Install dependencies
dbt deps

# Run models
dbt run

# Run tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

## Model Details

### `chw_activity_monthly`

**Purpose**: Aggregates CHW activities by CHW and month for dashboard reporting.

**Grain**: One row per CHW per month

**Primary Key**: `(chv_id, report_month)`

**Metrics Calculated**:
1. `total_activities` - Total count of all activities
2. `unique_households_visited` - Distinct households visited
3. `unique_patients_served` - Distinct patients served (NULLs excluded)
4. `pregnancy_visits` - Count of pregnancy visit activities
5. `child_assessments` - Count of child assessment activities
6. `family_planning_visits` - Count of family planning activities

**Configuration**:
- Materialization: Incremental table
- Incremental Strategy: `delete+insert`
- Unique Key: `['chv_id', 'report_month']`
- Handles late-arriving data (lookback: 2 months)

### Expected Output

Based on the sample data, the model produces:

| chv_id | report_month | total_activities | unique_households_visited | unique_patients_served | pregnancy_visits | child_assessments | family_planning_visits |
|--------|--------------|------------------|---------------------------|------------------------|------------------|-------------------|------------------------|
| CHV001 | 2025-01-01   | 4                | 2                         | 2                      | 3                | 1                 | 0                      |
| CHV001 | 2025-02-01   | 3                | 3                         | 3                      | 1                | 1                 | 1                      |
| CHV002 | 2025-01-01   | 3                | 2                         | 2                      | 0                | 2                 | 0                      |
| CHV002 | 2025-02-01   | 1                | 1                         | 1                      | 1                | 0                 | 0                      |
| CHV003 | 2025-02-01   | 2                | 1                         | 1                      | 0                | 0                 | 2                      |
| CHV006 | 2025-01-01   | 2                | 1                         | 2                      | 1                | 1                 | 0                      |

## Testing

The project includes comprehensive tests in `schema.yml`:

### Column-Level Tests
- `not_null` tests on all key columns
- `relationships` test to validate CHW IDs exist in dimension table
- Expression tests to ensure metrics are non-negative
- Logical validation tests (e.g., unique_households ≤ total_activities)

### Model-Level Tests
- Unique combination test on `(chv_id, report_month)`
- Business rule validation (sum of activity types ≤ total activities)
- Data quality checks

Run tests with:
```bash
dbt test
dbt test --select chw_activity_monthly
```

## Key Implementation Details

### Month Assignment Logic

The `month_assignment` macro handles the 26th cutoff:

```sql
case
    when extract(day from activity_date) >= 26 then
        date_trunc('month', activity_date + interval '1 month')
    else
        date_trunc('month', activity_date)
end
```

### Incremental Strategy

The model uses `delete+insert` to:
- Handle late-arriving data
- Allow reprocessing of historical months
- Maintain data accuracy with updates

### Data Quality Filters

The model excludes:
- Records with `chv_id IS NULL`
- Records with `activity_date IS NULL`
- Records with `is_deleted = TRUE`

## Performance Considerations

- **Incremental materialization** reduces processing time
- **Indexed columns** in source table: `chv_id`, `activity_date`, `created_at`
- **Lookback window** of 2 months balances freshness and performance
- **Aggregation** reduces dashboard query load

## Business Context

Community Health Workers (CHWs) provide critical healthcare services in communities:
- Pregnancy/antenatal care visits
- Child health assessments (under-5)
- Family planning services
- Household registrations

This model enables:
- Performance tracking and monitoring
- Identification of high/low performers
- Resource allocation decisions
- Program effectiveness evaluation

## Assignment Checklist

✅ **dbt Model**: Complete with incremental configuration
✅ **Macro**: Implements 26th cutoff rule
✅ **Tests**: 10+ tests covering data quality
✅ **Documentation**: Comprehensive column and model descriptions
✅ **Expected Output**: Matches requirements
✅ **Business Rules**: All implemented correctly

## Author

**LuxDevHQ Analytics Team**  
Week 15 Final Assignment - dbt Monthly Aggregation

## Questions or Issues?

For questions about this implementation:
1. Review the business requirements in `/docs`
2. Check the schema documentation
3. Run `dbt docs serve` for interactive documentation
4. Contact the analytics team

---

**Note**: This is a demonstration project for educational purposes. In production, replace sample data with actual source connections.
