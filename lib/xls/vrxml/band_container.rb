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

    class BandContainer

      attr_accessor :bands
      attr_accessor :order

      def initialize(order:)
        @order      = order
        @bands      = Array.new
        @band_type  = nil
      end

      def attributes
        rv = Hash.new
        rv['order'] = @order
        return rv
      end

      def bands_to_xml (a_node)
        @bands.each do |band|
          band.to_xml(a_node)
        end
      end

    end

    class Background < BandContainer

      def to_xml (a_node)
        if @bands.size > 0
          Nokogiri::XML::Builder.with(a_node) do |xml|
            xml.background(attributes)
          end
          bands_to_xml(a_node.children.last)
        end
      end

    end

    class PageHeader < BandContainer

      def to_xml (a_node)
        if @bands.size > 0
          Nokogiri::XML::Builder.with(a_node) do |xml|
            xml.pageHeader(attributes)
          end
          bands_to_xml(a_node.children.last)
        end
      end

    end

    class ColumnHeader < BandContainer

      def to_xml (a_node)
        if @bands.size > 0
          Nokogiri::XML::Builder.with(a_node) do |xml|
            xml.columnHeader(attributes)
          end
          bands_to_xml(a_node.children.last)
        end
      end

    end

    class GroupHeader < BandContainer

      def to_xml (a_node)
        if @bands.size > 0
          Nokogiri::XML::Builder.with(a_node) do |xml|
            xml.groupHeader(attributes)
          end
          bands_to_xml(a_node.children.last)
        end
      end

    end

    class GroupFooter < BandContainer

      def to_xml (a_node)
        if @bands.size > 0
          Nokogiri::XML::Builder.with(a_node) do |xml|
            xml.groupFooter(attributes)
          end
          bands_to_xml(a_node.children.last)
        end
      end

    end

    class Detail < BandContainer

      def to_xml (a_node)
        if @bands.size > 0
          Nokogiri::XML::Builder.with(a_node) do |xml|
            xml.detail(attributes)
          end
          bands_to_xml(a_node.children.last)
        end
      end

    end

    class ColumnFooter < BandContainer

      def to_xml (a_node)
        if @bands.size > 0
          Nokogiri::XML::Builder.with(a_node) do |xml|
            xml.columnFooter(attributes)
          end
          bands_to_xml(a_node.children.last)
        end
      end

    end

    class PageFooter < BandContainer

      def to_xml (a_node)
        @bands.each do |band|
          page_number_refs = []
          band.children.each do |child|
            if child.kind_of? TextField
              if "$.$$VARIABLES[index]['PAGE_NUMBER']" == child.text_field_expression
                page_number_refs << child
              end
            end
          end
          if page_number_refs.length > 1
            page_number_ref_count = 0
            page_number_refs.each do |ref|
              page_number_ref_count += 1
              evaluation_time = ( 1 == page_number_ref_count ? "Now" : "Report" )
              ref.evaluation_time = evaluation_time
            end
          end
        end
        if @bands.size > 0
          Nokogiri::XML::Builder.with(a_node) do |xml|
            xml.pageFooter(attributes)
          end
          bands_to_xml(a_node.children.last)
        end
      end

    end

    class LastPageFooter < BandContainer

      def to_xml (a_node)
        if @bands.size > 0
          Nokogiri::XML::Builder.with(a_node) do |xml|
            xml.lastPageFooter(attributes)
          end
          bands_to_xml(a_node.children.last)
        end
      end

    end

    class Summary < BandContainer

      def to_xml (a_node)
        if @bands.size > 0
          Nokogiri::XML::Builder.with(a_node) do |xml|
            xml.summary(attributes)
          end
          bands_to_xml(a_node.children.last)
        end
      end

    end

    class Title < BandContainer

      def to_xml (a_node)
        if @bands.size > 0
          Nokogiri::XML::Builder.with(a_node) do |xml|
            xml.title(attributes)
          end
          bands_to_xml(a_node.children.last)
        end
      end

    end

    class NoData < BandContainer

      def to_xml (a_node)
        if @bands.size > 0
          Nokogiri::XML::Builder.with(a_node) do |xml|
            xml.noData(attributes)
          end
          bands_to_xml(a_node.children.last)
        end
      end

    end

  end # of module 'Vrxml'
end # of module 'Xls'
