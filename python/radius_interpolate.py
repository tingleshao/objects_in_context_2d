import numpy as np
import matplotlib.pyplot as plt
from scipy import interpolate
import sys
# the passed x and r data array should be quoted 
# the step size should be the relative size in [0 1]
# btw: it is good to use step_size=0.01...

def writeRadius(x,r,f):
	for rp in r:
		f.write(str(rp))
		f.write(" ")


xs = sys.argv[1]
rs = sys.argv[2]
step_size = float(sys.argv[3])
index = sys.argv[4]
mosrepindex = sys.argv[5]
noise_index = sys.argv[6]
xx = xs.strip('[]').split(' ')
rr = rs.strip('[]').split(' ')
x = []
r = []
# convert string to array
for xp in xx:
	x.append(float(xp))
for rp in rr:
	r.append(float(rp))
print x
print r

t = np.arange(0.0,1.2,1.2/len(xx))
tck,u = interpolate.splprep([x,r],s=0)
unew = np.arange(0.0,1.0+step_size,step_size)
out = interpolate.splev(unew,tck)
print out

print "index: " + index

# TODO: there should be interpolated_rs data for each base+noise data file pair
#       consider a two-level interpolate data dir structure.
#f = open('data/mosrep'+mosrepindex+'/interpolated_rs_'+index,'w')

f = open('data/mosrep'+mosrepindex+'/'+'noise_'+noise_index+'/interpolated_rs_'+index,'w')
writeRadius(out[0], out[1],f)

plt.figure()
plt.plot(x,r,'x',out[0],out[1])
plt.axis('equal')
#
plt.show()
