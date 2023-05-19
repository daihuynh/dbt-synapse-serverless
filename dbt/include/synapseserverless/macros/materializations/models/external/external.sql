{% materialization external, default %}
    
    {%- set identifier = model['alias'] -%}

    {%- set target_relation = api.Relation.create(identifier=identifier,
                                             schema=schema,
                                             database=database,
                                             type='external') -%}

    # prehook
    {{ run_hooks(pre_hooks, inside_transaction=False) }}

    {%- call statement('main') -%}
        {{ get_create_external_table_as(target_relation, sql) }}
    {% endcall %}

    # commit
    {{ adapter.commit() }}

    # posthook
    {{ run_hooks(post_hooks, inside_transaction=False) }}

    {{ return({'relations': [target_relation]}) }}
{% endmaterialization %}
