# pg_create_subscriber

Initialize a new logical subscriber from a physical replica or base backup. This tool is based on [pglogical_create_subscriber](https://github.com/2ndQuadrant/pglogical/blob/REL2_x_STABLE/pglogical_create_subscriber.c) but adapted to use the builtin [Logical Replication](https://www.postgresql.org/docs/current/logical-replication.html) insted of the [pglogical](https://github.com/2ndQuadrant/pglogical) extension.

## Supported PostgreSQL versions

The aim of the project is support as many community-supported major versions of Postgres as possible. Currently, the following versions of PostgreSQL are supported:

10, 11, 12 and 13.

## Installation from source code

Source code installs are the same as for any other PostgreSQL extension built using PGXS.

Make sure the directory containing `pg_config` from the PostgreSQL release is
listed in your `PATH` environment variable. You might have to install a `-dev`
or `-devel` package for your PostgreSQL release from your package manager if
you don't have `pg_config`.

Then run `make` to compile, and `make install` to
install. You might need to use `sudo` for the install step.

e.g. for a typical Fedora or RHEL 7 install, assuming you're using the
[yum.postgresql.org](http://yum.postgresql.org) packages for PostgreSQL:

```sh
$ sudo dnf install postgresql13-devel
$ git clone https://github.com/fabriziomello/pg_create_subscriber.git
$ cd pg_create_subscriber
$ PATH=/usr/pgsql-13/bin:$PATH
$ USE_PGXS=1 make
$ USE_PGXS=1 make install
```

## Usage

```
$ pg_create_subscriber --help
pg_create_subscriber create new logical subscriber from basebackup of provider.

Usage:
  pg_create_subscriber [OPTION]...

General options:
  -D, --pgdata=DIRECTORY            data directory to be used for new node,
                                    can be either empty/non-existing directory,
                                    or directory populated using
                                    pg_basebackup -X stream command
  --databases                       optional list of databases to replicate
  -n, --subscriber-name=NAME        name of the newly created subscrber
  --subscriber-dsn=CONNSTR          connection string to the newly created subscriber
  --provider-dsn=CONNSTR            connection string to the provider
  --publication-names=PUBLICATIONS  comma separated list of publication names
  --drop-slot-if-exists             drop replication slot of conflicting name
  -s, --stop                        stop the server once the initialization is done
  -v                                increase logging verbosity
  --extra-basebackup-args           additional arguments to pass to pg_basebackup.
                                    Safe options: -T, -c, --xlogdir/--waldir

Configuration files override:
  --hba-conf              path to the new pg_hba.conf
  --postgresql-conf       path to the new postgresql.conf
  --recovery-conf         path to the template recovery configuration
```

## Example

Before start you should setup two PostgreSQL nodes using [Streaming Replication](https://www.postgresql.org/docs/current/warm-standby.html#STREAMING-REPLICATION). One node will be the `master.node` and another `replica.node`.


### 1. Create publication on `master.node`

```sql
CREATE PUBLICATION pub_test FOR ALL TABLES;
```

### 2. Stop the `replica.node`

```sh
systemctl stop postgresql-13
```

### 3. Execute `pg_create_subscriber` over the stopped `replica.node`

```sh
pg_create_subscriber --pgdata=/var/lib/pgsql/13/data --stop -v \
  --databases=fabrizio --subscriber-name=sub_test --publication-names='pub_test' \
  --subscriber-dsn='host=replica.node user=postgres port=5432' \
  --provider-dsn='host=master.node user=postgres port=5432'
```

### 4. Start the new `replica` node

```sh
systemctl start postgresql-13
```

Please feel free to [open a PR](https://github.com/fabriziomello/pg_create_subscriber/pull/new/master).

## Authors

- [Fabrízio de Royes Mello](mailto:fabriziomello@gmail.com)

## Funding

All this work was only possible with the funding and support of [OnGres](https://www.ongres.com).

## Credits

Thanks to all my [OnGres colleagues](https://www.ongres.com/about-us/#ourteam) for support and testing.

Thanks to my friend [Martín Marqués](https://github.com/martinmarques) for the awesome webinar [Highway to Zero Downtime PostgreSQL Upgrades](https://www.2ndquadrant.com/en/blog/webinar-highway-to-zero-downtime-postgresql-upgrades-follow-up) that gave me the ideas to finish this tool.

## License

PostgreSQL server source code, used under the [PostgreSQL license](https://www.postgresql.org/about/licence/).<br>
Portions Copyright (c) 1996-2021, The PostgreSQL Global Development Group<br>
Portions Copyright (c) 1994, The Regents of the University of California

All other parts are licensed under the 3-clause BSD license, see LICENSE file for details.<br>
Copyright (c) 2021, Fabrízio de Royes Mello <fabriziomello@gmail.com>
