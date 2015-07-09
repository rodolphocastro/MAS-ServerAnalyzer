class TopProcessesController < ApplicationController
	def index
		@topProcesses = TopProcess.all
	end
	
	def show
		@topProcess = TopProcess.find(params[:id])
	end

	def new

	end

	def create
		@topProcess = TopProcess.new(top_process_params)
		@topProcess.save
		redirect_to @topProcess
	end

	private
	def top_process_params
		params.require(:top_process).permit(:header, :pid, :user, :pr, :ni, :virt, :res, :shr, :s, :cpu_usage, :mem_usage, :time_usage, :command)
	end
end
