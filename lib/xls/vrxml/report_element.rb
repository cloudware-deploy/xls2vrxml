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

    class ReportElement

      attr_accessor :x
      attr_accessor :y
      attr_accessor :width
      attr_accessor :height
      attr_accessor :style
      attr_accessor :properties
      attr_accessor :position_type
      attr_accessor :stretch_type
      attr_accessor :print_when_expression

      # custom
      attr_accessor :theme_style

      def initialize
        @x                     = 0
        @y                     = 0
        @width                 = 0
        @height                = 0
        @style                 = nil
        @properties            = nil
        @position_type         = 'FixRelativeToTop'
        @stretch_type          = 'NoStretch'
        @print_when_expression = nil
        @theme_style           = nil
      end

      def attributes
        rv = Hash.new
        rv['x']            = @x
        rv['y']            = @y
        rv['width']        = @width
        rv['height']       = @height
        rv['style']        = @style unless @style.nil?
        rv['positionType'] = @position_type unless @position_type == 'FixRelativeToTop'
        rv['stretchType']  = @stretch_type  unless @stretch_type  == 'NoStretch'
        rv['themeStyle']   = @theme_style unless @theme_style.nil?
        return rv
      end

      def to_xml (a_node)
        Nokogiri::XML::Builder.with(a_node) do |xml|
          xml.reportElement(attributes)
          if not @properties.nil?
            @properties.each do |property|
              if property.instance_of? Property
                property.to_xml(a_node.children.last)
              end
            end
            @properties.each do |property|
              if property.instance_of? PropertyExpression
                property.to_xml(a_node.children.last)
              end
            end
          end
          unless @print_when_expression.nil?
            Nokogiri::XML::Builder.with(a_node.children.last) do |xml|
              xml.printWhenExpression {
                xml.cdata(@print_when_expression)
              }
            end
          end
        end
      end

    end # class 'ReportElement'

  end # of module 'Vrxml'
end # of module 'Xls'
