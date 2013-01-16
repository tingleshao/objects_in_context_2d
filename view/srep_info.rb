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
    @app.para("hello world")
    @app.para($sreps.to_s)

  end

  def refresh()
    paint()
  end
end

