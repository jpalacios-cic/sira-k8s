require_dependency 'issue'

module Mopa
	module Patches
		module IssuePatch
			def self.included(base)
				base.class_eval do
					# unloadable

					validate :validarMaxEstimado

					protected
					def validarMaxEstimado
					  Rails.logger.info "plugin_mopa: #{Setting.plugin_mopa.inspect}"
					  idTarea = Setting.plugin_mopa['id_tarea']
					  Rails.logger.info "idTarea: #{idTarea.inspect}"
					  if idTarea.present? && idTarea.include?(tracker_id.to_s)
							max_horas = Setting.plugin_mopa['max_horas']
							if max_horas.present?
								if estimated_hours.present?
									if estimated_hours <= max_horas.to_f
										return true 
									else
									  errors.add("error", "el tiempo estimado no puede ser superior a #{max_horas} horas")
									end
								end
							else 
								return true
							end
						end
					end
				end
			end
		end
	end
end

unless Issue.included_modules.include?(Mopa::Patches::IssuePatch)
	Issue.send(:include, Mopa::Patches::IssuePatch)
end