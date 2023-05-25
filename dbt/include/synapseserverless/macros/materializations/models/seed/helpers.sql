{% macro synapseserverless__load_csv_rows(model, agate_table) %}

  {% set cols_sql = get_seed_column_quoted_csv(model, agate_table.column_names) %}

  {% set sql %}
      WITH CTE_CSVData AS (
        SELECT *
        FROM (
            VALUES
            {% for row in agate_table.rows -%}
              ({%- for value in row -%}
                '{{ value | string }}'
                {%- if not loop.last%},{%- endif %}
                {%- endfor %}
              )
              {%- if not loop.last%},{%- endif %}
            {%- endfor %}
        ) AS tbl({{ cols_sql }})
      )
      SELECT *
      FROM CTE_CSVData
  {% endset %}

  {{ return(sql) }}
{% endmacro %}