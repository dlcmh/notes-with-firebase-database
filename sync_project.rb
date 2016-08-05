PROJECTS = 'projects'
CURRENT_DIR = __dir__
LAST_SYNCED_FILE = 'LAST_SYNCED'

def projects_is_second_to_last_element_in_current_dir
  expected_projects_position == actual_projects_position
end

def expected_projects_position
  CURRENT_DIR.split('/').size - 2
end

def actual_projects_position
  CURRENT_DIR.split('/').rindex(PROJECTS)
end

def project_name
  File.basename(CURRENT_DIR)
end

def target_dropbox_folder_for_rsync
  File.join(Dir.home, 'Dropbox', PROJECTS, project_name)
end

def target_dropbox_folder_for_rsync_does_not_exist
  true unless Dir.exists? target_dropbox_folder_for_rsync
end

def needs_initial_sync
  target_dropbox_folder_for_rsync_does_not_exist
end

def perform_initial_sync
  puts "performing initial sync for #{project_name}"
  Dir.mkdir target_dropbox_folder_for_rsync
  two_way_project_dropbox_sync
  puts 'done'
end

def perform_normal_sync
  puts "performing normal sync for #{project_name}"
  two_way_project_dropbox_sync
  puts 'done'
end

def two_way_project_dropbox_sync
  if dropbox_last_sync_is_newer
    puts 'dropbox has more recent sync'
    sync_dropbox_to_project
    update_project_synced_datetime_to_that_of_dropbox
  else
    sync_project_to_dropbox
    update_synced_datetime_to_project_and_dropbox
  end
end

def dropbox_last_sync_is_newer
  last_synced_datetime_per_dropbox > last_synced_datetime_per_project
end

def last_synced_datetime_per_project
  File.read project_last_synced_file
end

def last_synced_datetime_per_dropbox
  File.read dropbox_last_synced_file
end

def update_synced_datetime_to_project_and_dropbox
  timestamp = Time.now
  open(project_last_synced_file, 'w').write(timestamp)
  open(dropbox_last_synced_file, 'w').write(timestamp)
end

def update_project_synced_datetime_to_that_of_dropbox
  timestamp = last_synced_datetime_per_dropbox
  open(project_last_synced_file, 'w').write(timestamp)
end

def project_last_synced_file
  File.join(CURRENT_DIR, LAST_SYNCED_FILE)
end

def dropbox_last_synced_file
  File.join(target_dropbox_folder_for_rsync, LAST_SYNCED_FILE)
end


def sync_project_to_dropbox
  puts 'syncing from project to dropbox'
  rsync(CURRENT_DIR, target_dropbox_folder_for_rsync)
end

def sync_dropbox_to_project
  puts 'syncing from dropbox to project'
  rsync(target_dropbox_folder_for_rsync, CURRENT_DIR)
end

def rsync(src, dest)
  src += '/'
  `rsync --archive --delete --exclude-from=.gitignore \
   #{src} #{dest}`
end

def sync
  return unless projects_is_second_to_last_element_in_current_dir
  if needs_initial_sync
    perform_initial_sync
  else
    perform_normal_sync
  end
  exec "fswatch -1 . | xargs -0 -n1 ruby #{__FILE__}"
end

sync
