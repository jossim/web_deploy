helpers do
  ### authenticated session methods ###

  def create_session(url = '/')  
    authenticated = authenticate(params["username"], params["password"])

    if authenticated
      session["auth"] = authenticated
      session["live"] = true
      session["notice"] = "You are now logged in!"
      redirect url
    else  
      session["live"] = true
      session["errors"] = "Invalid username or password"  
      redirect "/login"  
    end  
  end
  
  def authenticate(user, password)
    if params["password"].empty? || params["password"].empty?
      return false
    else
      $log.debug "APP_DATA: #{APP_DATA.inspect}"
      $log.debug "params: #{params.inspect}"

      password_hashed = BCrypt::Engine.hash_secret(password, APP_DATA['configurations']['password_salt'])

      return APP_DATA['configurations']['username'] == user && APP_DATA['configurations']['password_hash'] == password_hashed
    end
  end
  
  def destroy_session  
    if authenticated?
      session["live"] = true
      session["notice"] = "You are now logged out!"
    end
    session.delete("auth")    
    redirect "/logout"
  end 

  def authenticated?
    if session["auth"]
      true
    end
  end    
  # helper method that protects routes that should require login
  def protected!
    unless authenticated?
      session["live"] = true
      session["url"] = @env["REQUEST_URI"]
      session["errors"] = "you need to be logged in to view this page"
      redirect "/login"
    end
  end
  ###  end authentication methods ###

  def get_projects
    return APP_DATA['projects']
  end

  def get_project_by_id(id)
    projects = get_projects()
    return projects[id]
  end
  
  def get_file_paths(file_objects)
    file_paths = []
    
    file_objects.each do |file|
      file_paths << file[1].path
    end
    
    return file_paths
  end

  def get_added_files(repo)
    return get_file_paths(repo.status.added)
  end

  def get_untracked_files(repo)
    return get_file_paths(repo.status.untracked)
  end

  def get_changed_files(repo)
    return get_file_paths(repo.status.changed)
  end

  def get_deleted_files(repo)
    return get_file_paths(repo.status.deleted)
  end

  def get_commit_history(repo, limit=nil)
    commit_log_objects = repo.log
    if limit
      commit_log_objects = commit_log_objects[0...limit]
    end

    commit_array = []

    commit_log_objects.each do |commit|
      commit = commit.to_hash
      commit_array << "Commit: #{commit['id']}"
      commit_array << "Author: #{commit['author']['name']} &nbsp &lt;#{commit['author']['email']}&gt;"
      commit_array << "Date: #{commit['committed_date']}"
      commit_array << ""
      commit_array << "&nbsp&nbsp&nbsp #{commit['message']}"
      commit_array << ""
    end
    
    return commit_array
  end

  def add_files(repo, files)
    unless files.nil?
      server_root = env["DOCUMENT_ROOT"].sub("/public","")
      Dir.chdir(repo.path.sub('.git',''))

      system("git add #{files.join(' ')}")

      Dir.chdir(server_root)
    end
  end

  def remove_files(repo, files)
    unless files.nil?
      server_root = env["DOCUMENT_ROOT"].sub("/public","")
      Dir.chdir(repo.path.sub('.git',''))

      system("git rm #{files.join(' ')}")

      Dir.chdir(server_root)
    end
  end

  def commit_with_result(repo, message)
    server_root = env["DOCUMENT_ROOT"].sub("/public","")
    Dir.chdir(repo.path.sub('.git',''))
    
    commit_result = []
    stdin, stdout, stderr = Open3.popen3("git commit -m '#{message}'")

    Dir.chdir(server_root)
    commit_result = stderr.read.split("\n") + stdout.read.split("\n")
    return commit_result
  end

  def push_with_result(repo, location, branch)
    server_root = env["DOCUMENT_ROOT"].sub("/public","")
    Dir.chdir(repo.path.sub('.git',''))
    
    push_result = []
    stdin, stdout, stderr = Open3.popen3("git push #{location} #{branch}")

    Dir.chdir(server_root)
    push_result = stderr.read.split("\n") + stdout.read.split("\n")
    return push_result
  end

  def pull_with_result(repo, remote = false, location = 'origin', branch = 'master')
    server_root = env["DOCUMENT_ROOT"].sub("/public","")
    Dir.chdir(repo)
    
    pull_result = []
    stdin, stdout, stderr = Open3.popen3("git pull #{location} #{branch}")

    Dir.chdir(server_root)
    pull_result = stderr.read.split("\n") + stdout.read.split("\n")
    return pull_result
    
  end
end

