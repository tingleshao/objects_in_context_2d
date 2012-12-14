class DrawPad
  attr_reader :atoms 
	
  def initialize(app)
    @app = app
    @atoms = []
    @inCircle = false
  end
	
  def paint()
    @app.clear
    @app.background 'pat101_21.png'
    @app.flow :margin => 3 do
      @fileName = @app.edit_line
      @app.button("Save") {
        alert @atoms.to_s
        if @fileName.text != ""
          fn = @fileName.text
        else 
          fn = "srep_temp"
        end
        File.open(fn + '.txt','w') {|file|
	  file.write (@atoms.to_s)
	  file.close}
      }
      @app.button("Undo") {
        if(@atoms.size > 0)
	  @atoms.pop
        end
        @inCircle = false
	  refresh }
     end
     @app.nofill
     atoms.each do |atom|
       @app.oval atom[0]-atom[2]/2, atom[1]-atom[2]/2, atom[2]
     end
   end

   def refresh()
     paint
     @app.click do |button, left, top|
       if @inCircle == false
	 @atoms << [left, top, 10]
	 @inCircle = true
	 paint
       else 
	 @atoms.last[2] = @atoms.last[2] + 1.5
	 paint
       end
   end
   @app.keypress do |k|
     if "#{k.inspect}".to_s == "g"
     else
       @inCircle = false
     end
   end
 end
	
end 
