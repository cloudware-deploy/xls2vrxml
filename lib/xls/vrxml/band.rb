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

module Xls
  module Vrxml

    class Band

      attr_reader   :tag
      attr_accessor :children
      attr_accessor :height
      attr_accessor :split_type
      attr_accessor :print_when_expression
      attr_accessor :properties
      attr_accessor :auto_float
      attr_accessor :auto_stretch
      attr_accessor :stretch_type
      attr_reader   :casper_binding
      
      def initialize(tag:, cell: nil)
        @tag                   = tag
        @children              = Array.new
        @height                = 18;
        @split_type            = 'Prevent'
        @print_when_expression = nil
        @properties            = nil
        @auto_stretch          = false
        @auto_float            = false
        @stretch_type          = nil
        @cell                  = cell
      end

      def attributes
        rv = Hash.new
        rv['height']    = @height
        rv['splitType'] = @split_type
        return rv
      end

      def casper_binding=(value)
        @properties ||= []
        @properties << Property.new('casper.binding', value.to_json)
      end

      def to_xml (a_node)
        Nokogiri::XML::Builder.with(a_node) do |xml|
          if nil != @cell
            xml.comment(" #{@tag} @ #{ @cell[:ref] || ''}")
          end
          xml.band(attributes) {
            unless @properties.nil?
              @properties.each do |property|
                xml.property(property.attributes)
              end
            end
            unless @print_when_expression.nil?
              xml.printWhenExpression {
                xml.cdata @print_when_expression
              }
            end
          }
        end
        @children.each do |child|
          child.to_xml(a_node.children.last)
        end
      end

    end

  end # of module 'Vrxml'
end # of module 'Xls'
