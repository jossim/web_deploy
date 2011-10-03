require './temp_require.rb'

before do
  @projects = get_projects()
  @html_title = ''
  @title = ''
  unless env['PATH_INFO'] == '/login' || env['PATH_INFO'] == '/logout'
    protected!
  end
end

after do
  unless session['live']
    session.delete('errors')
    session.delete('notice')
  end
  session.delete('live')
end

get '/login' do
  @html_title = 'login'
  erb :login
end

post '/login' do
  create_session
end

get '/session/kill' do
  destroy_session
end

get '/logout' do
  erb :logout
end

get '/' do
  @title = "Welcome to Web Deploy"
  erb :index
end

get '/project/:id' do
  @project = get_project_by_id(params[:id])
  @title = @project['name']
  $log.debug "params in method: #{params.inspect}"
  @dev_repo = Grit::Repo.new(@project['dev_repo'])

  @commit_history = get_commit_history(@dev_repo, 3)
  erb :project
end

get '/project/:id/dev' do
  @project = get_project_by_id(params[:id])
  @title = @project['name']
  @dev_repo = Grit::Repo.new(@project['dev_repo'])

  @untracked_files = get_untracked_files(@dev_repo)
  @added_files = get_added_files(@dev_repo)
  @changed_files = get_changed_files(@dev_repo)
  @deleted_files = get_deleted_files(@dev_repo)

  @commit_history = get_commit_history(@dev_repo, 10)
  erb :dev
end

get '/project/:id/test' do
  @project = get_project_by_id(params[:id])
  @title = @project['name']
  erb :test
end

get '/project/:id/pro' do
  @project = get_project_by_id(params[:id])
  @title = @project['name']
  erb :production
end

post '/project/:id/add-remove-commit' do
  @project = get_project_by_id(params[:id])
  @dev_repo = Grit::Repo.new(@project['dev_repo'])
  @commit_result = []
  unless params[:files].nil?
    @deleted = params[:files][:deleted]
    @untracked = params[:files][:untracked] 
    @changed = params[:files][:changed]
    
    @added = []
    unless @untracked.nil?
      @added += @untracked
    end
    unless @changed.nil?
      @added += @changed
    end

    $log.debug "added: #{@added}"

    add_files(@dev_repo, @added)
    remove_files(@dev_repo, @deleted)
    
    @commit_result = commit_with_result(@dev_repo, params[:message])
  end
  erb :commit
end

post '/project/:id/push' do
  @project = get_project_by_id(params[:id])
  @dev_repo = Grit::Repo.new(@project['dev_repo'])
  @push_result = push_with_result(@dev_repo, "origin", "master")
  erb :push
end

post '/project/:id/pull' do
  @project = get_project_by_id(params[:id])
  repo = @project[params[:repo]]

  @pull_result = pull_with_result(repo)
  erb :pull
end
