helpers do

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
    stdout, stderr = Open3.capture3("git commit -m '#{message}'")

    Dir.chdir(server_root)
    commit_result = stderr.split("\n") + stdout.split("\n")
    return commit_result
  end

  def push_with_result(repo, location, branch)
    server_root = env["DOCUMENT_ROOT"].sub("/public","")
    Dir.chdir(repo.path.sub('.git',''))
    
    push_result = []
    stdout, stderr = Open3.capture3("git push #{location} #{branch}")

    Dir.chdir(server_root)
    push_result = stderr.split("\n") + stdout.split("\n")
    return push_result
  end

  def pull_with_result(repo, remote = false, location = 'origin', branch = 'master')
    server_root = env["DOCUMENT_ROOT"].sub("/public","")
    Dir.chdir(repo)
    
    pull_result = []
    stdout, stderr = Open3.capture3("git pull #{location} #{branch}")

    Dir.chdir(server_root)
    pull_result = stderr.split("\n") + stdout.split("\n")
    return pull_result
    
  end
end

