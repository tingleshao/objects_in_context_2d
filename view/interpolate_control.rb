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
          f = File.new($points_file_path+ $mosrepindex.to_s, 'r')   
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
         puts "indices: " +  indices.to_s 
          
  # this is where it calls computeBaseKappa
##########
#########
#####
          foo = computeBaseKappa(xt,yt, indices, h, rr)
#######
#####   what is xendt and yendt?
       ub = []
       vb = []
       srep.atoms.each_with_index do |a, i|
         ub << a.spoke_direction[0]  # fill up u_base 
         curve = srep.skeletal_curve
         curve_x = curve[0] 
         curve_y = curve[1]
         current_point_index = indices[i]
         if i != indices.size - 1 
           v = [curve_x[current_point_index+1] - curve_x[current_point_index], curve_y[current_point_index+1] - curve_y[current_point_index] ]   
         else 
            v = [curve_x[current_point_index] - curve_x[current_point_index-1], curve_y[current_point_index] - curve_y[current_point_index-1 ] ]   
         end  
          # need to normalize v
           norm_v = Math.sqrt(v[0]**2 + v[1] **2) 
          v = v.collect{|x| x / norm_v }
          vb << v 
       end
         puts "U: " + ub.to_s
         puts "V: " + vb.to_s
         foo2 = computeBaseKappa2(ub,vb,indices)
         # now we have the values foo2 which is the corrected k? 
        # check if it is correct
         puts "#########################3compare two kappas: #####################"
         puts "kappa1: " + foo[0].to_s
         puts "kappa2: " + foo2.to_s
          kappa = foo2
          rt = srep.atoms.collect{|atom| atom.spoke_length[0]} 
          interpolateKappa3(rt, kappa, step_size, index,indices)
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
