# srep.rb
# This is a class that models an s-rep.
#
# Author: Chong Shao (cshao@.cs.unc.edu)
# ----------------------------------------------------------------

# spoke directions:
#   0: upper spokes
#   1: lower spokes
class SRep 
  attr_accessor :interpolate_finished, :index, :atoms, :skeletal_curve, :interpolated_spokes_begin, 
     :interpolated_spokes_end, :extend_interpolated_spokes_end, :show_curve, :show_interpolated_spokes, 
     :show_extend_disk, :show_extend_spokes, :step_size, :color, :offset, :base_index, :mask_func, :orientation
	
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
    puts "null srep initialized"
  end

  def to_s
    "i am an s-rep! \n"
    "Here are my atoms: \n"
    @atoms.each do |at|
       puts at
    end
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
      if isb[2] == -1
        spoke_begin = @interpolated_spokes_begin[ind]
        spoke_v = [ isb[0] - spoke_begin[0], isb[1] - spoke_begin[1]]
        extend_v = spoke_v.collect{|e| e * ratio }
        extend_v_end = [spoke_begin[0] + extend_v[0], spoke_begin[1] + extend_v[1], isb[2], isb[3] ,isb[4]]

        @extend_interpolated_spokes_end[ind] = extend_v_end
        # check intersection with others 
        if checkIntersection 
          
          sreps.each_with_index do |srep, srep_ind|   
            srep.extend_interpolated_spokes_end.each_with_index do |spoke_end, spoke_end_index|
              if ( ( srep.index != @index ) || ( (ind-spoke_end_index).abs > 1 ) && srep.index == @index )
                check_result = checkSpokeIntersection(@interpolated_spokes_end[ind][0], @interpolated_spokes_end[ind][1], extend_v_end[0], extend_v_end[1], srep.interpolated_spokes_end[spoke_end_index][0], srep.interpolated_spokes_end[spoke_end_index][1], spoke_end[0], spoke_end[1])
                if check_result[0] 
		  @extend_interpolated_spokes_end[ind] = isb
                  @extend_interpolated_spokes_end[ind][2] = srep.index
                  @extend_interpolated_spokes_end[ind][3] = srep.extend_interpolated_spokes_end[spoke_end_index]
                  intersection_points << [check_result[1], check_result[2]]
                  if spoke_end[2] == -1
                    spoke_end[2] = @index
                    spoke_end[3] = @extend_interpolated_spokes_end[ind]
                  end
                # prevent some spokes that from escaping the intersections  
                elsif srep.index != @index and checkSpokeEndAndDiskIntersection(@extend_interpolated_spokes_end[ind][0], @extend_interpolated_spokes_end[ind][1], srep)
                  @extend_interpolated_spokes_end[ind] = isb
                  @extend_interpolated_spokes_end[ind][2] = srep.index
                end
              end
            end
          end
        end
      end
    end
    return intersection_points
  end


end
