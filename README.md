# ronin-core

[![CI](https://github.com/ronin-rb/ronin-core/actions/workflows/ruby.yml/badge.svg)](https://github.com/ronin-rb/ronin-core/actions/workflows/ruby.yml)
[![Code Climate](https://codeclimate.com/github/ronin-rb/ronin-core.svg)](https://codeclimate.com/github/ronin-rb/ronin-core)
[![Gem Version](https://badge.fury.io/rb/ronin-core.svg)](https://badge.fury.io/rb/ronin-core)

* [Website](https://ronin-rb.dev/)
* [Source](https://github.com/ronin-rb/ronin-core)
* [Issues](https://github.com/ronin-rb/ronin-core/issues)
* [Documentation](https://ronin-rb.dev/docs/ronin-core/frames)
* [Discord](https://discord.gg/6WAb3PsVX9) |
  [Mastodon](https://infosec.exchange/@ronin_rb)

## Description

ronin-core is a core library providing common functionality for all ronin
libraries.

ronin-core is part of the [ronin-rb] project, a toolkit for security research
and development.

## Features

* Provides access to the XDG directories (`~/.config/`, `~/.cache/`,
  `~/.local/share`).
* Allows querying `~/.gitconfig` for common git settings.
* Provides a common `Command` base class for all ronin libraries.
* Provides a `Shell` and `CommandShell` base classes for writing interactive
  shells.
* Provides a `Params` API for adding user configurable parameters to classes.
* Has 85% documentation coverage.
* Has 99% test coverage.

## Requirements

* [Ruby] >= 3.0.0
* [reline] ~> 0.4
* [command_kit] ~> 0.6
* [irb] ~> 1.0

## Install

### Gemfile

```ruby
gem 'ronin-core', '~> 0.1'
```

### gemspec

```ruby
gem.add_depedency 'ronin-core', '~> 0.1'
```

### [gemspec.yml]

```yaml
dependencies:
  ronin-core: ~> 0.1
```

## Examples

### Params

```ruby
class BaseClass

  include Ronin::Core::Params::Mixin

end
```

```ruby
class MyModule < BaseClass

  param :str, desc: 'A basic string param'

  param :feature_flag, Boolean, desc: 'A boolean param'

  param :enum, Enum[:one, :two, :three],
               desc: 'An enum param'

  param :num1, Integer, desc: 'An integer param'

  param :num2, Integer, default: 42,
                       desc: 'A param with a default value'

  param :num3, Integer, default: ->{ rand(42) },
                        desc: 'A param with a dynamic default value'

  param :float, Float, 'Floating point param'

  param :url, URI, desc: 'URL param'

  param :pattern, Regexp, desc: 'Regular Expression param'

end

mod = MyModule.new(params: {num1: 1, enum: :two})
mod.params
# => {:num2=>42, :num3=>25, :num1=>1, :enum=>:two}
```

### CLI

Define a main command for `ronin-foo`:

```ruby
# lib/ronin/foo/cli.rb
require 'command_kit/commands'
require 'command_kit/commands/auto_load'

module Ronin
  module Foo
    class CLI

      include CommandKit::Commands
      include CommandKit::Commands::AutoLoad.new(
        dir:       "#{__dir__}/cli/commands",
        namespace: "#{self}::Commands"
      )

      command_name 'ronin-foo'

      command_aliases['ls'] = 'list'
      # ...

    end
  end
end
```

Add a `bin/ronin-foo` file (don't forget to `chmod +x` it) that invokes the
main command:

```ruby
#!/usr/bin/env ruby

root = File.expand_path(File.join(__dir__,'..'))
if File.file?(File.join(root,'Gemfile.lock'))
  Dir.chdir(root) do
    begin
      require 'bundler/setup'
    rescue LoadError => e
      warn e.message
      warn "Run `gem install bundler` to install Bundler"
      exit -1
    end
  end
end

require 'ronin/foo/cli'
Ronin::Foo::CLI.start
```

Define a common command class for all `ronin-foo`'s commands:

```ruby
# lib/ronin/foo/cli/command.rb
require 'ronin/core/cli/command'

module Ronin
  module Foo
    class CLI
      class Command < Core::CLI::Command

        man_dir File.join(__dir__,'..','..','..','..','man')

      end
    end
  end
end
```

Define a `list` sub-command under the `ronin-foo` main command:

```ruby
# lib/ronin/foo/cli/commands/list.rb
require 'ronin/foo/cli/command'

module Ronin
  module Foo
    class CLI
      module Commands
        class List < Command

          usage '[options] [NAME]'

          argument :name, required: false,
                          desc:     'Optional name to list'

          description 'Lists all things'

          man_page 'ronin-foo-list.1'

          def run(name=nil)
            # ...
          end

        end
      end
    end
  end
end
```

Test it out:

```shell
$ ./bin/ronin-foo
Usage: ronin-foo [options] [COMMAND [ARGS...]]

Options:
    -h, --help                       Print help information

Arguments:
    [COMMAND]                        The command name to run
    [ARGS ...]                       Additional arguments for the command

Commands:
    help
    list, ls
$ ./bin/ronin-foo ls
```

### CLI::CommandShell

Define a custom command shell:

```ruby
class HTTPShell < Ronin::Core::CLI::CommandShell

  shell_name 'http'

  command :get, usage: 'PATH [HEADERS...]',
                summary: 'Sends a GET request'
  def get(path,*headers)
    # ...
  end

  command :post, usage: 'PATH DATA [HEADERS...]',
                 summary: 'Sends a POST request'
  def post(path,data,*headers)
    # ...
  end

end
```

Then start it:

```ruby
HTTPShell.start
```

```
http> get /foo
...
http> post /foo var=bar
...
```

## Development

1. [Fork It!](https://github.com/ronin-rb/ronin-core/fork)
2. Clone It!
3. `cd ronin-core/`
4. `bundle install`
5. `git checkout -b my_feature`
6. Code It!
7. `bundle exec rake spec`
8. `git push origin my_feature`

## License

Copyright (c) 2021-2024 Hal Brodigan (postmodern.mod3@gmail.com)

ronin-core is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

ronin-core is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with ronin-core.  If not, see <https://www.gnu.org/licenses/>.

[ronin-rb]: https://ronin-rb.dev/

[Ruby]: https://www.ruby-lang.org
[command_kit]: https://github.com/postmodern/command_kit.rb#readme
[reline]: https://github.com/ruby/reline#readme
[irb]: https://github.com/ruby/irb#readme

[gemspec.yml]: https://github.com/postmodern/gemspec.yml#readme
