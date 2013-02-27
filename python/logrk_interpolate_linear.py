import numpy as np
from scipy.interpolate import interp1d
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
base_index = sys.argv[4]

print "index:  " + str(index)
print "step_size: " + str(step_size)
print "base_index: " + str(base_index)


# convert string into array
for foo in rkk:
	rk.append(float(foo))

print "rk: " +  str(rk)

t = np.linspace(0,1,100)
x = t
print "x: " + str(t)
f = interp1d(x,rk)
print f

print "index: " + index
file_handle = open('data3/interpolated_logrkm1s_'+str(index),'w')
writelogrk(f,file_handle)

plt.figure()
plt.plot(x,f,'x')
plt.axis('equal')
#
plt.show()
