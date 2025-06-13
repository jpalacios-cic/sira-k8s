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

class IssuesControllerTest < ActionController::TestCase
  include Redmine::I18n

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
  RedmineAgile::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_agile).directory + '/test/fixtures/', [:agile_data, :agile_sprints])

  def setup
    @project_1 = Project.find(1)
    @project_2 = Project.find(5)
    EnabledModule.create(:project => @project_1, :name => 'agile')
    EnabledModule.create(:project => @project_2, :name => 'agile')
    @request.session[:user_id] = 1
    @issue1 = Issue.find(1)
    @issue2 = Issue.find(2)
  end
  def test_get_index_with_colors
    with_agile_settings "color_on" => "issue" do
      @issue1.color = AgileColor::AGILE_COLORS[:red]
      @issue1.save
      compatible_request :get, :index
      assert_response :success
      assert_select 'tr#issue-1.issue.bk-red', 1
    end
  end

  def test_get_index_with_sprint_filter
    sprint = AgileSprint.find(1)
    @issue1.agile_sprint = sprint
    @issue1.save
    compatible_request :get,
      :index,
      # :params => {
        # :set_filter => 1,
        "set_filter"=>"1", "sort"=>"id:desc", "f"=>["agile_sprints", ""], "op"=>{"agile_sprints"=>"="}, "v"=>{"agile_sprints"=>["1"]}, "c"=>["agile_sprint"]
        # :c => ['agile_sprints'],
        # :f => ['agile_sprints'],
        # :op => {'agile_sprints' => '='},
        # :v => {'agile_sprints' => ['1']
        # }

    compatible_request :get, :index
    assert_response :success
    # assert_equal @response.body.to_s, 'ds'
    assert_select 'tr#issue-1 td.agile_sprint', sprint.to_s

    # QueriesControllerTest {"project_id"=>"1", "type"=>"IssueQuery", "name"=>"agile_sprints"}
  end

  def test_post_issue_journal_color
    with_agile_settings 'color_on' => 'issue' do
      compatible_request :put, :update, :id => 1, :issue => { :agile_color_attributes => { :color => AgileColor::AGILE_COLORS[:red] } }
      details = @issue1.journals.order(:id).last.details.last
      assert @issue1.color
      assert_equal 'color', details.prop_key
      assert_equal AgileColor::AGILE_COLORS[:red], details.value
    end
  end

  def test_index_with_story_points_total
    compatible_request :get, :index, t: ['story_points']
    assert_response :success
    assert_select '.query-totals .total-for-story-points', text: l(:field_story_points) + ': 3'
  end

  def test_index_with_story_points_total_and_grouping
    compatible_request :get, :index, t: ['story_points'], group_by: 'project'
    assert_response :success
    assert_select '.query-totals .total-for-story-points', text: l(:field_story_points) + ': 3'
    assert_select 'tr.group', count: 4 do
      assert_select '.total-for-story-points .value', text: '3', count: 1
      assert_select '.total-for-story-points', text: 'Story points: 3', count: 1
      assert_select '.total-for-story-points', text: 'Story points: 0', count: 3
    end
  end

  def test_new_issue_with_sp_value
    with_agile_settings 'estimate_units' => 'story_points', 'story_points_on' => '1' do
      compatible_request :get, :new, :project_id => 1
      assert_response :success
      assert_select 'input#issue_agile_data_attributes_story_points'
    end
  end

  def test_new_issue_without_sp_value
    with_agile_settings 'estimate_units' => 'hours', 'story_points_on' => '0' do
      compatible_request :get, :new, :project_id => 1
      assert_response :success
      assert_select 'input#issue_agile_data_attributes_story_points', :count => 0
    end
  end

  def test_create_issue_with_sp_value
    with_agile_settings 'estimate_units' => 'story_points', 'story_points_on' => '1' do
      assert_difference 'Issue.count' do
        compatible_request :post, :create, :project_id => 1, :issue => {
          :subject => 'issue with sp',
          :tracker_id => 3,
          :status_id => 1,
          :priority_id => IssuePriority.first.id,
          :agile_data_attributes => { :story_points => 50 }
        }
      end
      issue = Issue.last
      assert_equal 'issue with sp', issue.subject
      assert_equal 50, issue.story_points
    end
  end

  def test_post_issue_journal_story_points
    with_agile_settings 'estimate_units' => 'story_points', 'story_points_on' => '1' do
      compatible_request :put, :update, :id => 1, :issue => { :agile_data_attributes => { :story_points => 100 } }
      assert_equal 100, @issue1.story_points
      sp_history = JournalDetail.where(:property => 'attr', :prop_key => 'story_points', :journal_id => @issue1.journals).last
      assert sp_history
      assert_equal 100, sp_history.value.to_i
    end
  end

  def test_show_issue_with_story_points
    with_agile_settings 'estimate_units' => 'story_points', 'story_points_on' => '1' do
      compatible_request :get, :show, :id => 1
      assert_response :success
      assert_select '#issue-form .attributes', :text => /Story points/, :count => 1
    end
  end

  def test_show_issue_with_order_by_story_points
    session[:issue_query] = { :project_id => @issue1.project_id,
                              :filters => { 'status_id' => { :operator => 'o', :values => [''] } },
                              :group_by => '',
                              :column_names => [:tracker, :status, :story_points],
                              :totalable_names => [],
                              :sort => [['story_points', 'asc'], ['id', 'desc']]
                            }
    with_agile_settings 'estimate_units' => 'story_points', 'story_points_on' => '1' do
      compatible_request :get, :show, :id => 1
      assert_response :success
      assert_select '#issue-form .attributes', :text => /Story points/, :count => 1
    end
  ensure
    session[:issue_query] = {}
  end
  def test_update_issue_story_points_save_sprint
    @request.session[:user_id] = 2
    with_agile_settings 'estimate_units' => 'story_points', 'story_points_on' => '1' do
      assert @issue2.agile_sprint
      compatible_request :put, :update, id: 2, issue: { agile_data_attributes: { agile_sprint_id: 0, story_points: 3 } }
      assert_response :redirect
      assert @issue2.reload.agile_sprint
    end
  end

  def test_show_issue_form_with_story_points_select
    with_agile_settings('sp_values' => [1,2,3],
      'estimate_units' => 'story_points', 'story_points_on' => '1') do
        compatible_request :get, :new, :project_id => 1
        assert_response :success
        assert_select 'select#issue_agile_data_attributes_story_points'
    end
  end

  def test_dont_show_story_points_select_when_no_sp_values
    with_agile_settings('sp_values' => [],
      'estimate_units' => 'story_points', 'story_points_on' => '1') do
        compatible_request :get, :new, :project_id => 1
        assert_response :success
        assert_select 'select#issue_agile_data_attributes_story_points', :count => 0
    end
  end

  def test_issue_bulk_edit_with_color_field
    with_agile_settings('color_on' => 'issue') do
      compatible_request :get, :bulk_edit, ids: [1, 2]
      assert_response :success
      assert_select "#issue_agile_color_attributes_color"
      assert_element_bulk_edit('issue_agile_color_attributes_color')

      assert_match "issue_agile_data_attributes_agile_sprint_id", @response.body
      assert_element_bulk_edit('issue_agile_data_attributes_agile_sprint_id')
    end
  end

  def test_issue_bulk_edit_without_color_field
    compatible_request :get, :bulk_edit, ids: [1, 2]
    assert_response :success
    assert_select "#issue_agile_color_attributes_color", false

    assert_match "issue_agile_data_attributes_agile_sprint_id", @response.body
    assert_element_bulk_edit('issue_agile_data_attributes_agile_sprint_id')
  end

  def test_issue_bulk_edit_with_sp_field
    with_agile_settings(
      'sp_values' => [1,2,3],
      'estimate_units' => 'story_points',
      'story_points_on' => '1') do
      compatible_request :post, :bulk_edit, {ids: [1, 2], issue: { tracker_id: '3' }}
      assert_response :success
      assert_select "#issue_agile_data_attributes_story_points"
      assert_element_bulk_edit('issue_agile_data_attributes_story_points')
    end
  end

  def test_issue_bulk_edit_without_sp_field
    with_agile_settings('sp_values' => [], 'story_points_on' => '0') do
      compatible_request :post, :bulk_edit, {ids: [1, 2], issue: { tracker_id: '2' }}
      assert_response :success
      assert_select "#issue_agile_data_attributes_story_points", false
    end
  end

  def test_bulk_update_for_sprint_with_story_points
    issues = Issue.where(id: [1,2])
    assert_equal [1, 2], issues.map { |issue| issue.agile_data.story_points }
    with_agile_settings('sp_values' => [1,2,3], 'estimate_units' => 'story_points', 'story_points_on' => '1') do
        compatible_request :post, :bulk_update, ids: [1,3], issue: { agile_data_attributes: { agile_sprint_id: '1', id: '' } }
        assert_response :redirect
        assert_equal [1, 2], issues.map { |issue| issue.agile_data.story_points }
    end
  end

  def test_bulk_update_save_agile_data_for_copies
    issue_ids = [1, 3]
    issues = Issue.where(id: issue_ids)
    assert_equal [1, 0], issues.map { |issue| issue.agile_data.story_points.to_i }
    with_agile_settings('sp_values' => [1,2,3], 'estimate_units' => 'story_points', 'story_points_on' => '1') do
        compatible_request :post, :bulk_update, { ids: issue_ids, link_copy: 1, copy: 1, copy_subtasks: 1 }
        assert_response :redirect
        assert_equal [1, 0], Issue.last(2).map { |issue| issue.agile_data.story_points.to_i }
    end
  end

  def test_issue_bulk_update_with_none_fields
    issues = Issue.where(id: [1, 2])
    # save old issues agile data
    # [ [sprint_id, story_points, color], [sprint_id, story_points, color] ]
    old_issues_agile = []
    issues.each_with_index do |issue, ind|
      old_issues_agile[ind] = [
        issue.agile_sprint.try(:id),
        issue.agile_data.story_points,
        issue.color
      ]
    end

    params = {
      ids: [1, 2],
      issue: {
        agile_data_attributes: {
          agile_sprint_id: '',
          story_points: ''
        }
      }
    }
    with_agile_settings('color_on' => 'issue') do
      compatible_request :post, :bulk_update, params
      assert_response :redirect

      old_issues_agile.each_with_index do |old_issue, ind|
        issues[ind].reload
        assert_equal old_issue[0], issues[ind].agile_sprint.try(:id)
        assert_equal old_issue[1], issues[ind].agile_data.story_points
      end
    end
  end

  def test_issue_bulk_edit_dont_break_with_tasks_from_different_projects
    compatible_request :get, :bulk_edit, ids: [1, 4]
    assert_response :success
  end

  def test_issue_bulk_edit_with_sprint_field
    compatible_request :get, :bulk_edit, ids: [1, 2]
    assert_response :success
    assert_match "issue_agile_data_attributes_agile_sprint_id", @response.body
  end

  def test_issue_bulk_update_with_sprint_field
    issues = Issue.where(id: [1, 2])
    compatible_request :post, :bulk_update, ids: [1, 2], issue: { agile_data_attributes: { agile_sprint_id: '1' } }
    assert_response :redirect
    assert_equal [1, 1], issues.map { |issue| issue.reload.agile_sprint.id }
  end

  def test_issue_bulk_update_with_color_field
    issues = Issue.where(id: [1, 2])
    params = {
        ids: [1, 2],
        issue: {
            agile_color_attributes: {
                color: AgileColor::AGILE_COLORS[:green]
            }
        }
    }
    with_agile_settings('color_on' => 'issue') do
      compatible_request :post, :bulk_update, params
      assert_response :redirect
      assert_equal ['green', 'green'], issues.map { |issue| issue.color }
    end
  end

  def test_issue_bulk_edit_with_different_projects_without_sp_field
    with_agile_settings('story_points_on' => '1') do
      compatible_request :get, :bulk_edit, ids: [1, 4]
      assert_response :success
      assert_select "#issue_agile_data_attributes_story_points", false
    end
  end

  def test_issue_bulk_edit_with_sp_field
    with_agile_settings(
      'sp_values' => [1, 2, 3],
      'estimate_units' => 'story_points',
      'story_points_on' => '1') do
      compatible_request :post, :bulk_edit, {ids: [1, 2], issue: { tracker_id: '3' }}
      assert_response :success
      assert_select "#issue_agile_data_attributes_story_points"
      assert_element_bulk_edit('issue_agile_data_attributes_story_points')
    end
  end

  def test_issue_bulk_update_with_sp_field
    issues = Issue.where(id: [1, 2])
    params = {
        ids: [1, 2],
        issue: {
            agile_data_attributes: {
                story_points: '3'
            },
            tracker_id: '3'
        }
    }
    with_agile_settings('story_points_on' => '1') do
      compatible_request :post, :bulk_update, params
      assert_response :redirect
      assert_equal [3, 3], issues.map { |issue| issue.story_points }
    end
  end

  def test_issue_bulk_edit_without_sp_field
    with_agile_settings('sp_values' => [], 'story_points_on' => '0') do
      compatible_request :post, :bulk_edit, {ids: [1, 2], issue: { tracker_id: '2' }}
      assert_response :success
      assert_select "#issue_agile_data_attributes_story_points", false
    end
  end

  def test_update_for_sprint_with_story_points
    @request.session[:user_id] = 2 # User without manage_sprints permission
    assert_equal 1, @issue2.agile_data.agile_sprint_id
    assert_equal 2, @issue2.agile_data.story_points
    with_agile_settings('sp_values' => [1,2,3], 'estimate_units' => 'story_points', 'story_points_on' => '1') do
      compatible_request :put, :update, id: @issue2.id, issue: { agile_data_attributes: { story_points: '3', id: @issue2.agile_data.id } }
      assert_response :redirect
      @issue2.reload
      assert_equal 1, @issue2.agile_data.agile_sprint_id
      assert_equal 3, @issue2.agile_data.story_points
    end
  end

  def test_update_closed_issue_with_all_closed_sprints
    @request.session[:user_id] = 1
    assert_equal 1, @issue2.agile_data.agile_sprint_id
    # close issue with sprint 1
    @issue2.update(status_id: 5)
    # close all sprints
    AgileSprint.update_all(status: AgileSprint::CLOSED)
    # get edit issue page
    compatible_request :get, :edit, id: @issue2.id

    # expect: related sprint 1 present in the issue's sprints
    assert_select '#issue_agile_data_attributes_agile_sprint_id' do
      assert_select 'optgroup' do
        assert_select 'option', value: @issue2.agile_data.agile_sprint_id
      end
    end
  end

  private

  def assert_element_bulk_edit(element_id)
    assert_select "select##{element_id}" do |options|
      options.each do |option|
        assert_select option, 'option[value="none"]'
        assert_select option, 'option[value=""][selected="selected"]'
      end
    end
  end
end
