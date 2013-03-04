# io toolbox contains functions for read/write saved data files
require 'nokogiri'
require 'test/unit'
include Test::Unit::Assertions

load 'lib/io_toolbox.rb'

# test case 0:
#puts readSrepData(0)

doc  = readSrepData(0)
# test case 1:
#puts doc.xpath("//srep//points")[1]

# test case 2: 
#puts doc.xpath("//srep//points")[0].xpath("//point")[4]

# test case 3:
assert_equal(true, doc.xpath("//srep//points")[0].xpath("//point")[0].xpath("//x")[0].content.to_s().strip()=="110")

# test case 4:

