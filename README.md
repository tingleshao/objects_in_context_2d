rablo2d
=======

##Description
rablo2d is a tool for: <br/>
1. Producing 2d objects in medial representation. <br/>
2. Analyzing their relationship in multi-object context. <br/>
3. Generating data for multi-object statistics.<br/>
##Install
To use me, you need to install:
* [Ruby 1.9.3](http://www.ruby-lang.org/en/downloads/)
* [Shoes](http://shoesrb.com/downloads) (more stable in Linux than in Windows)
  * I had experienced compiling shoes in Ubuntu, by missing something in ruby-dev. Solutions can be found in Stackoverflow.
* [Python](http://www.python.org/getit/)/[SciPy and NumPy](http://www.scipy.org/Download)/[Matplotlib](https://github.com/matplotlib/matplotlib/downloads)
  * current version uses functions in SciPy and NumPy to compute B-Spline interpolation. This may be changed later. 


##Short Introduction
<br/>
To run me, you can go to the directory that contains me and type the following command:

      $ shoes rablo2d.rb
      
In rablo2d you can play around with multiple 2d objects. Each one has a boundary that implied by a series of disks. <br/><br/>
![img1](https://lh6.googleusercontent.com/-UfgaVkImm2I/UMEMozFNtOI/AAAAAAAAC6w/4cFSuiA2Sa4/s640/Screenshot%2520from%25202012-12-06%252016%253A18%253A01.jpg)
<br/>
<br/>
By pushing "Interpolate All" button, the spokes that in between base points will be interpolated.<br/><br/>
![img2](https://lh4.googleusercontent.com/-Qp3j9wAyWKs/UMEMo2FHkwI/AAAAAAAAC64/Wj0QJcnIR6s/s640/Screenshot%2520from%25202012-12-06%252016%253A18%253A26.jpg)
<br/>
<br/>
By keeping push "Dilate" button, all the spokes will extend by a small ratio, once it intersects with other spokes, it will stop extending itself. Finally this process yields a linking structure in the spakes between objects.<br/><br/>
![img3](https://lh6.googleusercontent.com/-rOI0k-YHYLI/UMEMoyyBX4I/AAAAAAAAC60/srwV3Efu81U/s640/Screenshot%2520from%25202012-12-06%252016%253A20%253A25.jpg)
<br/>
<br/>
The linking structure can be displayed.<br/><br/>
![img4](https://lh4.googleusercontent.com/-c8JSBUiqn4o/UMTQbilhxAI/AAAAAAAADCo/0_PTHE0jPgo/s640/Screenshot%2520from%25202012-12-09%252012%253A49%253A08.jpg)
<br/>
<br/>
User can change the visibility of any elements to make the result more clear.<br/><br>/
![img5](https://lh4.googleusercontent.com/-vvS6IxvZHV4/UMTQbspNEjI/AAAAAAAADCs/TV0yV7vhDOY/s640/Screenshot%2520from%25202012-12-09%252012%253A49%253A13.jpg)