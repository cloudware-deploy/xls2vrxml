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

    class TextField < StaticText

      attr_accessor :text_field_expression
      attr_accessor :is_stretch_with_overflow
      attr_accessor :is_blank_when_null
      attr_accessor :evaluation_time
      attr_accessor :pattern
      attr_accessor :pattern_expression
      attr_reader   :report_element
      attr_reader   :casper_binding

      def initialize (binding:, cell: nil, text_field_expression: nil, pattern: nil, tracking: nil)
        super(binding: binding, text: nil)
        @text_field_expression     = nil
        @is_blank_when_null        = nil
        @is_stretch_with_overflow  = false
        @evaluation_time           = nil
        if nil != binding
          @evaluation_time             = binding[:evaluationTime]
          @pattern                     = pattern || binding[:pattern]
          @pattern_expression          = binding[:patternExpression]
          @is_stretch_with_overflow    = binding[:is_stretch_with_overflow] || binding[:isStretchWithOverflow] || ( binding.include?(:textAdjust) ? 'StretchHeight' == binding[:textAdjust] :false )
          @casper_binding  = binding[:'casper.binding']
        else
          @evaluation_time           = nil
          @pattern                   = nil
          @pattern_expression        = nil
          @casper_binding            = nil
        end
        @text_field_expression = text_field_expression || binding[:text_field_expression] || binding[:textFieldExpression]
        @cell                  = cell
        @tracking              = tracking
      end

      def attributes
        rv = Hash.new
        rv[:isStretchWithOverflow] = true if @is_stretch_with_overflow
        rv[:pattern]               = @pattern unless @pattern.nil?
        rv[:isBlankWhenNull]       = @is_blank_when_null unless @is_blank_when_null.nil?
        rv[:evaluationTime]        = @evaluation_time unless @evaluation_time.nil?
        return rv
      end

      def to_xml (a_node)
        # -
        background_to_xml(a_node)
        # -
        Nokogiri::XML::Builder.with(a_node) do |xml|
          if nil != @cell
            xml.comment(" #{@cell[:name] || @cell[:ref] || ''}#{@tracking ? " #{@tracking}" : '' } ")
          end  
          xml.textField(attributes)
        end
        if nil != @casper_binding
          @report_element.properties ||= []
          #
          ignore = true
          if @casper_binding.keys.count < 1
            # pass
          elsif ( 1 == casper_binding.keys.count && true == @casper_binding.has_key?(:editable) )
            if 0 == @casper_binding[:editable].keys.count
              # pass
            elsif ( 1 == @casper_binding[:editable].keys.count && true == @casper_binding[:editable].has_key?(:is) && false == @casper_binding[:editable][:is] )
              # pass
            else
              ignore = false
            end
          else
            ignore = false
          end
          if false == ignore
            @report_element.properties << Property.new('casper.binding', @casper_binding.to_json)
          end
        end
        @report_element.to_xml(a_node.children.last)
        box_to_xml(a_node.children.last)
        if nil != @text_field_expression && @text_field_expression.length > 0
          Nokogiri::XML::Builder.with(a_node.children.last) do |xml|
            xml.textFieldExpression {
              xml.cdata(@text_field_expression)
            }
          end
        end
        if nil != @pattern_expression && @pattern_expression.length > 0
          Nokogiri::XML::Builder.with(a_node.children.last) do |xml|
            xml.patternExpression {
              xml.cdata(@pattern_expression)
            }
          end
        end
        # -
        foreground_to_xml(a_node)
      end

    end # of class 'TextField'

  end # of module 'Vrxml'
end # of module 'Xls'
