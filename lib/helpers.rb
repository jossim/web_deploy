helpers do

  def get_projects
    return APP_DATA['projects']
  end

  def get_project_by_id(id)
    projects = get_projects()
    return projects[id]
  end

  def get_untracked_files(repo)
    file_objects = repo.status.untracked
    file_paths = []
    
    file_objects.each do |file|
      file_paths << file[1].path
    end
    
    return file_paths
  end

  def get_changed_files(repo)
    file_objects = repo.status.changed
    file_paths = []
    
    file_objects.each do |file|
      file_paths << file[1].path
    end
    
    return file_paths

  end

  def get_deleted_files(repo)
    file_objects = repo.status.deleted
    file_paths = []
    
    file_objects.each do |file|
      file_paths << file[1].path
    end
    
    return file_paths

  end

end
