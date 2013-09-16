# srep.rb
# This is a class that models an s-rep.
#
# Author: Chong Shao (cshao@.cs.unc.edu)
# ----------------------------------------------------------------

# spoke directions:
#   0: upper spokes
#   1: lower spokes
#load 'main.rb'
class SRep 
  attr_accessor :interpolate_finished, :index, :atoms, :skeletal_curve, :interpolated_spokes_begin, 
     :interpolated_spokes_end, :extend_interpolated_spokes_end, :show_curve, :show_interpolated_spokes, 
     :show_extend_disk, :show_extend_spokes, :step_size, :color, :offset, :base_index, :mask_func, :orientation, :mapping_info, :correspond_info
	
  def initialize(index, atoms, skeletal_curve, step_size, color, offset)
    @index = index
    @atoms = atoms
    @skeletal_curve = skeletal_curve
    @step_size = step_size
    @color = color
    @offset = offset
    @show_curve = true
    @show_interpolated_spokes = true
    @show_extend_disk = true
    @show_extend_spokes = true
   
    @interpolated_spokes_begin = []
    @interpolated_spokes_end = []
    @extend_interpolated_spokes_end = []
    @mask_func = []
    @mapping_info = []
    @correspond_info = []
    puts "srep fully initialized"
  end

  def initialize()
    @atoms = []
    @skeletal_curve = []
    @show_curve = true
    @show_interpolated_spokes = true
    @show_extend_disk = true
    @show_extend_spokes = true

    @interpolated_spokes_begin = []
    @interpolated_spokes_end = []
    @extend_interpolated_spokes_end = []
    @mask_func = [] 
    @mapping_info = []
    @correspond_info = [] 
    puts "null srep initialized"
  end

  def to_s
    "i am an s-rep! \n"
    "Here are my atoms: \n"
    @atoms.each do |at|
       puts at
    end
  end

  def get_linking_info
    file_name = $points_file_path + @index.to_s
    if File::exists?(file_name)
      gamma_file = File.open(file_name, "r")
    else
      alert('file does not exist, interpolate it now')
      xt = @atoms.collect{|atom| atom.x}
      yt = @atoms.collect{|atom| atom.y}
      step_size = 0.01
      interpolateSkeletalCurveGamma(xt,yt,step_size,srep.index)
      gamma_file = File.open(file_name, "r")
    end 
    xs = gamma_file.gets.split(" ").collect{|x| x.to_f}
    ys = gamma_file.gets.split(" ").collect{|y| y.to_f}
   
    return @interpolated_spokes_begin.to_s + "\n=======\n" +
           @interpolated_spoke_end.to_s + "\n=======\n" +
           @extend_interpolated_spokes_end.to_s + "\n=======\n" +  # this may not contain index information .. need to add it 
           @linking_atom_index.to_s
  end

  def getLength
    if @skeletal_curve == []
       return @atoms.size
    else 
       return @skeletal_curve.size
    end
  end

  def checkIntersection(other_srep)
  # this method checks the intersection between self and another srep, for the BASE points
  # based on this intersection, decide the curve's linking index
    @atoms.each_with_index do |atom, i| 
       if atom.linking_index == -1
          other_srep.atoms.each_with_index do |other_atom, j|
           actual_dist = Math.sqrt( (atom.x - other_atom.x)**2 + (atom.y - other_atom.y)**2 )
           if actual_dist < (atom.expand_spoke_length[0] + other_atom.expand_spoke_length[0]) #=> intersection
              atom.linking_index = other_srep.index
              atom.color = other_srep.color
              other_atom.linking_index = @index
              other_atom.color = @color
              atom.linking_atom_index = j
              other_atom.linking_atom_index = i
           end
         end
      end
    end
  end

  def getExtendInterpolatedSpokesEnd()
    if @extend_interpolated_spokes_end.length < @interpolated_spokes_end.length
      @extend_interpolated_spokes_end = @interpolated_spokes_end.dup
    end
    return @extend_interpolated_spokes_end
  end

  def extendInterpolatedSpokes(ratio, sreps, checkIntersection)
    intersection_points = []
    # if the @extend_interpolated_spokes_end is not synchronzied with
    #   @interpolated_spokes_end, it means that it is the first time extension 
    # so deep copy the array @interpolated_spokes_end into @extend_interpolated_spokes_end
    if @extend_interpolated_spokes_end.length != @interpolated_spokes_end.length
      @extend_interpolated_spokes_end = @interpolated_spokes_end.dup
    end

    @extend_interpolated_spokes_end.each_with_index do |isb, ind|
      # if mask_func[ind] == -1) <-- have not intersected to anyone
      #extend spoke
      # calculate direction
      if isb[2] == -1  #TODO optimize this by doing a pre-calculation
        spoke_begin = @interpolated_spokes_begin[ind]
        spoke_v = [ isb[0] - spoke_begin[0], isb[1] - spoke_begin[1]]
        extend_v = spoke_v.collect{|e| e * ratio }
        extend_v_end = [spoke_begin[0] + extend_v[0], spoke_begin[1] + extend_v[1], isb[2], isb[3] ,isb[4]]

        @extend_interpolated_spokes_end[ind] = extend_v_end
        # check intersection with others 
        if checkIntersection 
          # for this srep, check its spoke intersection with itself and other sreps 
          sreps.each_with_index do |srep, srep_ind|   
            srep.extend_interpolated_spokes_end.each_with_index do |spoke_end, spoke_end_index|  
              if ( ( srep.index != @index ) || ( (ind-spoke_end_index).abs > 1 ) && srep.index == @index )
                check_result = checkSpokeIntersection(@interpolated_spokes_end[ind][0], @interpolated_spokes_end[ind][1], extend_v_end[0], extend_v_end[1], srep.interpolated_spokes_end[spoke_end_index][0], srep.interpolated_spokes_end[spoke_end_index][1], spoke_end[0], spoke_end[1])
                if check_result[0] 
		  @extend_interpolated_spokes_end[ind] = isb # TODO: can I remove this line?
                  @extend_interpolated_spokes_end[ind][2] = srep.index
                  @extend_interpolated_spokes_end[ind][3] = spoke_end_index
                  intersection_points << [check_result[1], check_result[2]]
                  if spoke_end[2] == -1 # write the infomation into the corresponding other objects 
                    spoke_end[2] = @index
                    spoke_end[3] = ind
                  end
                # prevent some spokes from escaping the intersections  
                elsif srep.index != @index and checkSpokeEndAndDiskIntersection(@extend_interpolated_spokes_end[ind][0], @extend_interpolated_spokes_end[ind][1], srep)[0]
                  @extend_interpolated_spokes_end[ind] = isb
                  @extend_interpolated_spokes_end[ind][2] = srep.index
                  @extend_interpolated_spokes_end[ind][3] = checkSpokeEndAndDiskIntersection(@extend_interpolated_spokes_end[ind][0], @extend_interpolated_spokes_end[ind][1], srep)[1]
                  # TODO: modify this so that it can distinguish the upper and lower side, may just look at neighbors, or relate this to the spoke orientation
                end
              end
            end
          end
        end
      end
    end
    return intersection_points
  end

  def getMappingInfo()
    # mapping info is stored in [2] of extend_interpolated_spokes_end
    
    return @mapping_info
  end

  def getCorrespondInfo() 
    # corresponding info is stored in [3] of extend_interpolated_spokes_end
    
    return @correspond_info
  end

  # NEW!!
  def addNoise(noise_data) 
  # this function uses the noise_data array, add it into srep  
     atom_position_noise = noise_data[0]
     spoke_length_noise = noise_data[1]
     spoke_dir_noise = noise_data[2]
     # add noise for atom base position
     atom_position_noise.each_with_index do |one_atom_noise, i| 
        @atoms[i].x = @atoms[i].x + one_atom_noise[0]
        @atoms[i].y = @atoms[i].y + one_atom_noise[1]
     end 
  end

end
