class MopaController < ApplicationController
	def index
		sql = "select * from CERTIFICACIONES_REALIZADAS where codigo_proyecto = '#{params[:project_id]}'"
		@certificaciones = ActiveRecord::Base.connection.select_rows(sql)
		@project = Project.find(params[:project_id])
		
		
		if !User.current.allowed_to?(:ver_mopa, @project)
          render_404
        end
		
		
	end
end