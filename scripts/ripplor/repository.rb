$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/../lib')

require "version"

class Repository

  attr_reader :name
  attr_reader :targets
  attr_reader :clone_command

  def initialize(repo_root, name, path, variable, targets = 'clean clean-integration test publish', master_branch = 'master')
    if repo_root.nil?
      abort('Repository Git root cannot be nil for repository ' + @name)
    end
    @repo_root = repo_root
      
    if name.nil?
      abort('Name cannot be nil')
    end
    @name = name

    if path.nil? || path == ''
      abort('Repository path cannot be nil for repository ' + @name)
    end
    @path = File.expand_path(path)

    @variable = variable

    if targets.nil?
      abort('Repository build targets cannot be nil for repository ' + @name)
    end
    @targets = targets

    if master_branch.nil?
      abort('Repository master branch cannot be nil for repository ' + @name)
    end
    @master_branch = master_branch
    
    @clone_command = 'git clone -b ' + @master_branch + " " + @repo_root + @name + '.git ' + @path 
  end

  def checkout
    if File.exist?(@path)
      FileUtils.rm_rf(@path)
    end

    puts '  Checking out ' + @path
    execute(@clone_command)
    execute('cd ' + @path + '; git submodule update --init')
    create_bundle_version
  end

  def update_versions(versions)
    create_branch(@bundle_version)
    puts '  Updating versions'
    versions.each_pair do |variable, version|
      Version.update(variable, version, @path, true)
    end

    execute('cd ' + @path + '; git commit --allow-empty -a -m "[RIPPLOR] Updated versions"')
  end

  def build(s3_keys, log_file)
    puts '  Building:'
    puts '    BUNDLE_VERSION: ' + @bundle_version
    puts '    TARGETS: ' + @targets
    execute(
      'ant ' +
      '-propertyfile ' + s3_keys + ' ' +
      '-f ' + @path + '/build-*/build.xml ' +
      '-Dbundle.version=' + @bundle_version + ' ' +
      @targets + ' >> ' + log_file)
  end

  def versions
    versions = Hash.new
    
    IO.foreach(@path + '/build.versions') do |line|
      if line =~ /([^=]*)=(.*)/
        if !($1.strip[-6..-1] == '-RANGE')
          versions[$1.strip] = $2.strip 
        end
      end
    end

    versions[@variable] = @bundle_version
    versions
  end

  def push
    puts 'Pushing ' + @path
    execute('cd ' + @path + '; git push origin ' + @bundle_version + ':' + @master_branch)
  end

########################################################################################################################

  private

  def create_branch(name)
    puts('  Creating branch ' + name + ' -> ' + @master_branch)
    execute('cd ' + @path + '; git checkout -q -b ' + name + ' --track origin/' + @master_branch)
  end
  
  def create_bundle_version
    version = nil
    IO.foreach(@path + '/build.properties') do |line|
      version = $1.strip if line =~ /^version=(.*)/
    end

    @bundle_version = version + '.D-' + Time.now.utc.strftime("%Y%m%d%H%M%S")
  end

  def execute(command)
    output = `#{command}`
    if $?.to_i != 0
      abort('Execution Failed')
    end
    output
  end

end