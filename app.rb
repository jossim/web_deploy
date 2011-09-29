require 'rubygems'
require 'bundler'
Bundler.require
require 'yaml'
require 'sinatra'

APP_DATA = YAML.load_file('config.yaml')

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

get '/' do
  @projects = get_projects()
  erb :index
end

get '/project/:project_id' do
  @project = get_project_by_id(params[:project_id])
  @dev_repo = Grit::Repo.new(@project['dev_repo'])
  @untracked_files = get_untracked_files(@dev_repo)
  $log.debug "## untracked files: #{@untracked_files}"
  @changed_files = get_changed_files(@dev_repo)
  $log.debug "## changed files: #{@changed_files}"
  @deleted_files = get_deleted_files(@dev_repo)
  $log.debug "## deleted files: #{@deleted_files}"
  erb :project
end
