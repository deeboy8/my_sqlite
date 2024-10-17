# my_sqlite

## Overview

This project implements a lightweight SQLite-like interface in Ruby, allowing users to interact with CSV files as though they were databases. The core of the project is the MySqliteRequest class, which is designed to mimic the behavior of a SQL query builder. You can chain method calls to progressively build queries and execute them using the run method. The project also includes a Command Line Interface (CLI) to perform SQL-like operations on CSV files interactively.

## Features

__Chained SQL-like queries__: Build queries progressively by chaining method calls.
__Supported operations__: ```SELECT```, ```INSERT```, ```UPDATE```, ```DELETE```, ```JOIN```, and ```ORDER```.
__Data source__: Operates on CSV files, which act as the database tables.
__Simple join operations__: Supports one JOIN and one WHERE clause per request.
__Interactive CLI__: A command-line interface that allows SQL-like interaction with CSV files.

## Usage

MySqliteRequest Class
MySqliteRequest allows building and executing queries on CSV files. Each method, except run, returns the instance itself for chaining.

Example Query

```ruby
request = MySqliteRequest.new
request.from('nba_player_data.csv')
       .select('name')
       .where('birth_state', 'Indiana')
       .run  # => [{"name" => "Andre Brown"}]
```

Key Methods

* ```from(table_name)```: Set the CSV file as the data source.
* ```select(column_name)```: Choose columns to return.
* ```where(column_name, criteria)```: Filter rows based on a condition.
* ```join(column_on_db_a, filename_db_b, column_on_db_b)```: Join two CSV files.
* ```insert(table_name)```: Insert data into the specified CSV.
* ```update(table_name)```: Update rows in the CSV.
* ```delete```: Delete matching rows.
* ```run```: Execute the query.

Start the CLI to interact with CSV files:

```text
ruby my_sqlite_cli.rb
```

Execute SQL-like commands such as:

```text
SELECT * FROM students;
INSERT INTO students VALUES (John, john@example.com, A);
UPDATE students SET email = 'jane@example.com' WHERE name = 'Jane';
DELETE FROM students WHERE name = 'John';
```

## Conclusion

This project offers a simple, flexible way to query and manipulate CSV files using Ruby. It combines a powerful query-building class with an interactive CLI for SQL-like operations.