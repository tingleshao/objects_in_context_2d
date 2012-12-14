load 'srep_toolbox.rb'
load 'atom.rb'
load 'srep.rb'
def ddl
srep1= generateStraight2DDiscreteSrep(20,15,64,64,128,3);
#~ srep2 = generate2DDiscreteSrep(20,15,32,32,128);
#~ $corrLes = checkSrepIntersection(srep1, srep2, 0,0);
return srep1
end

def ddl2
  srep1 = generateStraight2DDiscreteSrepC();
  return srep1
end

def ddl3
  points = [[10,20],[20,15],[30,10],[40,12],[50,16]]
  l = [[7,7,7],[7,7],[7,7],[8,8],[7,7,7]]
  u = [[[-1,3],[-1,-4],[-3,-1]],[[-1,4],[-1,-5]],[[-1,4],[-1,-6]],[[1,9],[1,-8]],[[1,2],[1,-5],[3,2]]]
  srep = generate2DDiscreteSrep(points,l,u)
  puts 'ddl'
  puts srep
end

def ddl4
  points = [[50,100],[100,75],[150,50],[200,60],[250,80]]
  x = points.collect{|p| p[0]}

  y = points.collect{|p| p[1]}
#  puts "y: " + y.to_s
  interpolateSkeletalCurveGamma(x,y,0.01)
end	

def ddl5
  # test compute kappa at base points 
  f = File.new('interpolated_points_0', 'r')
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
  h = 0.01
  while l = f.gets
    puts "l: " + l
  end
  
  f.close
  ff = File.new('interpolated_rs_0', 'r')
  ff.gets
  rs = ff.gets.strip.split(' ')
  puts "rs: " + rs.to_s
  rt = []
  rs.each do |r|
    rt << r.to_f
  end

  indices = []
  points = [[50,100],[100,75],[150,50],[200,60],[250,80]]
  indices << 0
  points.each_with_index do |p, i|
    if i != 0 && i != points.length-1
      v = xt.collect{|x| (x-p[0]).abs }.each_with_index.min
      indices << v[1]
    end
  end
  indices << xt.length-1

  kappa,kt = computeBaseKappa(xt,yt, indices, h, rt)
  return kappa,kt,rt
end
 
def ddl6
# test what the file exactl gets
foo = File.open('interpolated_points_0', 'r')
x = foo.gets
y = foo.gets
foo = File.open('interpolated_rs_0', 'r')
r = foo.gets.split(' ').collect{|bar| bar.to_f}
foo = File.open('interpolated_logrkm1s_0', 'r')
logrkm1 = foo.gets.split(" ").collect{|bar| bar.to_f 	}
puts 'x: ' + x
puts 'y: ' + y
puts 'r: ' + r.length.to_s
puts 'logrkm1: ' + logrkm1.length.to_s

end

#k,kt =  ddl5
#puts kt
ddl6
