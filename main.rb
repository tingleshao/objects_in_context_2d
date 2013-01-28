# file: main.rb
# This is the main program of the 2D objects in context protypeing system.
# It contains a class Field that abstracts the canvas of the main window that displays the s-reps. 
# It contains a class InterpolationControl that abstracts a subwindow for user 
#  to select which s-rep's spokes to interpolate. 
# The last part: Shoes.app runs the program.
#
# Author: Chong Shao (cshao@cs.unc.edu)
# ----------------------------------------------------------------


load 'lib/srep_toolbox.rb'
load 'lib/color.rb'
load 'view/interpolate_control.rb'
load 'view/srep_info.rb'
load 'view/file_loader_view.rb'

# change the path will effect all these things 
$points_file_path = "data/interpolated_points_"
$radius_file_path = "data/interpolated_rs_"
$logrk_file_path = 'data/interpolated_logrkm1s_'
$dilate_ratio = 1.05
$a_big_number = 100
$end_disk_spoke_number = 20

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
    spoke_end_x_up2 = cx + spoke_length[1] * u_m1[0]
    spoke_end_y_up2 = cy - spoke_length[1] * u_m1[1]
    @app.line(cx, cy, spoke_end_x_up2, spoke_end_y_up2)
    if type == 'end'
    u_0 = spoke_direction[2]
    spoke_end_x_u0 = cx + spoke_length[2] * u_0[0]
    spoke_end_y_u0 = cy - spoke_length[2] * u_0[1]
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
      render_interp_spokes(shiftx, shifty, Color.white, spoke_begin, spoke_end)
    end

    if (srep.getExtendInterpolatedSpokesEnd()).length > 0 and srep.show_extend_spokes
      spoke_begin = srep.interpolated_spokes_end  
      spoke_end = srep.getExtendInterpolatedSpokesEnd()
      render_extend_interp_spokes(shiftx, shifty, Color.red, spoke_begin, spoke_end)
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
  def render_interp_spokes(shiftx, shifty, color, ibegin, iend)
    @app.stroke color
    ibegin.each_with_index do |p, i|
       @app.line(p[0]+shiftx, p[1]+shifty, iend[i][0]+shiftx, iend[i][1]+shifty)
    end
  end
   
  # method for rendering extended part of spokes
  def render_extend_interp_spokes(shiftx, shifty, color, ibegin, iend)
    @app.stroke color
    iend.each_with_index do |p, i|
      @app.line(ibegin[i][0]+shiftx, ibegin[i][1]+shifty, p[0]+shiftx, p[1]+shifty)
    end
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
      background rgb(50, 50, 90, 0.7)
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
#
#

         $sreps.each_with_index do |srep, srep_index| 
                  file1 = File.open($points_file_path + srep_index.to_s, 'r')
         #  puts "file: " +  file1.to_s
          test = "here!!!!!!!!!!!!!!!1"
                xt = file1.gets.split(' ').collect{|x| x.to_f}
	           yt = file1.gets.split(' ').collect{|y| y.to_f}
             file2 = File.open($radius_file_path + srep_index.to_s, 'r')
           	       rt = file2.gets.split(' ').collect{|r| r.to_f}
             file3 = File.open($logrk_file_path + srep_index.to_s, 'r')
             logrkm1 = file3.gets.split(' ').collect{|logrkm1| logrkm1.to_f}

           $a_big_number.times do
   puts test 
           puts "file: " +  file1.to_s

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
          
             curr_index = indices[base_index] + $step_go_so_far  + 1 
            # this is wrong... .
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
  #
############################
########################
##########################
      #       file3 = File.open($logrk_file_path + srep_index.to_s, 'r')
       #      logrkm1 = file3.gets.split(' ').collect{|logrkm1| logrkm1.to_f}
#################
###################
#################
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
               k1t = ( 1 + ( -1 * Math.exp(logrkm1[indices[base_index]]   ) ) ) / rt[indices[base_index]] 
               k2t = ( 1 + ( -1 * Math.exp(logrkm1[indices[base_index+1]] ) ) ) / rt[indices[base_index+1]] 
            
               u1t = srep.atoms[base_index].spoke_direction[0]
               u2t = srep.atoms[base_index+1].spoke_direction[0]
               ui = interpolateSpokeAtPos(u1t, norm_v1t, k1t, d1t, u2t, norm_v2t, k2t, d2t)
      #        puts "ui: " + ui.to_s
               srep.interpolated_spokes_begin << [xt[curr_index],yt[curr_index],-1]    
      #        puts "rt: " + rt[curr_index-1].to_s
               srep.interpolated_spokes_end  <<  [xt[curr_index]+ui[0]*rt[curr_index],yt[curr_index]-ui[1]*rt[curr_index],-1,[],'regular']
               # interpolate another side
               u1t = $sreps[srep_index].atoms[base_index].spoke_direction[1]
               u2t = $sreps[srep_index].atoms[base_index+1].spoke_direction[1]
               ui = interpolateSpokeAtPos(u1t, norm_v1t, k1t, d1t, u2t, norm_v2t, k2t, d2t)
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
      button("Interpolate Spokes 2") {
     # make this correct!! 

     # the k is the change of the swings .
    # ... which can be approximated by the change of the swings of 3 base points .....
   # 
#
# global variables: :(
#  $step_go_so_far = 0
#  @shifts = [300,300,300]
#  $current_base_index = 0	
#  $info = ""
#  $dilateCount = 0
#  $linkingPts = []
#  $show_linking_structure = false

#### #########
# do it for each srep
         $sreps.each_with_index do |srep, srep_index| 
   # do many times .... ( a big number may refer to the number of spokes between each two base points? ) 
           $a_big_number.times do
             # interpolate one side
    #  retrieve the list for base indices 
   # it tells which index is base index in the long list... ( well)  
             indices = srep.base_index
            # initially it is zero 
             base_index = $current_base_index

             distance_to_next_base = ( indices[base_index+1] - indices[base_index] ) - $step_go_so_far 
           
             # no it is needed.
             if distance_to_next_base == 0 # <= reached another base point
               $step_go_so_far  = 0
           # update current_base_index
               $current_base_index = $current_base_index +1    
               distance_to_next_base = indices[base_index+1] - indices[base_index]
          # Why here is no checking for base index out of bound? 
               spoke_index = $current_base_index
             end
          
          #after here we have the curr_index
             curr_index = indices[base_index] + $step_go_so_far  + 1 

            # this should be modified in next version 
             d1t = 0.01 * $step_go_so_far 
             d2t = distance_to_next_base * 0.01 

             # calculate parameters
             # every iteration it reads a file so it is slow....
             # read all points, rs, logrkm1s from the file
             file = File.open($points_file_path + srep_index.to_s, 'r')

            # xt/ yt: interpolatd x and y locus
             xt = file.gets.split(' ').collect{|x| x.to_f}
	           yt = file.gets.split(' ').collect{|y| y.to_f}
             file = File.open($radius_file_path + srep_index.to_s, 'r')
          # rt: interpolated radius r
    	       rt = file.gets.split(' ').collect{|r| r.to_f}
          # logrk: interpolated logrk <= needs to be fixed.
  #
############################
########################
##########################
             file = File.open($logrk_file_path + srep_index.to_s, 'r')
             logrkm1 = file.gets.split(' ').collect{|logrkm1| logrkm1.to_f}
#################
###################
#################
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
               k1t = ( 1 + ( -1 * Math.exp(logrkm1[indices[base_index]]   ) ) ) / rt[indices[base_index]] 
               k2t = ( 1 + ( -1 * Math.exp(logrkm1[indices[base_index+1]] ) ) ) / rt[indices[base_index+1]] 
            
               u1t = srep.atoms[base_index].spoke_direction[0]
               u2t = srep.atoms[base_index+1].spoke_direction[0]
               ui = interpolateSpokeAtPos(u1t, norm_v1t, k1t, d1t, u2t, norm_v2t, k2t, d2t)
      #        puts "ui: " + ui.to_s
               srep.interpolated_spokes_begin << [xt[curr_index],yt[curr_index],-1]    
      #        puts "rt: " + rt[curr_index-1].to_s
               srep.interpolated_spokes_end  <<  [xt[curr_index]+ui[0]*rt[curr_index],yt[curr_index]-ui[1]*rt[curr_index],-1,[],'regular']
               # interpolate another side
               u1t = $sreps[srep_index].atoms[base_index].spoke_direction[1]
               u2t = $sreps[srep_index].atoms[base_index+1].spoke_direction[1]
               ui = interpolateSpokeAtPos(u1t, norm_v1t, k1t, d1t, u2t, norm_v2t, k2t, d2t)
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
     para $info
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

  points0 = [[110,100],[160,75],[210,50],[260,60],[310,80]]
  l0 = [[35,35,35],[40,40],[50,50],[40,40],[35,35,35]]
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
end
  
initialConfig
end


