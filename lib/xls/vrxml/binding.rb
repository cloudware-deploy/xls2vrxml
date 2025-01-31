#
# Copyright (c) 2011-2023 Cloudware S.A. All rights reserved.
#
# This file is part of xls2vrxml.
# Based on sp-excel-loader.
#
# xls2vrxml is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# xls2vrxml is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with xls2vrxml.  If not, see <http://www.gnu.org/licenses/>.
#
# encoding: utf-8
#

module Xls
  module Vrxml

    class Binding

      attr_accessor :sheet
      attr_accessor :tables
      attr_accessor :columns
      attr_accessor :map

      ALL = [ 
          { key: :parameters , name: 'PARAMETERS_BINDING'  }, 
          { key: :fields     , name: 'FIELDS_BINDING'      },
          { key: :variables  , name: 'VARIABLES_BINDING'   },
          { key: :bands      , name: 'BANDS_BINDING'       },
          { key: :named_cells, name: 'NAMED_CELLS_BINDING' },
          { key: :other      , name: 'OTHER'               }
      ]
      def self.all()
        return ALL
      end

      COLUMNS=['Name', 'Value', 'Updated At']
      def self.columns()
        return COLUMNS
      end

      #
      # Initializer binding for a workbook
      #
      # @param @workbook Pre-loaded workbook.
      #
      def initialize(workbook:)
        @workbook = workbook
        @columns  = {}
      end

      #
      # Load 'binding' data from the workbook.
      #
      def load()
        # load 'binding' sheet
        @sheet  = Binding.get_sheet(named: 'Binding', at: @workbook)
        # load all tables
        @tables = {}
        ALL.each do | table |
          @tables[table[:key]] = Binding.get_table(named: table[:name], at: @sheet)
        end
        # ref
        ref_table = @tables[ALL[0][:key]]
        if nil == ref_table
          raise "Reference table NOT found!"
        end
        @columns['Name']       = get_table_column_index(table: ref_table, named: 'Name')
        @columns['Value']      = get_table_column_index(table: ref_table, named: 'Value')
        @columns['Updated At'] = get_table_column_index(table: ref_table, named: 'Updated At')
        @map = {}
        @tables.each do | key, table |
          @map[key] = {}
          Binding.iterate_table(table: table, at: @sheet) do | row, cells |
            data = {}
            @columns.each do | k, _ |
              if nil == cells[@columns[k]] || nil == cells[@columns[k]].value
                next
              end
              data[k] = {
                cell: cells[@columns[k]],
                name: k,
                value: cells[@columns[k]] ? cells[@columns[k]].value.strip : nil,
                row: row,
                column: @columns[k]
              }
            end # columns
            next if 0 == data.keys.count
            @map[key][data['Name'][:value]] = data
          end # table
        end # tables loop
      end

      #
      #
      # Patch a field binding data.
      #
      # @param field Field name ( string ) to patch.
      # @param value Field value ( JSON object ) to set.
      #
      def patch(type:, field:, value:)
        values = { 'Value': value, 'Updated At': Time.now }
        # grab field data
        data = @map[field]
        if nil == data
          values['Name'] = field

          row = @sheet.add_row()
          @table.auto_filter.ref = RubyXL::Reference.new(
            @table.auto_filter.ref.row_range.min, @table.auto_filter.ref.row_range.max + 1,
            @table.auto_filter.ref.col_range.min, @table.auto_filter.ref.col_range.max
          )
          @table.ref = "A1:C4" # TODO
          data = {}
          @columns.each do | k, _ |
            data[k] = {
              cell: nil,
              name: k,
              value: nil,
              row: @map.size + 1,
              column: @columns[k]
            }
          end
          @map[data['Name'][:value]] = data
          # raise "data for binding field #{field} NOT found!"
        end
        #
        values.each do | k, v |
          cell = data[k.to_s][:cell]
          # ... update value ...
          # TODO use .change_contents
          if nil == cell
            # ... by adding a new cell ...
            sheet.add_cell(data[k.to_s][:row], data[k.to_s][:column], v)
          else
            # ... by replacing cell ...
            sheet.delete_cell(cell.row, cell.column)
            sheet.add_cell(cell.row, cell.column, v)
          end
        end
      end
      
      private
      
      #
      # Get a sheet from a workbook.
      #
      # @param named: Sheet name.
      # @param at: Workbook
      #
      def self.get_sheet(named:, at:)
        at.worksheets.each do |ws|
          if named.is_a?(Array)
            named.each do | name |
              if ws.sheet_name == name
                return ws
              end
            end
          else
            if ws.sheet_name == named
              return ws
            end
          end
        end
        raise "Sheet #{named} NOT found!"
      end

      #
      # Obtain a map of named cells to cells reference.
      #
      # @param sheet Sheet where to look for named cells.
      # @param at    Workbook.
      #
      # TODO: this duplicates read_named_cells
      #
      def self.get_named_cells_map(sheet:, at:)
        map   = Hash.new
        r_map = Hash.new
        if nil == at.defined_names
          return map, r_map
        end
        ref_regexp = sheet.sheet_name + '!\$*([A-Z]+)\$*(\d+)'
        at.defined_names.each do |dn|
          next unless dn.local_sheet_id.nil?
          match = dn.reference.match(ref_regexp)
          if match and match.size == 3
            matched_name = match[1].to_s + match[2].to_s
            if map[dn.name]
              ::Xls::Vrxml::Log.ERROR(msg: "duplicate cellname for ref #{matched_name}: #{map[dn.name]} and #{dn.name}", exception: ArgumentError)
            elsif r_map[matched_name]
              ::Xls::Vrxml::Log.ERROR(msg: "duplicate cellname for ref #{matched_name}: #{r_map[matched_name]} and #{dn.name}", exception: ArgumentError)
            end
            map[dn.name] = matched_name
            r_map[matched_name] = dn.name
          end
        end
        return map, r_map
      end

      #
      # Get a table from a sheet.
      #
      # @param named    Table name.
      # @param at       Sheet.
      # @param optional When not optional, an error will be raised - otherwise nil will be returned.
      #
      def self.get_table(named:, at:, optional: false)
        at.generic_storage.each do |tbl|
          return tbl if tbl.is_a? RubyXL::Table and tbl.name == named
        end
        raise "Table #{named} NOT found!" if false == optional
      end

      #
      # Obtain a table column index.
      #
      # @param table Table name.
      # @param named Column name.
      #
      def get_table_column_index(table:, named:)
        table.table_columns.each_with_index do | column, index |
          return index if column.name == named
        end
        raise "Table column #{named} NOT found!"
      end

      #
      # Iterate a table.
      #
      # @param table Table object to iterate.
      # @param at    Sheet that owns table.
      #
      def self.iterate_table(table:, at:)
        ref = RubyXL::Reference.new(table.ref)
        for row in ref.row_range.begin()+1..ref.row_range.end()
          next if nil == at[row]
          row_cells = []
          ref.col_range.each do |column|
            row_cells << at[row][column]
          end
          yield row, row_cells
        end
      end

    public

      #
      # Map C/JavaScript types to Java types.
      #
      # @param a_type C or JavaScript type
      #
      # @return Mapped type.
      #
      def self.to_java_class(a_type)
        case a_type.downcase
        when 'java.lang.double', 'double', 'float'
          return 'java.lang.Double'
        when 'java.lang.integer', 'integer', 'int'
          return 'java.lang.Integer'
        when 'java.lang.boolean', 'boolean', 'bool'
          return 'java.lang.Boolean'
        when 'java.lang.string', 'string'
          return 'java.lang.String'
        when 'java.util.date', 'Date'
          return 'java.util.Date'
        else
          raise "Don't know how to convert C/JavaScript type '#{a_type}' to Java type!"
        end
      end

      # 
      # Parse a string as JSON.
      #
      # @param type  Hint for what kind of binding object is being parsed.
      # @param value String to parse as JSON object.
      #
      def self.parse(type:, value:)
        begin
          binding = JSON.parse(value, symbolize_names: true)
        rescue JSON::ParserError => e
          puts "  ⌄".red
          puts "⨯ #{type.to_s} binding value is NOT a valid JSON object!".red
          puts "#{value}".yellow
          puts "  ⌃ error ( #{e.message} )".red
          raise e # or  exit -1
        end
      end

      #
      # Log and raise an error.
      #
      # @param msg Message to display.
      # @param error Error to raise.
      #
      def self.halt(msg:, file: nil, line: nil, error: nil)
        if nil != file && nil != line
          puts "@#{file}:#{line}".yellow
        end
        puts "  ⌄".red
        puts "⨯ #{msg}".red
        puts "  ⌃ error".red
        if nil != error
          raise error
        else
            raise "Stopped"
        end
      end

      #
      # Translate a string value to a boolean.
      #
      # @param a_value String value to translate.
      #
      # @return True of false. 
      #
      def self.to_b(value)
        value.match(/(true|t|yes|y|1)$/i) != nil
      end

    end # of class 'Binding'

  end # of module 'Vrxml'
end # of module 'Xls'
  