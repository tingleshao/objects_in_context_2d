# file: main.rb
# The main program of the 2D objects in context protypeing system.
# It contains a class Field that abstracts the canvas of the main window that displays the s-reps. 
# It contains a class InterpolationControl that abstracts a subwindow for user 
#  to select which s-rep's spokes to interpolate. 
# The last part: Shoes.app runs the program.
#
# Author: Chong Shao (cshao@cs.unc.edu)
# ----------------------------------------------------------------

require 'nokogiri'
load 'lib/srep_toolbox.rb'
load 'lib/color.rb'
load 'view/interpolate_control.rb'
load 'view/srep_info.rb'
load 'view/file_loader_view.rb'
load 'lib/io_toolbox.rb'

#$mosrepindex = 3

$mosrepindex = ARGV[1].to_s
$noise_index = ARGV[2].to_s

$noise_file_name = 'noise_data_' + $noise_index + '.txt'

# change the path will effect all these things 
$points_file_path = "data/mosrep"+$mosrepindex.to_s+ "/noise_" + $noise_index + "/interpolated_points_"
$radius_file_path = "data/mosrep"+$mosrepindex.to_s + "/noise_" + $noise_index +"/interpolated_rs_"
$logrk_file_path = "data/mosrep"+$mosrepindex.to_s + "/noise_" + $noise_index + "/interpolated_logrkm1s_"
#$logrk_file_path2 = "data2/interpolated_logrkm1s_"
#$logrk_file_path3 = "data3/interpolated_logrkm1s_"
#$radius_file_path2 = "data2/interpolated_rs_"
#$points_file_path2 = "data2/interpolated_points_"
$saved_linking_data_path = "data/saved_data/mosrep" + $mosrepindex.to_s + '/noise_' + $noise_index.to_s + '/linking'
$saved_mapping_data_path = "data/saved_data/mosrep" + $mosrepindex.to_s + '/noise_' + $noise_index.to_s + '/mapping'

$saved_data_path = 'data/saved_data/mosrep' + $mosrepindex.to_s + '/noise_' + $noise_index.to_s + '/'
$dilate_ratio = 1.05
$a_big_number = 100
$end_disk_spoke_number = 20


def transform_interp_spoke_index(n)
     k = n - 1
     i = -1
     if k <= 98
        i = k * 2
     elsif k <= 138
        i = k - 98 + 237
     elsif k <= 237
        i = (k-139) * 2 + 1
     else
        i = (k-238) + 198
     end
     return i
end

$colored_spoke_indices_origin = [35, 40, 41, 42, 44, 45, 47, 50]
$colored_spoke_indices = []
$colored_spoke_indices_origin.each do |n|
   $colored_spoke_indices << transform_interp_spoke_index(n)
end

class Field
# this is the Field class that draws everything about s-rep on the main UI
  attr_accessor :sreps, :shifts
  
  def initialize(app, points, sreps, shifts)
    @app = app
    # set window size
    @width, @height= 800, 600
    @sreps = sreps 
    @shifts = shifts
  end
  
  def setSrep(srep, index) 
    @sreps[index] = srep
  end
  
  def addSrep(srep) 
    @sreps << srep
  end
 
  # methods for rendering points 
  def render_point_big(x, y, color)
    @app.stroke color
    @app.strokewidth 2
    @app.nofill
    @app.oval x-1,y-1, 2
  end

  def render_point_small(x, y, color, bg_color)
   @app.stroke color
   @app.line x, y, x, y+1
   @app.stroke bg_color
   @app.line x, y+1, x+1, y+1
  end
  
  # methods for rendering disks
  def render_circle(cx, cy, d, color)
    @app.stroke color
    @app.nofill 
    @app.oval cx, cy, d
  end

  # methods for rendering spokes
  def render_spokes(cx, cy, type, spoke_length, spoke_direction, color)
    @app.stroke color
    u_p1 = spoke_direction[0]
    u_m1 = spoke_direction[1] 
    @app.stroke color
    spoke_end_x_up1 = cx + spoke_length[0] * u_p1[0]
    spoke_end_y_up1 = cy - spoke_length[0] * u_p1[1]
    @app.line(cx, cy, spoke_end_x_up1, spoke_end_y_up1)
    spoke_end_x_up2 = cx + spoke_length[0] * u_m1[0]
    spoke_end_y_up2 = cy - spoke_length[0] * u_m1[1]
    @app.line(cx, cy, spoke_end_x_up2, spoke_end_y_up2)
    if type == 'end'
    u_0 = spoke_direction[2]
    spoke_end_x_u0 = cx + spoke_length[0] * u_0[0]
    spoke_end_y_u0 = cy - spoke_length[0] * u_0[1]
    @app.line(cx, cy, spoke_end_x_u0, spoke_end_y_u0)
    end
  end

  # the method for rendering s-reps
  def render_srep(*args)
    srep = args[0]
    shiftx  = args[1]
    shifty = args[2]
    scale = args[3]
    show_sphere = args[4]
      
    srep.atoms.each_with_index do |atom|
      render_atom(atom.x + shiftx, atom.y + shifty, atom.color)
      if show_sphere
        center_x = atom.x + shiftx - atom.spoke_length[0]
        center_y = atom.y + shifty - atom.spoke_length[0]
        d = atom.spoke_length[0] * 2
	render_circle(center_x, center_y, d, srep.color)
      end
      if srep.show_extend_disk
        center_x = atom.x + shiftx - atom.expand_spoke_length[0]
        center_y = atom.y + shifty - atom.expand_spoke_length[0]
        d = atom.expand_spoke_length[0] * 2 
        render_circle(center_x, center_y, d, srep.color)
      end 
      atom_x = atom.x+shiftx
      atom_y = atom.y+shifty
      render_spokes(atom_x, atom_y, atom.type, atom.spoke_length, atom.spoke_direction, srep.color)
    end

    if srep.interpolated_spokes_begin.length > 0 and srep.show_interpolated_spokes
      spoke_begin = srep.interpolated_spokes_begin
      spoke_end = srep.interpolated_spokes_end
      render_interp_spokes(shiftx, shifty, Color.white, spoke_begin, spoke_end, srep.index)
    end

    if (srep.getExtendInterpolatedSpokesEnd()).length > 0 and srep.show_extend_spokes
      spoke_begin = srep.interpolated_spokes_end  
      spoke_end = srep.getExtendInterpolatedSpokesEnd()
      render_extend_interp_spokes(shiftx, shifty, srep.color, spoke_begin, spoke_end)
    end
    
    if srep.show_curve
      # display the interpolated curve points
      render_curve($sreps, srep.index, srep, shiftx, shifty)
    end
  end 
  
  def render_curve(sreps, index, srep, shiftx, shifty)
    file_name = $points_file_path + index.to_s
    if File::exists?(file_name)
      gamma_file = File.open(file_name, "r")
    else
      alert('file does not exist, interpolate it now')
      xt = srep.atoms.collect{|atom| atom.x}
      yt = srep.atoms.collect{|atom| atom.y}
      step_size = 0.01
      interpolateSkeletalCurveGamma(xt,yt,step_size,srep.index)
      gamma_file = File.open(file_name, "r")
    end 
    xs = gamma_file.gets.split(" ").collect{|x| x.to_f}
    ys = gamma_file.gets.split(" ").collect{|y| y.to_f}
   
    if (srep.interpolate_finished)
      xs.each_with_index do |x,i|
        spoke_ind = i*2
        atom_type = srep.getExtendInterpolatedSpokesEnd()[spoke_ind][4]
        back_atom_type = srep.getExtendInterpolatedSpokesEnd()[spoke_ind+1][4]
        if atom_type != 'end' and back_atom_type != 'end'
          linkingIndex = srep.getExtendInterpolatedSpokesEnd()[spoke_ind][2]
          if linkingIndex == -1
            color1 = srep.color
          else 
            color1 = sreps[linkingIndex].color
          end
            linkingIndex = srep.getExtendInterpolatedSpokesEnd()[spoke_ind+1][2]
          if linkingIndex == -1
            color2 = srep.color
          else 
            color2 = sreps[linkingIndex].color
          end
        else 
          color1 = srep.color
          color2 = srep.color
        end
        render_atom(x+shiftx,ys[i]+shifty, color1)
        render_atom(x+shiftx+3*srep.orientation[0], ys[i]+shifty+3*srep.orientation[1], color2)
      end
    else 
      xs.each_with_index do |x,i|
        render_atom(x+shiftx,ys[i]+shifty, srep.color)
        render_atom(x+shiftx+3*srep.orientation[0], ys[i]+shifty+3*srep.orientation[1], srep.color)
      end
    end
  end
  
  # method for rendering interpolated spokes
  def render_interp_spokes(shiftx, shifty, color, ibegin, iend, srep_index)

    ibegin.each_with_index do |p, i|
       if ($colored_spoke_indices.include? i and srep_index == 0)
          @app.stroke Color.blue
       else
          @app.stroke color
       end
       @app.line(p[0]+shiftx, p[1]+shifty, iend[i][0]+shiftx, iend[i][1]+shifty)
    end
  end
   
  # method for rendering extended part of spokes
  def render_extend_interp_spokes(shiftx, shifty, color, ibegin, iend)
    @app.stroke color
    # TODO: BUGGY!!
    iend.each_with_index do |p, i|
	if p.size >= 4 and  (p[3].is_a? Integer) and p[3] >= 0 and p[3] < 3 
	      @app.stroke $sreps[p[3]].color
	elsif p.size >=3 and (p[2].is_a? Integer) and p[2] >= 0 and p[2] < 3 
	      @app.stroke $sreps[p[2]].color
	end
      @app.line(ibegin[i][0]+shiftx, ibegin[i][1]+shifty, p[0]+shiftx, p[1]+shifty)
    end
  end

  def color_one_spoke(shiftx, shifty, color, ibegin, iend) 
    @app.stroke color
    @app.line(ibegin[0]+shiftx, ibegin[1]+shifty, iend[0]+shiftx, iend[0]+shifty)
  end
  
  # method for rendering atoms
  def render_atom(x, y, color)
    render_point_big(x, y, color)
  end
  
  # method for rendering linking structure
  def render_linking_structure(shifts)
     shift = shifts[0]
     $linkingPts.each do |pt|
       if pt != []
         render_atom(pt[0]+shift, pt[1]+shift, Color.black)
       end
     end
  end

  # this method calls the render_srep() and render_linking_structure() method
  def paint
    @app.nostroke
    checkSrepIntersection

    $sreps.each.with_index do |srep, i|
      render_srep(srep, @shifts[i] , @shifts[i] , 1.5, true)
    end

    if $show_linking_structure 
       render_linking_structure(@shifts)
    end
  end  
 
  # this method interates the sreps and let them check the spoke intersection
  def checkSrepIntersection
   (0..$sreps.length-1).each do |j|
    (0..$sreps.length-1).each do |i|
       if i != j
        $sreps[j].checkIntersection($sreps[i])
       end
    end
   end
  end

 def [](*args)
    x, y = args
    raise "Cell #{x}:#{y} does not exist!" unless cell_exists?(x, y)
    @field[y][x]
 end
  
 def []=(*args)
   x, y, v = args
   cell_exists?(x, y) ? @field[y][x] = v : false
 end
end

# this is the driver for the main program
Shoes.app :width => 1000, :height => 800, :title => '2d multi object' do
  def render_field
    clear do 
      background rgb(192, 192, 192, 0.7)   # light gray
   #       html_doc = Nokogiri::HTML("<html><body><h1>Loaded with XML</h1></body></html>")
   #  para html_doc
   #  para " \n\n\n\n"
	para $info
      flow :margin => 6 do

       # code for buttons
      button("Dilate") { 
	 $sreps.each do |srep|
	    srep.atoms.each do |atom|
	      atom.dilate($dilate_ratio)
	    end
            # dilate interpolated spokes
            # and check intersection 
            # user can specify first serval count to speed up dilate
            if $dilateCount > 6
              sublinkingPts = srep.extendInterpolatedSpokes($dilate_ratio, $sreps, true)
              sublinkingPts.each do |p|
                $linkingPts << p
              end
            else
              srep.extendInterpolatedSpokes($dilate_ratio, $sreps, false)
            end
	  end
          $linkingPts = $linkingPts.uniq
          $dilateCount = $dilateCount + 1
          refresh @points, $sreps, @shifts
        }

	button("Reset") {
	  @dontGrowLst= []
	  initialConfig
	}

        button("Check File") {
          window :title => "draw srep", :width => 402, :height => 375 do
	          ip = InterpolateControl.new(self) # change dp to ip
          end
        }

       
        button("Load") {
         window :title => "choose file", :width => 250, :height => 100 do
           flv = FileLoaderView.new(self) 
         end
        }
        button("Interpolate Spokes") {
     # make this correct!! 

     # the k is the change of the swings .
    # ... which can be approximated by the change of the swings of 3 base points .....
    # i guesss...
   # need to look at my report!
   # 

         $sreps.each_with_index do |srep, srep_index| 
             file1 = File.open($points_file_path + srep_index.to_s, 'r')
             test = "here!!"
             xt = file1.gets.split(' ').collect{|x| x.to_f}
	     yt = file1.gets.split(' ').collect{|y| y.to_f}
             file2 = File.open($radius_file_path + srep_index.to_s, 'r')
             rt = file2.gets.split(' ').collect{|r| r.to_f} #=> get the r files 
      #       if srep_index == 2
       #        alert(rt.to_s)
        #     end
             file3 = File.open($logrk_file_path + srep_index.to_s, 'r')
             logrkm1 = file3.gets.split(' ').collect{|logrkm1| logrkm1.to_f}
             puts "logrkm1 length: " + logrkm1.length.to_s
             $a_big_number.times do # default: 100
            # interpolate one side
                indices = srep.base_index
                base_index = $current_base_index
                distance_to_next_base = ( indices[base_index+1] - indices[base_index] ) - $step_go_so_far 
                if distance_to_next_base == 0 # <= reached another base point
                   $step_go_so_far  = 0
                   $current_base_index = $current_base_index +1    
                   distance_to_next_base = indices[base_index+1] - indices[base_index]
                   spoke_index = $current_base_index
                end
          
                curr_index = indices[base_index] + $step_go_so_far + 1 
                # this is wrong... . <= why?
                d1t = 0.01 * $step_go_so_far 
                d2t = distance_to_next_base * 0.01 

             # calculate parameters
             # read all points, rs, logrkm1s from the file
      #       file = File.open($points_file_path + srep_index.to_s, 'r')
            # xt/ yt: interpolatd x and y locus
        #     xt = file1.gets.split(' ').collect{|x| x.to_f}
	      #     yt = file1.gets.split(' ').collect{|y| y.to_f}
        #     file2 = File.open($radius_file_path + srep_index.to_s, 'r')
          # rt: interpolated radius r
    	#       rt = file2.gets.split(' ').collect{|r| r.to_f}
          # logrk: interpolated logrk <= needs to be fixed.

# here it uses the large difference to produce v, which is not good.
               if curr_index < xt.length-1
                  v1t = [xt[curr_index] - xt[indices[base_index]], yt[curr_index] - yt[indices[base_index]]]
            # it checks whether it reaches the next base index
                  if curr_index == indices[base_index+1]
                     v2t = [xt[indices[base_index+1]+1] - xt[curr_index], yt[indices[base_index+1]+1] - yt[curr_index]]
                  else
                     v2t = [xt[indices[base_index+1]] - xt[curr_index], yt[indices[base_index+1]] - yt[curr_index]]
                  end

    #           puts "v1t: " + v1t.to_s
            # yes it normalizes the size of v vector
                  size_v1t = v1t[0]**2 + v1t[1]**2
                  norm_v1t = v1t.collect{|v| v / size_v1t} 
                  size_v2t = v2t[0]**2 + v2t[1]**2
     #          puts "size_v2t: " + size_v2t.to_s
                  norm_v2t = v2t.collect{|v| v / size_v2t} 
          

# these k's are calculated using the stored value of log(1-rk)
	          puts "curr logrkm1: " + logrkm1[indices[base_index]].to_s
                  puts "additional logrkm1: " + logrkm1[indices[base_index+1]].to_s
                  k1t = ( 1 + ( -1 * Math.exp(logrkm1[indices[base_index]]   ) ) ) / rt[indices[base_index]] 
                  if logrkm1[indices[base_index+1]] 
                     k2t = ( 1 + ( -1 * Math.exp(logrkm1[indices[base_index+1]] ) ) ) / rt[indices[base_index+1]] 
                  else
                     k2t = ( 1 + ( -1 * Math.exp(logrkm1[-1] ) ) ) / rt[indices[-1]] 
                  end
                  u1t = srep.atoms[base_index].spoke_direction[0]
                  u2t = srep.atoms[base_index+1].spoke_direction[0]
           #    if (srep_index == 2)
           #         ui = interpolateSpokeAtPos2(u1t,norm_v1t,k1t,d1t)
           #    else
                  ui = interpolateSpokeAtPos(u1t, norm_v1t, k1t, d1t, u2t, norm_v2t, k2t, d2t)
           #    end
          #     if srep_index == 2
        #            alert ui
	#       end
               # ui should be normalized
         #      ui_size = Math.sqrt(ui[0] ** 2 + ui[1] ** 2)
         #      ui = [ui[0]/ui_size, ui[1]/ui_size]
      #        puts "ui: " + ui.to_s
                  srep.interpolated_spokes_begin << [xt[curr_index],yt[curr_index],-1]    
      #        puts "rt: " + rt[curr_index-1].to_s
                  srep.interpolated_spokes_end  <<  [xt[curr_index]+ui[0]*rt[curr_index],yt[curr_index]-ui[1]*rt[curr_index],-1,[],'regular']




               # interpolate another side
                  u1t = $sreps[srep_index].atoms[base_index].spoke_direction[1]
                  u2t = $sreps[srep_index].atoms[base_index+1].spoke_direction[1]
              # if (srep_index == 2)
              #     ui = interpolateSpokeAtPos2(u1t,norm_v1t,k1t,d1t)
             #  else 
                  ui = interpolateSpokeAtPos(u1t, norm_v1t, k1t, d1t, u2t, norm_v2t, k2t, d2t)
            #   end
       #       puts "ui: " + ui.to_s
                  spoke_index = indices[base_index]+$step_go_so_far+1
                  spoke_begin_x = xt[spoke_index]
                  spoke_begin_y = yt[spoke_index ]
                  $sreps[srep_index].interpolated_spokes_begin << [spoke_begin_x,spoke_begin_y,-1,[],'regular']    
     #          puts "rt: " + rt[indices[base_index]+$step_go_so_far].to_s
                  spoke_end_x = spoke_begin_x + ui[0]*rt[spoke_index]
                  spoke_end_y = spoke_begin_y - ui[1]*rt[spoke_index]
                  $sreps[srep_index].interpolated_spokes_end  <<  [spoke_end_x,spoke_end_y,-1,[],'regular']
              else



               # add spoke interpolation for end disks
               # get atom for end disks
               end_atom_one = srep.atoms[0]
               end_atom_two = srep.atoms[-1]
               end_atoms = [end_atom_one, end_atom_two]
               # get upper and lower and middle spokes
               end_atoms.each_with_index do |atom, i|
                 atom_spoke_dir_plus1 = atom.spoke_direction[0]
                 atom_spoke_dir_minus1 = atom.spoke_direction[1]
                 atom_spoke_dir_zero = atom.spoke_direction[2]
                 x_diff_1 = atom_spoke_dir_zero[0] - atom_spoke_dir_plus1[0]
                 x_diff_2 = atom_spoke_dir_zero[0] - atom_spoke_dir_minus1[0]

                 y_diff_1 = atom_spoke_dir_zero[1] - atom_spoke_dir_plus1[1]
                 y_diff_2 = atom_spoke_dir_zero[1] - atom_spoke_dir_minus1[1]
                 x_step_size_1 = x_diff_1.to_f / 15
                 y_step_size_1 = y_diff_1.to_f / 15
                 x_step_size_2 = x_diff_2.to_f / 15
                 y_step_size_2 = y_diff_2.to_f / 15
                 previous_x = atom_spoke_dir_plus1[0] 
                 previous_y = atom_spoke_dir_plus1[1] 
                 $end_disk_spoke_number.times do 
                   new_spoke_dir_x = previous_x + x_step_size_1
                   new_spoke_dir_y = previous_y + y_step_size_1
                   # normalize 
                   length_new_spoke = Math.sqrt(new_spoke_dir_x**2 + new_spoke_dir_y**2)
                   new_spoke_dir_x = new_spoke_dir_x / length_new_spoke
                   new_spoke_dir_y = new_spoke_dir_y / length_new_spoke
                   previous_x = new_spoke_dir_x
                   previous_y = new_spoke_dir_y
                   # calculate interpolated spoke end
                   new_spoke_vector_x = atom.spoke_length[0]*new_spoke_dir_x
                   new_spoke_vector_y = atom.spoke_length[0]*new_spoke_dir_y
                   new_spoke_end = [atom.x + new_spoke_vector_x, atom.y - new_spoke_vector_y,-1,[],'end']
                   $sreps[srep_index].interpolated_spokes_begin << [atom.x, atom.y]
                   $sreps[srep_index].interpolated_spokes_end << new_spoke_end
                 end
                 previous_x = atom_spoke_dir_minus1[0]
                 previous_y = atom_spoke_dir_minus1[1]
                 $end_disk_spoke_number.times do 
                   new_spoke_dir_x = previous_x + x_step_size_2
                   new_spoke_dir_y = previous_y + y_step_size_2
                   # normalize 
                   length_new_spoke = Math.sqrt(new_spoke_dir_x**2 + new_spoke_dir_y**2)
                   new_spoke_dir_x = new_spoke_dir_x / length_new_spoke
                   new_spoke_dir_y = new_spoke_dir_y / length_new_spoke
                   previous_x = new_spoke_dir_x
                   previous_y = new_spoke_dir_y
                   # calculate interpolated spoke end
                   new_spoke_vector_x = atom.spoke_length[0]*new_spoke_dir_x
                   new_spoke_vector_y = atom.spoke_length[0]*new_spoke_dir_y
                   new_spoke_end = [atom.x + new_spoke_vector_x, atom.y - new_spoke_vector_y,-1,[],'end']
                   $sreps[srep_index].interpolated_spokes_begin << [atom.x, atom.y]
                   $sreps[srep_index].interpolated_spokes_end << new_spoke_end
                   $sreps[srep_index].interpolate_finished = true
                 end
               end
               $info = "interpolation finished"
             end
             $step_go_so_far = $step_go_so_far + 1
     #        puts "count: "+ $step_go_so_far.to_s
             
             refresh @points, $sreps, @shifts
           end
           $step_go_so_far = 1
           $current_base_index = 0
         end
       }

       button("Info") {
          window :title => "s-rep info", :width => 402, :height => 375 do
            # si = sreps info
	          si = SrepInfo.new(self)
          end  
       }

#              ---------------------------------------------------
#                EDIT

      button("orthogonalization") {
	 orthogonalized_middle_spokes = computeOrthogonalizedSpokes($sreps[0])
         3.times do |i|
            orthogonalized_middle_spokes[i][1] = orthogonalized_middle_spokes[i][1]
            $sreps[0].atoms[i+1].spoke_direction[0] = orthogonalized_middle_spokes[i]
         end
            $info = orthogonalized_middle_spokes.to_s
            $sreps[0].interpolated_spokes_begin = []
            $sreps[0].interpolated_spokes_end = []
	    $sreps[0].extend_interpolated_spokes_end = []
          refresh @points, $sreps, @shifts           
      }
#
      button("save") {
         # save all the linking infomation with assocaited mosrep index as file name postfix
	 # things to save:
         #      linking structure index 
         #      mapping: medial curve pts color, where it links to 
         # save as txt
         # save linking 
         link_save = File.open($saved_linking_data_path,'w')
         link_save.write($linkingPts.to_s)
         link_save.close
         # save mapping information
         mapping_save = File.open($saved_mapping_data_path, 'w')
         mapping_info = $sreps[0].get_linking_info # TODO: fix this get_linking_info method
         mapping_save.write(mapping_info.to_s)
         mapping_save.close 
      }

      button("save2") {
	 # according to the notes, this save2 button will save the follows:
         # 1. array for all the interpolated spokes for the reference obj, parameterized by a 
         #     number from 0 to 1 ( currently it has 100 spokes? )
         # 2. index for the neighbor ( 0 if not intersected ) <- how about self-linking?
         # 3. array for linking length   
         # 4. a link position array, indicates which spoke on that object this spoke links to 
         # ^^^^^^^^^^^^^^^
	 # data1: base pts positions for 3 s-reps, in 3 files
         # data2: interpolated spokes end for 3 sreps, in 3 files 
         # data3: extended_spokes for srep0, in one file
         # from the 3 kinds of data above, we should be able to generate all the data for stats
         number_of_sreps = $sreps.size
         number_of_sreps.times do |i|
            data1_save = File.open($saved_data_path + "interpolated_pts_" + i.to_s, 'w')
            pts_info = $sreps[i].skeletal_curve
            data1_save.write(pts_info.to_s)
            data1_save.close
         end
         number_of_sreps.times do |i|
            data2_save = File.open($saved_data_path + "interpolated_spokes_" + i.to_s,'w')
            interp_info_begin = $sreps[i].interpolated_spokes_begin
            data2_save.write(interp_info_begin.to_s)
            data2_save.write("\n========\n")
            interp_info_end = $sreps[i].interpolated_spokes_end
            data2_save.write(interp_info_end.to_s)
            data2_save.close
         end
         data3_save = File.open($saved_data_path + 'ref_obj_linking','w')
         ref_obj_linking_info = $sreps[0].extend_interpolated_spokes_end
         data3_save.write(ref_obj_linking_info.to_s)
         data3_save.close
         
         alert('save completed.')
      }
  
      button("save as") {
         # currently save as config_1
         saveSrepDataAsXML('srep_data/config_1.xml',$sreps,3)
      }  

      button("label spokes") {
         indices = [49]
         indices.each do |k|
            i = k / 2 - 1
            # get the position for that spoke with index i 
            shiftx = @shifts[0]
	    shifty = @shifts[1]
            srep_0 = $sreps[0]
            ibegin = [srep_0.interpolated_spokes_begin[i][0],srep_0.interpolated_spokes_begin[i][1]]
            iend = [srep_0.interpolated_spokes_end[i][0],srep_0.interpolated_spokes_end[i][1]]
            # color it
	    @field.color_one_spoke(shiftx, shifty, Color.blue, ibegin, iend)
         end
      } 
     
    #  button("Interpolate Spokes 2") {
    #	srep = $sreps[0]
   #	srep_index = 0
#	curr_index = 0
#	if not $xt 
#		file = File.open($points_file_path + srep_index.to_s, 'r')
#		$xt = file.gets.split(' ').collect{|x| x.to_f}
#		$yt = file.gets.split(' ').collect{|y| y.to_f}
#		file = File.open($radius_file_path2 + srep_index.to_s, 'r')
#		  # rt: interpolated radius r
#	    	$rt = file.gets.split(' ').collect{|r| r.to_f}
#		  # logrk: interpolated logrk 
#		file = File.open($logrk_file_path3 + srep_index.to_s, 'r')
#		$logrkm1 = file.gets.split(' ').collect{|logrkm1| logrkm1.to_f}
#		$indices = srep.base_index
 #     	        puts "read all data needed >"   
  #      end
   #     # initially it is zero 
   #     base_index = $current_base_index

    #    distance_to_next_base = ( $indices[base_index+1] - $indices[base_index] ) - $step_go_so_far 
     #   puts "dis to next base: " + distance_to_next_base.to_s
    #    curr_index = $indices[base_index] + $step_go_so_far  + 1 
     #   if distance_to_next_base == 0 # <= reached another base point
      #          puts "############################################################"
	#	puts "############################################################"
	#	puts "                         at base end!                       "
	#	puts "############################################################"
	#	puts "############################################################"
	#	$step_go_so_far  = 0
#		# update current_base_index
#		$current_base_index = $current_base_index + 1    
#		$ui1 = srep.atoms[$current_base_index].spoke_direction[0]
#		$ui2 = srep.atoms[$current_base_index].spoke_direction[1]
#		distance_to_next_base = $indices[base_index+1] - $indices[base_index]
#		#  Why here is no checking for base index out of bound? 
 #               base_index = $current_base_index
#		spoke_index = $current_base_index
#	end
          
 #       # -->>>>>> after here we have the curr_index
         
  #      # initialization
#	if curr_index == 1
 #               $ui1 = srep.atoms[0].spoke_direction[0]
  #              $ui2 = srep.atoms[0].spoke_direction[1]
   #    		distance_to_next_base = $indices[base_index+1] - $indices[base_index]

    #            base_index = $current_base_index
	#	spoke_index = $current_base_index
  #      end
        # avoid index out of bound when computing v
   #     if curr_index != base_index[-1]
              # calculate v1 
    #           v1t = [$xt[curr_index+1] - $xt[curr_index], $yt[curr_index+1] - $yt[curr_index]]
#	end
            # normalize the size of v vector
 #       size_v1t = Math.sqrt(v1t[0]**2 + v1t[1]**2)
  #      d1t = size_v1t
   #     norm_v1t = v1t.collect{|v| v / size_v1t} 
     
    #    k1t = ( 1 + ( -1 * Math.exp($logrkm1[curr_index] ) ) ) / $rt[curr_index] 
            
        # call a method to interpolate 
#        puts "u1before update" + $ui1.to_s
 #       $ui1 = interpolateSpokeAtPos2($ui1, norm_v1t, -1 * k1t, d1t)
  #      puts "u1after update" + $ui1.to_s
#        puts "u2before update" + $ui2.to_s
 #       $ui2 = interpolateSpokeAtPos2($ui2, norm_v1t, k1t, d1t)
  #      puts "u2after update" + $ui2.to_s
   #   #        puts "ui: " + ui.to_s
    #    srep.interpolated_spokes_begin << [$xt[curr_index],$yt[curr_index],-1]    
     # #        puts "rt: " + rt[curr_index-1].to_s
      #  srep.interpolated_spokes_end  <<  [$xt[curr_index]+$ui1[0]*$rt[curr_index],$yt[curr_index]-$ui1[1]*$rt[curr_index],-1,[],'regular']
 ## srep.interpolated_spokes_end  <<  [$xt[curr_index]+$ui1[0],$yt[curr_index]-$ui1[1],-1,[],'regular']
  #      spoke_index = $indices[base_index]+$step_go_so_far+1
   #     spoke_begin_x = $xt[spoke_index]
    #    spoke_begin_y = $yt[spoke_index]
     #   $sreps[srep_index].interpolated_spokes_begin << [spoke_begin_x,spoke_begin_y,-1,[],'regular']    
     #   spoke_end_x = spoke_begin_x + $ui2[0]*$rt[spoke_index]
      #  spoke_end_y = spoke_begin_y - $ui2[1]*$rt[spoke_index]
       # $sreps[srep_index].interpolated_spokes_end  <<  [spoke_end_x,spoke_end_y,-1,[],'regular']
    #    #       puts "ddl" +  $sreps[srep_index].interpolated_spokes_end.to_s
     #   refresh @points, $sreps, @shifts
      #  $step_go_so_far = $step_go_so_far + 1              
      # }

 #            else
=begin

               # add spoke interpolation for end disks
               # get atom for end disks
               end_atom_one = srep.atoms[0]
               end_atom_two = srep.atoms[-1]
               end_atoms = [end_atom_one, end_atom_two]
               # get upper and lower and middle spokes
               end_atoms.each_with_index do |atom, i|
                 atom_spoke_dir_plus1 = atom.spoke_direction[0]
                 atom_spoke_dir_minus1 = atom.spoke_direction[1]
                 atom_spoke_dir_zero = atom.spoke_direction[2]
                 x_diff_1 = atom_spoke_dir_zero[0] - atom_spoke_dir_plus1[0]
                 x_diff_2 = atom_spoke_dir_zero[0] - atom_spoke_dir_minus1[0]

                 y_diff_1 = atom_spoke_dir_zero[1] - atom_spoke_dir_plus1[1]
                 y_diff_2 = atom_spoke_dir_zero[1] - atom_spoke_dir_minus1[1]
                 x_step_size_1 = x_diff_1.to_f / 15
                 y_step_size_1 = y_diff_1.to_f / 15
                 x_step_size_2 = x_diff_2.to_f / 15
                 y_step_size_2 = y_diff_2.to_f / 15
                 previous_x = atom_spoke_dir_plus1[0] 
                 previous_y = atom_spoke_dir_plus1[1] 
                 $end_disk_spoke_number.times do 
                   new_spoke_dir_x = previous_x + x_step_size_1
                   new_spoke_dir_y = previous_y + y_step_size_1
                   # normalize 
                   length_new_spoke = Math.sqrt(new_spoke_dir_x**2 + new_spoke_dir_y**2)
                   new_spoke_dir_x = new_spoke_dir_x / length_new_spoke
                   new_spoke_dir_y = new_spoke_dir_y / length_new_spoke
                   previous_x = new_spoke_dir_x
                   previous_y = new_spoke_dir_y
                   # calculate interpolated spoke end
                   new_spoke_vector_x = atom.spoke_length[0]*new_spoke_dir_x
                   new_spoke_vector_y = atom.spoke_length[0]*new_spoke_dir_y
                   new_spoke_end = [atom.x + new_spoke_vector_x, atom.y - new_spoke_vector_y,-1,[],'end']
                   $sreps[srep_index].interpolated_spokes_begin << [atom.x, atom.y]
                   $sreps[srep_index].interpolated_spokes_end << new_spoke_end
                 end
                
                 # another end  
                 previous_x = atom_spoke_dir_minus1[0]
                 previous_y = atom_spoke_dir_minus1[1]
                 $end_disk_spoke_number.times do 
                   new_spoke_dir_x = previous_x + x_step_size_2
                   new_spoke_dir_y = previous_y + y_step_size_2
                   # normalize 
                   length_new_spoke = Math.sqrt(new_spoke_dir_x**2 + new_spoke_dir_y**2)
                   new_spoke_dir_x = new_spoke_dir_x / length_new_spoke
                   new_spoke_dir_y = new_spoke_dir_y / length_new_spoke
                   previous_x = new_spoke_dir_x
                   previous_y = new_spoke_dir_y
                   # calculate interpolated spoke end
                   new_spoke_vector_x = atom.spoke_length[0]*new_spoke_dir_x
                   new_spoke_vector_y = atom.spoke_length[0]*new_spoke_dir_y
                   new_spoke_end = [atom.x + new_spoke_vector_x, atom.y - new_spoke_vector_y,-1,[],'end']
                   $sreps[srep_index].interpolated_spokes_begin << [atom.x, atom.y]
                   $sreps[srep_index].interpolated_spokes_end << new_spoke_end

#         ---------------------------- all finished 
                   $sreps[srep_index].interpolate_finished = true

      #          @points, $sreps, @shifts
       #          end
            # this is the end of a loop for one pair of spokes    

     #          refresh @points, $sreps, @shifts      
   #            end 
   
     #          $info = "interpolation finished"
  #        end
=end
       

     end
     # code for the check list 
     @list = ['Medial Curve', 'Interpolated Spokes', 'Extended Spokes', 'Extended Disks', 'Linking Structure']
     stack do
       @list.map! do |name|
         flow { @c = check; para name }
         [@c, name]
       end
       if $sreps[0].show_curve 
         @list[0][0].checked = true
       end
       if $sreps[0].show_interpolated_spokes
         @list[1][0].checked = true
       end
       if $sreps[0].show_extend_spokes 
         @list[2][0].checked = true
       end
       if $sreps[0].show_extend_disk 
         @list[3][0].checked = true
       end
       if $show_linking_structure
         @list[4][0].checked = true
       end
       button "Refresh" do
         $sreps.each do |srep| 
           srep.show_curve = @list[0][0].checked?
           srep.show_interpolated_spokes = @list[1][0].checked?
           srep.show_extend_spokes = @list[2][0].checked?
           srep.show_extend_disk = @list[3][0].checked?
         end
         $show_linking_structure = @list[4][0].checked?
         if @list[4][0].checked?
           $sreps.each do |srep|
             srep.extend_interpolated_spokes_end.each_with_index do |spoke_end, i|
                if spoke_end[2] != -1 
                   $linkingPts << [spoke_end[0], spoke_end[1]]  
                end
             end
           end
         end
         refresh @points, $sreps, @shifts
         if @list[4][0].checked?
       #    linkLinkingStructurePoints($sreps, self, 300) 
         end         
       end
     end

     stack do @status = para :stroke => black end
     @field.paint
     para "dilate count: " + $dilateCount.to_s
  
   end  
 end
  
# refresh the UI
 def refresh points, sreps, shifts
   self.nofill
   @field = Field.new self, points, sreps, shifts
   render_field
 end
  


# initialization
def initialConfig
  $step_go_so_far = 0
  @shifts = [300,300,300]
  $current_base_index = 0	
  $info = ""
  $dilateCount = 0
  $linkingPts = []
  $show_linking_structure = false
  $flip = 0

  # read srep data from xml
  
  doc  = readSrepData($mosrepindex)
  points0 = returnAtomsListFromXML(doc,0)
  l0 = returnSpokeLengthListFromXML(doc,0)
  u0 = returnSpokeDirListFromXML(doc,0)
 
 # points0 = [[110,100],[160,5],[210,50],[260,60],[310,80]]
 # l0 = [[35,35,35],[40,40],[30,30],[40,40],[35,35,35]]
 # u0 = [[[-1,3],[-0.1,-4],[-9,1]],[[-1,4],[1.1,-3]],[[-1,4],[0.2,-6]],[[1,9],[0.05,-8]],[[1,2],[1,-5],[6,1]]]

# TODO: add code here to read the noise file and add that information into srep data
#       readNoiseFromNoiseFile() is in io_toolbox. 
#       getNoiseForOneSrep() is in srep_toolbox. <- OK
#       generate2DDiscreteSrep() is modified to add noise. <- OK

  noise_data = readNoiseFromNoiseFile($noise_file_name)
  srep0_noise_data = getNoiseForOneSrep(noise_data,0)
  srep0 = generate2DDiscreteSrep(points0,l0,u0,0.01,0,srep0_noise_data)
  srep0.orientation = [0,1]
  $sreps = [srep0]
  
  points1 = returnAtomsListFromXML(doc,1)
  l1 = returnSpokeLengthListFromXML(doc,1)
#  alert l1
  u1 = returnSpokeDirListFromXML(doc,1)
  #points1 = [[200,190],[250,190],[300,200],[350,180],[400,160]]
  #l1 = [[35,35,35],[40,40],[45,45],[40,40],[35,35,35]]
  #u1 = [[[-1,6],[0.5,-3],[-9,1]],[[-1,4],[-1,-3]],[[-1,4],[-0.1,-6]],[[1,9],[1,-1.5]],[[1,2],[2,-5],[6,1]]]
  srep1_noise_data = getNoiseForOneSrep(noise_data,1)
  srep1 = generate2DDiscreteSrep(points1,l1,u1,0.01,1,srep1_noise_data)
  srep1.color = Color.green
  srep1.orientation = [0,1]
  $sreps << srep1

  points2 = returnAtomsListFromXML(doc,2)
  l2 = returnSpokeLengthListFromXML(doc,2)
  u2 = returnSpokeDirListFromXML(doc,2)
  #points2 = [[30,50],[10,100],[9,150],[20,200],[50,240],[110,290]]
  #l2 = [[35,35,35],[35,35],[40,40],[35,35],[40,40],[40,40,40]]
  #u2 = [[[6,1],[6,-0.5],[-9,1]],[[-1,4],[3,-0.5]],[[-1,4],[5,-0.5]],[[1,9],[5,1]],[[1,9],[5,3]],[[1,2],[3,5],[6,1]]]
  srep2_noise_data = getNoiseForOneSrep(noise_data,2)
  srep2 = generate2DDiscreteSrep(points2,l2,u2,0.01,2,srep2_noise_data)
  srep2.color = Color.purple
  srep2.orientation = [0,1]
  $sreps << srep2

  refresh @points, $sreps, @shifts
end
  
initialConfig

end


