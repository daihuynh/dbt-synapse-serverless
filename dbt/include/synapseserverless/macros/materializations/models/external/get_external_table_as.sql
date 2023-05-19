{% macro get_create_external_table_as(relation, sql) %}
    {{ adapter.dispatch('get_create_external_table_as', 'dbt')(relation, sql) }}
{% endmacro %}

{% macro synapseserverless__get_create_external_table_as(relation, sql) %}
    {%- set location = config.get('location', default='') -%}
    {%- set data_source = config.get('data_source', default='') -%}
    {%- set file_format = config.get('file_format', default='') -%}
    {% set tmp_relation = relation.incorporate(path={"identifier": relation.identifier.replace("#", "") ~ '_temp_view'},
                                                type='view')-%}
    -- Drop temp view
    {{ synapseserverless__drop_relation_script(tmp_relation) }}

    -- Drop old external table
    {{ synapseserverless__drop_relation_script(relation) }}

    -- Create temp view
    EXEC('create view {{ tmp_relation.include(database=False) }} as
            {{ sql }}
    ');

    CREATE EXTERNAL TABLE {{ relation.include(database=False) }}
    WITH (
        LOCATION = '{{ location }}',
        DATA_SOURCE = {{ data_source }},
        FILE_FORMAT = {{ file_format }}
    ) AS (
        SELECT *
        FROM {{ tmp_relation.include(database=False) }}
    )

    -- Drop temp view
    {{ synapseserverless__drop_relation_script(tmp_relation) }}
   
{% endmacro%}
