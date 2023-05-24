{% materialization external, default %}
    
    {%- set identifier = model['alias'] -%}

    {%- set target_relation = api.Relation.create(identifier=identifier,
                                             schema=schema,
                                             database=database,
                                             type='external') -%}

    {{ drop_relation_if_exists(target_relation) }}

    # prehook
    {{ run_hooks(pre_hooks, inside_transaction=False) }}

    -- `BEGIN` happens here:
    {{ run_hooks(pre_hooks, inside_transaction=True) }}

    {%- call statement('main') -%}
        {{ get_create_external_table_as(target_relation, sql) }}
    {% endcall %}

    {{ run_hooks(post_hooks, inside_transaction=True) }}

    # commit
    {{ adapter.commit() }}

    # posthook
    {{ run_hooks(post_hooks, inside_transaction=False) }}

    {{ return({'relations': [target_relation]}) }}
{% endmaterialization %}
