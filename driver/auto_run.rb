# this script runs main.rb automatically
# the conifig index and the noise index is given as argument 
# first argument: config index
# second argument: beginning noise index
# third argument: end noise index 

config_index = ARGV[0].to_i
beginning_noise_index = ARGV[1].to_i
end_noise_index = ARGV[2].to_i

rshoes = '/home/chong/shoes/dist/shoes'
if end_noise_index < beginning_noise_index
	puts 'the end noise index is smaller than or equal to the beginning noise index! the program will do nothing.' 
else 
	base_command = rshoes + ' ../main.rb ' + config_index.to_s 
        command = ''
	(end_noise_index - beginning_noise_index + 1).times do |i|
		command += base_command + ' ' + (beginning_noise_index + i).to_s + ' & '
	end

	command = command[0..-3]
        puts command
	system(command)
end

