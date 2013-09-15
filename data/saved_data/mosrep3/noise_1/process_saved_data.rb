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


interp_spokes_begin_0_str = interp_spoke_0_str.split("========\n")[0]
interp_spokes_end_0_str = interp_spoke_0_str.split("========\n")[1]

interp_spokes_begin_0_lst = interp_spokes_begin_0_str.strip[2..-3].split('], [')
interp_spokes_begin_0_lst.each_with_index do |s,i|
#    	puts i.to_s + ' ' + s 
end

interp_spokes_end_0_lst = interp_spokes_end_0_str.strip[2..-3].split("], [")
interp_spokes_end_0_lst.each_with_index do |s, i|
	puts i.to_s + ' ' + s
end

# read extended interpolated spokes end data 
ext_spoke_read = File.open($dir+'ref_obj_linking', 'r')
ext_spoke_str = ''
while line = ext_spoke_read.gets
     ext_spoke_str += line
end
ext_spoke_read.close
#puts ext_spoke_str

ext_spoke_lst = ext_spoke_str.strip[2..-3].split("], [")
ext_spoke_lst.each_with_index do |s, i|
     puts i.to_s + ' ' + s
end

# process the lst to get the x y position data 










#puts "aaa: " +  interp_spokes_begin_0_lst[-1]




# Do point 2:



