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

    class Image < StaticText

      attr_accessor :image_expression
      attr_accessor :h_align
      attr_accessor :v_align

      def initialize(binding:, image_expression: nil, cell: nil, tracking: nil)
        super(binding: nil, text: nil, cell: cell, tracking: tracking)
        @scale_image      = 'RetainShape'
        @h_align          = 'Center'
        @v_align          = 'Middle'
        @on_error_type    = 'Blank'
        @image_expression = image_expression || binding[:imageExpression] || ''
        @report_element.print_when_expression = binding[:printWhenExpression]
      end

      def attributes
        { scaleImage: @scale_image, hAlign: @h_align, vAlign: @v_align, onErrorType: @on_error_type }
      end

      def to_xml (a_node)
        Nokogiri::XML::Builder.with(a_node) do |xml|
          xml.image(attributes)
        end
        @report_element.to_xml(a_node.children.last)
        @box.to_xml(a_node.children.last) unless @box.nil?
        Nokogiri::XML::Builder.with(a_node.children.last) do |xml|
          xml.imageExpression {
            xml.cdata(@image_expression)
          }
        end
      end

    end # class 'Image'

  end # of module 'Vrxml'
end # of module 'Xls'
