load 'top_process.rb'

# MAS - PROJECT
# Ultimate Vegas Team
# File: LogParser.rb
# Made by: Rodolpho
# Class responsible for parsing the logs.
# Usage:
# 1) Load the TopProcess class
# 2) Create a new instance, use the path to the input file as argument to the initializer
# Example: lp1 = TopProcess.new('Logs/log1.txt')
# 3) Run the method 'parse_all', it will automatically parse the file.
# 4) Use the method 'save_processes', use as argument the output file desired
# Example: lp1.save_processes('Outputs/log1_processed.txt')
class LogParser
	# Atributes for the Log Parser class
	attr_accessor :path_to_file, :file
	# Array containing the lines in each timestamps were found!
	attr_accessor :timestamp_lines
	# Regex used on this application
	attr_accessor :timestamp_regex, :top_regex, :tasks_regex, :cpu_regex, :mem_regex, :swap_regex, :process_regex
	# Array containing the found processes
	attr_accessor :processes
	
	
	# Method for initializing the Parser
	def initialize(path_to_file)
		self.path_to_file = path_to_file
		self.timestamp_lines = []
		self.processes = Array.new

		puts '[LogParser] Setting up'
		puts '[LogParser] Opening file %s' % path_to_file
		# All regex were made via the website http://www.regexr.com/
		# See also http://www.tutorialspoint.com/ruby/ruby_regular_expressions.htm
		# () => Capturing group
		# (?:) => Non-Capturing group
		# (?: *) => Discard any number of whitespaces
		# (?: +) => Discard ONE or MORE number of whitespaces
		# Regex used to find timestamps within the file, 100% done
		self.timestamp_regex = /([a-zA-Z]*) (20[0-9][0-9]-[0-9][0-9]-\d\d \d\d:\d\d:\d\d)/
		# Regex used to find the top header, 100% done
		self.top_regex = /\btop - \b(?:\d\d:\d\d:\d\d) \bup\b (?:\d\d) (?:days|hours|months|seconds|minutes), (?:\d\d:\d\d).  (?:\d \busers)\b,  \bload average: \b(\d\d|\d,\d\d), (\d\d|\d,\d\d), (\d\d|\d,\d\d)/
		# Regex used to process the overall task tasks within the top header, 100% done
		self.tasks_regex = /\bTarefas:(?: *)(\d*)(?: *)\btotal,(?: *)\b(\d*)(?: *)\bexecutando,(?: *)\b(\d*)(?: *)\bdormindo\b,(?: *)(\d*)\b(?: *)parado,(?: *)(\d*)(?: *)zumbi/
		# Regex used to parse the overall CPU data within the top header, 100% done
		self.cpu_regex = /%Cpu\(s\):(?: *)(\d*,\d*) us,(?: *)(\d*,\d*) sy,(?: *)(\d*,\d*) ni,(?: *)(\d*,\d*) id,(?: *)(\d*,\d*) wa,(?: *)(\d*,\d*) hi,(?: *)(\d*,\d*) si,(?: *)(\d*,\d*) st/
		# Regex used to parse the overall MEMORY data within the top header, 100% done
		self.mem_regex = /KiB Mem:(?: *)(\d*) total,(?: *)(\d*) used,(?: *)(\d*) free,(?: *)(\d*) buffers/
		# Regex used to parse the overall SWAP data within the top header, 100% done
		self.swap_regex = /KiB Swap:(?: *)(\d*) total,(?: *)(\d*) used,(?: *)(\d*) free.(?: *)(\d*) cached Mem/
		# Regex used to parse which process data, WORK IN PROGRESS
		self.process_regex = /(?: *)(\d*)(?: *)(\w+)(?: *)(\d+)(?: +)(\d+)(?: +)(\d+)(?: +)(\d+)(?: +)(\d+)(?: +)(\w+)(?: +)(\d*,\d*)(?: +)(\d*,\d*)(?: *)(\d+:\d+.\d*)(?: +)([a-zA-Z\/:0-9\-\+\_]+)/
	end

	# Method for parsing a text block
	def parse(start_line, ending_line)
		# Formato do arquivo...
		# <TimeStamp> \n
		# 5 Linhas de informações
		# 1 Linha em branco
		# Dados...
		# ---------------------------------------
		# <Timestamp, [0]> MrBurns 2015-05-17 00:00:01
		# <Load Average, [1]> top - 00:00:02 up 12 days, 13:04,  8 users,  load average: 0,00, 0,01, 0,05
		# <Tasks Data, [2]> Tarefas: 590 total,   2 executando, 589 dormindo,   0 parado,   0 zumbi
		# <Cpu Load, [3]> %Cpu(s):  3,7 us,  0,6 sy,  0,0 ni, 95,3 id,  0,2 wa,  0,0 hi,  0,2 si,  0,0 st
		# <Memory Data, [4]> KiB Mem:   8107664 total,  6194672 used,  1912992 free,    90172 buffers
		# <Swap Data, [5]> KiB Swap:  2152444 total,   390692 used,  1761752 free.   872964 cached Mem
		# <Blank line, [6]>
		# <Useless header, [7]> PID USUÁRIO  PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
		# <Data itself, [>=8]> 7724 root      20   0   29480   1868   1136 S   6,1  0,0   0:00.01 top
		# Header:
		# [Machine - TimeStamp] Load Average: <Load Average Data>; Tasks: <Tasks Data>; %Cpu(s): <Cpu Data>; KiB Mem: <KiB Mem Data>; KiB Swap: <KiB Swap Data>
		# MrBurns 2015-05-17 00:00:01 load average: 0,00 0,01 0,05 Tarefas: 590 2 589 0 0 %Cpu(s): 3,7 0,6 0,0 95,3 0,2 0,0 0,2 0,0 KiB Mem: 8107664 6194672 1912992 90172 KiB Swap: 2152444  390692 1761752 87296
		#puts 'Parsing from line %d up to line %d (not included)' % [start_line, ending_line]
		File.foreach(file).with_index do |line, index|
			if (index >= start_line && index < ending_line)
				#puts 'Reading line [%d]' % index
				# Switch case, searching to see if said line matches any of the regexes.
				case line
				when self.timestamp_regex
					# Group 1: ServerName
					# Group 2: The timestamp itself
					#puts 'Timestamp @ line %d!' % index
					temp = line.match(self.timestamp_regex)
					@server_name, @log_timestamp = temp.captures
					#puts 'Server name is %s' % @server_name
					#puts 'The timestamp is %s' % @log_timestamp
					@header_start = '%s - %s' % [@server_name, @log_timestamp]
				when self.top_regex
					# Group 1: Load Average 1
					# Group 2: Load Average 2
					# Group 3: Load Average 3
					#puts 'Top Header @ line %d!' % index
					temp = line.match(self.top_regex)
					@load_1, @load_2, @load_3 = temp.captures
					# Gabiarra needed here!
					# Why is it needed? Because the log is using , as a decimal point whereas the to_f method only parses . decimal pointers
					#puts 'Load average: %.2f %.2f %.2f' % [@load_1.gsub(",",".").to_f, @load_2.gsub(",",".").to_f, @load_3.gsub(",",".").to_f]
					@header_top = 'Load average: %.2f %.2f %.2f' % [@load_1.gsub(",",".").to_f, @load_2.gsub(",",".").to_f, @load_3.gsub(",",".").to_f]
				when self.tasks_regex
					# Group 1: Total tasks
					# Group 2: Running tasks
					# Group 3: Sleeping tasks
					# Group 4: Stopped tasks
					# Group 5: Zombie tasks
					#puts 'Tasks Header @ line %d!' % index
					temp = line.match(self.tasks_regex)
					@tasks_total, @tasks_running, @tasks_sleeping, @tasks_stopped, @tasks_zombie = temp.captures
					#puts 'Tasks: %d Total %d Running %d Sleeping %d Stopped %d Zombies' % [@tasks_total, @tasks_running, @tasks_sleeping, @tasks_stopped, @tasks_zombie]
					@header_tasks = 'Tasks: %d %d %d %d %d' % [@tasks_total, @tasks_running, @tasks_sleeping, @tasks_stopped, @tasks_zombie]
				when self.cpu_regex
					# Group 1: Cpu us
					# Group 2: Cpu sy
					# Group 3: Cpu ni
					# Group 4: Cpu id
					# Group 5: Cpu wa
					# Group 6: Cpu hi
					# Group 7: Cpu si
					# Group 8: Cpu st
					#puts 'CPU Data @ line %d!' % index
					temp = line.match(self.cpu_regex)
					@cpu_us, @cpu_sy, @cpu_ni, @cpu_id, @cpu_wa, @cpu_hi, @cpu_si, @cpu_st = temp.captures
					#puts '%%CPU(s): %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f' % [@cpu_us.gsub(",",".").to_f, @cpu_sy.gsub(",",".").to_f, @cpu_ni.gsub(",",".").to_f, @cpu_id.gsub(",",".").to_f, @cpu_wa.gsub(",",".").to_f, @cpu_hi.gsub(",",".").to_f, @cpu_si.gsub(",",".").to_f, @cpu_st.gsub(",",".").to_f]
					@header_cpu = '%%CPU(s): %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f' % [@cpu_us.gsub(",",".").to_f, @cpu_sy.gsub(",",".").to_f, @cpu_ni.gsub(",",".").to_f, @cpu_id.gsub(",",".").to_f, @cpu_wa.gsub(",",".").to_f, @cpu_hi.gsub(",",".").to_f, @cpu_si.gsub(",",".").to_f, @cpu_st.gsub(",",".").to_f]
				when self.mem_regex
					# Group 1: Memory Total
					# Group 2: Memory Used
					# Group 3: Memory Free
					# Group 4: Memory Buffers
					#puts 'MEM Data @ line %d!' % index
					temp = line.match(self.mem_regex)
					@mem_total, @mem_used, @mem_free, @mem_buffer = temp.captures
					#puts 'KiB Mem: %d %d %d %d' % [@mem_total, @mem_used, @mem_free, @mem_buffer]
					@header_mem = 'KiB Mem: %d %d %d %d' % [@mem_total, @mem_used, @mem_free, @mem_buffer]
				when self.swap_regex
					# Group 1: Swap Total
					# Group 2: Swap Used
					# Group 3: Swap Free
					# Group 4: Swap Cached
					#puts 'SWAP Data @ line %d!' % index
					temp = line.match(self.swap_regex)
					@swap_total, @swap_used, @swap_free, @swap_cached = temp.captures
					#puts 'KiB Swap: %d %d %d %d' % [@swap_total, @swap_used, @swap_free, @swap_cached]
					@header_swap = 'KiB Swap: %d %d %d %d' % [@swap_total, @swap_used, @swap_free, @swap_cached]
				when self.process_regex
					# Group 1: Process PID
					# Group 2: Process User
					# Group 3: Process PR
					# Group 4: Process NI
					# Group 5: Process VIRT
					# Group 6: Process RES
					# Group 7: Process SHR
					# Group 8: Process S
					# Group 9: Process %CPU
					# Group 10: Process %MEM
					# Group 11: Process Time
					# Group 12: Process Command
					#puts 'Found a Process @ line %d!' % index
					temp = line.match(self.process_regex)
					@process_pid, @process_user, @process_pr, @process_ni, @process_virt, @process_res, @process_shr, @process_s, @process_cpu, @process_mem, @process_time, @process_cmd = temp.captures
					#puts 'Process data: %d %s %d %d %d %d %d %s %.2f %.2f %s %s' % [@process_pid, @process_user, @process_pr, @process_ni, @process_virt, @process_res, @process_shr, @process_s, @process_cpu.gsub(",",".").to_f, @process_mem.gsub(",",".").to_f, @process_time, @process_cmd]
					process_temp = TopProcess.new
					process_temp.header = '%s %s %s %s %s %s' % [@header_start, @header_top, @header_tasks, @header_cpu, @header_mem, @header_swap]
					process_temp.pid = @process_pid
					process_temp.user = @process_user
					process_temp.pr = @process_pr
					process_temp.ni = @process_ni
					process_temp.virt = @process_virt
					process_temp.res = @process_res
					process_temp.shr = @process_shr
					process_temp.s = @process_s
					process_temp.cpu_usage = @process_cpu.gsub(",",".").to_f
					process_temp.mem_usage = @process_mem.gsub(",",".").to_f
					process_temp.time_usage = @process_time
					process_temp.command = @process_cmd
					#self.processes << process_temp
					process_temp.save
				end
			end
		end
	end

	# Method for opening a file.
	def open_file
		self.file = File.new(path_to_file, 'r')
	end

	# Method for finding TOP batches within a file
	def find_batches
		line_num = 0;
		# Parsing the file, line by line
		file.each do |line|
			#puts '[%d] %s' % [line_num, line]
			# If this line matches the timestamp regex...
			if (line =~ timestamp_regex)
				#puts 'Found timestamp!!'
				# Add it to the Timestamp_lines array
				timestamp_lines << line_num
			end
			line_num+=1
		end
		# Adding the last line to the timestamps
		timestamp_lines << line_num
	end

	# Method for printing all the stored processes to the STDOUT
	def print_processes
		processes.each do |p|
			puts p.to_str
		end
	end

	# Method for storing all the processes in an output file
	def save_processes(output_file)
		puts '[LogParser] Saving all the processes to file [%s]' % output_file
		File.open(output_file, 'w') do |file|
			processes.each do |p|
				file.puts(p.to_str)
			end
		end
		puts '[LogParser] All the data has been saved.'
	end

	# Method for automatic parsing of a file
	def parse_all
		puts '[LogParser] Beggining the parsing of the file'
		time_start = Time.now
		self.open_file
		self.find_batches
		i = 0
		while i < self.timestamp_lines.length-1
			parse(timestamp_lines[i], timestamp_lines[i+1])
			#puts 'Parsing from lines %d to %d' % [timestamp_lines[i], timestamp_lines[i+1]]
			i += 1
		end
		time_end = Time.now
		delta = time_end - time_start
		#puts 'Parsing began @ %f and endeded @ %f' % [time_start.to_f, time_end.to_f]
		puts '[LogParser] Time elapsed to parse the file: %f ms' % delta.to_f
	end
end
