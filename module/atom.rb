# atom.rb
# This is a class that model the atom in an s-rep.
# 
# Author: Chong Shao (cshao@cs.unc.edu)
# ----------------------------------------------------------------


class Atom
# this is the Atom class. It represents a discrete atom in the m-rep

# instance variables 
  attr_accessor :spoke_length, :expand_spoke_length, :spoke_direction, :type, :x, :y, :color, :linking_index
	
  # initializer
  def initialize(spoke_length, spoke_direction, type, x, y, cc)
    @spoke_length = spoke_length
    @expand_spoke_length = spoke_length.dup
    @spoke_direction = spoke_direction
    @type = type
    @x = x
    @y = y
    @color = cc
    @linking_index = -1
  end
	
  # atom to_string method
  def to_s 
    "i am an atom! \n my type: " + @type + "\n my position: x: " + @x.to_s + " y: " + @y.to_s + "\n my spokes length: " + @spoke_length.to_s + "\n my spoke direction: " + @spoke_direction.to_s + "\n my correspoinding color: " + @color.to_s
  end
 
  # atom can dilate its spokes
  def dilate(ratio)
    if @linking_index == -1
      @expand_spoke_length[0] = @expand_spoke_length[0] * ratio
      @expand_spoke_length[1] = @expand_spoke_length[1] * ratio
      if @type == 'end'
        @expand_spoke_length[2] = @expand_spoke_length[2] * ratio
      end
    end
  end

  # get how much it dilated 
  def getExpandRatio
    return @expand_spoke_length[0] / @spoke_length
  end

end
