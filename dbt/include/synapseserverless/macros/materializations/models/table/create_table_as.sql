{% macro synapseserverless__create_table_as(temporary, relation, sql) -%}
    {{ exceptions.CompilationError(
        "creating tables is not supported in serverless pools"
        )
    }}
{% endmacro %}
