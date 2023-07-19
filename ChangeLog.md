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

