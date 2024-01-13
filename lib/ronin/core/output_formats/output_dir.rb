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

require 'ronin/core/output_formats/output_format'

require 'fileutils'

module Ronin
  module Core
    module OutputFormats
      #
      # Base class that represents an output directory.
      #
      # @api semipublic
      #
      # @since 0.2.0
      #
      class OutputDir < OutputFormat

        # The path to the output directory.
        #
        # @return [String]
        attr_reader :path

        #
        # Initializes the output directory.
        #
        # @param [String] path
        #   The path to the output directory.
        #
        def initialize(path)
          super()

          @path = File.expand_path(path)
          FileUtils.mkdir_p(@path)
        end

        #
        # Opens an output directory.
        #
        # @param [String] path
        #   The path to the new output directory.
        #
        # @yield [output_dir]
        #   If a block is given, it will be passed the initialized output
        #   directory. Once the block returns, the output format will
        #   automatically be closed.
        #
        # @yieldparam [Dir] output_dir
        #   The newly opened output directory.
        #
        # @return [Dir]
        #   If no block is given, the newly initialized output directory will be
        #   returned.
        #
        def self.open(path)
          output_dir = new(path)

          if block_given?
            yield output_dir
            output_dir.close
          else
            return output_dir
          end
        end

        #
        # "Closes" the output directory.
        #
        # @note This method is mainly for compatibility with {OutputFile}.
        #
        def close
        end

      end
    end
  end
end
