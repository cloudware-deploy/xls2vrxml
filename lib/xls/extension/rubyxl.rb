# encoding: utf-8
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

require 'rubyXL'
require 'rubyXL/objects/ooxml_object'


# Monkey patch to RubyXL
module RubyXL

  class SortCondition < OOXMLObject
    define_attribute(:ref           , :string, :required => true)
    define_element_name 'sortCondition'
  end

  class SortState < OOXMLObject
    define_attribute(:ref           , :string, :required => true)
    define_element_name 'sortState'
    define_child_node(RubyXL::SortCondition)
  end

  class TableColumn < OOXMLObject
    define_attribute(:id            , :int   , :required => true)
    define_attribute(:name          , :string, :required => true)
    define_attribute(:totalsRowShown, :int   , :default  => 0   )
    define_element_name 'tableColumn'
  end

  class TableColumns < OOXMLContainerObject
    define_attribute(:count, :int, :default => 0)
    define_child_node(RubyXL::TableColumn, :collection => true)
    define_element_name 'tableColumns'
  end

  class TableStyleInfo < OOXMLObject
    define_attribute(:name              , :string , :required => true)
    define_attribute(:showColumnStripes , :string , :default  => 0)
    define_attribute(:showFirstColumn   , :string , :default  => 0)
    define_attribute(:showLastColumn    , :string , :default  => 0)
    define_attribute(:showRowStripes    , :string , :default  => 0)
    define_element_name 'tableStyleInfo'
  end

  class Table < OOXMLTopLevelObject
    CONTENT_TYPE = 'application/vnd.openxmlformats-officedocument.spreadsheetml.table+xml'
    REL_TYPE     = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/table'

    define_attribute(:id            , :int   , :required => true)
    define_attribute(:name          , :string, :required => true)
    define_attribute(:ref           , :string, :required => true)
    define_attribute(:displayName   , :string, :required => true)
    define_child_node(RubyXL::AutoFilter)
    define_child_node(RubyXL::SortState)
    define_child_node(RubyXL::TableColumns)
    define_child_node(RubyXL::TableStyleInfo)

    define_element_name 'table'
    set_namespaces('http://schemas.openxmlformats.org/spreadsheetml/2006/main' => nil)

    def xlsx_path
      ROOT.join('xl', 'tables', "table#{file_index}.xml")
    end

  end

  class Tables < OOXMLContainerObject
    define_child_node(RubyXL::Table, :collection => true)
    define_element_name 'tables'
  end

  class Worksheet

    define_relationship(RubyXL::Table)

    def add_table(id:, name:, ref:, columns:, style: 'TableStyleMedium2')

      self.relationship_container ||= RubyXL::OOXMLRelationshipsFile.new
      _t_n  = self.relationship_container.relationships.size + 1
      _r_id = "rId#{_t_n}"
      _target = "../tables/table#{_t_n}.xml"
      self.relationship_container.relationships << RubyXL::Relationship.new(id: _r_id, target: _target, type: ::RubyXL::Table::REL_TYPE)

      table = RubyXL::Table.new(id: _t_n, name: name.to_underscore.upcase, ref: ref, display_name: name)
      table.table_columns = ::RubyXL::TableColumns.new(count: 3)
      columns.each do | column |
        table.table_columns << ::RubyXL::TableColumn.new(id: column[:id], name: column[:name])
      end
      table.auto_filter = ::RubyXL::AutoFilter.new(ref: ref)
      table.table_style_info = RubyXL::TableStyleInfo.new(name: style)
      table.table_style_info.show_row_stripes = 1

      self.table_parts ||= ::RubyXL::TableParts.new
      self.table_parts << ::RubyXL::TablePart.new(r_id: _r_id)

      # this will generate a xl/tables/table<n>.xml
      self.generic_storage << table
    end

    def ref2abs(ref)
      "#{self.sheet_name}!#{RubyXL::Reference.ref2abs(ref)}"
    end

  end

  class TablePart < OOXMLObject
    define_relationship(:required => true)
    define_element_name 'tablePart'
  end

  class Reference

    def self.ref2abs(ref)
      row, col = RubyXL::Reference.ref2ind(ref)
      str = ''
      loop do
        x = col % 26
        str = ('A'.ord + x).chr + str
        col = (col / 26).floor - 1
        break if col < 0
      end
      "$#{str}$#{(row + 1).to_s}"
    end

  end

end

#
# Make Sure RubyXL does not steal our patch for table loading
#
RubyXL::TableFile.send(:remove_const, 'REL_TYPE')
RubyXL::TableFile.const_set('REL_TYPE', 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/table-do-not-load')

RubyXL::TableFile.send(:remove_const, 'CONTENT_TYPE')
RubyXL::TableFile.const_set('CONTENT_TYPE', 'application/vnd.openxmlformats-officedocument.spreadsheetml.table-dont-load+xml')

