# this is a math toolbox for the project, 
# the first tool is the spline interpolation
# author: chong shao (cshao@cs.unc.edu)



def spline_fit(sampled_points, interp_points)
	# this function takes a given set of discrete points and fit the curve of them using piece wise splines functions	
	
end

def vector_project(a,b)
  # compute projection a on direction of b
  scalar = dot(a,b) / dot(b,b)
  projection = [scalar * b[0], scalar * b[1]]
  return [projection, scalar] 
end

def dot(a,b)
  # compute dot product of a and b
  # assume a and b are vectors in 2D
  p = a[0] * b[0] + a[1] * b[1]
  return p
end
