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


    
