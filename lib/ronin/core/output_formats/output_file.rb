# frozen_string_literal: true
#
# Copyright (c) 2021-2023 Hal Brodigan (postmodern.mod3 at gmail.com)
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

module Ronin
  module Core
    module OutputFormats
      #
      # Base class for all output file formats.
      #
      # @api semipublic
      #
      # @since 0.2.0
      #
      class OutputFile < OutputFormat

        # The output stream to write to.
        #
        # @return [IO]
        attr_reader :io

        #
        # Initializes the output format.
        #
        # @param [IO] io
        #   The output stream to write to.
        #
        def initialize(io)
          super()

          @io = io
        end

        #
        # Opens an output file.
        #
        # @param [String] path
        #   The path to the new output file.
        #
        # @yield [output_format]
        #   If a block is given, it will be passed the initialized output
        #   format. Once the block returns, the output format will automatically
        #   be closed.
        #
        # @yieldparam [OutputFormat] output_format
        #   The newly opened output format.
        #
        # @return [OutputFormat]
        #   If no block is given, the newly initialized output format will be
        #   returned.
        #
        def self.open(path)
          output = new(File.open(path,'w'))

          if block_given?
            yield output
            output.close
          else
            return output
          end
        end

        #
        # Closes the output file.
        #
        def close
          @io.close unless @io == $stdout
        end

      end
    end
  end
end
