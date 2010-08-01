# seamless

Python allows you to signal the end of a code block with indentation. Ruby 
suffers from an extremely verbose and tedious block terminator, "end". Much 
like Lisps end up with dozens of close-parens, Ruby files that use modules 
and classes heavily end up with a plethora of "ends" that just aren't necessary.

Write a Ruby file, but skip all the "ends". Line up your code blocks like in
Python. Then just call it 'your_file.rbe', require 'seamless', and require
'your_file'. Seamless does the rest.

Should this ever see widespread use? I don't know. But it's pretty fun!

## Example

    module Hello
      module World
        class Runner
          def initialize(user)
            @user = user
          def run
            puts "Hello, #{@user}"

Much cleaner! Sure, a bit contrived, but no more ends!

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Michael Edgar. See LICENSE for details.
