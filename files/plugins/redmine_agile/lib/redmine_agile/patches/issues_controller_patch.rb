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

module RedmineAgile
  module Patches
    module IssuesControllerPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          helper :agile_sprints
          include AgileSprintsHelper

          alias_method :parse_params_for_bulk_update_without_agile, :parse_params_for_bulk_update
          alias_method :parse_params_for_bulk_update, :parse_params_for_bulk_update_with_agile
        end
      end

      module InstanceMethods
        def parse_params_for_bulk_update_with_agile(params)
          return parse_params_for_bulk_update_without_agile({}) unless params

          agile_data = [:agile_data_attributes, :agile_color_attributes]
          attributes = parse_params_for_bulk_update_without_agile(params)

          agile_data.each do |agile_attr|
            if attributes[agile_attr].present?
              attributes[agile_attr].reject! {|k, v| v.blank?}
              attributes[agile_attr] = replace_none_values_with_blank(attributes[agile_attr])
              attributes.delete(agile_attr) if attributes[agile_attr].blank?
            end
          end

          attributes
        end

        private

        def replace_none_values_with_blank(params)
          attributes = (params || {})
          attributes.keys.each {|k| attributes[k] = '' if attributes[k] == 'none'}
          if (custom = attributes[:custom_field_values])
            custom.keys.each do |k|
              if custom[k].is_a?(Array)
                custom[k] << '' if custom[k].delete('__none__')
              else
                custom[k] = '' if custom[k] == '__none__'
              end
            end
          end
          attributes
        end
      end
    end
  end
end

unless IssuesController.included_modules.include?(RedmineAgile::Patches::IssuesControllerPatch)
  IssuesController.send(:include, RedmineAgile::Patches::IssuesControllerPatch)
end
