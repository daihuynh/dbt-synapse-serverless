{% macro synapseserverless__create_csv_table(model, agate_table) %}
  {%- set column_override = model['config'].get('column_types', {}) -%}
  {%- set quote_seed_column = model['config'].get('quote_columns', None) -%}
  {%- set location = model['config'].get('location', '') -%}
  {%- set data_source = model['config'].get('data_source', '') -%}
  {%- set file_format = model['config'].get('file_format', '') -%}

  {% set sql %}
    CREATE EXTERNAL TABLE {{ this.render() }}
    WITH (
        LOCATION = '{{ location }}',
        DATA_SOURCE = {{ data_source }},
        FILE_FORMAT = {{ file_format }}
    ) AS
  {% endset %}

  {% call statement('_') -%}
    {{ sql }}
  {%- endcall %}

  {{ return(sql) }}
{% endmacro %}

{% macro synapseserverless__load_csv_rows(model, agate_table) %}

  {% set batch_size = get_batch_size() %}

  {% set cols_sql = get_seed_column_quoted_csv(model, agate_table.column_names) %}
  {% set bindings = [] %}

  {% set statements = [] %}

  {% for chunk in agate_table.rows | batch(batch_size) %}
      {% set bindings = [] %}

      {% for row in chunk %}
          {% do bindings.extend(row) %}
      {% endfor %}

      {% set sql %}
          WITH CTE_CSVData AS (
            SELECT *
            FROM (
                VALUES
                {% for row in chunk -%}
                    ({%- for column in agate_table.column_names -%}
                        {{ get_binding_char() }}
                        {%- if not loop.last%},{%- endif %}
                    {%- endfor -%})
                    {%- if not loop.last%},{%- endif %}
                {%- endfor %}
            ) AS tbl({{ cols_sql }})
          )
          SELECT *
          FROM CTE_CSVData
      {% endset %}

      {% do adapter.add_query(sql, bindings=bindings, abridge_sql_log=True) %}

      {% if loop.index0 == 0 %}
          {% do statements.append(sql) %}
      {% endif %}
  {% endfor %}

  {# Return SQL so we can render it out into the compiled files #}
  {{ return(statements[0]) }}
{% endmacro %}


{% macro synapseserverless__get_csv_sql(create_or_truncate_sql, insert_sql) %}
    -- External table creation
    {{ create_or_truncate_sql }}
    -- As selecting data from the below sql
    {{ insert_sql }}
{% endmacro %}