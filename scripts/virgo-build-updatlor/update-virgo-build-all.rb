#!/usr/bin/env ruby -wKU
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'repository'
require "rubygems"
require "etc"

require 'options'

args = Choice.choices

if File.exist?(File.expand_path(args[:repository_map]))
  paths = Hash.new
  IO.foreach(File.expand_path(args[:repository_map])) do |line|
    paths[$1.strip] = $2.strip if line =~ /([^=]*)=(.*)/
  end
else
  paths = {
    'osgi-test-stubs' => 'osgi-test-stubs',
    'osgi-extensions' => 'osgi-extensions',
    'util' => 'util',
    'test' => 'test',
    'medic' => 'medic',
    'artifact-repository' => 'artifact-repository',
    'kernel' => 'kernel',
    'kernel-tools' => 'kernel-tools',
    'web' => 'web',
    'snaps' => 'snaps',
    'apps' => 'apps',
    'documentation' => 'documentation',
    'web-server' => 'web-server',
    'performance-test' => 'performance-test',
    'system-verification-tests' => 'system-verification-tests',
    'kernel-system-verification-tests' => 'kernel-system-verification-tests',
    'kernel-tools' => 'kernel-tools',
    'sample-greenpages' => 'sample-greenpages',
    'sample-configuration-properties' => 'sample-configuration-properties',
    'sample-formtags' => 'sample-formtags',
    'sample-osgi-examples' => 'sample-osgi-examples',
    'gemini-web-container' => 'gemini-web-container'
  }
end

#def initialize(repo_root, name, path, variable, bundle_version = nil, targets = 'clean clean-integration test publish publish-eclipse', committerId = '', master_branch = '2.1.x')

local_repo_root = 'git@git.springsource.org:virgo/'
virgo_repo_root = 'ssh://' + args[:remote_user] + '@git.eclipse.org/gitroot/virgo/org.eclipse.virgo.'
gemini_web_repo_root = 'ssh://' + args[:remote_user] + '@git.eclipse.org/gitroot/gemini.web/org.eclipse.gemini.web.'

ALL_REPOS = [
  Repository.new(virgo_repo_root, 'web-server',                            paths['web-server'], nil, "2.1.x"),
  Repository.new(virgo_repo_root, 'documentation',                         paths['documentation'], nil, "2.1.x"),
  Repository.new(virgo_repo_root, 'apps',                                  paths['apps'], nil, "2.1.x"),
  Repository.new(virgo_repo_root, 'web',                                   paths['web'], nil, "2.1.x"),
  Repository.new(virgo_repo_root, 'kernel',                                paths['kernel'], nil, "2.1.x"),
  Repository.new(virgo_repo_root, 'artifact-repository',                   paths['artifact-repository'], nil, "2.1.x"),
  Repository.new(virgo_repo_root, 'medic',                                 paths['medic'], nil, "2.1.x"),
  Repository.new(virgo_repo_root, 'test',                                  paths['test'], nil, "2.1.x"),
  Repository.new(virgo_repo_root, 'util',                                  paths['util'], nil, "2.1.x"),
  Repository.new(virgo_repo_root, 'osgi-extensions',                       paths['osgi-extensions'], nil, "2.1.x"),
  Repository.new(virgo_repo_root, 'osgi-test-stubs',                       paths['osgi-test-stubs'], nil, "2.1.x"),
  Repository.new(virgo_repo_root, 'kernel-tools',                          paths['kernel-tools'], nil, "2.1.x"),
  Repository.new(gemini_web_repo_root, 'gemini-web-container',             paths['gemini-web-container'], nil, "1.1.x", 'dummytarget', nil, "1.1.x")
]

start_time = Time.new

ALL_REPOS.each do |repo|
  puts 'Updating ' + repo.name
  puts '  Checkout with "' + repo.clone_command + '"' 
  repo.checkout
  repo.update_virgo_build(args[:build_version])
  puts ''
end

puts 'Execution Time: ' + Time.at(Time.new - start_time).utc.strftime('%R:%S')

print 'Do you want to push? (y/n) '
commit_ok = STDIN.gets.chomp
if commit_ok =~ /y.*/
  ALL_REPOS.each do |repo|
    repo.push
  end
end


