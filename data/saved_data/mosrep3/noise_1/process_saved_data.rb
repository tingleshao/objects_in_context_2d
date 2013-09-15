# this script reads a set of saved mosrep data, including the xx and the xxx,
# and then convert it into the format that steve marron likes .

# magic number stealed from main.rb
$a_big_number = 100
$end_disk_spoke_number = 20

$dir = '' 


# read interpolated spoke begin and spoke end data
# 1. spoke begin data is for the single srep spoke length data, which should be computed with spoke end data.
# 2. spoke end data is for computing the interpolated extended spoke length. 
# read data
interp_spoke_0_read = File.open($dir+'interpolated_spokes_0','r')
interp_spoke_0_str = ''
while line = interp_spoke_0_read.gets
 	interp_spoke_0_str += line	
end
interp_spoke_0_read.close
#puts interp_spoke_0_str

interp_spokes_begin_0_str = interp_spoke_0_str.split("========\n")[0]
interp_spokes_end_0_str = interp_spoke_0_str.split("========\n")[1]
#puts interp_spokes_begin_0_str

#puts interp_spokes_end_0_str

interp_spokes_begin_0_lst = interp_spokes_begin_0_str.strip[2..-3].split('], [')
interp_spokes_begin_0_lst.each_with_index do |s,i|
    	puts i.to_s + ' ' + s 
end

interp_spokes_end_0_lst = interp_spokes_end_0_str.strip[2..-3].split("], [")
interp_spokes_end_0_lst.each_with_index do |s, i|
	puts i.to_s + ' ' + s
end

#puts "aaa: " +  interp_spokes_begin_0_lst[-1]




# Do point 2:



