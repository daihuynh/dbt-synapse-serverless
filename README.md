# dbt-synapse-serverless

custom [dbt](https://www.getdbt.com) adapter for [Azure Synapse](https://azure.microsoft.com/en-us/services/synapse-analytics/) serverless pools. This adapter largely inherits from dbt-synapse, which itself inherits from dbt-sqlserver. For more info, see those repos.

## major differences b/w `dbt-synapse-serverless` and `dbt-synapse`
In serverless pools, you can't:
- make tables (except external).
- rename table relations but views.
- use three part names (only `schema.relation`).
## Status & Support

```
this adapter is an experiment, here be dragons! I really don't even recommend you use dbt with serverless
```

In this fork, I have collected all ideas and fixes in the orignal adapter's WIKI and PRs, and re-implemented dbt-core's features utilising CETAS (Create External Table As Select) in Synapse Serverless:

1. **External Table** as a materialization type. Please use 'external' in config.
2. **Snapshot** is re-implemented as a one-off snapshot materialized as an external table using CETAS.
3. **Seed** is re-implemented as a one-off external table creation using CETAS.
4. **Test** is now available. Temporary results from testing code is stored in a view instead of table.

## Limitation

External tables cannot be re-created without removing associated folder/files at the specified location in creation. My suggestion is to create a Pipeline in Synapse to drop an external table and its associated folder/files all at once.
For snapshots and seed external tables, you can create seperate folders, e.g. MySnapshot, in Azure Data Lake, then build a Synapse Pipeline to cleanup folder. After cleaning up, the pipeline triggers another pipeline in DevOps to re-create snapshots and seeds using ```dbt seed``` and ```dbt snapshot```.

## Installation & Setup

This is not published to PyPI. 

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

