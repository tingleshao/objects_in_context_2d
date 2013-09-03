# file: srep_toolbox.rb
# This file contains functions for generating discrete 2D sreps and 
#  functions for interpolating spokes from base atoms information.
#
# Author: Chong Shao (cshao@cs.unc.edu)
# ----------------------------------------------------------------


load 'module/srep.rb'
load 'module/atom.rb'
load 'lib/color.rb'
load 'view/srep_info.rb'
load 'lib/math_toolbox.rb'


$points_file_path2 = "data2/interpolated_points_"
$radius_file_path2 = "data2/interpolated_rs_"
$logrk_file_path2 = 'data2/interpolated_logrkm1s_'
$pi = Math::PI

def generate2DDiscreteSrep(atoms, spoke_length, spoke_direction, step_size, srep_index, noise_data)
  # This function returns an srep which has parameters specified in the arguments lists
  srep = SRep.new()

  # add noise 
  atom_position_noise = noise_data[0]
  spoke_length_noise = noise_data[1]
  spoke_dir_noise = noise_data[2]

  srep.index = srep_index	
  atoms.each_with_index do |atom, i|
    if i == 0 or i == atoms.length - 1
	type = 'end'
    else
	type = 'inner'
    end
    # normalize the u vector
    usi = spoke_direction[i]
    usi.each_with_index do |ui, index|
      usi[index] = [Float(ui[0]),Float(ui[1])]
    end
    usi.each_with_index do |ui, index|
      x = ui[0]
      y = ui[1]
      ui.each_with_index do |foo, index2|
        ui[index2] = foo / Math.sqrt(x**2+y**2)
      end
    end 
   
    # add noise to usi
    curr_spoke_dir_noise = spoke_dir_noise[i]
    new_x = 1.0
    curr_degree = Math.atan(usi[0][1] / usi[0][0])
    degree_with_noise = curr_degree + curr_spoke_dir_noise
    new_tan = Math.tan(degree_with_noise)
    new_y = new_x * new_tan
    # normalize again
    len = Math.sqrt(new_x**2 + new_y **2)
    usi[0][0] = new_x / len
    usi[0][1] = new_y / len

    # make sure the spoke length vector is in type Float
    li = spoke_length[i]
     
    # add noise to li
    li.each_with_index do |l, index|
      li[index] = li[index] + spoke_length_noise[i]
    end

    li.each_with_index do |l, index|
      li[index] = Float(l)
    end

         # make sure the positions x-y is in type Float
    atom.each_with_index do |foo, index|
	atom[index] = Float(foo)
    end
    atom_obj = Atom.new(li, usi, type, atom[0], atom[1], Color.red)
    srep.atoms.push(atom_obj)
  end

  # add noise for atom base position
  alert(atom_position_noise)
  atom_position_noise.each_with_index do |one_atom_noise, i| 
  #   alert(one_atom_noise)
     srep.atoms[i].x = srep.atoms[i].x + one_atom_noise[0]
     srep.atoms[i].y = srep.atoms[i].y + one_atom_noise[1]
  end 

  srep.color = Color.default

  # compute the interpolated curve 
  xt = srep.atoms.collect{|atom| atom.x }
  yt = srep.atoms.collect{|atom| atom.y }
  puts "srep: index in toolbox: " + srep_index.to_s
  curve = interpolateSkeletalCurveGamma(xt, yt, step_size, srep_index)
  srep.skeletal_curve = curve

  # compute indices 
  indices = []
  indices << 0
  atoms.each_with_index do |atom, i|
    if i != 0 && i != atoms.length-1
      diff = curve[0].collect{|x| (x-atom[0]).abs }
      v = diff.index(diff.min)
      indices << v
    end
  end
  indices << curve[0].length-1
  srep.base_index = indices   
  puts "indices: "+  indices.to_s

  # use the curve and upper spokes to get the value of lower spokes and end spokes 
  # calculate v at base points
  v= []
  v << [ -1*(curve[0][indices[0]+1]-curve[0][indices[0]]), 1*(curve[1][indices[0]+1]-curve[1][indices[0]])]

  indices.each_with_index do |ind, i |
    if i < indices.length - 1 && i != 0
      v << [curve[0][ind+1]-curve[0][ind], -1*(curve[1][ind+1]-curve[1][ind])]
    end
  end
  
  v << [ curve[0][indices[-1]] - curve[0][indices[-1]-1], -1* (curve[1][indices[-1]]- curve[1][indices[-1]-1]) ] 
  puts "v: "+ v.to_s
  refine = true
  if refine
  # make sure the upper and lower spokes have the same angle
  # get the upper spokes directions 
    srep.atoms.each_with_index do |atom, i| 
      u1 = atom.spoke_direction[0]  
      puts "u1: " + u1.to_s
      size_norm_v=  Math.sqrt(v[i][0] **2 + v[i][1] **2)
      norm_v = [v[i][0] / size_norm_v ,  v[i][1] / size_norm_v ]
      u1_proj_on_v = norm_v.collect{|e| e* (u1[0] * norm_v[0] + u1[1] * norm_v[1])} 
      size_proj = Math.sqrt(u1_proj_on_v[0] **2 + u1_proj_on_v[1] **2 )
      norm_proj = [u1_proj_on_v[0] / size_proj, u1_proj_on_v[1] / size_proj]
      u1_prep_to_v = [u1[0] - u1_proj_on_v[0], u1[1] - u1_proj_on_v[1]]
      u0 = [1 * u1_proj_on_v[0] - u1_prep_to_v[0], 1  *  u1_proj_on_v[1] - u1_prep_to_v[1]]
      # normalize u0
      u0_size = Math.sqrt(u0[0] ** 2 + u0[1] **2)  
      u0[0] = u0[0] / u0_size
      u0[1] = u0[1] / u0_size
      #check whether perpendicular
      diff = [u0[0]-u1[0],u0[1]-u1[1]]
      prod = diff[0] * norm_v[0] + diff[1]*norm_v[1]
      puts "prod: "+ prod.to_s
      atom.spoke_direction[1] = u0
    end

    # for the end spokes, set their direction to the v 
    a0u2 = [v[0][0], v[0][1]]
    a0u2_size = Math.sqrt(a0u2[0] ** 2 + a0u2[1] **2)
    a0u2[0] = a0u2[0] / a0u2_size
    a0u2[1] = a0u2[1] / a0u2_size
    srep.atoms[0].spoke_direction[2] = a0u2

    aendu2 = [v[-1][0], v[-1][1]]
    aendu2_size = Math.sqrt(aendu2[0] ** 2 + aendu2[1] **2)
    aendu2[0] = aendu2[0] / aendu2_size
    aendu2[1] = aendu2[1] / aendu2_size
    srep.atoms[-1].spoke_direction[2] = aendu2
  end
  return srep
end

def checkSrepIntersection(srep1, srep2, shift1, shift2)
  # this function checks the intersection between s-reps before spoke interpolation
  # returns a list indicates that for each atom in srep1, what is the correspoinding neighbor srep color 
  correLst = []
  srep1.atoms.each_with_index do |atom1, j|
    correLst << [0, nil]
    atom1posX = atom1.x + shift1
    atom1posY = atom1.y + shift1
    srep2_0PosX = srep2.atoms[0].x + shift2
    srep2_0PosY = srep2.atoms[0].y + shift2
    minDistSoFar = getDistance(atom1posX, atom1posY, srep2_0PosX, srep2_0PosY)
    distToSrep2_0 = atom1.spoke_length[0] + srep2.atoms[0].spoke_length[0]
    if minDistSoFar < distToSrep2_0
      correLst[j] = [1,0]
    end
    srep2.atoms.each_with_index do |atom2, i|
      atom2posX = atom2.x + shift2
      atom2posY = atom2.y + shift2
      # asssume all three r's for one atom are equivalent to each other (partial blum?  case)
      r1PlusR2 = atom1.spoke_length[0] + atom2.spoke_length[0]
      dist =  getDistance(atom1posX, atom1posY, atom2posX, atom2posY) 
      if dist < r1PlusR2 
	if dist < minDistSoFar
	  correLst[j] = [1, i]
	  minDistSoFar = dist
	end
      end
    end
  end
  return correLst
end

def interpolateSkeletalCurveGamma(xt,yt,step_size,index)
# this function takes the discrete base points and interpolate the gamma (skeletal curves)
#   - interpolate gamma can be done using cubic spline 
#   - this function uses system call on a python routine
  # give x, y, stepsize, retrun a interpolated dense points and write it into a file.
  # read that file. 
  # then we have the gamma values. That is for one srep.
  # call the python script to generate intepolated gammas
  xs = '"[' + xt.join(" ") + ']"'
  ys = '"[' + yt.join(" ") + ']"'
  step_size_s = step_size.to_s
  index = index.to_s
  system("python python/curve_interpolate.py " + xs + ' ' + ys + ' ' + step_size_s + ' ' + index.to_s + ' ' + $mosrepindex.to_s)
  # the 'interpolated_points_[index]' file contains interpolated points
  # the interpolated file is stored by the python program.

  curve_file = File.new($points_file_path + index, "r")
  ixs = curve_file.gets.strip.split(' ').collect{|x| x.to_f}
  iys = curve_file.gets.strip.split(' ').collect{|x| x.to_f}
  return ixs, iys
end

def interpolateRadius(xt,yt,rt,step_size,index)
# this function interpolates r values
# parameters: x values         xt
#             y values         yt
#             r values         rt 
#             step size        step_size
  xyt = ["0"]
  xt.each_with_index do |x, i|
    if i !=0 
      xy = xyt[i-1].to_f + Math.sqrt( (xt[i] - xt[i-1]) ** 2 + (yt[i] - yt[i-1]) ** 2 )
      xyt << xy.to_s
    end
  end
  xs = '"[' + xyt.join(" ") + ']"'
  rs = '"[' + rt.join(" ") + ']"'
  step_size_s = step_size.to_s
  system("python python/radius_interpolate.py " + xs + ' ' + rs + ' ' + step_size_s + ' ' + index +' ' + $mosrepindex.to_s )
  # the 'interpolated_radius_[index]' file contains interpolated points
  r_file = File.new($radius_file_path+index, "r")
  irs = r_file.gets
  puts "irs: " + irs  
  return irs
end

def interpolateKappa(rt, kt, step_size, index)
# since rk < 1, we need get r to interpolate kappa
# rt is an array that contains radius 
# this function produces the k array that has the same length as the r array
  rk = [rt,kt].transpose.map{|x| x.reduce(:*)}
  puts "#################################################################"
  puts "rk: " + rk.to_s
  rkm1 = rk.collect{|x| 1-x}  
  puts " ###############################################################"
  puts "rkm1: " + rkm1.to_s
  logrkm1 = rkm1.collect{|x| Math.log(x)}
  logrkm1s = '"[' + logrkm1.join(" ") + ']"'
  step_size_s = step_size.to_s
  system("python python/logrk_interpolate.py " + logrkm1s + ' ' + step_size_s + ' ' + index.to_s + ' ' + $mosrepindex.to_s)
  # the 'interpolated_logrkm1s' file contains interpolated log(1-rk)
  logrkm1_file = File.new($logrk_file_path + index.to_s , "r")
  ilogrkm1s = logrkm1_file.gets
  puts "ilogrkm1s: " + ilogrkm1s
  return ilogrkm1s
end

def interpolateKappa2(rt,kt,step_size,index)
 # the boundary should be extrapolated
  rk = [rt,kt].transpose.map{|x| x.reduce(:*)}
  puts "#################################################################"
  puts "rk: " + rk.to_s
  rkm1 = rk.collect{|x| 1-x}  
  puts " ###############################################################"
  puts "rkm1: " + rkm1.to_s
  logrkm1 = rkm1.collect{|x| Math.log(x)}
  logrkm1_0 = 2* logrkm1[0] - logrkm1[1]
  logrkm1_last = 2 * logrkm1[-2] - logrkm1[-1]
  logrkm1.insert(0,logrkm1_0)
  logrkm1 << logrkm1_last
  logrkm1s = '"[' + logrkm1.join(" ") + ']"'
  step_size_s = step_size.to_s
  
  system("python python/logrk_interpolate.py " + logrkm1s + ' ' + step_size_s + ' ' + index.to_s)
  # the 'interpolated_logrkm1s' file contains interpolated log(1-rk)
  logrkm1_file = File.new($logrk_file_path2 + index.to_s , "r")
  ilogrkm1s = logrkm1_file.gets
  puts "ilogrkm1s: " + ilogrkm1s
  return ilogrkm1s
end

def interpolateKappa3(rt,kt,step_size,index,base_index)
# linear interpolate and extrapolate kappa
  rk = [rt,kt].transpose.map{|x| x.reduce(:*)}
  puts " ------- >o< ------"
  oneMinusRK = rk.collect{|x| 1 - x}
  oneMinusRK.each_with_index do |x,i|
	if x < 0
		oneMinusRK[i] = 0.1
        end
  end
  puts " ------- >o< ------"
  puts "one minus rk: " + oneMinusRK.to_s
  log1minusRK = oneMinusRK.collect{|x| Math.log(x)}
 # log1minusRK_0 = 2 * log1minusRK[0] - log1minusRK[1]
  #log1minusRK_last = 2 * log1minusRK[-2] - log1minusRK[-1]
  #log1minusRK.insert(0,log1minusRK_0)
  #log1minusRK << log1minusRK_last
  log1minusRKstr = '"[' + log1minusRK.join(" ") + ']"'
  step_size_str = step_size.to_s
  puts "in ruby: " + base_index.to_s.strip()
  puts "in ruby: " + log1minusRKstr.to_s
  system("python python/logrk_interpolate_linear.py " + log1minusRKstr + ' ' + step_size_str + ' ' + index.to_s + ' "' + base_index.to_s.strip()+'"' + ' ' + $mosrepindex.to_s)
  # the 'interpolated_logrkm1s' file contains interpolated log(1-rk)
  log1minusRK_file = File.new($logrk_file_path3 + index.to_s , "r")
  ilog1minusRKs = log1minusRK_file.gets
  puts "ilogrkm1s: " + ilog1minusRKs
  return ilog1minusRKs

end

# %%%%%%%%%%%%%%%%%%%%% need to work on this %%%%%%%%%%%%%%%%%
# %%%%%%%%%%%%%%%%
def computeBaseKappa1(ub,vb,base_indices)
  # this should be the correct version of base kappa computation
  # steps:
  #      1. use ub, compute swing of u: du on base points
  #      2. use vb, compute du proj on v
  #      3. divided by length of v get the kappa k on base points 
  number_of_base_points = ub.size
  du = []
  (1..ub.size-1).each do |i|
    du << [ub[i][0] - ub[i-1][0], ub[i][1] - ub[i-1][1]]
  end
   
   # this Du is swing of spokes between two base points. it should be divided by the step size
  #   to get the estimatd swing of spokes for base points for one step size.
  # compute distance between base indices (number of step sizes) 
  indices_distance = []
  (base_indices.size-1).times do | i |
    indices_distance << base_indices[i+1] - base_indices[i]
  end
  # compute the average between adjacent du's
  avgDu = []
  (1..ub.size-2).each_with_index do |i, ind|
    avgDu << [(du[i][0] + du[i-1][0]) / (2*indices_distance[ind+1]), (du[i][1] + du[i-1][1]) / (2*indices_distance[ind+1])]
  end 
  # handle boundary case
  du_normalize_0 = [ du[0][0] / (indices_distance[0]), du[0][1] / (indices_distance[0]) ] 
  avgDu.insert(0,du_normalize_0) 
  du_normalize_last = [du[-1][0] / (indices_distance[-1]), du[-1][1]/ (indices_distance[-1])]
  avgDu << du[-1] 
 

  # now we have du
  k = []
  # first k and last k are from du
  puts "avgDU: " + avgDu.to_s
  puts "vb: " + vb.to_s
  avgDu.each_with_index do |one_du,i| 
    k << vector_project(one_du, vb[i])[1]
  end 
  # just need that scalar 
  return k 
end

def computeBaseKappa2(ub,vb,base_indices)
  # this should be the correct version of base kappa computation
  # steps:
  #      1. use ub, compute swing of u: du on base points
  #      2. use vb, compute du proj on v
  #      3. divided by length of v get the kappa k on base points 
  number_of_base_points = ub.size
  du = []
  (1..ub.size-1).each do |i|
    du << [ub[i][0] - ub[i-1][0], ub[i][1] - ub[i-1][1]]
  end
   
   # this Du is swing of spokes between two base points. it should be divided by the step size
  #   to get the estimatd swing of spokes for base points for one step size.
  # compute distance between base indices (number of step sizes) 
  indices_distance = []
  (base_indices.size-1).times do | i |
    indices_distance << base_indices[i+1] - base_indices[i]
  end
  # compute the average between adjacent du's
  avgDu = []
  (1..ub.size-2).each_with_index do |i, ind|
    avgDu << [4*(du[i][0] + du[i-1][0]) / (2*indices_distance[ind+1]), 4*(du[i][1] + du[i-1][1]) / (2*indices_distance[ind+1])]
  end 
  # handle boundary case
  du_normalize_0 = [ 5 * du[0][0] / (indices_distance[0]),  5 * du[0][1] / (indices_distance[0]) ] 
  avgDu.insert(0,du_normalize_0) 
  du_normalize_last = [2* du[-1][0] / (indices_distance[-1]),2 * du[-1][1]/ (indices_distance[-1])]
  avgDu << du[-1] 
 

  # now we have du
  k = []
  # first k and last k are from du
  puts "avgDU: " + avgDu.to_s
  puts "vb: " + vb.to_s
  avgDu.each_with_index do |one_du,i| 
    k << vector_project(one_du, vb[i])[1]
  end 
  # just need that scalar 
  return k 
end


def computeBaseKappa(xt,yt, indices, h, rt)
  # this function computes kappas at base points using the curvature formula
  # also checks whether rk at these base points are smaller than 1
  # k = (x'y''-y'x'') / (x'^2+y'^2)^(3/2)
  # compute numerical derivatives 
  # for end points the way to compute derivatives are different
  # the index should not contain the first and the last index

  # need to change this so that kappa is computed as swing of spokes 
  dx = []
  dy = []
  ddx = []
  ddy = []
  dx0 = (xt[1] - xt[0]) / h
  dx1 = (xt[2] - xt[1]) / h
  dxe = (xt[-1] - xt[-2]) / h
  dxem1 = (xt[-2] - xt[-3]) / h
  ddx0 = (dx1 - dx0) / h
  ddxe = (dxe - dxem1) / h
  dy0 = (yt[1] - yt[0]) / h
  dy1 = (yt[2] - yt[1]) / h
  dye = (yt[-1] - yt[-2]) / h
  dyem1 = (yt[-2] - yt[-3]) / h
  ddy0 = (dy1 - dy0) / h
  ddye = (dye - dyem1) / h
  dx << dx0
  dy << dy0
  ddx << ddx0
  ddy << ddy0
 
  rs = []
  rs << rt[0]
 
  indices.each do |i|
    if i != 0 && i != (xt.length - 1)	
      dxi = ( xt[i+1] - xt[i-1] ) / (2 * h)
      dyi = ( yt[i+1] - yt[i-1] ) / (2 * h)
      ddxi = (xt[i+1] - (2 * xt[i]) + xt[i-1]) / (h**2.0)
      ddyi = (yt[i+1] - (2 * yt[i]) + yt[i-1]) / (h**2.0) 
      dx << dxi 
      dy << dyi 
      ddx << ddxi
      ddy << ddyi
 
      rs << rt[i]
    end
  end

  rs << rt[-1]
  dx << dxe
  dy << dye
  ddx << ddxe
  ddy << ddye
  kappa = []
  kr = []
  puts "***********************************"
  puts "dx: " + dx.to_s
  dx.each_with_index do |dxi, i|
    ki = (dx[i] * ddy[i] - dy[i] * ddx[i]) / ((dx[i]**2)+(dy[i]**2))**(3.0/2.0) 
    kappa << ki
    #compute k * r 
    kri = ki * rs[i]
    kr << kri
  end
 
  return kappa, kr 
end

def extrapolateKappa()
 # this function extrapolates kappa ...

end


def interpolateSpokeAtPos(u1t, v1t, k1t, d1t, u2t, v2t, k2t, d2t)
  # we know the 
  # this function interpolates the spole at 1st base points to the right..
  # using the formula:
  #   u(t+dt) = (1+a(t)*dt)u(t) - k(t)v(t)dt
  # 
  # d1t and d2t are all positive
 # puts "uvk: " + u1t.to_s + " " + v1t.to_s + " " + k1t.to_s
  a1 = computeAUsingUVK(u1t,v1t,k1t)
  a2 = computeAUsingUVK(u2t,v2t,k2t)
  utp1dt0 = (1+a1*d1t) * u1t[0] -  k1t * v1t[0] * d1t
  utp1dt1 = (1+a1*d1t) * u1t[1] -  k1t * v1t[1] * d1t
  utp2dt0 = (1-a2*d2t) * u2t[0] +  k2t * v2t[0] * d2t
  utp2dt1 = (1-a2*d2t) * u2t[1] +  k2t * v2t[1] * d2t
 # puts "uvkd: " + u2t.to_s + " " + v2t.to_s + " " + k2t.to_s + " " + d2t.to_s
 # puts "aaaa: " + utp1dt0.to_s 
 # puts "bbbb: " + utp2dt0.to_s
 # puts "d1t: "+ d1t.to_s
 # puts "d2t: "+ d2t.to_s
  return [(utp1dt0*d2t+utp2dt0*d1t)/(d1t+d2t), (utp1dt1*d2t+utp2dt1*d1t)/(d1t+d2t)]
end

def interpolateSpokeAtPos2(ut,vt,kt,dt)
# this is the interpolate spoke function for the second button
#    u(t+dt) = (1+a(t)*dt)u(t) - k(t)v(t)dt
  at = computeAUsingUVK(ut,vt,kt)
  puts "norm of v: " + twoDNorm2(vt).to_s
  puts "norm of u: " + twoDNorm2(ut).to_s
  puts "kt: " + kt.to_s
  puts "at: " + at.to_s
  utdtx = (1+at*dt) * ut[0] - kt * vt[0] * dt
  utdty = (1+at*dt) * ut[1] - kt * vt[1] * dt
  u = twoDNormalize([utdtx, utdty])
  return u
end

def computeAUsingUVK(ut,vt,kt)
# make sure kt and vt are all nomalized

  ut = twoDNormalize(ut)

  a = kt * dot(ut,vt)	
  print "a: " + a.to_s + "\n"
  return a
end

def checkSpokeIntersection(x1,y1,x2,y2,x3,y3,x4,y4)
  if x1 == x2 || x3 == x4 
    return [false, 0, 0]
  end
  #compute two intervals
  i1 = [[x1,x2].min, [x1,x2].max]
  i2 = [[x3,x4].min, [x3,x4].max]
  # TEST IF THERE IS MUTUAL REGION	
  if ([x1,x2].max < [x3,x4].min)
    return [false, 0 ,0]
  end
  # compute A and b for two lines
  a1 = (y1-y2) / (x1-x2)
  a2 = (y3-y4) / (x3-x4)
  b1 = y1 - a1 * x1
  b2 = y3 - a2 * x3 
  # check if two lines are parallel 
  if a1 == a2
    return [false, 0, 0]
  end
  # compute the intersection x
  xa = (b2-b1) / (a1-a2)
  if ( (xa< [[x1,x2].min, [x3,x4].min].max ) || (xa> [[x1,x2].max, [x3,x4].max].min) )
    return [false, 0, 0]
  else 
    ya = a1 * xa + b1
   if ya.nan?
      puts "stuff: " + x1.to_s + " " + y1.to_s + " " + x2.to_s + " " + y2.to_s + " " + x3.to_s + " "  + y3.to_s + " " + x4.to_s + " " + y4.to_s
   end  
  return [true, xa, ya]
  end    
end 

def checkSpokeEndAndDiskIntersection(x,y,srep)
  # this function avoids a few spokes that goes too far away
  srep.atoms.each do |atom|
    disk_x = atom.x
    disk_y = atom.y
    disk_r = atom.expand_spoke_length[0] 
    disk_to_center = Math.sqrt(( x - disk_x ) ** 2 + ( y - disk_y ) ** 2)
    if disk_r * 0.9 >= disk_to_center
       return true
    end
  end
  return false
end

def linkLinkingStructurePoints(sreps, app, shift)
# this function links the intersection points to form a linking structure
  sreps.each_with_index do |srep, srep_index|
    srep.extend_interpolated_spokes_end.each_with_index do |spoke_end, spoke_end_index|
      app.stroke("#3399FF")
      if spoke_end[3].length > 0
        puts "case0: " + ( spoke_end[3].length > 0 ).to_s
        app.line(spoke_end[0]+shift, spoke_end[1]+shift, spoke_end[3][0]+shift, spoke_end[3][1]+shift)
      end
      puts "case3: " + (spoke_end[2] != -1).to_s
      if spoke_end[2] != -1
        if spoke_end_index+2 < srep.extend_interpolated_spokes_end.length and srep.extend_interpolated_spokes_end[spoke_end_index+2][2] != -1 and spoke_end[4] == 'regular' and srep.extend_interpolated_spokes_end[spoke_end_index+2][4] == 'regular'
          puts "case1: " + ( spoke_end_index+2 < srep.extend_interpolated_spokes_end.length ).to_s
          puts "case2: " + ( srep.extend_interpolated_spokes_end[spoke_end_index+2][2] != -1 ).to_s
          app.line(spoke_end[0]+shift, spoke_end[1]+shift, srep.extend_interpolated_spokes_end[spoke_end_index+2][0]+shift,  srep.extend_interpolated_spokes_end[spoke_end_index+2][1]+shift)
        end
      end
    end
  end
end


def computeOrthogonalizedSpokes(srep)
  interpolated_spokes_begin = srep.interpolated_spokes_begin
  interpolated_spokes_end = srep.interpolated_spokes_end
   
  srep_base_index = srep.base_index
  
  # get base spokes 
  base_atoms = srep.atoms
  base_spoke_dir_lst = []

  implied_boundary_dirs = []
  # compute the implied boundary direction 
  srep_base_index.each_with_index do |index, i| 
     if index != 0 and index != 100
        interpolated_spokes_left_begin = interpolated_spokes_begin[index-1]
        interpolated_spokes_left_end = interpolated_spokes_end[index-1]
        interpolated_spokes_right_begin = interpolated_spokes_begin[index+1]
        interpolated_spokes_right_end = interpolated_spokes_end[index+1]
        # compute implied boundary dir (the dir orthotogonal to the boundary)   
        implied_boundary_line = [ interpolated_spokes_left_end[0] - interpolated_spokes_right_end[0], interpolated_spokes_left_end[1] - interpolated_spokes_right_end[1]] 
    
        implied_boundary_dir = [ -1 *implied_boundary_line[1], -1 * implied_boundary_line[0]] 
        # normalize the implied boundary dir
        implied_boundary_dir = twoDNormalize(implied_boundary_dir)
        # adjust the base atom dir to the implied boundary dir
        
        # update implied boundary dirs

         implied_boundary_dirs << implied_boundary_dir
       
     end
  end

  return implied_boundary_dirs 
   
end

# new 
def getNoiseForOneSrep(noise_data, srep_index)
   # this function returns noise data for one srep, given the index of that srep and the noise data for a mos-rep (all sreps)
   # assume the noise data is already an array
   # assume the number of atoms for that mosrep is fixed as: 5,5,4 <- this may be dangerous! 
   one_srep_noise_data = []
   mosrep_atom_position_noise_data = noise_data[0]
   mosrep_spoke_length_noise_data = noise_data[1]
   mosrep_spoke_dir_noise_data = noise_data[2]
   if srep_index == 0 
      one_srep_noise_data << mosrep_atom_position_noise_data[0]
      one_srep_noise_data << mosrep_spoke_length_noise_data[0,5]
      one_srep_noise_data << mosrep_spoke_dir_noise_data[0,5]
   elsif srep_index == 1
      one_srep_noise_data << mosrep_atom_position_noise_data[1]
      one_srep_noise_data << mosrep_spoke_length_noise_data[5,5]
      one_srep_noise_data << mosrep_spoke_dir_noise_data[5,5]
   elsif srep_index == 2
      one_srep_noise_data << mosrep_atom_position_noise_data[2]
      one_srep_noise_data << mosrep_spoke_length_noise_data[10,4]
      one_srep_noise_data << mosrep_spoke_dir_noise_data[10,4]
   end   
   return one_srep_noise_data
end




