require 'csv'

=begin
Part 1 Describing the scope of project

# SELECT QUERY - done
        -> multiple WHERE
        # it works but the data is being duplicated for some reason
                request = MySqliteRequest.new
                request = request.from('nba_player_data.csv')
                request = request.select('name')
                request = request.where('college', 'University of California')
                request = request.where('year_start', '1997')
                request.run


# INSERT QUERY - done
# UPDATE - not started

    request = MySqliteRequest.new
    request = request.update('nba_player_data.csv') +
    request = request.values('name' => 'Alaa Renamed')
    request = request.where('name', 'Alaa Abdelnaby')
    request.run

# DELETE - not started

    request = MySqliteRequest.new
    request = request.delete()
    request = request.from('nba_player_data.csv')
    request = request.where('name', 'Alaa Abdelnaby')
    request.run



#1 type of requiest
#2 set settings
#3 run
=end


class MySqliteRequest
    def initialize
        @type_of_request = :none
        @select_columns = []
        @where_params = []
        @insert_attributes = :none
        @update_attributes = :none
        @table_name = nil
        @order = :asc

    end

    def from(table_name)
        @table_name = table_name
        self
    end

    def select(columns)
        if columns.length != 0
            if(columns.is_a?(Array))
                @select_columns += columns.collect { |elem| elem.to_s }
            else
                @select_columns << columns.to_s
            end
        end
        self._setTypeOfRequest(:select)
        self
    end

    def where(column_name, criteria)
        @where_params << [column_name, criteria]
        self
    end

    def join(column_on_db_a, filename_db_b, column_on_db_b)
        self
    end

    def order(order, column_name)
        self
    end

    def insert(table_name)
        self._setTypeOfRequest(:insert)
        @table_name = table_name
        self
    end

    def values_data_type(data)
        if(data.instance_of? Array)
            return data.join(",")
          elsif(data.instance_of? Hash)
            return data.values.join(",")
          elsif(data.instance_of? String)
            return data
          else
            puts "the values needs to be either array, hash, string data types"
          end
    end

    def values(data)
        if(@type_of_request == :insert)
            @insert_attributes = values_data_type(data)
        elsif  (@type_of_request == :update)
            @update_attributes = data
        else
            raise "Wrong type of request to call values()"
        end
        self
    end

    def update(table_name)
        self._setTypeOfRequest(:update)
        @table_name = table_name
        self
    end

    def set(data)
        self
    end

    def delete
        self._setTypeOfRequest(:delete)
        self
    end

    def print_select_type
        puts "Select Attributes #{@select_columns}"
        puts "Where Attributes #{@where_params}"
    end

    def print_insert_type
        puts "Insert Attributes #{@insert_attributes}"
    end

    def print
        puts "Type Of Request #{@type_of_request}"
        puts "Table Name #{@table_name}"
        if(@type_of_request == :select)
            print_select_type
        elsif (@type_of_request == :insert)
            print_insert_type
        end
    end

    def run
        print
        if(@type_of_request == :select)
            _run_select
        elsif (@type_of_request == :insert)
            _run_insert
        elsif (@type_of_request == :update)
            _run_update
        elsif (@type_of_request == :delete)
            _run_delete
        end
    end

    def _setTypeOfRequest(new_type)
        if(@type_of_request == :none or @type_of_request == new_type)
            @type_of_request = new_type
        else
            raise "Invalid: type of request already set to #{@type_of_request} (new type => #{new_type}"
        end
    end

    def _select_all
        result = []
        CSV.parse(File.read(@table_name), headers: true).each do |row|
            result << row.to_hash
        end
        p result
    end

    def _select_entry
        result = []
        CSV.parse(File.read(@table_name), headers: true).each do |row|
            @where_params.each do |where_attribute|
                if row[where_attribute[0]] == where_attribute[1]
                    result << row.to_hash.slice(*@select_columns)
                end
            end
        end
        p result
    end


    def _run_select
        if @where_params.length == 0
            _select_all
        else
            _select_entry
        end
    end
    
    def _run_insert
        File.open(@table_name, 'a') do |f|
            f.puts @insert_attributes
        end
    end

    def _run_update
        result = []
        CSV.open(@table_name, headers: true).map(&:to_hash).each do |row|
            if row[@where_params[0][0]] == @where_params[0][1]
                @update_attributes.each do | key, value |
                    row[key] = value
                end
                result << row
            else
                result << row
            end
        end

        CSV.open(@table_name, "w", :headers => true) do |csv|
            csv << result[0].keys
            result.each do |hash|
                csv << CSV::Row.new(hash.keys, hash.values)
            end
        end
    end

    def _run_delete
        result = []
        CSV.open(@table_name, headers: true).map(&:to_hash).each do |row|
            if row[@where_params[0][0]] == @where_params[0][1]
                next
            else
                result << row
            end
        end
        
        CSV.open(@table_name, "w", :headers => true) do |csv|
            csv << result[0].keys
            result.each do |hash|
                csv << CSV::Row.new(hash.keys, hash.values)
            end
        end
    end

end

=begin
def _main()

    request = MySqliteRequest.new
    request = request.from('nba_player_data_light.csv')
    request = request.select('name')
    request = request.where('college', 'Indiana University')
    p request.run
    puts

    request = MySqliteRequest.new
    request = request.insert('nba_player_data_light.csv')
    request = request.values({"name" => "Don Adams", "year_start" => "1971", "year_end" => "1977", "position" => "F", "height" => "6-6", "weight" => "210", "birth_date" => "November 27, 1947", "college" => "Northwestern University"})
    request.run

    request = MySqliteRequest.new
    request = request.from('nba_player_data_light.csv')
    request = request.select('name')
    request = request.where('college', 'Indiana University')
    request = request.where('year_start', '1971')
    p request.run

    request = MySqliteRequest.new
    request = request.update('nba_player_data.csv')
    request = request.values('name' => 'Alaa Renamed')
    request = request.where('name', 'Alaa Abdelnaby')
    request.run

    1. check if the name exists in th table
    if so
        2. try updating the value
    if not
        3. insert?

end

_main()
=end