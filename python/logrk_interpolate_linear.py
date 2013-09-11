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
base_index_s = sys.argv[4]
mosrepindex = sys.argv[5]
noise_index = sys.argv[6]
# convert string into array
for ele in rkk:
	rk.append(float(ele))

base_index = []
base_index_lst = base_index_s.strip("[]").split(', ')
for ele in base_index_lst:
	base_index.append(int(ele))

x = base_index
t = np.linspace(1,100,100)
print t
f = interp1d(x,rk)

print "index: " + index
file_handle = open('data/mosrep' + mosrepindex + '/'+'noise_'+noise_index+'/interpolated_logrkm1s_'+str(index),'w')
writelogrk(f(t),file_handle)
print "f(t): " + str(f(t))
plt.figure()
plt.plot(x,rk,'x',t,f(t),'-')
plt.axis('equal')
#
plt.show()
