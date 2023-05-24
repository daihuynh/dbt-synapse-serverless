{% macro synapseserverless__snapshot_hash_arguments(args) -%}
    CONVERT(VARCHAR(32), HashBytes('MD5', {% for arg in args %}
        coalesce(cast({{ arg }} as varchar(max)), '') {% if not loop.last %} + '|' + {% endif %}
    {% endfor %}), 2)
{%- endmacro %}

{% macro snapshot_timestamp_strategy(node, snapshotted_rel, current_rel, config, target_exists) %}
    {% set primary_key = config['unique_key'] %}
    {% set updated_at = config['updated_at'] %}
    {% set invalidate_hard_deletes = config.get('invalidate_hard_deletes', false) %}

    {# No row changed logics here for 1 time snapshot
        since the destined materialization is external table.
        Due to the limitation of Synapse Serverless, dropping 
        external table doesn't remove corresponding file location. 
        Re-creation without removing the underlying file will 
        throw error.
     #}
    {% set scd_id_expr = snapshot_hash_arguments([primary_key, updated_at]) %}

    {% do return({
        "unique_key": primary_key,
        "updated_at": updated_at,
        "scd_id": scd_id_expr,
        "invalidate_hard_deletes": invalidate_hard_deletes
    }) %}
{% endmacro %}

{% macro snapshot_check_strategy(node, snapshotted_rel, current_rel, config, target_exists) %}
    {% set check_cols_config = config['check_cols'] %}
    {% set primary_key = config['unique_key'] %}
    {% set invalidate_hard_deletes = config.get('invalidate_hard_deletes', false) %}
    {% set updated_at = config.get('updated_at', snapshot_get_time()) %}

    {% set column_added = false %}

    {% set column_added, check_cols = snapshot_check_all_get_existing_columns(node, false, check_cols_config) %}
    
    {# No row changed logics here for 1 time snapshot
        since the destined materialization is external table.
        Due to the limitation of Synapse Serverless, dropping 
        external table doesn't remove corresponding file location. 
        Re-creation without removing the underlying file will 
        throw error.
     #}
    {% set scd_id_expr = snapshot_hash_arguments([primary_key] + check_cols + [updated_at]) %}

    {% do return({
        "unique_key": primary_key,
        "updated_at": updated_at,
        "scd_id": scd_id_expr,
        "invalidate_hard_deletes": invalidate_hard_deletes
    }) %}
{% endmacro %}