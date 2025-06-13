require 'redmine'

Redmine::Plugin.register :sira do
	name 'Plugin SIRA'
	author 'CIC'
	description 'Plugin SIRA'
	version '1.0.0'
	url 'https://www.cic.es/'
	author_url 'https://www.cic.es/'
	menu	:top_menu,
			:sira1,
			'/projects/grupo_cic/time_entries/report?utf8=%E2%9C%93&criteria%5B%5D=user&set_filter=1&sort=spent_on%3Adesc&f%5B%5D=spent_on&op%5Bspent_on%5D=m&f%5B%5D=user_id&op%5Buser_id%5D=%3D&v%5Buser_id%5D%5B%5D=me&f%5B%5D=&group_by=user&t%5B%5D=hours&t%5B%5D=&columns=day&criteria%5B%5D=issue&encoding=ISO-8859-15',
			{
				:caption => 'Mis imputaciones de este mes',
				:html => {:title => 'Ver las imputaciones del usuario del mes actual'}
			}
	
	menu 	:top_menu,
			:sira2,
			'/projects/grupo_cic/time_entries/report?utf8=%E2%9C%93&criteria%5B%5D=project&set_filter=1&sort=spent_on%3Adesc&f%5B%5D=spent_on&op%5Bspent_on%5D=m&f%5B%5D=subproject_id&op%5Bsubproject_id%5D=%21&v%5Bsubproject_id%5D%5B%5D=48&v%5Bsubproject_id%5D%5B%5D=38&f%5B%5D=&group_by=project&t%5B%5D=hours&t%5B%5D=&columns=day&criteria%5B%5D=user&encoding=ISO-8859-15',
			{
				:caption => 'Imputaciones en mis proyectos',
				:html => {:title => 'Ver las imputaciones de este mes en mis proyectos'}
			}
	
	menu	:top_menu,
			:sira3,
			'/projects/control_horario/issues/new',
			{
				:caption => 'Incidencias Control Horario',
				:html => {:title => 'Poner incidencia en el control horario'}
			}
	
	menu	:top_menu,
			:sira4,
			'/projects/grupo_cic/issues?utf8=%E2%9C%93&set_filter=1&sort=id%3Adesc&f%5B%5D=status_id&op%5Bstatus_id%5D=%3D&v%5Bstatus_id%5D%5B%5D=1&v%5Bstatus_id%5D%5B%5D=12&v%5Bstatus_id%5D%5B%5D=2&v%5Bstatus_id%5D%5B%5D=16&v%5Bstatus_id%5D%5B%5D=17&v%5Bstatus_id%5D%5B%5D=18&f%5B%5D=assigned_to_id&op%5Bassigned_to_id%5D=%3D&v%5Bassigned_to_id%5D%5B%5D=me&f%5B%5D=&c%5B%5D=cf_27&c%5B%5D=tracker&c%5B%5D=priority&c%5B%5D=status&c%5B%5D=subject&c%5B%5D=author&c%5B%5D=assigned_to&c%5B%5D=start_date&c%5B%5D=due_date&c%5B%5D=total_estimated_hours&c%5B%5D=total_spent_hours&group_by=project&t%5B%5D=estimated_hours&t%5B%5D=spent_hours&t%5B%5D=cf_5&t%5B%5D=',
			{
				:caption => 'Mis Tareas',
				:html => {:title => 'Mis tareas agrupadas por proyectos'}
			}
	
	menu	:top_menu,
			:sira5,
			'/projects/cau-cic/issues/new',
			{
				:caption => 'Incidencias SIRA CAU',
				:html => {:title => 'SIRA CAU'}
			}
end