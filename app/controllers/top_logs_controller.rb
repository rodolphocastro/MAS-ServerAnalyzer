class TopLogsController < ApplicationController
	def index

	end

	def new

	end

	def show
		@topLog = TopLog.find(params[:id])
		@topLog.parse_log
	end

	def create
		@topLog = TopLog.new(top_log_params)
		@topLog.save
		redirect_to @topLog
	end

	def parse
		
	end

	private
	def top_log_params
		params.require(:top_log).permit(:comment, :top_file)
	end
end
