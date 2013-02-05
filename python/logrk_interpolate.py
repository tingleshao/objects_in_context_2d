import numpy as np
import matplotlib.pyplot as plt
from scipy import interpolate
import sys
# the passed x and r data array should be quoted 
# the step size should be the relative size in [0 1]
# btw: it is good to use step_size=0.01...

def writelogrk(logrk,f):
	for lrk in logrk:
		f.write(str(lrk))
		f.write(" ")

rks = sys.argv[1]
step_size = float(sys.argv[2])
index = sys.argv[3]
rkk = rks.strip('[]').split(' ')
rk = []

# convert string to array
for foo in rkk:
	rk.append(float(foo))

print "rk: " +  str(rk)

t = np.arange(0.0,1.25,(1.25-0.0)/len(rk))
x = t
print "x: " + str(x)
tck,u = interpolate.splprep([x,rk],s=0)
unew = np.arange(0.0,1.0+step_size,step_size)
out = interpolate.splev(unew,tck)
print out

print "index: " + index
f = open('data2/interpolated_logrkm1s_'+str(index),'w')
writelogrk(out[1],f)

plt.figure()
plt.plot(x,rk,'x',out[0],out[1])
plt.axis('equal')
#
plt.show()
