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

require File.expand_path('../../../test_helper', __FILE__)

class VelocityChartTest < ActiveSupport::TestCase
  fixtures :users, :projects, :trackers, :enumerations, :issue_statuses, :issue_categories

  def setup
    @user = User.first
    @tracker = Tracker.first
    @project = Project.first_or_create(name: 'VelocityChartTest', identifier: 'velocitycharttest')
    @project.trackers << @tracker unless @project.trackers.include?(@tracker)
    @new_status = IssueStatus.where(name: 'New').first
    @closed_status = IssueStatus.where(name: 'Closed').first
  end

  def test_returned_data
    chart_data_cases.each do |test_case|
      test_case_issues = test_case[:issues].call
      test_case[:interval_data].each do |case_interval|
        chart_data = RedmineAgile::Charts::VelocityChart.data(test_case_issues, case_interval[:options])
        assert_equal case_interval[:result], extract_values(chart_data)
      end
      test_case_issues.destroy_all
    end
  ensure
    @project.issues.destroy_all
    @project.destroy
  end

  private

  def extract_values(chart_data)
    { title: chart_data[:title], datasets: chart_data[:datasets].map { |data| data.slice(:type, :data, :label) } }
  end

  def chart_data_cases
    data_cases = [
      {
        name: 'every month issues',
        issues: Proc.new { Issue.where(id: (1..12).map { |month| create_issue_data(month) }.flatten) },
        intervals: {
          day: {
            title: 'Velocity',
            dates: { date_from: Date.parse('2018-12-31'), date_to: Date.parse('2019-01-01'), interval_size: 'day' },
            result: [
                     { type: 'bar', data: [0, 2.0], label: 'Created' },
                     { type: 'line', data: [0.0, 2.0], label: 'Created trendline' },
                     { type: 'bar', data: [0, 1.0], label: 'Closed' },
                     { type: 'line', data: [0.0, 1.0], label: 'Closed trendline' }
                   ]
          },
          month: {
            title: 'Velocity',
            dates: { date_from: Date.parse('2019-03-01'), date_to: Date.parse('2019-03-31'), interval_size: 'week' },
            result: [
                     { type: 'bar', data: [2.0, 0, 0, 0, 0], label: 'Created' },
                     { type: 'line', data: [1.2000000000000002, 0.8, 0.3999999999999999, 0.0], label: 'Created trendline' },
                     { type: 'bar', data: [2, 0, 0, 0, 0], label: 'Closed' },
                     { type: 'line', data: [1.2000000000000002, 0.8, 0.3999999999999999, 0.0], label: 'Closed trendline' }
                   ]
          },
          year: {
            title: 'Velocity',
            dates: { date_from: Date.parse('2019-01-01'), date_to: Date.parse('2019-12-31'), interval_size: 'month' },
            result: [
                     { type: 'bar', data: [4, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 0], label: 'Created' },
                     { type: 'line', data: [2.9340659340659343, 2.7527472527472527, 2.5714285714285716, 2.39010989010989, 2.208791208791209, 2.0274725274725274, 1.8461538461538463, 1.664835164835165, 1.4835164835164836, 1.3021978021978022, 1.120879120879121, 0.9395604395604398, 0.75824175824175826], label: 'Created trendline' },
                     { type: 'bar', data: [2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 1, 1, 0], label: 'Closed' },
                     { type: 'line', data: [1.2857142857142858, 1.2252747252747254, 1.164835164835165, 1.1043956043956045, 1.043956043956044, 0.9835164835164836, 0.9230769230769231, 0.8626373626373627, 0.8021978021978023, 0.7417582417582419, 0.6813186813186815, 0.620879120879121, 0.5604395604395606], label: 'Closed trendline' }
                   ]
          },
          between: {
            title: 'Velocity',
            dates: { date_from: Date.parse('2019-07-01'), date_to: Date.parse('2019-12-31'), interval_size: 'month' },
            result: [
                     { type: 'bar', data: [2, 2, 2, 2, 1, 1, 0], label: 'Created' },
                     { type: 'line', data: [2.392857142857143, 2.0714285714285716, 1.75, 1.4285714285714286, 1.1071428571428572, 0.7857142857142856, 0.4642857142857144], label: 'Created trendline' },
                     { type: 'bar', data: [2, 0, 2, 0, 1, 1, 0], label: 'Closed' },
                     { type: 'line', data: [1.3928571428571428, 1.2142857142857142, 1.0357142857142856, 0.8571428571428571, 0.6785714285714285, 0.5, 0.3214285714285714], label: 'Closed trendline' }
                   ]
          }
        }
      },
      {
        name: 'every month issues by hours',
        issues: Proc.new { Issue.where(id: (1..12).map { |month| create_issue_data(month) }.flatten) },
        intervals: {
          day: {
              title: 'Velocity',
              dates: { date_from: Date.parse('2018-12-31'), date_to: Date.parse('2019-01-01'), chart_unit: 'hours', interval_size: 'day' },
              result: [
                       { type: 'bar', data: [0, 6.0], label: 'Created' },
                       { type: 'line', data: [0.0, 6.0], label: 'Created trendline' },
                       { type: 'bar', data: [0, 2.8], label: 'Closed' },
                       { type: 'line', data: [2.8000000000000003], label: 'Closed trendline' }
                     ]
          },
          month: {
              title: 'Velocity',
              dates: { date_from: Date.parse('2019-03-01'), date_to: Date.parse('2019-03-31'), chart_unit: 'hours', interval_size: 'week' },
              result: [
                       { type: 'bar', data: [17.0, 0, 0, 0, 0], label: 'Created' },
                       { type: 'line', data: [10.2, 6.8, 3.4000000000000004, 0.0], label: 'Created trendline' },
                       { type: 'bar', data: [19.8, 0, 0, 0, 0], label: 'Closed' },
                       { type: 'line', data: [11.879999999999999, 7.92, 3.960000000000001, 0.0], label: 'Closed trendline' }
                     ]
          },
          year: {
              title: 'Velocity',
              dates: { date_from: Date.parse('2019-01-01'), date_to: Date.parse('2019-12-31'), chart_unit: 'hours', interval_size: 'month' },
              result: [
                       { type: 'bar', data: [14.0, 13.0, 17.0, 21.0, 25.0, 29.0, 33.0, 37.0, 41.0, 45.0, 24.0, 25.0, 0], label: 'Created' },
                       { type: 'line', data: [21.0989010989011, 21.736263736263734, 22.373626373626372, 23.010989010989007, 23.648351648351646, 24.285714285714285, 24.92307692307692, 25.56043956043956, 26.197802197802197, 26.835164835164832, 27.47252747252747, 28.10989010989011, 28.747252747252745], label: 'Created trendline' },
                       { type: 'bar', data: [6.8, 0, 19.8, 0, 36.0, 0, 55.4, 0, 78.0, 0, 22.0, 23.0, 0], label: 'Closed' },
                       { type: 'line', data: [13.032967032967033, 13.95054945054945, 14.868131868131869, 15.785714285714285, 16.7032967032967, 17.62087912087912, 18.538461538461537, 19.456043956043956, 20.373626373626372, 21.29120879120879, 22.208791208791208, 23.126373626373628, 24.043956043956044], label: 'Closed trendline' }
                     ]
          },
          between: {
              title: 'Velocity',
              dates: { date_from: Date.parse('2019-07-01'), date_to: Date.parse('2019-12-31'), chart_unit: 'hours', interval_size: 'month' },
              result: [
                       { type: 'bar', data: [33.0, 37.0, 41.0, 45.0, 24.0, 25.0, 0], label: 'Created' },
                       { type: 'line', data: [44.285714285714285, 39.285714285714285, 34.285714285714285, 29.285714285714285, 24.285714285714285, 19.285714285714285, 14.285714285714285], label: 'Created trendline' },
                       { type: 'bar', data: [55.4, 0, 78.0, 0, 22.0, 23.0, 0], label: 'Closed' },
                       { type: 'line', data: [44.364285714285714, 38.07142857142857, 31.77857142857143, 25.485714285714284, 19.19285714285714, 12.899999999999999, 6.607142857142854], label: 'Closed trendline' }
                     ]
          }
        }
      },
      {
          name: 'every month issues by sp',
          issues: Proc.new { Issue.where(id: (1..12).map { |month| create_issue_data(month) }.flatten) },
          intervals: {
              day: {
                  title: 'Velocity',
                  dates: { date_from: Date.parse('2018-12-31'), date_to: Date.parse('2019-01-01'), chart_unit: 'story_points', interval_size: 'day' },
                  result: [
                           { type: 'bar', data: [0, 30.0], label: 'Created' },
                           { type: 'line', data: [0.0, 30.0], label: 'Created trendline' },
                           { type: 'bar', data: [0, 14.0], label: 'Closed' },
                           { type: 'line', data: [0.0, 14.0], label: 'Closed trendline' }
                         ]
              },
              month: {
                  title: 'Velocity',
                  dates: { date_from: Date.parse('2019-03-01'), date_to: Date.parse('2019-03-31'), chart_unit: 'story_points', interval_size: 'week' },
                  result: [
                           { type: 'bar', data: [81, 0, 0, 0, 0], label: 'Created' },
                           { type: 'line', data: [48.599999999999994, 32.4, 16.200000000000003, 0.0], label: 'Created trendline' },
                           { type: 'bar', data: [93.4, 0, 0, 0, 0], label: 'Closed' },
                           { type: 'line', data: [56.04, 37.36, 18.68, 0.0], label: 'Closed trendline' }
                         ]
              },
              year: {
                  title: 'Velocity',
                  dates: { date_from: Date.parse('2019-01-01'), date_to: Date.parse('2019-12-31'), chart_unit: 'story_points', interval_size: 'month' },
                  result: [
                           { type: 'bar', data: [62, 61, 81, 101, 121, 141, 161, 181, 201, 221, 120, 121, 0], label: 'Created' },
                           { type: 'line', data: [99.6923076923077, 103.23076923076924, 106.76923076923077, 110.30769230769232, 113.84615384615385, 117.38461538461539, 120.92307692307693, 124.46153846153847, 128.0, 131.53846153846155, 135.0769230769231, 138.6153846153846, 142.15384615384616], label: 'Created trendline' },
                           { type: 'bar', data: [29.2, 0, 93.4, 0, 173.6, 0, 269.8, 0, 382.0, 0, 110, 111, 0], label: 'Closed' },
                           { type: 'line', data: [61.472527472527474, 66.21428571428572, 70.95604395604396, 75.6978021978022, 80.43956043956044, 85.18131868131869, 89.92307692307693, 94.66483516483517, 99.4065934065934, 104.14835164835165, 108.8901098901099, 113.63186813186815, 118.37362637362638], label: 'Closed trendline' }
                         ]
              },
              between: {
                  title: 'Velocity',
                  dates: { date_from: Date.parse('2019-07-01'), date_to: Date.parse('2019-12-31'), chart_unit: 'story_points', interval_size: 'month' },
                  result: [
                           { type: 'bar', data: [161, 181, 201, 221, 120, 121, 0], label: 'Created' },
                           { type: 'line', data: [216.85714285714286, 192.42857142857142, 168.0, 143.57142857142856, 119.14285714285714, 94.71428571428572, 70.28571428571428], label: 'Created trendline' },
                           { type: 'bar', data: [269.8, 0, 382.0, 0, 110, 111, 0], label: 'Closed' },
                           { type: 'line', data: [216.76428571428565, 186.07142857142853, 155.3785714285714, 124.68571428571428, 93.99285714285716, 63.30000000000004, 32.60714285714292], label: 'Closed trendline' }
                         ]
              }
          }
      }
    ]

    test_cases = data_cases.map do |test_case|
      {
        issues: test_case[:issues],
        interval_data: test_case[:intervals].map do |interval_name, interval_data|
                        {
                          name: [test_case[:name], 'interval', interval_name].join(' '),
                          options: { chart_unit: 'issues', interval_size: 'day' }.merge(interval_data[:dates]),
                          result: { title: interval_data[:title], datasets: interval_data[:result] }
                        }
                      end
      }
    end

    test_cases
  end

  def create_issue_data(month)
    closed_month = month.to_s.rjust(2, '0')
    created_month = (month > 1 ? month - 1 : month).to_s.rjust(2, '0')
    issue_ids = []
    # 2 issue per month
    2.times do |i|
      issue = Issue.create!(tracker: @tracker,
                            project: @project,
                            author: @user,
                            subject: "Issue ##{month} - #{i}",
                            done_ratio: (month.even? && month < 11) ? month * 10 : 0,
                            status: month.odd? ? @closed_status : @new_status,
                            estimated_hours: month * 2 + i)
      issue.reload
      issue.create_agile_data(story_points: month * 10 + i)
      issue.update(created_on: "2019-#{created_month}-0#{i + 1} 09:00", closed_on: "2019-#{closed_month}-0#{i + 1} 11:00")
      issue_ids << issue.id
    end
    issue_ids
  end
end
