# a viewer for loading saved data files


class FileLoaderView

  attr_accessor :app
  def initialize(app)
    @app = app
    refresh()
  end
  
  def paint()
    @app.clear()
    @app.stack :margin => 3 do 
      @app.para("File name: ")
      @app.edit_line("ddl")
      @app.button("Load")

    # then this function load the file, and pass it as the global variable to the main window, set the flag to yes. and uses it to refresh the GUI. ( add interpolated spokes)..



   end
  end
  
  def refresh()
    paint()
  end 

 
end
