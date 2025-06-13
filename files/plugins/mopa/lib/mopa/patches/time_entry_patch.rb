require_dependency 'time_entry'

module Mopa
	module Patches
		module TimeEntryPatch
			def self.included(base)
				base.class_eval do
					# unloadable
					validate :horasNoCertificadas
					before_destroy :check_if_can_be_destroyed

					protected
					def check_if_can_be_destroyed
						isActivo = Setting.plugin_mopa['isCertificadoActivo']
						if isActivo.present?
							timeEntry = TimeEntry.find(id)
							@mesImputado = timeEntry.spent_on.month
							@idProyecto = timeEntry.project_id
							
							sql = "select id_proyecto_gestor_tareas from CERTIFICACIONES_REALIZADAS where id_proyecto_gestor_tareas=#{@idProyecto} and mes=#{@mesImputado}"
							certificacion = self.class.connection.select_value(sql)

							if certificacion.present?
								throw(:abort)
							else
								return true
							end
						else
							return true
						end
					end

					protected
					def horasNoCertificadas
						id_estados = Setting.plugin_mopa['id_estados']
						if id_estados.include? issue.status_id.to_s
							isActivo = Setting.plugin_mopa['isCertificadoActivo']
							if isActivo.present?
								if spent_on.present?
									@mesImputado = spent_on.month
									@idProyecto = issue.project_id
									
									sql = "select id_proyecto_gestor_tareas from CERTIFICACIONES_REALIZADAS where id_proyecto_gestor_tareas=#{@idProyecto} and mes=#{@mesImputado}"
									certificacion = self.class.connection.select_value(sql)

									if certificacion.present?
										errors.add("error", "no se pueden crear/editar horas de esta tarea en esta fecha")
									else
										return true 
									end
								end
							else
								return true
							end
						else
							errors.add("error", "no se pueden crear/editar horas de esta tarea en este estado")
						end
					end
				end
			end
		end
	end
end

unless TimeEntry.included_modules.include?(Mopa::Patches::TimeEntryPatch)
	TimeEntry.send(:include, Mopa::Patches::TimeEntryPatch)
end