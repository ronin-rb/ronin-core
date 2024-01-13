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

require 'uri'
require 'fileutils'

module Ronin
  module Core
    #
    # Utility methods for interacting with the system.
    #
    # @api semipublic
    #
    # @since 0.2.0
    #
    module System
      #
      # The detected Operating System type.
      #
      # @return [:linux, :macos, :freebsd, :openbsd, :netbsd, :windows, nil]
      #
      def self.os
        @os ||= if    RUBY_PLATFORM.include?('linux')   then :linux
                elsif RUBY_PLATFORM.include?('darwin')  then :macos
                elsif RUBY_PLATFORM.include?('freebsd') then :freebsd
                elsif RUBY_PLATFORM.include?('openbsd') then :openbsd
                elsif RUBY_PLATFORM.include?('netbsd')  then :netbsd
                elsif Gem.win_platform?                 then :windows
                end
      end

      #
      # The list of `bin/` directories containing executables.
      #
      # @return [Array<String>]
      #
      def self.paths
        @paths ||= if ENV['PATH']
                     ENV['PATH'].split(File::PATH_SEPARATOR)
                   else
                     []
                   end
      end

      #
      # Determines if a command is installed.
      #
      # @param [String] command
      #   The command name to search for.
      #
      # @return [Boolean]
      #   Indicates whether the command was found or not.
      #
      def self.installed?(command)
        paths.any? do |bin_dir|
          File.executable?(File.join(bin_dir,command))
        end
      end

      #
      # The detected download command.
      #
      # @return ['curl', 'wget', nil]
      #
      # @api private
      #
      def self.downloader
        @downloader ||= if os == :macos then :curl
                        else
                          if    installed?('wget') then :wget
                          elsif installed?('curl') then :curl
                          end
                        end
      end

      #
      # Exception class that indicates a download failed.
      #
      class DownloadFailed < RuntimeError
      end

      #
      # Downloads a file using either `curl` or `wget`.
      #
      # @param [URI::HTTP, String] url
      #   The URL to download.
      #
      # @param [String] dest
      #   The destination file or directory to download into.
      #
      # @return [String]
      #   The path to the downloaded file.
      #
      # @raise [DownloadFailed]
      #   The download failed or `curl`/`wget` could not be found on the system.
      #
      def self.download(url,dest)
        uri = URI(url)
        url = url.to_s

        if File.directory?(dest)
          dest = File.join(dest,File.basename(uri.path))
        end

        FileUtils.mkdir_p(File.dirname(dest))

        partial_dest = "#{dest}.part"

        case downloader
        when :wget
          unless system('wget','-c','-O',partial_dest,url)
            raise(DownloadFailed,"wget command failed: wget -c -O #{partial_dest} #{url}")
          end
        when :curl
          unless system('curl','-f','-L','-C','-','-o',partial_dest,url)
            raise(DownloadFailed,"curl command failed: curl -f -L -C - -o #{partial_dest} #{url}")
          end
        when nil
          raise(DownloadFailed,"could not find 'curl' or 'wget' on the system")
        else
          raise(NotImplementedError,"downloader not supported: #{downloader.inspect}")
        end

        FileUtils.mv(partial_dest,dest)
        return dest
      end
    end
  end
end
