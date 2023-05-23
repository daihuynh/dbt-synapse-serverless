{% macro synapseserverless__create_table_as(temporary, relation, sql) -%}
    {{ exceptions.raise_compiler_error(
        "creating tables is not supported in serverless pools"
        )
    }}
{% endmacro %}
