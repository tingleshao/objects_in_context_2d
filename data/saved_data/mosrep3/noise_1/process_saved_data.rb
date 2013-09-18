# this script reads a set of saved mosrep data, including the xx and the xxx,
# and then convert it into the format that steve marron likes .

# magic number stealed from main.rb
$a_big_number = 100
$end_disk_spoke_number = 20

dir = '' 

def convert_index_into_param(srep_ind, ind)

	a = 1.0
	b = 2.0
        x = 0.0
	#convert_index_into_param()
	srep1_d = 262.61340991061337
	srep1_d1 = 100.30808848763076
	srep1_d2 = 81.16122082909462

	srep1_sum_d = 2 * srep1_d + srep1_d1 + srep1_d2

	srep2_d = 222.63024693026233
	srep2_d1 = 100.82602152757617
	srep2_d2 = 78.71687886134345

	srep2_sum_d = 2 * srep2_d + srep2_d1 + srep2_d2

	srep3_d = 126.50819039964416
	srep3_d1 = 77.90119788092397
	srep3_d2 = 121.62157533960419

	srep3_sum_d = 2 * srep3_d + srep3_d1 + srep3_d2

   if srep_ind == 1
	   if ind <= 98
	      x = ind.to_f * srep2_d * (b-a) / (99.0 * srep2_sum_d )
	   elsif ind <= 138
	      x = srep2_d * (b-a) / srep2_sum_d + (ind-99) * srep2_d2 * (b-a)/ (40.0 * srep2_sum_d)
	   elsif ind <= 237
	      x = ( srep2_d + srep2_d2 ) * (b-a) / srep2_sum_d + (ind - 139) * srep2_d * (b-a) / (99.0 * srep2_sum_d )
	   else
	      x = ( srep2_d * 2 + srep2_d2) * (b-a) / srep2_sum_d + (ind - 238) * srep2_d1 * (b-a) / (40.0 * srep2_sum_d )
	   end
   elsif srep_ind == 2
           if ind <= 98
	      x = ind.to_f * srep3_d * (b-a) / (99.0 * srep3_sum_d )
	   elsif ind <= 138
	      x = srep3_d * (b-a) / srep3_sum_d + (ind-99) * srep3_d2 * (b-a)/ (40.0 * srep3_sum_d) 
	   elsif ind <= 237
	      x = ( srep3_d + srep3_d2 ) * (b-a) / srep3_sum_d + (ind - 139) * srep3_d * (b-a) / (99.0 * srep3_sum_d)
	   else
	      x = ( srep3_d * 2 + srep3_d2) * (b-a) / srep3_sum_d + (ind - 238) * srep3_d1 * (b-a) / (40.0 * srep3_sum_d )
	   end
   elsif srep_ind == 0
           if ind <= 98
	      x = ind.to_f * srep1_d * (b-a) / (99.0 * srep1_sum_d )
	   elsif ind <= 138
	      x = srep1_d * (b-a) / srep1_sum_d + (ind-99) * srep1_d2 * (b-a)/ (40.0 * srep1_sum_d )
	   elsif ind <= 237
	      x = ( srep1_d + srep1_d2 ) * (b-a) / srep1_sum_d + (ind - 139) * srep1_d * (b-a) / (99.0 * srep1_sum_d)
	   else
	      x = ( srep1_d * 2 + srep1_d2) * (b-a) / srep1_sum_d + (ind - 238) * srep1_d1 * (b-a) / (40.0 * srep1_sum_d )
	   end
   end
   y = a + x 
   return y
end


# read interpolated spoke begin and spoke end data
# 1. spoke begin data is for the single srep spoke length data, which should be computed with spoke end data.
# 2. spoke end data is for computing the interpolated extended spoke length. 
# read data
interp_spoke_0_read = File.open(dir+'interpolated_spokes_0','r')
interp_spoke_0_str = ''
while line = interp_spoke_0_read.gets
 	interp_spoke_0_str += line	
end
interp_spoke_0_read.close


interp_spokes_begin_0_str = interp_spoke_0_str.split("========\n")[0]
interp_spokes_end_0_str = interp_spoke_0_str.split("========\n")[1]

interp_spokes_begin_0_lst = interp_spokes_begin_0_str.strip[2..-3].split('], [')

interp_spokes_end_0_lst = interp_spokes_end_0_str.strip[2..-3].split("], [")

# read extended interpolated spokes end data 
ext_spokes_read = File.open(dir+'ref_obj_linking', 'r')
ext_spokes_str = ''
while line = ext_spokes_read.gets
     ext_spokes_str += line
end
ext_spokes_read.close


ext_spokes_lst = ext_spokes_str.strip[2..-3].split("], [")
ext_spokes_lst.each_with_index do |s, i|
 #    puts i.to_s + ' ' + s
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
 #   puts i.to_s + " " + x.to_s + " "+ interp_spokes_begin_0_y[i].to_s 
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
  # puts i.to_s + " " + x.to_s + " " + interp_spokes_end_0_y[i].to_s
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
ordered_interp_spokes_length_0 = []
#      1 3  
#  end1   end2
#      2 4
99.times do |i|
    ordered_interp_spokes_length_0 << interp_spokes_length_0[2*i]
end
40.times do |i|
    ordered_interp_spokes_length_0 << interp_spokes_length_0[238+i]
end
99.times do |i|
    ordered_interp_spokes_length_0 << interp_spokes_length_0[2*i+1]
end
40.times do |i|
    ordered_interp_spokes_length_0 << interp_spokes_length_0[197+i]
end

# Do point 2: computing the interpolated extended spoke length. 
# retrieve the x and y for ext_spokes_end
ext_spokes_end_x = []
ext_spokes_end_y = []
linking_labels = []
linked_spoke_indices = []
ext_spokes_lst.each_with_index do |s|
   ext_end_x = s.split(',')[0].to_f
   ext_end_y = s.split(',')[1].to_f
   label = s.split(',')[2].to_i
   linked_spoke_index = s.split(',')[3]

   ext_spokes_end_x << ext_end_x
   ext_spokes_end_y << ext_end_y
   linking_labels << label
   linked_spoke_indices << linked_spoke_index
end

ext_spokes_end_x.each_with_index do |x, i|
 #  puts i.to_s + ' ' + x.to_s + " " + ext_spokes_end_y[i].to_s
end
# calculate the length
ext_interp_spokes_length_0 = []


interp_spokes_end_0_x.each_with_index do |begin_x, i|
   end_x = ext_spokes_end_x[i]
   begin_y = interp_spokes_end_0_y[i]
   end_y = ext_spokes_end_y[i]
   spoke_len = Math.sqrt( (end_x - begin_x)**2 + (end_y - begin_y) **2 )
   ext_interp_spokes_length_0 << spoke_len
end
# reorder the length
ordered_ext_interp_spokes_length = []
ordered_linking_labels = []
ordered_linked_spoke_indices = []
#      1 3  
#  end1   end2
#      2 4
99.times do |i|
    ordered_ext_interp_spokes_length << ext_interp_spokes_length_0[2*i]
    ordered_linking_labels << linking_labels[2*i]
    ordered_linked_spoke_indices << linked_spoke_indices[2*i]
end
40.times do |i|
    ordered_ext_interp_spokes_length << ext_interp_spokes_length_0[238+i]
    ordered_linking_labels << linking_labels[238+i]
    ordered_linked_spoke_indices << linked_spoke_indices[238+i]
end
99.times do |i|
    ordered_ext_interp_spokes_length << ext_interp_spokes_length_0[2*i+1]
    ordered_linking_labels << linking_labels[2*i+1]
    ordered_linked_spoke_indices << linked_spoke_indices[2*i+1]
end
40.times do |i|
    ordered_ext_interp_spokes_length << ext_interp_spokes_length_0[197+i]
    ordered_linking_labels << linking_labels[197+i]
    ordered_linked_spoke_indices << linked_spoke_indices[197+i]
end

# print the result
ordered_interp_spokes_length_0.each_with_index do |l, i|
 #   puts i.to_s + ' ' + l.to_s
end
ordered_ext_interp_spokes_length.each_with_index do |l, i|
#    puts i.to_s + " " + l.to_s + " " + ordered_linking_labels[i].to_s
end

# output the part 2 of data list 

extended_length_write = File.open('extended_length.txt','w')
ordered_ext_interp_spokes_length.each_with_index do |l, i|
    if ordered_linking_labels[i].to_i != -1
       extended_length_write.puts  l.to_s
    else 
       extended_length_write.puts  '0.0'
    end
end
puts 'write extended spoke length complete.'
extended_length_write.close

# given an linked spoke pos index on the other obj, I should be able to convert
#   it into an number between a to b.
# then the array would be sorted according to srep 0's spoke index 
linked_spoke_index_in_other_obj_write = File.open('linked_spoke_index_in_other_obj.txt','w')
ordered_linked_spoke_indices.each_with_index do |ind, i|
     if ind.strip == "[]"
        linked_spoke_index_in_other_obj_write.puts '0.0'
     else
        srep_ind = ordered_linking_labels[i]
        linked_spoke_index_in_other_obj_write.puts convert_index_into_param(srep_ind,ind.to_i).to_s
     end
end
puts 'write mapping info complete.'
linked_spoke_index_in_other_obj_write.close

# output data for single sreps
# for every srep, the data layout is:
#  1. medial curve x y positions: x1 y1 x2 y2 x3 y3 
#  2. z values for spoke directions ordered in closkwise order (may simply use u1[0], u1[1] for now? after siguring out how to use CPNS code switch to z values)
#  3. log spoke length

# 1. medial curve x y positions
# srep1:
skeletal_curve_0_read = File.open('interpolated_pts_0','r')
skeletal_curve_0_str = ""
while line = skeletal_curve_0_read.gets
     skeletal_curve_0_str += line
end
skeletal_curve_0_read.close
skeletal_curve_xs_0 = skeletal_curve_0_str.strip[1..-2].split("], [")[0][1..-2]
skeletal_curve_ys_0 = skeletal_curve_0_str.strip[1..-2].split("], [")[1][1..-2]

skeletal_curve_xs_0_lst = skeletal_curve_xs_0.split(", ").map{|i| i.to_f}
skeletal_curve_ys_0_lst = skeletal_curve_ys_0.split(", ").map{|i| i.to_f}

skeletal_curve_0_write = File.open('skeletal_curve_srep_0.txt','w')
skeletal_curve_xs_0_lst.each_with_index do |x, i|
   skeletal_curve_0_write.puts x.to_s + " " + skeletal_curve_ys_0_lst[i].to_s + "\n"
end
skeletal_curve_0_write.close
puts 'write srep 1 base points info complete.'


# srep2
skeletal_curve_1_read = File.open('interpolated_pts_1','r')
skeletal_curve_1_str = ""
while line = skeletal_curve_1_read.gets
     skeletal_curve_1_str += line
end
skeletal_curve_1_read.close
skeletal_curve_xs_1 = skeletal_curve_1_str.strip[1..-2].split("], [")[0][1..-2]
skeletal_curve_ys_1 = skeletal_curve_1_str.strip[1..-2].split("], [")[1][1..-2]

skeletal_curve_xs_1_lst = skeletal_curve_xs_1.split(", ").map{|i| i.to_f}
skeletal_curve_ys_1_lst = skeletal_curve_ys_1.split(", ").map{|i| i.to_f}

skeletal_curve_1_write = File.open('skeletal_curve_srep_1.txt','w')
skeletal_curve_xs_1_lst.each_with_index do |x, i|
   skeletal_curve_1_write.puts x.to_s + " " + skeletal_curve_ys_1_lst[i].to_s + "\n"
end
skeletal_curve_1_write.close
puts 'write srep 2 base points info complete.'


# srep3
skeletal_curve_2_read = File.open('interpolated_pts_2','r')
skeletal_curve_2_str = ""
while line = skeletal_curve_2_read.gets
     skeletal_curve_2_str += line
end
skeletal_curve_2_read.close
skeletal_curve_xs_2 = skeletal_curve_2_str.strip[1..-2].split("], [")[0][1..-2]
skeletal_curve_ys_2 = skeletal_curve_2_str.strip[1..-2].split("], [")[1][1..-2]

skeletal_curve_xs_2_lst = skeletal_curve_xs_2.split(", ").map{|i| i.to_f}
skeletal_curve_ys_2_lst = skeletal_curve_ys_2.split(", ").map{|i| i.to_f}

skeletal_curve_2_write = File.open('skeletal_curve_srep_2.txt','w')
skeletal_curve_xs_2_lst.each_with_index do |x, i|
   skeletal_curve_2_write.puts x.to_s + " " + skeletal_curve_ys_2_lst[i].to_s + "\n"
end
skeletal_curve_2_write.close
puts 'write srep 3 base points info complete.'



#  2. z values for spoke directions ordered in closkwise order (may simply use u1[0], u1[1] for now? after siguring out how to use CPNS code switch to z values)
# srep 1
ordered_interp_spokes_end_0_x = []
ordered_interp_spokes_end_0_y = []

99.times do |i|
    ordered_interp_spokes_end_0_x << interp_spokes_end_0_x[2*i]
    ordered_interp_spokes_end_0_y << interp_spokes_end_0_y[2*i]
end
40.times do |i|
    ordered_interp_spokes_end_0_x << interp_spokes_end_0_x[238+i]
    ordered_interp_spokes_end_0_y << interp_spokes_end_0_y[238+i]
end
99.times do |i|
    ordered_interp_spokes_end_0_x << interp_spokes_end_0_x[2*i+1]
    ordered_interp_spokes_end_0_y << interp_spokes_end_0_y[2*i+1]
end
40.times do |i|
    ordered_interp_spokes_end_0_x << interp_spokes_end_0_x[197+i]
    ordered_interp_spokes_end_0_y << interp_spokes_end_0_y[197+i]
end

# srep 2
interp_spoke_1_read = File.open(dir+'interpolated_spokes_1','r')
interp_spoke_1_str = ''
while line = interp_spoke_1_read.gets
 	interp_spoke_1_str += line	
end
interp_spoke_1_read.close

interp_spokes_end_1_str = interp_spoke_1_str.split("========\n")[1]
interp_spokes_end_1_lst = interp_spokes_end_1_str.strip[2..-3].split("], [")

interp_spokes_end_1_x = []
interp_spokes_end_1_y = []
interp_spokes_end_1_lst.each do |s|
    end_pt_x = s.split(',')[0].to_f
    end_pt_y = s.split(',')[1].to_f
    interp_spokes_end_1_x << end_pt_x
    interp_spokes_end_1_y << end_pt_y
end

ordered_interp_spokes_end_1_x = []
ordered_interp_spokes_end_1_y = []

99.times do |i|
    ordered_interp_spokes_end_1_x << interp_spokes_end_1_x[2*i]
    ordered_interp_spokes_end_1_y << interp_spokes_end_1_y[2*i]
end
40.times do |i|
    ordered_interp_spokes_end_1_x << interp_spokes_end_1_x[238+i]
    ordered_interp_spokes_end_1_y << interp_spokes_end_1_y[238+i]
end
99.times do |i|
    ordered_interp_spokes_end_1_x << interp_spokes_end_1_x[2*i+1]
    ordered_interp_spokes_end_1_y << interp_spokes_end_1_y[2*i+1]
end
40.times do |i|
    ordered_interp_spokes_end_1_x << interp_spokes_end_1_x[197+i]
    ordered_interp_spokes_end_1_y << interp_spokes_end_1_y[197+i]
end

# srep 3
interp_spoke_2_read = File.open(dir+'interpolated_spokes_2','r')
interp_spoke_2_str = ''
while line = interp_spoke_2_read.gets
 	interp_spoke_2_str += line	
end
interp_spoke_2_read.close

interp_spokes_end_2_str = interp_spoke_2_str.split("========\n")[1]
interp_spokes_end_2_lst = interp_spokes_end_2_str.strip[2..-3].split("], [")

interp_spokes_end_2_x = []
interp_spokes_end_2_y = []
interp_spokes_end_2_lst.each do |s|
    end_pt_x = s.split(',')[0].to_f
    end_pt_y = s.split(',')[1].to_f
    interp_spokes_end_2_x << end_pt_x
    interp_spokes_end_2_y << end_pt_y
end

ordered_interp_spokes_end_2_x = []
ordered_interp_spokes_end_2_y = []

99.times do |i|
    ordered_interp_spokes_end_2_x << interp_spokes_end_2_x[2*i]
    ordered_interp_spokes_end_2_y << interp_spokes_end_2_y[2*i]
end
40.times do |i|
    ordered_interp_spokes_end_2_x << interp_spokes_end_2_x[238+i]
    ordered_interp_spokes_end_2_y << interp_spokes_end_2_y[238+i]
end
99.times do |i|
    ordered_interp_spokes_end_2_x << interp_spokes_end_2_x[2*i+1]
    ordered_interp_spokes_end_2_y << interp_spokes_end_2_y[2*i+1]
end
40.times do |i|
    ordered_interp_spokes_end_2_x << interp_spokes_end_2_x[197+i]
    ordered_interp_spokes_end_2_y << interp_spokes_end_2_y[197+i]
end

#  3. log spoke length
# srep 1:
log_spoke_len_0_write = File.open('log_spoke_len_srep_0.txt','w')
ordered_interp_spokes_length_0.each_with_index do |l, i|
   log_spoke_len_0_write.puts Math.log(l.to_f).to_s + "\n"
end
log_spoke_len_0_write.close
puts 'write srep 1 log spoke length info complete.'


# srep 2:
interp_spokes_begin_1_str = interp_spoke_1_str.split("========\n")[0]
interp_spokes_begin_1_lst = interp_spokes_begin_1_str.strip[2..-3].split('], [')

interp_spokes_begin_1_x = []
interp_spokes_begin_1_y = []
interp_spokes_begin_1_lst.each do |s|
    begin_pt_x = s.split(',')[0].to_f
    begin_pt_y = s.split(',')[1].to_f
    interp_spokes_begin_1_x << begin_pt_x
    interp_spokes_begin_1_y << begin_pt_y
end

interp_spokes_length_1 = []
interp_spokes_begin_1_x.each_with_index do |begin_x, i|
   end_x = interp_spokes_end_1_x[i]
   begin_y = interp_spokes_begin_1_y[i]
   end_y = interp_spokes_end_1_y[i]
   spoke_len = Math.sqrt( (end_x - begin_x)**2 + (end_y - begin_y) **2 )
   interp_spokes_length_1 << spoke_len
end

ordered_interp_spokes_length_1 = []
#      1 3  
#  end1   end2
#      2 4
99.times do |i|
    ordered_interp_spokes_length_1 << interp_spokes_length_1[2*i]
end
40.times do |i|
    ordered_interp_spokes_length_1 << interp_spokes_length_1[238+i]
end
99.times do |i|
    ordered_interp_spokes_length_1 << interp_spokes_length_1[2*i+1]
end
40.times do |i|
    ordered_interp_spokes_length_1 << interp_spokes_length_1[197+i]
end


log_spoke_len_1_write = File.open('log_spoke_len_srep_1.txt','w')
ordered_interp_spokes_length_1.each_with_index do |l, i|
   log_spoke_len_1_write.puts Math.log(l.to_f).to_s + "\n"
end
log_spoke_len_1_write.close
puts 'write srep 2 log spoke length info complete.'


# srep 3:
interp_spokes_begin_2_str = interp_spoke_2_str.split("========\n")[0]
interp_spokes_begin_2_lst = interp_spokes_begin_2_str.strip[2..-3].split('], [')

interp_spokes_begin_2_x = []
interp_spokes_begin_2_y = []
interp_spokes_begin_2_lst.each do |s|
    begin_pt_x = s.split(',')[0].to_f
    begin_pt_y = s.split(',')[1].to_f
    interp_spokes_begin_2_x << begin_pt_x
    interp_spokes_begin_2_y << begin_pt_y
end

interp_spokes_length_2 = []
interp_spokes_begin_2_x.each_with_index do |begin_x, i|
   end_x = interp_spokes_end_2_x[i]
   begin_y = interp_spokes_begin_2_y[i]
   end_y = interp_spokes_end_2_y[i]
   spoke_len = Math.sqrt( (end_x - begin_x)**2 + (end_y - begin_y) **2 )
   interp_spokes_length_2 << spoke_len
end

ordered_interp_spokes_length_2 = []
99.times do |i|
    ordered_interp_spokes_length_2 << interp_spokes_length_2[2*i]
end
40.times do |i|
    ordered_interp_spokes_length_2 << interp_spokes_length_2[238+i]
end
99.times do |i|
    ordered_interp_spokes_length_2 << interp_spokes_length_2[2*i+1]
end
40.times do |i|
    ordered_interp_spokes_length_2 << interp_spokes_length_2[197+i]
end



log_spoke_len_2_write = File.open('log_spoke_len_srep_2.txt','w')
ordered_interp_spokes_length_2.each_with_index do |l, i|
   log_spoke_len_2_write.puts Math.log(l.to_f).to_s + "\n"
end
log_spoke_len_2_write.close
puts 'write srep 3 log spoke length info complete.'



# part 2 output


ordered_interp_spokes_begin_0_x = []
ordered_interp_spokes_begin_0_y = []

99.times do |i|
    ordered_interp_spokes_begin_0_x << interp_spokes_begin_0_x[2*i]
    ordered_interp_spokes_begin_0_y << interp_spokes_begin_0_y[2*i]
end
40.times do |i|
    ordered_interp_spokes_begin_0_x << interp_spokes_begin_0_x[238+i]
    ordered_interp_spokes_begin_0_y << interp_spokes_begin_0_y[238+i]
end
99.times do |i|
    ordered_interp_spokes_begin_0_x << interp_spokes_begin_0_x[2*i+1]
    ordered_interp_spokes_begin_0_y << interp_spokes_begin_0_y[2*i+1]
end
40.times do |i|
    ordered_interp_spokes_begin_0_x << interp_spokes_begin_0_x[197+i]
    ordered_interp_spokes_begin_0_y << interp_spokes_begin_0_y[197+i]
end


ordered_interp_spokes_begin_1_x = []
ordered_interp_spokes_begin_1_y = []

99.times do |i|
    ordered_interp_spokes_begin_1_x << interp_spokes_begin_1_x[2*i]
    ordered_interp_spokes_begin_1_y << interp_spokes_begin_1_y[2*i]
end
40.times do |i|
    ordered_interp_spokes_begin_1_x << interp_spokes_begin_1_x[238+i]
    ordered_interp_spokes_begin_1_y << interp_spokes_begin_1_y[238+i]
end
99.times do |i|
    ordered_interp_spokes_begin_1_x << interp_spokes_begin_1_x[2*i+1]
    ordered_interp_spokes_begin_1_y << interp_spokes_begin_1_y[2*i+1]
end
40.times do |i|
    ordered_interp_spokes_begin_1_x << interp_spokes_begin_1_x[197+i]
    ordered_interp_spokes_begin_1_y << interp_spokes_begin_1_y[197+i]
end


ordered_interp_spokes_begin_2_x = []
ordered_interp_spokes_begin_2_y = []

99.times do |i|
    ordered_interp_spokes_begin_2_x << interp_spokes_begin_2_x[2*i]
    ordered_interp_spokes_begin_2_y << interp_spokes_begin_2_y[2*i]
end
40.times do |i|
    ordered_interp_spokes_begin_2_x << interp_spokes_begin_2_x[238+i]
    ordered_interp_spokes_begin_2_y << interp_spokes_begin_2_y[238+i]
end
99.times do |i|
    ordered_interp_spokes_begin_2_x << interp_spokes_begin_2_x[2*i+1]
    ordered_interp_spokes_begin_2_y << interp_spokes_begin_2_y[2*i+1]
end
40.times do |i|
    ordered_interp_spokes_begin_2_x << interp_spokes_begin_2_x[197+i]
    ordered_interp_spokes_begin_2_y << interp_spokes_begin_2_y[197+i]
end


# srep 1
spoke_dir_0_write = File.open('spoke_dir_srep_0.txt','w')
ordered_interp_spokes_end_0_x.each_with_index do |x, i|
   spoke_dir_0_write.puts (x - ordered_interp_spokes_begin_0_x[i]).to_s + " " + (ordered_interp_spokes_end_0_y[i] - ordered_interp_spokes_begin_0_y[i]).to_s + "\n"
end
spoke_dir_0_write.close
puts 'write srep 1 base points info complete.'
# srep 2
spoke_dir_1_write = File.open('spoke_dir_srep_1.txt','w')
ordered_interp_spokes_end_1_x.each_with_index do |x, i|
   spoke_dir_1_write.puts (x- ordered_interp_spokes_begin_1_x[i]).to_s + " " + (ordered_interp_spokes_end_1_y[i] - ordered_interp_spokes_begin_1_y[i]).to_s + "\n"
end
spoke_dir_1_write.close
puts 'write srep 2 base points info complete.'
#srep3
spoke_dir_2_write = File.open('spoke_dir_srep_2.txt','w')
ordered_interp_spokes_end_2_x.each_with_index do |x, i|
   spoke_dir_2_write.puts (x - ordered_interp_spokes_begin_2_x[i]).to_s + " " + (ordered_interp_spokes_end_2_y[i] - ordered_interp_spokes_begin_2_y[i]).to_s + "\n"
end
spoke_dir_2_write.close
puts 'write srep 3 base points info complete.'





