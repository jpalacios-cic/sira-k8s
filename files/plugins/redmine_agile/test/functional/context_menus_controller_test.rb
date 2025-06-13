# encoding: utf-8
#
# This file is a part of Redmin Agile (redmine_agile) plugin,
# Agile board plugin for redmine
#
# Copyright (C) 2011-2024 RedmineUP
# http://www.redmineup.com/
#
# redmine_agile is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_agile is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_agile.  If not, see <http://www.gnu.org/licenses/>.

require File.expand_path('../../test_helper', __FILE__)

class ContextMenusControllerTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries

  RedmineAgile::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_agile).directory + '/test/fixtures/', [:agile_data,
                                                                                                              :agile_sprints])

  def setup
    @project = Project.find(1)
    @issue1 = Issue.find(1)
    @issue2 = Issue.find(4)
    @shared_sprint = AgileSprint.create!(
      project_id: 2,
      name: 'Common sprint',
      description: 'Common sprint for test',
      status: 0,
      start_date: Date.today,
      end_date: Date.today + 1.week,
      sharing: 4
    )

    EnabledModule.create(:project => @project, :name => 'agile')
    EnabledModule.create(:project => @project, :name => 'agile_backlog')
    @request.session[:user_id] = 1
  end
  def test_get_issues_context_menu_with_sprint_attributes
    compatible_request :get, :issues, project_id: @project.id, ids: [@issue1.id]
    assert_response :success
    assert_match ERB::Util.url_encode("issue[agile_data_attributes][id]=1").gsub('%3D', '='), @response.body
  end

  def test_get_issues_context_menu_with_shared_sprint_attributes
    compatible_request :get, :issues, project_id: @project.id, ids: [@issue1.id, @issue2.id]
    assert_response :success
    assert_match @shared_sprint.name, @response.body
  end
end
