
def specs(dir)
  FileList["spec/#{dir}/*_spec.rb"].shuffle.join(' ')
end

def build
	sh('gem build cocoapods-develop.gemspec')
	sh('gem install cocoapods-develop-0.0.1.gem')
end

desc 'Builds the gem'
task :build do
	build
end

desc 'Runs all the specs'
task :specs do
  sh "bundle exec bacon #{specs('**')}"
end

task :default => :specs

