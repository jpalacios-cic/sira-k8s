require_dependency 'issues_helper'

module Mopa
	module Patches
		module IssuesHelperPatch
			def self.included(base)
				base.send(:include, InstanceMethods)

				base.class_eval do
					# unloadable
					alias_method :issue_heading, :tittleOverrided
				end
			end

			module InstanceMethods
				def tittleOverrided(issue)
					project = Project.find(issue.project.id)
					@identifier = project.identifier.upcase
					#h("#{issue.tracker} ##{issue.id} [#{@identifier}-#{issue.issueNumber}]")
					h("#{issue.tracker} ##{issue.id} [#{@identifier}-#{issue.id}]")
				end
			end
		end
	end
end

unless IssuesHelper.included_modules.include?(Mopa::Patches::IssuesHelperPatch)
	IssuesHelper.send(:include, Mopa::Patches::IssuesHelperPatch)
end