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
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'

require 'json'

require File.expand_path(File.join(File.dirname(__FILE__), 'monkey'))

require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'rubyxl_table_patch'))
require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'workbookloader'))

require File.expand_path(File.join(File.dirname(__FILE__), 'vrxml', 'object'))
require File.expand_path(File.join(File.dirname(__FILE__), 'vrxml', 'log'))
require File.expand_path(File.join(File.dirname(__FILE__), 'vrxml', 'binding'))

require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'jrxml', 'excel_to_jrxml'))
require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'jrxml', 'style'))
require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'jrxml', 'pen'))
require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'jrxml', 'band'))
require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'jrxml', 'band_container'))
require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'jrxml', 'box'))
require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'jrxml', 'group'))
require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'jrxml', 'parameter'))
require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'jrxml', 'field'))
require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'jrxml', 'variable'))
require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'jrxml', 'static_text'))
require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'jrxml', 'text_field'))
require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'jrxml', 'image'))
require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'jrxml', 'report_element'))
require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'jrxml', 'jasper'))
require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'jrxml', 'property'))
require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'jrxml', 'property_expression'))

require File.expand_path(File.join(File.dirname(__FILE__), 'vrxml', 'expression'))
require File.expand_path(File.join(File.dirname(__FILE__), 'vrxml', 'excel_to_vrxml'))

require File.expand_path(File.join(File.dirname(__FILE__), 'loader', 'version'))

module Xls
  module Loader
  end
end
