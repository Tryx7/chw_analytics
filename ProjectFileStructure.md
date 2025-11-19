# Complete Project File Structure

Create the following directory structure for your dbt project:

```
chw_analytics/
│
├── dbt_project.yml                    # Main project configuration
├── packages.yml                        # Package dependencies (dbt_utils)
├── README.md                          # Project documentation
├── .gitignore                         # Git ignore file
│
├── macros/
│   └── month_assignment.sql           # Month assignment macro (26th cutoff)
│
├── models/
│   │
│   ├── marts/                         # Business logic layer
│   │   ├── fct_chv_activity.sql      # Fact table with sample data
│   │   └── schema.yml                 # Source documentation (optional)
│   │
│   └── metrics/                       # Aggregated metrics layer
│       ├── chw_activity_monthly.sql  # Main aggregation model
│       └── schema.yml                 # Tests and documentation
│
├── tests/                             # Custom tests (optional)
│   └── .gitkeep
│
├── analyses/                          # Ad-hoc queries (optional)
│   └── .gitkeep
│
├── seeds/                             # CSV seed files (optional)
│   └── .gitkeep
│
└── target/                            # Compiled SQL (git ignored)
    └── .gitkeep
```

## Files to Create

### 1. Root Level Files

**dbt_project.yml** - Already provided in artifacts
**packages.yml** - Already provided in artifacts
**README.md** - Already provided in artifacts

### 2. .gitignore

Create `.gitignore` with:

```
# dbt
target/
dbt_packages/
logs/
dbt_modules/

# Python
*.pyc
__pycache__/
.pytest_cache/
.venv/
venv/
.env

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo
```

### 3. Macros

**macros/month_assignment.sql** - Already provided in artifacts

### 4. Models

**models/marts/fct_chv_activity.sql** - Already provided in artifacts
**models/metrics/chw_activity_monthly.sql** - Already provided in artifacts
**models/metrics/schema.yml** - Already provided in artifacts

### 5. Configuration File (in your home directory)

**~/.dbt/profiles.yml** - Template provided as "profiles.yml (example)"

## Quick Setup Commands

```bash
# 1. Create project directory
mkdir -p chw_analytics
cd chw_analytics

# 2. Create subdirectories
mkdir -p macros models/marts models/metrics tests analyses seeds

# 3. Create empty .gitkeep files
touch tests/.gitkeep analyses/.gitkeep seeds/.gitkeep

# 4. Copy the artifacts into their respective files
# (Use the artifacts provided above)

# 5. Initialize git (optional)
git init
# Create .gitignore file (content above)

# 6. Install dbt
pip install dbt-postgres

# 7. Install packages
dbt deps

# 8. Configure database connection
# Edit ~/.dbt/profiles.yml with your credentials

# 9. Test connection
dbt debug

# 10. Run the project
dbt run
dbt test
```

## Verification Checklist

After setting up, verify you have:

- [ ] `dbt_project.yml` in root
- [ ] `packages.yml` in root
- [ ] `README.md` in root
- [ ] `.gitignore` in root
- [ ] `macros/month_assignment.sql`
- [ ] `models/marts/fct_chv_activity.sql`
- [ ] `models/metrics/chw_activity_monthly.sql`
- [ ] `models/metrics/schema.yml`
- [ ] `~/.dbt/profiles.yml` configured with your database credentials

## Running the Project

```bash
# Install dependencies
dbt deps

# Run all models
dbt run

# Run specific model
dbt run --select chw_activity_monthly

# Run tests
dbt test

# Run specific model tests
dbt test --select chw_activity_monthly

# Generate and serve documentation
dbt docs generate
dbt docs serve
```

## Expected Results

After running `dbt run`, you should see:

```
Completed successfully
Done. PASS=2 WARN=0 ERROR=0 SKIP=0 TOTAL=2
```

After running `dbt test`, you should see all tests passing:

```
Completed successfully
Done. PASS=13 WARN=0 ERROR=0 SKIP=0 TOTAL=13
```

Your `chw_activity_monthly` table should have **6 rows** matching the expected output in the README.