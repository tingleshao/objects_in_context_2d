# this script reads 8 11 files and construct a long data vector for analysis!
# Author: Chong Shao / cshao@cs.unc.edu
# 2013 all rights reserved.

data_vector = File.open('data_vector.txt','w')

3.times do |i|
   reader = File.open('skeletal_curve_srep_' + i.to_s + '.txt', 'r')
   while line = reader.gets
      data_vector.puts line
   end
   reader.close
end

3.times do |i|
  reader = File.open('spoke_dir_srep_' + i.to_s + '.txt', 'r')
  while line = reader.gets
      data_vector.puts line
  end  
  reader.close
end

3.times do |i|
   reader = File.open('log_spoke_len_srep_' + i.to_s + '.txt', 'r')
   while line = reader.gets
       data_vector.puts line
   end
   reader.close
end

reader = File.open('extended_length.txt')
while line = reader.gets
    data_vector.puts line
end
reader.close

reader = File.open('linked_spoke_index_in_order_obj.txt')
while line = reader.gets
    data_vector.puts line
end
reader.close
puts "write data vector finished."
data_vector.close
