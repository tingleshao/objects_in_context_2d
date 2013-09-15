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
   #	puts i.to_s + ' ' + s 
end

interp_spokes_end_0_lst = interp_spokes_end_0_str.strip[2..-3].split("], [")
interp_spokes_end_0_lst.each_with_index do |s, i|
#	puts i.to_s + ' ' + s
end

# read extended interpolated spokes end data 
ext_spokes_read = File.open($dir+'ref_obj_linking', 'r')
ext_spokes_str = ''
while line = ext_spokes_read.gets
     ext_spokes_str += line
end
ext_spokes_read.close


ext_spokes_lst = ext_spokes_str.strip[2..-3].split("], [")
ext_spokes_lst.each_with_index do |s, i|
#     puts i.to_s + ' ' + s
end

# process the lst to get the x y position data 
interp_spokes_begin_0_x = []
interp_spokes_begin_0_y = []
interp_spokes_begin_0_lst.each do |s|
    begin_pt_x = s.split(',')[0].to_f
    begin_pt_y = s.split(',')[1].to_f
    interp_spokes_begin_0_x << begin_pt_x
    interp_spokes_begin_0_y << begin_pt_y
end

interp_spokes_begin_0_x.each_with_index do |x, i|
   # puts i.to_s + " " + x.to_s + " " interp_spokes_begin_0_y[i].to_s 
end

interp_spokes_end_0_x = []
interp_spokes_end_0_y = []
interp_spokes_end_0_lst.each do |s|
    end_pt_x = s.split(',')[0].to_f
    end_pt_y = s.split(',')[1].to_f
    interp_spokes_end_0_x << end_pt_x
    interp_spokes_end_0_y << end_pt_y
end

interp_spokes_end_0_x.each_with_index do |x, i|
 #  puts i.to_s + " " + x.to_s + " " + interp_spokes_end_0_y[i].to_s
end


#calculate length
interp_spokes_length_0 = []
interp_spokes_begin_0_x.each_with_index do |begin_x, i|
   end_x = interp_spokes_end_0_x[i]
   begin_y = interp_spokes_begin_0_y[i]
   end_y = interp_spokes_end_0_y[i]
   spoke_len = Math.sqrt( (end_x - begin_x)**2 + (end_y - begin_y) **2 )
   interp_spokes_length_0 << spoke_len
end

#reorder the spokes so that it goes clockwise continuously 



























#puts "aaa: " +  interp_spokes_begin_0_lst[-1]




# Do point 2:



