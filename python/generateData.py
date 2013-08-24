# this script is for generating base pts x y's and (probabily) radius' for test statistics
# two major modes of variations are:
# 	1. srep0, horizontal stretching 
#	2. srep1, left side raising / dropping
# other places has small variations sampled from gaussian dist.


from numpy import *
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
# hi
