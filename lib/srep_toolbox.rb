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

$points_file_path = "data2/interpolated_points_"
$radius_file_path = "data2/interpolated_rs_"
$logrk_file_path = 'data2/interpolated_logrkm1s_'
$pi = Math::PI

def generate2DDiscreteSrep(atoms, spoke_length, spoke_direction, step_size, srep_index)
  # This function returns an srep which has parameters specified in the arguments lists
  srep = SRep.new()
  srep.index = srep_index	
  atoms.each_with_index do |atom, i|
    if spoke_length[i].length == 3
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
    # make sure the spoke length vector is in type Float
    li = spoke_length[i]
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
      u1 = atom.spoke_direction[1]  
      size_norm_v=  Math.sqrt(v[i][0] **2 + v[i][1] **2)
      norm_v = [v[i][0] / size_norm_v ,  v[i][1] / size_norm_v ]
      u1_proj_on_v = norm_v.collect{|e| e* (u1[0] * norm_v[0] + u1[1] * norm_v[1])} 
      size_proj = Math.sqrt(u1_proj_on_v[0] **2 + u1_proj_on_v[1] **2 )
      norm_proj = [u1_proj_on_v[0] / size_proj, u1_proj_on_v[1] / size_proj]
      puts "norm_v: " + norm_v.to_s
      puts "norm_proj: " + norm_proj.to_s

      puts "u1_proj_on_v: " + u1_proj_on_v.to_s
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
      atom.spoke_direction[0] = u0
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
  system("python python/curve_interpolate.py " + xs + ' ' + ys + ' ' + step_size_s + ' ' + index.to_s)
  # the 'interpolated_points_[index]' file contains interpolated points

  curve_file = File.new($points_file_path+index.to_s, "r")
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
  system("python python/radius_interpolate.py " + xs + ' ' + rs + ' ' + step_size_s + ' ' + index )
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
  puts "inside 1: " + rk.to_s
  rkm1 = rk.collect{|x| 1-x}
  logrkm1 = rkm1.collect{|x| Math.log(x)}
  logrkm1s = '"[' + logrkm1.join(" ") + ']"'
  step_size_s = step_size.to_s
  system("python python/logrk_interpolate.py " + logrkm1s + ' ' + step_size_s + ' ' + index.to_s)
  # the 'interpolated_logrkm1s' file contains interpolated log(1-rk)
  logrkm1_file = File.new($logrk_file_path + index.to_s , "r")
  ilogrkm1s = logrkm1_file.gets
  puts "ilogrkm1s: " + ilogrkm1s
  return ilogrkm1s
end

def computeBaseKappa2(ub,vb, rt,base_index)
  #  this is the correct version of base kappa computation
  # steps:
  #      1. use ub, compute swing of u: du on base points
  #      2. use vb, compute du proj on v
  #      3. divided by length of v get the kappa k on base points 
  
  
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

def interpolateSpokeAtPos(u1t, v1t, k1t, d1t, u2t, v2t, k2t, d2t)
  # we know the 
  # this function interpolates the spole at 1st base points to the right..
  # using the formula:
  #   u(t+dt) = (1+a(t)*dt)u(t) - k(t)v(t)dt
  # 
  # d1t and d2t are all positive
   puts "uvk: " + u1t.to_s + " " + v1t.to_s + " " + k1t.to_s
   a1 = computeAUsingUVK(u1t,v1t,k1t)
  a2 = computeAUsingUVK(u2t,v2t,k2t)
  utp1dt0 = (1+a1*d1t) * u1t[0] -  k1t * v1t[0] * d1t
  utp1dt1 = (1+a1*d1t) * u1t[1] -  k1t * v1t[1] * d1t
  utp2dt0 = (1-a2*d2t) * u2t[0] +  k2t * v2t[0] * d2t
  utp2dt1 = (1-a2*d2t) * u2t[1] +  k2t * v2t[1] * d2t
  puts "uvkd: " + u2t.to_s + " " + v2t.to_s + " " + k2t.to_s + " " + d2t.to_s
  puts "aaaa: " + utp1dt0.to_s 
  puts "bbbb: " + utp2dt0.to_s
  puts "d1t: "+ d1t.to_s
  puts "d2t: "+ d2t.to_s
  return [(utp1dt0*d2t+utp2dt0*d1t)/(d1t+d2t), (utp1dt1*d2t+utp2dt1*d1t)/(d1t+d2t)]
end


def computeAUsingUVK(ut,vt,kt)
  a = kt * ( ut[0] * vt[0] + ut[1] * vt[1] )
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

