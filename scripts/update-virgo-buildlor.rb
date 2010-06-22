#!/usr/bin/env ruby -wKU
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require "rubygems"
require "choice"
require "etc"

Choice.options do

  header('')
  header('Required arguments:')

  option :new_version, :required => true do
    short('-n')
    long('--new-version=NEW-VERSION')
    validate(/\d(.\d(.\d(.([\w_-])+)?)?)?/)
    desc('The version to update to')
  end
  
end

newVersion = Choice.choices[:new_version]

puts 'Updating to Virgo-Build version \'' + newVersion + '\''

def execute(command)
  output = `#{command}`
  if $?.to_i != 0
    abort('Execution Failed, aborted.')
  end
  output
end

execute("git submodule update --init")
Dir.chdir("virgo-build")
execute("git fetch --tags")
execute("git checkout " + newVersion)
Dir.chdir("..")



