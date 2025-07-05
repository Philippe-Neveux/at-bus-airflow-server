{{
  config(
    materialized='table',
    description='Dynamically consolidated stops data using direct table references'
  )
}}

-- This model dynamically discovers and consolidates all stops_{date} tables
-- without requiring a sources.yml file

{% set stops_tables_query %}
    SELECT table_name 
    FROM `{{ target.project }}.at_bus_bronze.INFORMATION_SCHEMA.TABLES`
    WHERE table_name LIKE 'stops_%'
    ORDER BY table_name
{% endset %}

{% set stops_tables_result = run_query(stops_tables_query) %}

{% if stops_tables_result %}
    {% set stops_tables = stops_tables_result.columns[0].values() %}
{% else %}
    {% set stops_tables = [] %}
{% endif %}

-- Dynamic union of all stops tables
{% if stops_tables %}
    {% for table_name in stops_tables %}
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
