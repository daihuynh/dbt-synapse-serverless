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
