# frozen_string_literal: true

require 'yaml'

namespace :ci do
  workflow = YAML.load_file(File.join(__dir__, '.github', 'workflows', 'ci.yml'))
  script = File.join(__dir__, '.github', 'scripts', 'docker.sh')

  desc 'Run the "lint" job of ci.yml in Docker'
  task :lint do
    abort('ci:lint takes no RUBY or REDMINE.') if ENV['RUBY'] || ENV['REDMINE']
    steps = workflow.dig('jobs', 'lint', 'steps')
    ruby = steps.find { |step| step.dig('with', 'ruby-version') }.dig('with', 'ruby-version').to_s
    sh 'bash', script, 'lint', '--ruby', ruby
  end

  desc 'Run the "test" job of ci.yml in Docker. Options: REDMINE=7.0 RUBY=3.4'
  task :test do
    steps = workflow.dig('jobs', 'test', 'steps')
    ruby = ENV['RUBY'] || steps.find { |step| step.dig('with', 'ruby-version') }.dig('with', 'ruby-version').to_s
    redmine = ENV['REDMINE'] || steps.find { |step| step.dig('with', 'ref') }.dig('with', 'ref')
    sh 'bash', script, 'test', '--ruby', ruby, '--redmine', redmine
  end

  desc 'Remove the Docker images built by ci:test'
  task :clean do
    sh 'docker image ls --quiet redmine-xlsx-ci | sort -u | xargs -r docker image rm'
  end

  task :jobs do
    unsupported = workflow['jobs'].keys - %w[lint test]
    abort("ci.yml has jobs without a rake task: #{unsupported.join(', ')}") unless unsupported.empty?
  end
end

desc 'Run all jobs of ci.yml in Docker with the versions in ci.yml'
task ci: %w[ci:jobs ci:lint ci:test]
