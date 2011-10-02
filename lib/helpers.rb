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
    $log.debug "files to add: #{files.join(' ')}"
    unless files.nil?
      server_root = env["DOCUMENT_ROOT"].sub("/public","")
      Dir.chdir(repo.path.sub('.git',''))

      system("git add #{files.join(' ')}")

      Dir.chdir(server_root)
    end
  end

  def remove_files(repo, files)
    $log.debug "files to delete: #{files.join(' ')}"
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

    IO.popen "git commit -m '#{message}'" do |fd|
      until fd.eof?
        commit_result << fd.readline
      end
    end
    Dir.chdir(server_root)

    return commit_result
  end

end

