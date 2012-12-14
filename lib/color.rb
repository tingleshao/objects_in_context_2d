class Color
  
  @@black = '#000000'
  @@white = '#FFFFFF'
  @@blue = '#00FFFF'   
  @@red = '#FF0000'
  @@green = "#00FF66" 
  @@purple = "#CC66FF"
 
  def initialize()
  end
 
  def self.black
    @@black
  end
  
  def self.white
    @@white
  end 
  
  def self.blue
    @@blue
  end
 
  def self.red
    @@red
  end

  def self.green
    @@green
  end

  def self.purple
    @@purple
  end

  def self.default
    @@black
  end
end
