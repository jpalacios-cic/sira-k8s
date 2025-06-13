module RedmineFavoriteProjects
  def self.settings() Setting[:plugin_redmine_favorite_projects].blank? ? {} : Setting[:plugin_redmine_favorite_projects] end

  def self.default_list_style
    return (%w(list list_cards) && [RedmineFavoriteProjects.settings["default_list_style"]]).first || "list"
  end
end

REDMINE_FAVORITE_PROJECTS_REQUIRED_FILES = [
  'redmine_favorite_projects/helpers/favorite_projects_helper',
  'redmine_favorite_projects/hooks/views_projects_form_hook',
  'redmine_favorite_projects/hooks/views_layouts_hook',
  'redmine_favorite_projects/patches/project_patch',
  'redmine_favorite_projects/patches/projects_controller_patch',
  'redmine_favorite_projects/patches/projects_helper_patch',
  'redmine_favorite_projects/patches/auto_completes_controller_patch',
  'redmine_favorite_projects/patches/queries_helper_patch',
  'redmine_favorite_projects/patches/access_control_patch'
]

if Redmine::VERSION.to_s >= '4.2'
  REDMINE_FAVORITE_PROJECTS_REQUIRED_FILES << 'redmine_favorite_projects/patches/application_helper_patch'
end

base_url = File.dirname(__FILE__)
REDMINE_FAVORITE_PROJECTS_REQUIRED_FILES.each { |file| require(base_url + '/' + file) }
