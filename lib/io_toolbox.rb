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
     atom_0_sp1 = retrieve_spoke_dir_from_raw_xml_content(sps[1].content())
     atom_0_sp2 = retrieve_spoke_dir_from_raw_xml_content(sps[2].content())
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
     cont.length.times do |i|
          if cont[i] == "\n" or cont[i] == "\t"
              num1 = cont[0..i-1].to_f
          end 
          if cont[-i] == "\n" or cont[-i] == "\t"
              num2 = cont[-i+1..-1].to_f
          end
          if not num1.nil? and not num2.nil?
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
	
	atoms_lst.each_with_index do |atom, ind|
	    atom_xy_lst << [atom.x, atom.y]
	    spoke_length_lst << atom.spoke_length
	    spoke_dir_lst << atom.spoke_direction
	end
	builder = Nokogiri::XML::Builder.new do |data|
	   xml.data {
	        xml.number_of_sreps  number_of_sreps.to_s
	        xml.sreps {
		     	number_of_sreps.times do |i| {
			   srep = sreps[i]
                           atoms_lst = srep.atoms
			   atom_xy_lst = []
			   spoke_length_lst = []
		       	   spoke_dir_lst = []
			   xml.srep{
			       xml.number_of_base_points  len(srep.atoms).to_s
                               xml.points {
                                   atoms_lst.length.times do |i| {
				       	   xml.point {
						xml.x atom_xy_lst[i][0]
						xml.y atom_xy_lst[i][1]
		                           }
			           }
			       }
                               xml.radius {
                                   atoms_lst.length.times do |i| {
                                           xml.disk {
                                               xml.r spoke_length_lst[i]
                                               xml.r spoke_length_lst[i]
                                               if i ==0 or i==atoms_lst.length - 1
                                                  xml.r spoke_length_lst[i]
                                               end
                                           }
                                   }
                               }
                               xml.spoke_dirs {
                                    atoms_lst.length.times do |i| {
                                             xml.atom {
                                                xml.spoke {
                                                   xml.x spoke_dir_lst[i][0][0]
                                                   xml.y spoke_dir_lst[i][0][1]
                                                }
                                                xml.spoke {
                                                   xml.x spoke_dir_lst[i][1][0]
                                                   xml.y spoke_dir_lst[i][1][1]
                                                }
                                                if i == 0 or i == atoms_lst.length - 1
                                                   xml.spoke {
                                                     xml.x spoke_dir_lst[i][2][0]
					             xml.y spoke_dir_lst[i][2][1]
                                                   }
                                                end
                                             }
                                    }
                               }
			   }			
			}		
		}		
	   }
	end	
end



=begin
  points0 = [[110,100],[160,75],[210,50],[260,60],[310,80]]
  l0 = [[35,35,35],[40,40],[30,30],[40,40],[35,35,35]]
  u0 = [[[-1,3],[-0.1,-4],[-9,1]],[[-1,4],[1.1,-3]],[[-1,4],[0.2,-6]],[[1,9],[0.05,-8]],[[1,2],[1,-5],[6,1]]]
  srep0 = generate2DDiscreteSrep(points0,l0,u0,0.01,0)
  srep0.orientation = [0,1]
  $sreps = [srep0]

  points1 = [[200,190],[250,190],[300,200],[350,180],[400,160]]
  l1 = [[35,35,35],[40,40],[45,45],[40,40],[35,35,35]]
  u1 = [[[-1,6],[0.5,-3],[-9,1]],[[-1,4],[-1,-3]],[[-1,4],[-0.1,-6]],[[1,9],[1,-1.5]],[[1,2],[2,-5],[6,1]]]
  srep1 = generate2DDiscreteSrep(points1,l1,u1,0.01,1)
  srep1.color = Color.green
  srep1.orientation = [0,1]
  $sreps << srep1

  points2 = [[30,50],[10,100],[9,150],[20,200],[50,240],[110,290]]
  l2 = [[35,35,35],[35,35],[40,40],[35,35],[40,40],[40,40,40]]
  u2 = [[[6,1],[6,-0.5],[-9,1]],[[-1,4],[3,-0.5]],[[-1,4],[5,-0.5]],[[1,9],[5,1]],[[1,9],[5,3]],[[1,2],[3,5],[6,1]]]
  srep2 = generate2DDiscreteSrep(points2,l2,u2,0.01,2)
  srep2.color = Color.purple
  srep2.orientation = [1,0]
  $sreps << srep2
  
  refresh @points, $sreps, @shifts
=end
    
