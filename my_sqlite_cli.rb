require "readline"
require_relative "my_sqlite_request.rb"

=begin
Test requests

SELECT * FROM students.csv
        request = MySqliteRequest.new
        request = request.from('students.csv')
        request = request.select() -> SELECT * means to SELECT ALL
        request.run

SELECT name,email FROM students.csv WHERE name = 'Mila'
        request = MySqliteRequest.new
        request = request.from('students.csv')
        request = request.select('name', 'email')
        request = request.where('name', 'Mila')
        request.run

INSERT INTO students.csv VALUES (John,john@johndoe.com,A,https://blog.johndoe.com)
        request = MySqliteRequest.new
        request = request.insert('students.csv')
        request = request.values({"name" => "John", "email" => "john@johndoe.com", "???" => "A", "blog" => "https://blog.johndoe.com"})
        request.run

UPDATE students.csv SET email = 'jane@janedoe.com', blog = 'https://blog.janedoe.com' WHERE name = 'Mila'
        request = MySqliteRequest.new
        request = request.update('students.csv')
        request = request.values({'email' => 'jane@janedoe.com', "blog" => "https://blog.janedoe.com"})
        request = request.where('name', 'Mila')
        request.run

DELETE FROM students.csv WHERE name = 'John'
        request = MySqliteRequest.new
        request = request.delete()
        request = request.from('students.csv')
        request = request.where('name', 'John')
        request.run


=end

class MySqliteQueryCli
    def parse(buf)
        return buf
    end

    def select_all(instance_of_request)
        request = MySqliteRequest.new
        request = request.from(instance_of_request[3])
        request = request.select("")
        request.run
    end

    def sort_where(instance_of_request)
        result = instance_of_request[7][1,instance_of_request[7].length-2]
        return result
    end

    def sort_select_columns(columns)
        if columns.include? ","
            return columns.split(",")
        else
            return columns
        end
    end

    def select_columns(instance_of_request)
        request = MySqliteRequest.new
        request = request.from(instance_of_request[3])
        request = request.select(sort_select_columns(instance_of_request[1]))
        request = request.where(instance_of_request[5], sort_where(instance_of_request))
        request.run
    end


    def select_call(instance_of_request)
        p instance_of_request
        if instance_of_request[1] == "*"
            select_all(instance_of_request)
        else
            select_columns(instance_of_request)
        end
    end

    def sort_values(buf)
        buf = buf.chop
        return buf.split("(")[1]
    end

    def insert_call(instance_of_request, buf)
        request = MySqliteRequest.new
        request = request.insert(instance_of_request[2])
        request = request.values(sort_values(buf))
        request.run
    end

    def update_where(instance_of_request)
        array_len = instance_of_request.length()
        column_name = instance_of_request[array_len-3]
        column_value = instance_of_request[array_len-1].chop
        column_value = column_value[1...]
        return [column_name,column_value]
    end

    def create_hash(values_array)
        result_hash = Hash.new
        index_count = 0
        while index_count < values_array.length
            left, right = values_array[index_count]
            result_hash[left] = right
            index_count += 1
        end
        return result_hash
    end

    def create_array(values)
        values_array = values.split("', ")

        values_array[values_array.length()-1] = values_array[values_array.length()-1][0...(values_array[values_array.length()-1].length() - 1)]
        index_count = 0

        while index_count < values_array.length
            values_array[index_count] = values_array[index_count].split(" = '")
            index_count += 1
        end
        return values_array
    end

    def update_values(buf)
        values = buf.split("SET")[1][1...]
        values = values.split("WHERE")[0].chop
        values = create_array(values)
        return create_hash(values)
    end

    def update_call(instance_of_request, buf)
        request = MySqliteRequest.new
        request = request.update(instance_of_request[1])
        request = request.values(update_values(buf))
        update_where_val = update_where(instance_of_request)
        request = request.where(update_where_val[0], update_where_val[1])
        request.run
    end

    def delete_call(instance_of_request, buf)
        request = MySqliteRequest.new
        request = request.delete()
        request = request.from(instance_of_request[2])
        update_where_val = update_where(instance_of_request)
        request = request.where(update_where_val[0], update_where_val[1])
        request.run
    end

    def run!
        while buf = Readline.readline("> ", true)
            if buf == "EXIT" || buf == "exit"
                break
            else
                instance_of_request = buf.split(' ')
                if instance_of_request[0] == "SELECT"
                    select_call(instance_of_request)
                elsif instance_of_request[0] == "INSERT"
                    insert_call(instance_of_request, buf)
                elsif instance_of_request[0] == "UPDATE"
                    update_call(instance_of_request, buf)
                elsif instance_of_request[0] == "DELETE"
                    delete_call(instance_of_request, buf)
                end
            end
        end
    end
end

MySqliteQueryCli.new.run!