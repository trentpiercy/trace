import os
import glob

files = list(glob.glob(os.path.join("images",'*.*')))

l = []
for i in files:
	x = i.replace("images\\", "")
	x = x.replace(".png", "")
	l.append(i)

print(l)