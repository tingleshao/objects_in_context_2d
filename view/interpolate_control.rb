load 'lib/srep_toolbox.rb'

# a class for the subwindow for choosing the srep to compute interpolation
class InterpolateControl
	
  attr_accessor :app, :index, :msg
  def initialize(app)
    @app = app
   refresh
  end
	
  def paint()
    @app.clear
    @app.flow :margin => 3 do
      @app.button("Check") {
      	if checkIndexEmpty()
          @msg.text = "empty index!"
        else
          file_name = $radius_file_path2 + @index.text
          @msg.text = "file exists: "+  File::exists?(file_name).to_s
        end
      }
      @app.button("Interpolate") {
      # interpolate radius
          index = @index.text
          srep =  $sreps[index.to_i]
          xt = srep.atoms.collect{|atom| atom.x}
          yt = srep.atoms.collect{|atom| atom.y}
          rt = srep.atoms.collect{|atom| atom.spoke_length[0].to_s} 
          step_size = 0.01
          rs = interpolateRadius(xt,yt,rt,step_size,index)
          rr = rs.strip.split(' ').collect{|r| r.to_f} 
          # interpolate kappa
          # read interpolated file
          step_size = 0.01
          # rt and kt are the r's and k's on the base points 
          # calculate kappa at base positions using the curvature formula
          f = File.new($points_file_path2+ index, 'r')   
          xs = f.gets.strip.split(' ')
          ys = f.gets.strip.split(' ')
          xt = []
          xs.each do |x|
            xt << x.to_f
          end
          yt = []
          ys.each do |y|
            yt << y.to_f
          end
          h = step_size
          f.close
          ff = File.new($radius_file_path2+index, 'r')
          rs = ff.gets.strip.split(' ')
          indices= srep.base_index
  # this is where it calls computeBaseKappa
##########
#########
#####
          foo = computeBaseKappa(xt,yt, indices, h, rr)
#######
#####   what is xendt and yendt?
      #    foo2 = computeBaseKappa2(xt,yt,xendt,yendt,h,rr)
          kappa = foo[0]
          rt = srep.atoms.collect{|atom| atom.spoke_length[0]} 
          interpolateKappa(rt, kappa, step_size, index)
     }
     end
     @app.stack :margin => 3 do 
       @app.para "enter the index of the srep"
       @index = @app.edit_line :width => 50
       @msg = @app.para ""
     end
     @app.nofill
   end

   def refresh
     paint
   end
	
   def checkIndexEmpty()
     return @index.text.strip() == ""
   end
end
