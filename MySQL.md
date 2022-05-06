## Granting privileges

```sql
GRANT ALL PRIVILEGES ON db_name.* TO user@'localhost';
```

## Configuring MySQL timezone in Linux

```shell
$ mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u USERNAME --password=PASSWORD mysql
```
