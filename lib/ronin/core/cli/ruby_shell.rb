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

require_relative 'banner'

require 'command_kit/colors'
require 'irb'

module Ronin
  module Core
    module CLI
      #
      # Starts a customized Interactive Ruby console.
      #
      # @api semipublic
      #
      class RubyShell

        include Banner
        include CommandKit::Colors

        # The console name.
        #
        # @return [String]
        attr_reader :name

        # The optional context to spawn the console inside of.
        #
        # @return [Object, nil]
        attr_reader :context

        #
        # Initializes the console.
        #
        # @param [String] name
        #   The name of the IRB console.
        #
        # @param [Object, Module] context
        #   Custom context to launch IRB from within.
        #
        # @param [Hash{Symbol => Object}] kwargs
        #   Additional keyword arguments for `initialize`.
        #
        def initialize(name: 'ronin', context: nil, **kwargs)
          super(**kwargs)

          @name    = name
          @context = case context
                     when Module
                       Object.new.tap do |obj|
                         obj.singleton_class.include(context)
                         obj.singleton_class.define_singleton_method(:const_missing,&context.method(:const_missing))
                         obj.define_singleton_method(:inspect) do
                           "#<#{context}>"
                         end
                       end
                     else
                       context
                     end
        end

        #
        # Starts a customized [irb] console.
        # [irb]: https://github.com/ruby/irb#readme
        #
        # @param [Hash{Symbol => Object}] kwargs
        #   Additional keyword arguments for {#initialize}.
        #
        # @option kwargs [String] :name
        #   The name of the IRB console.
        #
        # @option kwargs [Object] :context
        #   Custom context to launch IRB from within.
        #
        def self.start(**kwargs)
          new(**kwargs).start
        end

        #
        # Configures IRB.
        #
        def configure
          IRB.setup(nil, argv: [])
          IRB.conf[:IRB_NAME] = @name

          set_prompt
          set_completion_dialog
        end

        #
        # Starts a customized [irb] console.
        # [irb]: https://github.com/ruby/irb#readme
        #
        def start
          print_banner if STDOUT.tty?

          configure

          workspace = if @context then IRB::WorkSpace.new(@context)
                      else             IRB::WorkSpace.new
                      end

          irb = IRB::Irb.new(workspace)
          irb.run
        end

        private

        #
        # Sets the IRB prompts for ronin.
        #
        def set_prompt
          colors(STDOUT).tap do |c|
            left_paren    = c.bold(c.bright_red('('))
            right_paren   = c.bold(c.bright_red(')'))
            prompt_prefix = "#{c.red('irb')}#{left_paren}#{c.red('%N')}#{right_paren}"

            IRB.conf[:PROMPT][:RONIN] = {
              AUTO_INDENT: true,
              PROMPT_I: "#{prompt_prefix}#{c.bold(c.bright_red('>'))} ",
              PROMPT_S: "#{prompt_prefix}%l ",
              PROMPT_C: "#{prompt_prefix}* ",
              RETURN:   "=> %s#{$/}"
            }

            IRB.conf[:PROMPT_MODE] = :RONIN
          end
        end

        #
        # Sets colors for the tab-completion menu.
        #
        # @since 0.3.0
        #
        def set_completion_dialog
          Reline::Face.config(:completion_dialog) do |conf|
            conf.define :default, foreground: :white, background: :black
            conf.define :enhanced, foreground: :black, background: :white
            conf.define :scrollbar, foreground: :white, background: :black
          end
        end

      end
    end
  end
end
