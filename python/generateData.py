# this script is for generating base pts x y's and (probabily) radius' for test statistics
# two major modes of variations are:
# 	1. srep0, horizontal stretching 
#	2. srep1, left side raising / dropping
# other places has small variations sampled from gaussian dist.


import numpy as np
from scipy import *
import math

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

'''
num_of_data = int(sys.argv[1])
gaussian_variance = float(sys.argv[2])
major_var_1 = float(sys.argv[3])
major_var_2 = float(sys.argv[4])
'''

output_file_index = int(sys.argv[1])

python_dir = '/home/chong/rablo2d_repo/rablo2d_freeze/python/'


output_file_name = python_dir + 'noise_data_' + str(output_file_index) + '.txt'
 
# example: config_3, first 2 pts, (90, 65), (150,80) => distance = 61.8 => variance ~= 6
gaussian_variance_base_pts = 5.0
# hard code the r's for the r variances
rs = [35,40,35,40,35,35,40,45,40,35,35,40,35,40]
# spoke dir variance, this number is in degrees
gaussian_variance_spoke_dirs = 7.0 

# gaussian seed
s = np.random.normal(0,math.sqrt(gaussian_variance_base_pts),28)

# the following hard coded data may be used in the future
'''
srep1_pts = [[90+s[0],100+s[1]],[150+s[2],75+s[3]],[210+s[4],50+s[5]],[270+s[6],60+s[7]],[330+s[8],80+s[9]]]
srep2_pts = [[200+s[10],190+s[11]],[250+s[12],190+s[13]],[300+s[14],200+s[15]],[350+s[16],180+s[17]],[400+s[18],160+s[19]]]
srep3_pts = [[-10+s[20],140+s[21]],[40+s[22],170+s[23]],[75+s[24],185+s[25]],[110+s[26],195+s[27]]]
'''

srep0_noise = [[s[0],s[1]],[s[2],s[3]],[s[4],s[5]],[s[6],s[7]],[s[8],s[9]]]
srep1_noise = [[s[10],s[11]],[s[12],s[13]],[s[14],s[15]],[s[16],s[17]],[s[18],s[19]]]
srep2_noise = [[s[20],s[21]],[s[22],s[23]],[s[24],s[25]],[s[26],s[27]]]

# the noise for disk radius
s2 = []
for r in rs:
	noise = np.random.normal(0,math.sqrt(37.0 * 0.1), 1)
	s2.append(noise[0])


# the noise for spoke direction
s3_raw = np.random.normal(0,math.sqrt(gaussian_variance_spoke_dirs),14)
s3 = []
for s3_e in s3_raw:
 	s3.append(s3_e)


# making the variance of the translation 30 pixels
translation_variance = 30

# making the variance of the swing 20 pixels 
swing_variance = 20

# generate a number for translation variance
ss1 = np.random.normal(0,4.0*math.sqrt(translation_variance),1)[0]
# decompose the value into a vector of direction (-1,2)
ssx = ss1 * -2.0 / math.sqrt(3)
ssy = ss1 * 1.0 / math.sqrt(3)
# add this thing into srep0_noise
srep0_noise = [[s[0]+ssx,s[1]+ssy],[s[2]+ssx,s[3]+ssy],[s[4]+ssx,s[5]+ssy],[s[6]+ssx,s[7]+ssy],[s[8]+ssx,s[9]+ssy]]
# generate a number for swing variance 
ss2 = np.random.normal(0,math.sqrt(swing_variance),1)[0]
# purely change in y will be OK
ssy1 = ss2
ssy2 = ss2 / 2.0
# add this thing into srep1_noise
srep1_noise[0][1] = srep1_noise[0][1] + ssy1
srep1_noise[1][1] = srep1_noise[1][1] + ssy2
# print out them to check
print srep0_noise
print srep1_noise
print srep2_noise
# print out them to check
print s2
print s3



# save the three noises array into txt
output_f = open(output_file_name,'w')
output_f.write(str(srep0_noise))
output_f.write('\n')
output_f.write(str(srep1_noise))
output_f.write('\n')
output_f.write(str(srep2_noise))
output_f.write('\n')
output_f.write(str(s2))
output_f.write('\n')
output_f.write(str(s3))

output_f.close()


# the following part is not used now because the change in design
# add two major modes of variations 
# first: stretching srep1
'''
s1 = np.random.normal(1,major_var_1,1)
'''
# having this number, we can multiply the original length by its size
# steps:
#      1. minus center
#      2. times ratio
#      3. add by center
# 

'''
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

'''

