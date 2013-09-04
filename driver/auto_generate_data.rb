# this script calls python/generateData.py to generate many noise data 
# the first argument is the beginning index
# the second argument is the ending index 

# if the beginning index is larger than the ending index,
# it will give error message and then do nothing.


begin_index = ARGV[0].to_i
end_index = ARGV[1].to_i


if ( end_index <= begin_index ) 
	puts 'begin index larger than or equal to end index! do nothing'
else 
	command = 'python ../python/generateData.py '
	(end_index - begin_index + 1 ).times do |i|
	   curr_command = command + (begin_index + i).to_s
	   system(curr_command)
	end
end

