select count(*) as application_rows
from bank_loan_applications;

select count(*) as stage_rows
from bank_loan_stage_history;

-- Check unique application IDs
select count(*) as total_rows,
count(distinct loan_id) as unique_rows 
from bank_loan_applications;

--  Check for missing values
select 
sum(case when loan_id is NULL 
		  then 1 else 0 end) as missing_loan_ids,
sum(case when application_received_time is null
		 then 1 else 0 end) as missing_recived_time
from bank_loan_applications ;


--  Check stage coverage
select 
stage_name,
count(*) as records,
count(distinct loan_id) as unique_loans
from bank_loan_stage_history
group by stage_name
order by stage_name;

-- Calculate baseline performance
-- First, calculate overall processing time from the application table.
SELECT
    COUNT(*) AS total_applications,
    ROUND(AVG(total_elapsed_hours), 2)
        AS avg_processing_hours,
    ROUND(MIN(total_elapsed_hours), 2)
        AS min_processing_hours,
    ROUND(MAX(total_elapsed_hours), 2)
        AS max_processing_hours,
    ROUND(AVG(total_active_work_hours), 2)
        AS avg_active_work_hours,
    ROUND(AVG(total_rework_count), 2)
        AS avg_rework_events
FROM bank_loan_applications;


select * from bank_loan_applications;

select
loan_product,
Count(*) as total_application,
round(avg(total_elapsed_hours), 2) as avg_processing_hrs,
round(avg(total_active_work_hours), 2) as avg_active_work_hrs,
round(avg(total_rework_count), 2) as avg_rework_events
from bank_loan_applications
group by loan_product
order by avg_processing_hrs DESC;

-- Find the slowest stage
-- Use the stage-history table to calculate stage-level metrics.
select 
stage_name,
count(*) as stage_records,
round(avg(elapsed_hours), 2) as avg_elapsed_hours,
round(sum(elapsed_hours), 2) as total_elapsed_hours,
round(avg(active_work_hours), 2) as avg_active_work_hrs,
SUM(rework_count) AS total_rework_events,
    ROUND(SUM(stage_cost_inr), 2)
        AS total_labor_cost_inr
from bank_loan_stage_history
group by stage_name
order by avg_elapsed_hours DESC;

-- Identify the root cause
-- A slow stage is a symptom. Your job is to explain why it is slow.
SELECT
    stage_name,
    complexity,
    COUNT(*) AS application_count,
    ROUND(AVG(elapsed_hours), 2)
        AS avg_elapsed_hours,
    ROUND(AVG(active_work_hours), 2)
        AS avg_active_hours,
    ROUND(AVG(rework_count * 1.0), 3)
        AS avg_rework_events,
    ROUND(AVG(stage_cost_inr), 2)
        AS avg_stage_cost_inr
FROM bank_loan_stage_history
GROUP BY stage_name, complexity
ORDER BY stage_name, avg_elapsed_hours DESC;

-- Quantify cost and the 20% opportunity
-- Calculate stage-level labor cost
SELECT
    stage_name,
    COUNT(DISTINCT loan_id) AS applications,
    ROUND(SUM(active_work_hours), 2)
        AS total_active_hours,
    ROUND(SUM(stage_cost_inr), 2)
        AS total_labor_cost_inr,
    ROUND(
        SUM(stage_cost_inr) /
        NULLIF(COUNT(DISTINCT loan_id), 0),
        2
    ) AS cost_per_application_inr
FROM bank_loan_stage_history
GROUP BY stage_name
ORDER BY total_labor_cost_inr DESC;

SELECT
    ROUND(AVG(elapsed_hours), 2)
        AS baseline_hours,
    ROUND(AVG(elapsed_hours) * 0.20, 2)
        AS hours_to_save,
    ROUND(AVG(elapsed_hours) * 0.80, 2)
        AS target_hours
FROM bank_loan_stage_history;


