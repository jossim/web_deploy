require './temp_require.rb'

before do
  @projects = get_projects()
end

get '/' do
  erb :index
end

get '/project/:id' do
  @project = get_project_by_id(params[:id])
  @dev_repo = Grit::Repo.new(@project['dev_repo'])

  @commit_history = get_commit_history(@dev_repo, 3)
  erb :project
end

get '/project/:id/dev' do
  @project = get_project_by_id(params[:id])
  @dev_repo = Grit::Repo.new(@project['dev_repo'])

  @untracked_files = get_untracked_files(@dev_repo)
  @added_files = get_added_files(@dev_repo)
  @changed_files = get_changed_files(@dev_repo)
  @deleted_files = get_deleted_files(@dev_repo)

  @commit_history = get_commit_history(@dev_repo, 10)
  erb :dev
end

get '/project/:id/test' do
  erb :test
end

get 'project/:id/pro' do
  erb :production
end

post '/project/:id/add-remove-commit' do
  @project = get_project_by_id(params[:id])
  @dev_repo = Grit::Repo.new(@project['dev_repo'])
  $log.debug "params: #{params.inspect}"
  @commit_result = []
  unless params[:files].nil?
    @deleted = params[:files][:deleted]
    @untracked = []
    @untracked ||= params[:files][:untracked] 
    @changed = []
    @changed ||= params[:files][:changed]

    add_files(@dev_repo, @untracked + @changed)
    remove_files(@dev_repo, @deleted)
    
    @commit_result = commit_with_result(@dev_repo, params[:message])
  end
  erb :commit
end

get '/project/:id/pull' do
  @project = get_project_by_id(params[:id])
  
  server_root = env["DOCUMENT_ROOT"].sub("/public","")

  Dir.chdir(@project['dev_repo'])
  
  @pull_result = []
  IO.popen "git pull origin master" do |fd|
    until fd.eof?
      @pull_result << fd.readline
    end
  end
  Dir.chdir(server_root)
  erb :pull
end

post '/project/:id/push' do

end

get '/project/:id/result' do

end
