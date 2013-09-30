import sys
from scipy.interpolate import interp1d
import matplotlib.pyplot as plt
from scipy import interpolate
import numpy as np



def writePts(x,y,f,l):
    for i in xrange(l):
	f.write(str(x[i]))
	f.write(" ")
	f.write(str(y[i]))
        f.write("\n")

fake_pts_str = sys.argv[1]

#fake_pts_str = "[[100, 200], [150, 110], [170, 200], [200, 210]]"

fake_pts_str = fake_pts_str[2:-1]
fake_pts_lst_str = fake_pts_str.split(", [")

fake_pts_x = []
fake_pts_y = []

for p in fake_pts_lst_str: 
    that_thing = map(int, p[0:-1].split(", "))
    fake_pts_x.append(that_thing[0])
    fake_pts_y.append(that_thing[1])

print fake_pts_x
print fake_pts_y
#fake_pts_x_i = np.linspace(fake_pts_x[0], fake_pts_x[-1], len(fake_pts_x))
#f = interp1d(fake_pts_x, fake_pts_y, kind='cubic')
#t = np.arange(0.0,1.2,(1.2)/100)
tck,u = interpolate.splprep([fake_pts_x, fake_pts_y], k = 2, s=1.0)
unew = np.arange(0, 1.00, 0.001)
out = interpolate.splev(unew, tck)
#print str(out)
print len(out[0])
for p in out[0]:
    print p


plt.figure()
plt.plot(fake_pts_x, fake_pts_y, 'x', out[0],out[1])
plt.axis('scaled')
plt.show()

f = open('interpolate_fake_linkingPts.txt','w')
writePts(out[0],out[1],f,len(out[0]))


#plt.plot(fake_pts_x, fake_pts_y, 'o', fake_pts_x_i, f(fake_pts_x_i), '--')
#plt.show()





