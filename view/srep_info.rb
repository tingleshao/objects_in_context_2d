# file: srep_info.rb
# author: Chong Shao (cshao@cs.unc.edu)
# view class for srep info

# # # # 

class SrepInfo 
  attr_accessor :app, :index, :msg
  def initialize(app)
    @app = app
    refresh()
  end

  def paint()
    @app.clear
# sub window can access $ variables
    @app.para("Number of objects: " + $sreps.length.to_s())
    @app.para("\n")
    @app.para("########################\n")
    $sreps.each_with_index do |srep,i|
      @app.para("object " + i.to_s() + " ") 
      @app.para(self.formatSrepInfo(srep))
    end 
  end

  def refresh()
    paint()
  end
# format srep info 
  def formatSrepInfo(srep)
    info = "\tname: " + "nil\n\tindex: " + srep.index.to_s() + "\n\tcolor: " + srep.color.to_s() + "\n"
    return info
  end
end

