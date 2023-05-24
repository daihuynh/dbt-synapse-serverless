{% macro synapseserverless__build_snapshot_table(strategy, sql) %}
    WITH CTE_Source AS (
        {{ sql }}
    )
    SELECT *,
        {{ strategy.scd_id }} as dbt_scd_id,
        {{ strategy.updated_at }} as dbt_updated_at,
        {{ strategy.updated_at }} as dbt_valid_from,
        LEAD({{ strategy.updated_at }}, 1) OVER (PARTITION BY {{ strategy.scd_id }} ORDER BY {{ strategy.updated_at }}) as dbt_valid_to
    FROM CTE_Source

{% endmacro %}
