# this script is for generating base pts x y's and (probabily) radius' for test statistics
# two major modes of variations are:
# 	1. srep0, horizontal stretching 
#	2. srep1, left side raising / dropping
# other places has small variations sampled from gaussian dist.


import numpy as np
from scipy import *

import sys

print "hello"

# argument 1: how many sample data we need 
# argument 2: noise gaussian variance

# note that the variance for two major modes of variations are hard coded into the code
# this may be changed later
# things that are also hard coded: 
# - the main configuration, 3 s(m)reps, number of pts: 5, 5, 4 respectively 
# - radius currently does not vary. 
# - right now only output plain text, may change into xml later 


num_of_data = int(sys.argv[1])
gaussian_variance = float(sys.argv[2])
major_var_1 = float(sys.argv[3])
major_var_2 = float(sys.argv[4])

# gaussian seed
s = np.random.normal(0,gaussian_variance,28)
srep1_pts = [[90+s[0],100+s[1]],[150+s[2],75+s[3]],[210+s[4],50+s[5]],[270+s[6],60+s[7]],[330+s[8],80+s[9]]]
srep2_pts = [[200+s[10],190+s[11]],[250+s[12],190+s[13]],[300+s[14],200+s[15]],[350+s[16],180+s[17]],[400+s[18],160+s[19]]]
srep3_pts = [[-10+s[20],140+s[21]],[40+s[22],170+s[23]],[75+s[24],185+s[25]],[110+s[26],195+s[27]]]

print srep1_pts
print srep2_pts
print srep3_pts

# add two major modes of variations 
# first: stretching srep1
s1 = np.random.normal(1,major_var_1,1)
# having this number, we can multiply the original length by its size
# steps:
#      1. minus center
#      2. times ratio
#      3. add by center
# 
# step1
s1_mean = (90 + 150 + 210 + 270 + 330) / 5
srep1_centered_pts = []
for pt in srep1_pts:
	srep1_centrered_pts.append([pt[0]-s1_mean, pt[1]])

# step2
for pt in srep1_centered_pts:
	pt[0] = pt[0] * s1

# step3
for pt in srep1_centered_pts:
	pt[0] = pt[0] + s1_mean

# second: srep2 leftside up / down
s2 = np.random.normal(0,major_var_2,1)
# having this number, we can multiply the original level of up / down by its size 
# steps:
# 	1. ... 
#	2. 
# 	3.

# convert them into xml...



