#!/usr/bin/env ruby -dwKU
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'repository'
require 'options'

args = Choice.choices
bundle_version = args[:version] + '.' + args[:build_stamp]
gemini_version = args[:gemini_version] + '.' + args[:gemini_build_stamp]

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
    'gemini-web' => 'gemini-web',
    'web' => 'web',
    'apps' => 'apps',
    'documentation' => 'documentation',
    'web-server' => 'web-server',
    'jetty-server' => 'jetty-server'
  }
end

#def initialize(repo_root, name, path, variable, bundle_version = nil, targets = 'clean clean-integration test publish publish-eclipse', committerId = '', master_branch = 'master')

virgo_eclipse_repo_root = 'ssh://' + args[:remote_user] + '@git.eclipse.org/gitroot/virgo/org.eclipse.virgo.'
gemini_eclipse_repo_root = 'ssh://' + args[:remote_user] + '@git.eclipse.org/gitroot/gemini.web/org.eclipse.gemini.web.'

if args[:product_release] == 'full-product' 

  ALL_REPOS = [
    Repository.new(virgo_eclipse_repo_root,  'osgi-test-stubs',      paths['osgi-test-stubs'],     'org.eclipse.virgo.teststubs',       bundle_version),
    Repository.new(virgo_eclipse_repo_root,  'osgi-extensions',      paths['osgi-extensions'],     'org.eclipse.virgo.osgi',            bundle_version),
    Repository.new(virgo_eclipse_repo_root,  'util',                 paths['util'],                'org.eclipse.virgo.util',            bundle_version),
    Repository.new(virgo_eclipse_repo_root,  'test',                 paths['test'],                'org.eclipse.virgo.test',            bundle_version),
    Repository.new(virgo_eclipse_repo_root,  'medic',                paths['medic'],               'org.eclipse.virgo.medic',           bundle_version),
    Repository.new(virgo_eclipse_repo_root,  'artifact-repository',  paths['artifact-repository'], 'org.eclipse.virgo.repository',      bundle_version),
    Repository.new(virgo_eclipse_repo_root,  'kernel',               paths['kernel'],              'org.eclipse.virgo.kernel',          bundle_version,   'test package publish publish-package-build publish-package-download'),
    Repository.new(virgo_eclipse_repo_root,  'kernel-tools',         paths['kernel-tools'],        'org.eclipse.virgo.kernel-tools',    bundle_version),
    Repository.new(gemini_eclipse_repo_root, 'gemini-web-container', paths['gemini-web'],          'org.eclipse.gemini.web',            gemini_version),
    Repository.new(virgo_eclipse_repo_root,  'web',                  paths['web'],                 'org.eclipse.virgo.web',             bundle_version),
    Repository.new(virgo_eclipse_repo_root,  'apps',                 paths['apps'],                'org.eclipse.virgo.apps',            bundle_version),
    Repository.new(virgo_eclipse_repo_root,  'documentation',        paths['documentation'],       'org.eclipse.virgo.documentation',   bundle_version,   'doc-html package publish publish-package-download'),
    Repository.new(virgo_eclipse_repo_root,  'web-server',           paths['web-server'],          'org.eclipse.virgo.web-server',      bundle_version,   'test package smoke-test publish publish-package-build publish-package-download'),
    Repository.new(eclipse_repo_root,        'jetty-server',         paths['jetty-server'],        'org.eclipse.virgo.jetty-server',    nil,              'jar package smoke-test publish publish-package-build publish-package-download')
  ]

elsif args[:product_release] == 'kernel' 

  ALL_REPOS = [
    Repository.new(virgo_eclipse_repo_root, 'osgi-test-stubs',     paths['osgi-test-stubs'],     'org.eclipse.virgo.teststubs',       bundle_version),
    Repository.new(virgo_eclipse_repo_root, 'osgi-extensions',     paths['osgi-extensions'],     'org.eclipse.virgo.osgi',            bundle_version),
    Repository.new(virgo_eclipse_repo_root, 'util',                paths['util'],                'org.eclipse.virgo.util',            bundle_version),
    Repository.new(virgo_eclipse_repo_root, 'test',                paths['test'],                'org.eclipse.virgo.test',            bundle_version),
    Repository.new(virgo_eclipse_repo_root, 'medic',               paths['medic'],               'org.eclipse.virgo.medic',           bundle_version),
    Repository.new(virgo_eclipse_repo_root, 'artifact-repository', paths['artifact-repository'], 'org.eclipse.virgo.repository',      bundle_version),
    Repository.new(virgo_eclipse_repo_root, 'kernel',              paths['kernel'],              'org.eclipse.virgo.kernel',          bundle_version,  'test package publish publish-package-build publish-package-download')
  ]

elsif args[:product_release] == 'web-server' 
  
  ALL_REPOS = [
    Repository.new(virgo_eclipse_repo_root, 'web',                 paths['web'],                 'org.eclipse.virgo.web',             bundle_version),
    Repository.new(virgo_eclipse_repo_root, 'apps',                paths['apps'],                'org.eclipse.virgo.apps',            bundle_version),
    Repository.new(virgo_eclipse_repo_root, 'documentation',       paths['documentation'],       'org.eclipse.virgo.documentation',   bundle_version,  'doc-html package publish publish-package-download'),
    Repository.new(virgo_eclipse_repo_root, 'web-server',          paths['web-server'],          'org.eclipse.virgo.web-server',      bundle_version,  'test package smoke-test publish publish-package-build publish-package-download'),
    Repository.new(eclipse_repo_root,       'jetty-server',        paths['jetty-server'],        'org.eclipse.virgo.jetty-server',    nil,             'jar package smoke-test publish publish-package-build publish-package-download')
  ]
  
else
  
  ALL_REPOS = [
    Repository.new(virgo_eclipse_repo_root, 'osgi-test-stubs',     paths['osgi-test-stubs'],     'org.eclipse.virgo.teststubs',       bundle_version),
    Repository.new(virgo_eclipse_repo_root, 'osgi-extensions',     paths['osgi-extensions'],     'org.eclipse.virgo.osgi',            bundle_version),
    Repository.new(virgo_eclipse_repo_root, 'util',                paths['util'],                'org.eclipse.virgo.util',            bundle_version),
    Repository.new(virgo_eclipse_repo_root, 'test',                paths['test'],                'org.eclipse.virgo.test',            bundle_version),
    Repository.new(virgo_eclipse_repo_root, 'medic',               paths['medic'],               'org.eclipse.virgo.medic',           bundle_version),
    Repository.new(virgo_eclipse_repo_root, 'artifact-repository', paths['artifact-repository'], 'org.eclipse.virgo.repository',      bundle_version),
    Repository.new(virgo_eclipse_repo_root, 'kernel',              paths['kernel'],              'org.eclipse.virgo.kernel',          bundle_version,  'test package publish publish-package-build publish-package-download'),
    Repository.new(virgo_eclipse_repo_root, 'kernel-tools',        paths['kernel-tools'],        'org.eclipse.virgo.kernel-tools',    bundle_version),
    Repository.new(virgo_eclipse_repo_root, 'web',                 paths['web'],                 'org.eclipse.virgo.web',             bundle_version),
    Repository.new(virgo_eclipse_repo_root, 'apps',                paths['apps'],                'org.eclipse.virgo.apps',            bundle_version),
    Repository.new(virgo_eclipse_repo_root, 'documentation',       paths['documentation'],       'org.eclipse.virgo.documentation',   bundle_version,  'doc-html package publish publish-package-download'),
    Repository.new(virgo_eclipse_repo_root, 'web-server',          paths['web-server'],          'org.eclipse.virgo.web-server',      bundle_version,  'test package smoke-test publish publish-package-build publish-package-download'),
    Repository.new(eclipse_repo_root,       'jetty-server',        paths['jetty-server'],        'org.eclipse.virgo.jetty-server',    nil,             'jar package smoke-test publish publish-package-build publish-package-download')
  ]
  
end

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
    if !args[:build_version].nil?
      puts '  updating Virgo Build to \'' + args[:build_version] + '\''
    end
    puts "  Building " + repo.name + " (s3.keys)"
    puts "  Create tag " + repo.bundle_version
    puts "  Update Master branch " + args[:new_version]
  else
    repo.create_release_branch(args[:version], args[:build_stamp], args[:release_type], accumulate_versions)
    if !args[:build_version].nil?
      repo.update_virgo_build(args[:build_version]) if !DRY_RUN
    end
    repo.build(args[:remote_user], log_file)
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

