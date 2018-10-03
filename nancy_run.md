COMMAND
==
  run

DESCRIPTION
===
  Use 'nancy run' to perform a single run for a database experiment.

  A DB experiment consists of one or more 'runs'. For example, if Nancy is being
  used to verify  that a new index  will affect  performance only in a positive
  way, two runs are needed. If one needs to only  collect query plans for each
  query group, a single run is enough. And finally, if there is  a goal to find
  an optimal value for some PostgreSQL setting, multiple runs will be needed to
  check how various values of the specified setting affect performance of the
  specified database and workload.

  An experimental run needs the following 4 items to be provided as an input:
    - environment: hardware or cloud instance type, PostgreSQL version, etc;
    - database: copy or clone of the database;
    - workload: 'real' workload or custom SQL;
    - (optional) delta (a.k.a. target): some DB change to be evaluated:
      * PostgreSQL config changes, or
      * some DDL (or arbitrary SQL) such as 'CREATE INDEX ...', or
      * theoretically, anything else.

OPTIONS
===
  NOTICE: A value for a string option that starts with 'file://' is treated as
          a path to a local file. A string value starting with 's3://' is
          treated as a path to remote file located in S3 (AWS S3 or analog).
          Otherwise, a string values is considered as 'content', not a link to
          a file.

  <b>--debug</b> (boolean)

  Turn on debug logging. This significantly increases the level of verbosity
  of messages being sent to STDOUT.

  <b>--keep-alive</b> (integer)

  How many seconds the entity (Docker container, Docker machine) will remain
  alive after the main activity of the run is finished. Useful for
  debugging (using ssh access to the container), for serialization of
  multiple experimental runs, for optimization of resource (re-)usage.

  WARNING: in clouds, use it with care to avoid unexpected expenses.

  --run-on (string)

  Where the experimental run will be performed. Allowed values:

    * 'localhost' (default)

    * 'aws'

    * 'gcp' (WIP, not yet implemented)

  If 'localhost' is specified (or --run-on is omitted), Nancy will perform the
  run on the localhost in a Docker container so ('docker run' must work
  locally).

  If 'aws' is specified, Nancy will use a Docker machine (EC2 Spot Instance)
  with a single container on it.

  --tmp-path (string)

  Path to the temporary directory on the current machine (where 'nancy run' is
  being invoked), to store various files while preparing them to be shipped to
  the experimental container/machine. Default: '/tmp'.

  --container-id (string)

  If specified, new container/machine will not be created. Instead, the existing
  one will be reused. This might be a significant optimization for a series of
  experimental runs to be executed sequentially.

  WARNING: This option is to be used only with read-only workloads.

  WIP: Currently, this option works only with '--run-on localhost'.

  --pg-version (string)

  Specify the major version of PostgreSQL. Allowed values:

    * '9.6'
    * '10' (default)

  Currently, there is no way to specify the minor version – it is always the
  most recent version, available in the official PostgreSQL APT repository (see
  https://www.postgresql.org/download/linux/ubuntu/).

  --pg-config (string)

  PostgreSQL config to be used (may be partial).

  --pg-config-auto (enum: oltp|olap)

  Perform \"auto-tuning\" for PostgreSQL config. Allowed values:

    * \"oltp\" to auto-tune Postgres for OLTP workload,
    * \"olap\" to auto-tune Postgres for OLAP (analytical) workload.

  This option can be combined with \"--pg-config\" – in this case, it will be
  applied *after* it (so \"auto-tuning\" values will be added to the end of
  the postgresql.conf file).

  --db-prepared-snapshot (string)

  Reserved / Not yet implemented.

  --db-dump (string)

  Database dump (created by pg_dump) to be used as an input. May be:

    * path to dump file (must start with 'file://' or 's3://'), may be:
      - plain dump made with 'pg_dump',
      - gzip-compressed plain dump ('*.gz'),
      - bzip2-compressed plain dump ('*.bz2'),
      - dump in \"custom\" format, made with 'pg_dump -Fc ..' ('*.pgdmp'),
    * sequence of SQL commands specified as in a form of plain text.

  --db-name (string)

  Name of database which must be tested. Name 'test' is internal used name,
  so is not correct value.

  --db-ebs-volume-id (string)

  ID of an AWS EBS volume, containing the database backup (made with pg_basebackup).

  In the volume's root directory, the following two files are expected:
    - base.tar.gz
    - pg_xlog.tar.gz for Postgres version up to 9.6 or pg_wal.tar.gz for Postgres 10+

  The following command can be used to get such files:
    'pg_basebackup -U postgres -zPFt -Z 5 -D /path/to/ebs/volume/root'
  Here '-Z 5' means that level 5 to be used for compression, you can choose any value from 0 to 9.


  --db-pgbench (string)

  Initialize database for pgbench. Contains pgbench init arguments:

    * Example nancy run --db-pgbench \"-s 100\"

  --commands-after-container-init (string)

  Shell commands to be executed after the container initialization. Can be used
  to add additional software such as Postgres extensions not present in
  the main contrib package.

  --sql-before-db-restore (string)

  Additional SQL queries to be executed before the database is initiated.
  Applicable only when '--db-dump' is used.

  --sql-after-db-restore (string)

  Additional SQL queries to be executed once the experimental database is
  initiated and ready to accept connections.

  --workload-real (string)

  'Real' workload – path to the file prepared by using 'nancy prepare-workload'.

  --workload-real-replay-speed (integer)

  The speed of replaying of the 'real workload'. Useful for stress-testing
  and forecasting the performance of the database under heavier workloads.

  --workload-custom-sql (string)

  SQL queries to be used as workload. These queries will be executed in a signle
  database session.

  --workload-pgbench (string)

  pgbench arguments to pass for tests.  Ex: \"-c 10 -j 4 -t 1000\"

  --workload-basis (string)

  Reserved / Not yet implemented.

  --delta-sql-do (string)

  SQL changing database somehow before running workload. For example, DDL:

    create index i_t1_experiment on t1 using btree(col1);

  --delta-sql-undo (string)

  SQL reverting changes produced by those specified in the value of the
  '--delta-sql-do' option. Reverting allows to serialize multiple runs, but it
  might be not possible in some cases. 'UNDO SQL' example reverting index
  creation:

    drop index i_t1_experiment;

  --delta-config (string)

  Config changes to be applied to postgresql.conf before running workload.
  Once configuration changes are made, PostgreSQL is restarted. Example:

    random_page_cost = 1.1

  --artifacts-destination (string)

  Path to a local ('file://...') or S3 ('s3://...') directory where artifacts
  of the experimental run will be placed. Among these artifacts:

    * detailed performance report in JSON format
    * whole PostgreSQL log, gzipped
    * full PostgreSQL config used in this experimental run

  --aws-ec2-type (string)

  Type of EC2 instance to be used. To keep budgets low, EC2 Spot instances will
  be utilized and automatic detections of the lowest price in the current AZ
  will be performed.

  WARNING: 'i3-metal' instances are not currently supported (WIP).

  The option may be used only with '--run-on aws'.

  --aws-keypair-name (string)

  The name of key pair to be used on EC2 instance to allow ssh access. Must
  correspond to SSH key file specified in the '--aws-ssh-key-path' option.

  The option may be used only with '--run-on aws'.

  --aws-ssh-key-path (string)

  Path to SSH key file (usually, has '.pem' extension).

  The option may be used only with '--run-on aws'.

  --aws-ebs-volume-size (string)

  Size (in gigabytes) of EBS volume to be attached to the EC2 instance.

  --s3cfg-path

  The path the '.s3cfg' configuration file to be used when accessing files in
  S3. This file must be local and must be specified if some options' values are
  in 's3://***' format.

  See also: https://github.com/s3tools/s3cmd

SEE ALSO

    nancy help