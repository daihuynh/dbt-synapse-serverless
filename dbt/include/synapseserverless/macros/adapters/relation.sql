# This doesn't work with table and Synapse Serverless doesn't support tabl as well
# Implementation take from the conversation at: 
# https://github.com/dbt-msft/dbt-synapse-serverless/issues/4
{% macro synapseserverless__rename_relation(from_relation, to_relation) -%}
  {% call statement('rename_relation') -%}
    DECLARE @to_definition nvarchar(max);
    SET @to_definition = replace(object_definition (object_id ('{{ from_relation.include(database=False) }}')), '{{ from_relation.include(database=False) }}', '{{ to_relation.include(database=False) }}');
    EXEC('DROP VIEW {{ from_relation.include(database=False) }}')
    EXEC('DROP VIEW IF EXISTS {{ to_relation.include(database=False) }}')
    EXEC(@to_definition)
  {%- endcall %}
{% endmacro %}


{% macro synapseserverless__drop_relation(relation) -%}
    {% call statement('drop_relation', auto_begin=False) -%}
      {{ synapseserverless__drop_relation_script(relation) }}
    {%- endcall %}
{% endmacro %}

{% macro synapseserverless__drop_relation_script(relation) -%}
  {% if relation.type == 'view' -%}
    {% set object_id_type = 'V' %}
    {% set relation_type = 'view' %}
  {% elif relation.type == 'table'%}
    {% set object_id_type = 'U' %}
    {% set relation_type = 'table' %}
  {% elif relation.type == 'external'%}
    {% set object_id_type = 'U' %}
    {% set relation_type = 'external table' %}
  {%- else -%} invalid target name
  {% endif %}
  if object_id ('{{ relation.include(database=False) }}','{{ object_id_type }}') is not null
    begin
    drop {{ relation_type }} {{ relation.include(database=False) }}
    end
{% endmacro %}
