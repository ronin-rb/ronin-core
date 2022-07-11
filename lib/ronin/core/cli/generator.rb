#
# Copyright (c) 2021-2022 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of ronin-core.
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

require 'ronin/core/cli/command'

require 'command_kit/colors'
require 'fileutils'
require 'erb'

module Ronin
  module Core
    module CLI
      #
      # Adds generator methods to a command.
      #
      # ## Example
      #
      #   class Gen < Command
      #   
      #     include Core::Generator
      #   
      #     template_dir File.join(ROOT,'data','templates')
      #   
      #     argument :path, desc: 'The path of the script to genereate'
      #   
      #     def run(path)
      #       erb 'script.rb.erb', path
      #     end
      #   
      #   end
      #
      module Generator
        include CommandKit::Colors

        def self.included(command)
          command.extend ClassMethods
        end

        module ClassMethods
          #
          # Gets or sets the template directory.
          #
          # @param [String, nil] path
          #   If a path is given, the template directory will be set.
          #
          # @return [String]
          #   The set template directory.
          #
          # @raise [NotImplementedError]
          #   The class did not set {template_dir}.
          #
          # @example
          #   template_dir File.join(__dir__,'..','..','..','..','data','templates','thing')
          #
          def template_dir(path=nil)
            if path
              @template_dir = File.expand_path(path)
            else
              @template_dir || (superclass.template_dir if superclass.kind_of?(ClassMethods))
            end
          end
        end

        # The directory to read files from.
        #
        # @return [String]
        attr_reader :template_dir

        #
        # Initializes the command.
        #
        # @raise [NotImplementedError]
        #   The class did not set the {template_dir} path.
        #
        def initialize(**kwargs)
          super(**kwargs)

          unless (@template_dir = self.class.template_dir)
            raise(NotImplementedError,"#{self.class} did not define template_dir")
          end
        end

        #
        # Prints an generator action to STDOUT.
        #
        # @param [Symbol] command
        #   The command that represents the generator action.
        #
        # @param [String] source
        #   The optional source file being copied or rendered.
        #
        # @param [String] dest
        #   The file or directory path being created or modified.
        #
        def print_action(command,source=nil,dest)
          line = "\t" << colors.bold(colors.green(command))
          line << "\t" << colors.green(source) if source
          line << "\t" << colors.green(dest)   if dest

          puts(line)
       end

        #
        # Creates an empty directory.
        #
        # @param [String] path
        #   The relative path of the directory to be created.
        #
        def mkdir(path)
          print_action 'mkdir', path
          FileUtils.mkdir_p(path)
        end

        #
        # Creates an empty file.
        #
        # @param [String] path
        #   The relative path of the empty file to be created.
        #
        def touch(path)
          print_action 'touch', path
          FileUtils.touch(path)
        end

        #
        # Changes the permissions of a file or directory.
        #
        # @param [String, Integer]
        #   The chmod String (ex: `"+x"`) or octal mask.
        #
        # @param [String]
        #   The path to the file or directory.
        #
        def chmod(mode,path)
          print_action "chmod #{mode}", path
          FileUtils.chmod(mode,path)
        end

        #
        # Copies a file in.
        #
        # @param [String] source
        #   The file within the {template_dir} to copy in.
        #
        # @param [String] dest
        #   The destination path to copy the file to.
        #
        def cp(source,dest)
          print_action 'cp', source, dest

          FileUtils.cp(File.join(@template_dir,source),dest)
        end

        #
        # Copies a directory in.
        #
        # @param [String] source
        #   The relative path to the directory within the {template_dir}.
        #
        # @param [String] dest
        #   The destination path to copy the directory to.
        #
        def cp_r(source,dest)
          print_action "cp -r", source, dest

          FileUtils.cp_r(File.join(@template_dir,source),dest)
        end

        #
        # Renders a file using an `.erb` template in the {template_dir}.
        #
        # @param [String] source
        #   The relative path to the file. The `.erb` template will be derived
        #   from the file path by appending the `.erb` file extension.
        #
        # @param [String, nil] dest
        #   The destination path to write the rendered file to.
        #   If no destination path is given, the result of the rendered `.erb`
        #   template will be returned.
        #
        def erb(source,dest=nil)
          if dest
            print_action 'erb', source, dest
          end

          source_path = File.join(@template_dir,source)

          return super(source_path,dest)
        end

        #
        # Runs a command.
        #
        # @param [String] command
        #   The command name to execute.
        #
        # @param [Array<String>] arguments
        #   Additional arguments for the command.
        #
        # @return [Boolean, nil]
        #   Indicates whether the command successfully executed or not.
        #
        def sh(command,*arguments)
          print_action "run", [command, *arguments].join(' ')

          system(command,*arguments)
        end
      end
    end
  end
end
