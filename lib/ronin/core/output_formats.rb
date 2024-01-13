# frozen_string_literal: true
#
# Copyright (c) 2021-2024 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# ronin-core is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ronin-core is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with ronin-core.  If not, see <https://www.gnu.org/licenses/>.
#

require 'ronin/core/output_formats/txt'
require 'ronin/core/output_formats/csv'
require 'ronin/core/output_formats/json'
require 'ronin/core/output_formats/ndjson'

module Ronin
  module Core
    #
    # Contains common output file formats, such as {TXT txt}, {CSV csv},
    # {JSON json}, and {NDJSON ndjson}.
    #
    module OutputFormats
      #
      # Adds {ClassMethods} to the other `OutputFormats` module which is
      # including {Ronin::Core::OutputFormats}.
      #
      # @param [Module] output_formats
      #   The other `OutputFormats` module which is including {OutputFormats}.
      #
      def self.included(output_formats)
        output_formats.extend ClassMethods
      end

      #
      # Class methods which are added to another `OutputFormats` module
      # when {Ronin::Core::OutputFormats} is included.
      #
      module ClassMethods
        #
        # Output formats grouped by name.
        #
        # @return [Hash{Symbol => Class<OutputFormat>}]
        #
        def formats
          @formats ||= {}
        end

        #
        # Output formats grouped by file extension.
        #
        # @return [Hash{String => Class<OutputFormat>}]
        #
        def file_exts
          @file_exts ||= {}
        end

        #
        # Registers a new output format.
        #
        def register(name,ext,output_format)
          formats[name]  = output_format
          file_exts[ext] = output_format
        end

        #
        # Infers the output format from the output file path.
        #
        # @param [String] path
        #   The output file path to infer the output format from.
        #
        # @return [Class<OutputFormat>, Class<TXT>]
        #   The inferred output format for the given path, or {TXT} if the
        #   output format could not be inferred.
        #
        def infer_from(path)
          file_exts.fetch(File.extname(path),TXT)
        end
      end
    end
  end
end
