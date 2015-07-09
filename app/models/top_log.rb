load 'log_parser.rb'

class TopLog < ActiveRecord::Base
	mount_uploader :top_file, TopFileUploader

	def parse_log
		lp1 = LogParser.new(self.top_file.path)
		lp1.parse_all
	end
end
