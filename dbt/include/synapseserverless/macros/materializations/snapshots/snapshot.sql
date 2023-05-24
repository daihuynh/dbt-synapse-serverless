{% materialization snapshot, adapter='synapseserverless' %}
  {%- set config = model['config'] -%}

  {%- set target_table = model.get('alias', model.get('name')) -%}

  {%- set strategy_name = config.get('strategy') -%}
  {%- set unique_key = config.get('unique_key') %}
  -- grab current tables grants config for comparision later on
  {%- set grant_config = config.get('grants') -%}

  {%- set target_relation = api.Relation.create(
                              identifier=target_table,
                              schema=config.get('target_schema'),
                              database=config.get('target_database'),
                              type='external') -%}

  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  {% set strategy_macro = strategy_dispatch(strategy_name) %}
  {% set strategy = strategy_macro(model, "snapshotted_data", "source_data", config, False) %}

  -- Cannot re-create external table in Synapse. Must have it done in Synapse, e.g. Synapse Pipelines
  {% set build_sql = build_snapshot_table(strategy, model['compiled_code']) %}
  
  {%- call statement('main') -%}
      {{ get_create_external_table_as(target_relation, build_sql) }}
  {% endcall %}

  {% do persist_docs(target_relation, model) %}

  {{ run_hooks(post_hooks, inside_transaction=True) }}

  {{ adapter.commit() }}

  {{ run_hooks(post_hooks, inside_transaction=False) }}

  {{ return({'relations': [target_relation]}) }}

{% endmaterialization %}