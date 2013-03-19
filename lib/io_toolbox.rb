# io toolbox contains functions for read/write saved data files
require 'nokogiri'
$srep_file_path = "srep_data/config_"
# read an xml and generate data lists
def readSrepData(config_index)
     file_name = $srep_file_path + config_index.to_s() + ".xml"
     f = File.open(file_name)
     doc = Nokogiri::XML(f)
     f.close
     return doc
end


def returnAtomsListFromXML(doc,srep_index)
     doc2 = doc.dup
     doc2.remove_namespaces!
     srep_doc =  doc2.xpath("//srep")[srep_index]
     # get the number of atoms in that srep
     # number of atoms = 
     number_of_atoms = doc.xpath("//sreps//srep:number_of_base_points", 'srep' => 'srep'+srep_index.to_s)[0].content().strip().to_i()
     atom_lst = []
     number_of_atoms.times do |i|
        x = srep_doc.xpath("//points").xpath("//point//x")[i+5*srep_index].content.to_s().strip().to_i()
        y = srep_doc.xpath("//points").xpath("//point//y")[i+5*srep_index].content.to_s().strip().to_i()
        atom_lst << [x,y]
     end

     return atom_lst
end

def returnSpokeLengthListFromXML(doc,srep_index)
     srep_docs = doc.xpath("//srep")[srep_index]
     number_of_atoms = doc.xpath("//sreps//srep:number_of_base_points", 'srep' => 'srep'+srep_index.to_s)[0].content().strip().to_i()
     spoke_len_lst = []
     # sinces spoke lengths are all equal, we pick one of them
     disks = doc.xpath("//radius:disk", 'radius' => 'srep'+srep_index.to_s())
     disks.each_with_index do |disk,i|
       spoke_len = parse_disk_content_from_xml(disk.content())
       rad_lst = []
       if i == 0 or i == number_of_atoms-1
          rad_lst << spoke_len
       end
       rad_lst << spoke_len
       rad_lst << spoke_len
       spoke_len_lst << rad_lst
     end
     
     return spoke_len_lst
end


def returnSpokeDirListFromXML(doc,srep_index)
     srep_docs = doc.xpath("//srep")[srep_index]
     number_of_atoms = doc.xpath("//sreps//srep:number_of_base_points", 'srep' => 'srep'+srep_index.to_s)[0].content().strip().to_i()
     spoke_dir_lst = []
     sps = doc.xpath("//atom:spoke", 'atom' => 'srep'+srep_index.to_s())
     # first atom has three spokes
     atom_0_sp0 = retrieve_spoke_dir_from_raw_xml_content(sps[0].content())
     puts "atom_0_sp0: " + atom_0_sp0.to_s
     atom_0_sp1 = retrieve_spoke_dir_from_raw_xml_content(sps[1].content())
     puts "atom_0_sp1: " + atom_0_sp1.to_s
     atom_0_sp2 = retrieve_spoke_dir_from_raw_xml_content(sps[2].content())
     puts "atom_0_sp2: " + atom_0_sp2.to_s
     spoke_dir_lst << [atom_0_sp0, atom_0_sp1, atom_0_sp2]
     ind = 3
     (number_of_atoms - 2).times do |i|
        atom_i_sp0 = retrieve_spoke_dir_from_raw_xml_content(sps[ind].content())
        ind += 1
        atom_i_sp1 = retrieve_spoke_dir_from_raw_xml_content(sps[ind].content())
        ind += 1
        spoke_dir_lst << [atom_i_sp0, atom_i_sp1]
     end
     atom_m1_sp0 = retrieve_spoke_dir_from_raw_xml_content(sps[ind].content())
     ind+=1
     atom_m1_sp1 = retrieve_spoke_dir_from_raw_xml_content(sps[ind].content())
     ind+=1
     atom_m1_sp2 = retrieve_spoke_dir_from_raw_xml_content(sps[ind].content())
     spoke_dir_lst << [atom_m1_sp0, atom_m1_sp1, atom_m1_sp2]
     return spoke_dir_lst
end

def retrieve_spoke_dir_from_raw_xml_content(cont)
     cont = cont.strip()
     outer_num1 = 0
     outer_num2 = 0
     count = 0
     cont.length.times do |i|
          count +=1
          if cont[i] == "\n" or cont[i] == "\t"
              num1 = cont[0..i-1].to_f
          end 
          if cont[-i] == "\n" or cont[-i] == "\t"
              num2 = cont[-i+1..-1].to_f
          end
          if count == 23
              num1 = cont[0..15].to_f
	      if cont[-24] == "-"
                 num2 = cont[-16..-1].to_f
              else
                 num2 = cont[-15..-1].to_f
              end
          end
          if not num1.nil? and not num2.nil?
              puts "num1: " + num1.to_s
	      puts "num2: " + num2.to_s
              outer_num1 = num1
              outer_num2 = num2
              break
          end
     end
     if outer_num1 % 1 == 0
	outer_num1 = outer_num1.to_i
     end
     if outer_num2 % 1 == 0
	outer_num2 = outer_num2.to_i
     end
     return [outer_num1, outer_num2]
end

def parse_disk_content_from_xml(cont)
   cont = cont.strip()
   if cont[1] == "\n" 
      return cont[0].to_i
   elsif cont[2] == "\n"
      return cont[0..1].to_i
   else
      return cont[0..2].to_i
   end 
end


def saveSrepDataAsXML(file_name,sreps,number_of_sreps)

	builder = Nokogiri::XML::Builder.new do |xml|
	   xml.data {
	        xml.number_of_sreps  number_of_sreps.to_s
	        xml.sreps {
		     	number_of_sreps.times do |i| 
			   srep = sreps[i]
                           atoms_lst = srep.atoms
			   atom_xy_lst = []
			   spoke_length_lst = []
		       	   spoke_dir_lst = []
			   	
                       	   atoms_lst.each_with_index do |atom, ind|
	                      atom_xy_lst << [atom.x, atom.y]
	                      spoke_length_lst << atom.spoke_length
	    		      spoke_dir_lst << atom.spoke_direction
	    		   end
			   xml.srep('xmlns' => ('srep'+i.to_s)){
			       xml.number_of_base_points  srep.atoms.length.to_s
                               xml.points {
                                   atoms_lst.length.times do |j| 
				       	   xml.point {
						xml.x atom_xy_lst[j][0].to_i
						xml.y atom_xy_lst[j][1].to_i
		                           }
			           end
			       }
                               xml.radius {
                                   atoms_lst.length.times do |j| 
                                           xml.disk {
                                               xml.r spoke_length_lst[j][0].to_i
                                               xml.r spoke_length_lst[j][0].to_i
                                               if j ==0 or j==atoms_lst.length - 1
                                                  xml.r spoke_length_lst[j][0].to_i
                                               end
                                           }
                                   end
                               }
                               xml.spoke_dirs {
                                    atoms_lst.length.times do |j| 
                                             xml.atom {
                                                xml.spoke {
                                                   xml.x ("\t"+ spoke_dir_lst[j][0][0].to_s()[0..15] +"\t")
                                                   xml.y ("\t"+ spoke_dir_lst[j][0][1].to_s()[0..15] +"\t")
                                                }
                                                xml.spoke {
                                                   xml.x ("\t"+ spoke_dir_lst[j][1][0].to_s()[0..15] +"\t")
                                                   xml.y ("\t"+ spoke_dir_lst[j][1][1].to_s()[0..15] +"\t")
                                                }
                                                if j == 0 or j == atoms_lst.length - 1
                                                   xml.spoke {
                                                     xml.x ("\t"+ spoke_dir_lst[j][2][0].to_s()[0..15] +"\t")
					             xml.y ("\t"+ spoke_dir_lst[j][2][1].to_s()[0..15] +"\t")
                                                   }
                                                end
                                             }
                                    end
                               }
			   }			
			end		
		}		
	   }
	end	
	f = File.open(file_name,'w')
        f.write(builder.to_xml)
	f.close
end



