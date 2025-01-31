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

    class Object

      #
      # Since consistency is not a requirement ... ... ...
      #
      def self.guess_layout_sheet(workbook:)
        # ... [B] consistency is not a requirement ... ...  ...
        ls_found = false
        workbook.worksheets.each do |ws|
          if 'layout' == ws.sheet_name.downcase
            return  ws.sheet_name
          end
        end
        if false == ls_found
          return  workbook.worksheets[0].sheet_name
        end
        # ... [E] consistency is not a requirement ... ...  ...
     end

    end # class 'Object'

  end # module 'Vrxml'
end # module 'Xls'
