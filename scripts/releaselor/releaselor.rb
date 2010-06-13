#!/usr/bin/env ruby -wKU
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'repository'
require 'options'

args = Choice.choices
bundle_version = args[:version] + '.' + args[:build_stamp]

DRY_RUN = args[:dryrun?].nil? ? false : true
puts "This is a dry run..." if DRY_RUN

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
    'apps' => 'apps',
    'documentation' => 'documentation',
    'web-server' => 'web-server'
  }
end

#def initialize(repo_root, name, path, variable, bundle_version=nil, targets = 'clean clean-integration test publish', master_branch = 'master')

local_repo_root = 'git@git.springsource.org:virgo/'
eclipse_repo_root = 'ssh://' + args[:remote_user] + '@git.eclipse.org/gitroot/virgo/org.eclipse.virgo.'

ALL_REPOS = [
  Repository.new(eclipse_repo_root, 'osgi-extensions',     paths['osgi-extensions'],     'org.eclipse.virgo.osgi',            bundle_version),
  Repository.new(eclipse_repo_root, 'util',                paths['util'],                'org.eclipse.virgo.util',            bundle_version),
  Repository.new(eclipse_repo_root, 'test',                paths['test'],                'org.eclipse.virgo.test',            bundle_version),
  Repository.new(eclipse_repo_root, 'medic',               paths['medic'],               'org.eclipse.virgo.medic',           bundle_version),
  Repository.new(eclipse_repo_root, 'artifact-repository', paths['artifact-repository'], 'org.eclipse.virgo.repository',      bundle_version),
  Repository.new(eclipse_repo_root, 'kernel',              paths['kernel'],              'org.eclipse.virgo.kernel',          bundle_version,  'test package publish'),
  Repository.new(eclipse_repo_root, 'kernel-tools',        paths['kernel-tools'],        'org.eclipse.virgo.kernel-tools',    bundle_version),
  Repository.new(eclipse_repo_root, 'web',                 paths['web'],                 'org.eclipse.virgo.web',             bundle_version),
  Repository.new(eclipse_repo_root, 'apps',                paths['apps'],                'org.eclipse.virgo.apps',            bundle_version),
  Repository.new(eclipse_repo_root, 'documentation',       paths['documentation'],       'org.eclipse.virgo.documentation',   bundle_version,  'doc publish'),
  Repository.new(eclipse_repo_root, 'web-server',          paths['web-server'],          nil,                                 bundle_version,  'test package smoke-test publish')
]

log_file=File.expand_path('./release.log')
start_time = Time.new

accumulate_versions = Hash.new
ALL_REPOS.each do |repo|
  puts 'Releasing ' + repo.name
  puts '  checkout with "' + repo.clone_command + '"' if DRY_RUN
  repo.checkout(true)
  if DRY_RUN
    puts "  Create Release branch " + args[:version] + ", " + args[:build_stamp] + ", " + args[:release_type] 
    puts "    using versions: "
    accumulate_versions.sort.each {|keyval| puts "      " + keyval[0] + " = " + keyval[1]}
    puts "  Building " + repo.name + " (s3.keys)"
    puts "  Create tag " + repo.bundle_version
    puts "  Update Master branch " + args[:new_version]
  else
    repo.create_release_branch(args[:version], args[:build_stamp], args[:release_type], accumulate_versions)
    repo.build(args[:s3_keys], log_file)
    repo.create_tag
    repo.update_master_branch(args[:new_version], accumulate_versions)
  end
  accumulate_versions = (repo.versions).merge(accumulate_versions)
end

if !DRY_RUN
  puts 'Execution Time: ' + Time.at(Time.new - start_time).utc.strftime('%R:%S')
  puts ''

  print 'Do you want to push? (y/n) '
  commit_ok = STDIN.gets.chomp
  if commit_ok =~ /y.*/
    ALL_REPOS.each do |repo|
      repo.push(args[:new_version])
    end
  end
end

