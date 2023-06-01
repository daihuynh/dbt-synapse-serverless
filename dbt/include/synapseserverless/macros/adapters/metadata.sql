{# Turn off NOLOCK in dbt-sqlserver adapter #}
{% macro synapseserverless__information_schema_hints() %}{% endmacro %}
