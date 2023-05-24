{% macro synapseserverless__build_snapshot_table(strategy, sql) %}
    {%- set columns = get_columns_in_query(sql) -%}
    {%- do columns.remove(strategy.updated_at) -%}
    
    WITH CTE_Source AS (
        {{ sql }}
    ), CTE_Staging AS (
        SELECT *
            , {{ strategy.scd_id }} as dbt_scd_id
            , {{ strategy.updated_at }} AS [dbt_valid_from]
            , IIF({{ strategy.scd_id }} = LEAD({{ strategy.scd_id }}, 1) OVER (PARTITION BY {{ strategy.unique_key }} ORDER BY {{ strategy.updated_at }}), NULL, LEAD({{ strategy.updated_at }}, 1) OVER (PARTITION BY {{ strategy.unique_key }} ORDER BY {{ strategy.updated_at }})) AS [dbt_valid_to]
            , IsLast = IIF({{ strategy.updated_at }} = MAX({{ strategy.updated_at }}) OVER (PARTITION BY {{ strategy.unique_key }}), 1, 0)
        FROM CTE_Source
    )
    SELECT 
        {% for column in columns -%}
            {{column}} {% if not loop.last%},{% endif %} 
        {%- endfor -%}
        , IIF(dbt_valid_from = MIN(dbt_valid_from) OVER (PARTITION BY {{ strategy.unique_key }} ORDER BY dbt_valid_from), dbt_valid_from, LAG(dbt_valid_to) OVER (PARTITION BY {{ strategy.unique_key }} ORDER BY dbt_valid_from)) AS dbt_updated_at
        , IIF(dbt_valid_from = MIN(dbt_valid_from) OVER (PARTITION BY {{ strategy.unique_key }} ORDER BY dbt_valid_from), dbt_valid_from, LAG(dbt_valid_to) OVER (PARTITION BY {{ strategy.unique_key }} ORDER BY dbt_valid_from)) AS dbt_valid_from
        , dbt_valid_to
    FROM CTE_Staging
    WHERE dbt_valid_to IS NOT NULL OR IsLast = 1
{% endmacro %}
