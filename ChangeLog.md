### 0.2.0 / 2024-07-22

* Require [command_kit] ~> 0.5.
* Added the `mastodon:` keyword argument to {Ronin::Core::Metadata::Authors::ClassMethods#author}.
* Added {Ronin::Core::Metadata::Authors::Author#mastodon}.
* Added {Ronin::Core::Metadata::Authors::Author#mastodon_url}.
* Added {Ronin::Core::OutputFormats}.
* Added {Ronin::Core::OutputFormats::OutputFile}.
* Added {Ronin::Core::OutputFormats::OutputDir}.
* Added {Ronin::Core::System}.
* Added {Ronin::Core::CLI::Banner}.
* Added {Ronin::Core::CLI::Help::Banner}.
* Added {Ronin::Core::CLI::CompletionCommand}.
* Added {Ronin::Core::CLI::Printing::Params#param_usage}.
* Print the new ASCII art banner in {Ronin::Core::CLI::RubyShell#start} and
  {Ronin::Core::CLI::Shell.start}.
* Added a default `quit` command to {Ronin::Core::CLI::CommandShell}.
* Print the author's Mastodon profile URL in
  {Ronin::Core::CLI::Printing::Metadata}.
* Change the formatting of {Ronin::Core::CLI::Logging#log_warn} to output
  ANSI bold-bright-yellow.
* Change the formatting of {Ronin::Core::CLI::Logging#log_error} to output
  ANSI bold-bright-red.

### 0.1.3 / 2024-06-19

* Improved {Ronin::Core::ClassRegistry::ClassMethods#load_class_from_file}
  to handle returning the class when the file has already been loaded.

### 0.1.2 / 2023-07-18

#### CLI

* Changed {Ronin::Core::CLI::RubyShell#initialize} to wrap a `Module` `context:`
  value in an `Object` instance which includes the module. This allows the
  IRB session to gain access to the module's constants and instances methods,
  as well as correctly define and call instance methods in the IRB session.

### 0.1.1 / 2023-03-01

#### CLI

* Allow {Ronin::Core::CLI::Shell} and {Ronin::Core::CLI::CommandShell} to
  rescue interrupts while a shell command is running, and not exit from the
  shell.

### 0.1.0 / 2023-02-01

* Initial release:
  * Provides access to the XDG directories (`~/.config/`, `~/.cache/`,
    `~/.local/share`).
  * Allows querying `~/.gitconfig` for common git settings.
  * Provides a common `Command` base class for all ronin libraries.
  * Provides a `Shell` and `CommandShell` base classes for writing interactive
    shells.
  * Provides a `Params` API for adding user configurable parameters to classes.

[command_kit]: https://github.com/postmodern/command_kit.rb#readme
