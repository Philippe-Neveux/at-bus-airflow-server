{{
  config(
    materialized='table',
    description='Dynamically consolidated trips data using direct table references'
  )
}}

-- This model dynamically discovers and consolidates all trips_{stop_id}_{date} tables
-- without requiring a sources.yml file

{% set trips_tables_query %}
    SELECT table_name 
    FROM `{{ target.project }}.at_bus_bronze.INFORMATION_SCHEMA.TABLES`
    WHERE table_name LIKE 'trips_%'
    ORDER BY table_name
{% endset %}

{% set trips_tables_result = run_query(trips_tables_query) %}

{% if trips_tables_result %}
    {% set trips_tables = trips_tables_result.columns[0].values() %}
{% else %}
    {% set trips_tables = [] %}
{% endif %}

-- Dynamic union of all trips tables
{% if trips_tables %}
    {% for table_name in trips_tables %}
        {% if not loop.first %}UNION ALL{% endif %}
        SELECT 
            *,
            'at_bus_bronze.{{ table_name }}' as source_table,
            CURRENT_TIMESTAMP as consolidated_at
        FROM `{{ target.project }}.at_bus_bronze.{{ table_name }}`
    {% endfor %}
{% else %}
    -- Fallback: return empty result set if no tables found
    SELECT 
        NULL as source_table,
        CURRENT_TIMESTAMP as consolidated_at
    WHERE FALSE
{% endif %}
