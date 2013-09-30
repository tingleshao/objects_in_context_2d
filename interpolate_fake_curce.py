import sys
from scipy.interpolate import interp1d

fake_pts_str = sys.argv[1]

fake_pts_str = fake_pts_str[2:-1]
fake_pts_lst_str = fake_pts_str.split(", [")

fake_pts_x = []
fake_pts_y = []

for p in fake_pts_lst_str: 
    that_thing = map(float, p[0:-1].split(", "))
    fake_pts_x.append(that_thing[0])
    fake_pts_y.append(that_thing[1])



