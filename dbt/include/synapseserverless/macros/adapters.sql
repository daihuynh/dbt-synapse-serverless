{# TODO Actually Implement the rename index piece #}
{# TODO instead of deleting it...  #}
{% macro synapseserverless__rename_relation(from_relation, to_relation) -%}
    {{ exceptions.raise_compiler_error(
        "renaming relations is not supported in serverless pools"
        )
    }}
{% endmacro %}

{% macro synapseserverless__create_table_as(temporary, relation, sql) -%}
    {{ exceptions.raise_compiler_error(
        "creating tables is not supported in serverless pools"
        )
    }}
{% endmacro %}

{% macro synapseserverless__get_columns_in_relation(relation) -%}
  {% call statement('get_columns_in_relation', fetch_result=True) %}
    select
        column_name,
        data_type,
        character_maximum_length,
        numeric_precision,
        numeric_scale
    from INFORMATION_SCHEMA.COLUMNS
    where table_name = '{{ relation.identifier }}'
      and table_schema = '{{ relation.schema }}'
  {% endcall %}
  {% set table = load_result('get_columns_in_relation').table %}
  {{ return(sql_convert_columns_in_relation(table)) }}
{% endmacro %}
