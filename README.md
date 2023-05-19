# dbt-synapse-serverless

custom [dbt](https://www.getdbt.com) adapter for [Azure Synapse](https://azure.microsoft.com/en-us/services/synapse-analytics/) serverless pools. This adapter largely inherits from dbt-synapse, which itself inherits from dbt-sqlserver. For more info, see those repos.

## major differences b/w `dbt-synapse-serverless` and `dbt-synapse`
In serverless pools, you can't:
- make tables (except external)
- rename relations
- use three part names (only `schema.relation`)
## status & support

```
this adapter is an experiment, here be dragons! I really don't even recommend you use dbt with serverless
```

I have put some simple hacks in this forked version that supports:

1. Re-use "get_columns_in_relation" from dbt-synapse apdater without the temp table hack because Synapse Serverless technically doesn't support table creation. It means this version can work with dbt-utils, e.g. "star" macro.
2. Add "External Table" materialization. Please use "external" as materialization for this purpose. However, re-creation cannot be done in DBT. You will need to buidl a pipeline to remove physical folder in connected Data Lake.
3. Re-use "test" materialization from dbt-sqlserver adapter. Testing SQL code will be materialized into a view instead of a temp table.

## Installation & Setup

This is not published to PyPI. for now, install the original version from Github with:

```sh
pip install git+https://github.com/dbt-msft/dbt-synapse-serverless.git
```

To install this forked version:
```sh
pip install git+https://github.com/daihuynh/dbt-synapse-serverless.git
```

### Caveats
1. You can't use the default or master database on a "built-in" serverless pool, because somehow they enmeshed with the spark pool. You must go to the master db and make a new db first. That is what you will use for the dbt project.
2. dbt won't stop  you from trying to make tables, but it's not going to work. I would welcome PRs if people wanna make that experience better
3. I don't expect this to be supported for much longer as changes to dbt-core will require tables to make things like tests work.


## Authentication

Please see the [Authentication section of dbt-sqlserver's README.md](https://github.com/dbt-msft/dbt-sqlserver#authentication).

The only difference is to provide the adapter type as `synapseserverless` so for example:

```yml
jaffle_shop:
  target: serverless
  outputs:
    serverless:
      type: synapseserverless
      driver: "ODBC Driver 17 for SQL Server"
      schema: dbo
      host: <serverlessendpoint>
      database: <serverlessdb>
      authentication: CLI
```

