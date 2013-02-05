import numpy as np
import matplotlib.pyplot as plt
from scipy import interpolate
import sys



def writePts(x,y,f):
	for xp in x:
		f.write(str(xp))
		f.write(" ")
	f.write('\n')
	for yp in y:
		f.write(str(yp))
		f.write(" ")




# the passed x and y data should be quoted 
xs = sys.argv[1]
ys = sys.argv[2]
step_size = float(sys.argv[3])
index = sys.argv[4]
xx = xs.strip('[]').split(' ')
yy = ys.strip('[]').split(' ')
x = []
y = []
# convert string to array
for xp in xx:
	x.append(float(xp))
for yp in yy:
	y.append(float(yp))

print x
print y

#points = [[50,100],[100,75],[150,50],[200,60],[250,80]]
#for p in points:
#	x.append(p[0])
#	y.append(p[1])
# the parameterization t should range between 0 to 1
t = np.arange(0.0,1.2,(1.2)/len(xx))
tck,u = interpolate.splprep([x,y],s=0)
unew = np.arange(0.0,1.01,step_size)
out = interpolate.splev(unew,tck)
print out

print "index: " + str(index)
f = open('data2/interpolated_points_'+index,'w')
writePts(out[0],out[1] ,f)


#plt.figure()
#plt.plot(x,y,'x',out[0],out[1])
#plt.axis('equal')
#plt.show()
