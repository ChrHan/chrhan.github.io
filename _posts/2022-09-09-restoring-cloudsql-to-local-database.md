---
layout: post
title: "Restoring CloudSQL to Local Database"
date: 2022-09-09 23:50:00
categories: gcp cloudsql
tags: gcp cloudsql
cover-img: ["/assets/images/gcp-cloudsql.webp"]
thumbnail-img: "/assets/images/gcp-cloudsql.webp"
---

## Background

Google Cloud Platform CloudSQL can [export database to GCS as `.sql.` flat file](https://cloud.google.com/sql/docs/postgres/import-export/import-export-sql).
How to setup this backup will be covered in another post as it would be extensive.
This post will explain how to restore these `.sql` files locally, as it is not a straightforward process.

## Problem faced

Exported flat files cannot be easily imported to local database, as they contain CloudSQL specific roles:
- `cloudsqlsuperuser`
- `cloudsqladmin`

Another problem, if you have never tried to restore a PostgreSQL dump to another database, is that it requires multiple steps:
1. Create a blank database
2. Import your database to newly created database at (1)

## Solution

For dealing with CloudSQL specific roles, there are two options:
1. Change your import script to comment out `cloudsqlsuperuser` and `cloudsqladmin` role, or
2. Possibly creating an empty role named `cloudsqlsuperuser` and `cloudsqladmin`

Run the following script on your PostgreSQL to fix this issue with option (1):
```
    CREATE ROLE cloudsqlsuperuser;
    CREATE ROLE cloudsqladmin;
```

For option (2), you would need to comment out specific lines mentioning `cloudsqlsuperuser` and `cloudsqladmin` role.

To restore database, the following CLI command format can be used:
```
    createdb -U <database_user> -T template0 <new_database_name> -h <postgres_ip_address> -p <postgres_port> -W
    psql -U <database_user> <new_database_name> -f <path/to/file> -h <postgres_ip_address> -p <postgres_port> -W
```

For each command, you will be asked for postgreSQL password and both command runs interactively.

If you want to skip password, you can run the following command
```
    export PGPASSWORD=<database_password>
    createdb -U <database_user> -T template0 <new_database_name> -h <postgres_ip_address> -p <postgres_port>
    psql -U <database_user> <new_database_name> -f <path/to/file> -h <postgres_ip_address> -p <postgres_port>
```

