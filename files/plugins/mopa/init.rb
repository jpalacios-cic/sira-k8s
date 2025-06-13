require 'redmine'

Redmine::Plugin.register :mopa do
	name 'Plugin MOPA'
	author 'CIC'
	description 'Plugin MOPA'
	version '1.0.2'
	url 'https://www.cic.es/'
	author_url 'https://www.cic.es/'
	settings	:default => {'empty' => true},
				:partial => 'settings/maxEstimado'
	menu :project_menu, :mopa, { :controller => 'mopa', :action => 'index' }, :caption => 'Mopa Certificaciones', :before => :setting, :param => :project_id
	
	project_module :mopa do
		permission :ver_mopa, :mopa => :index
	end
end