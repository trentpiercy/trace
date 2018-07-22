import os
import glob

files = list(glob.glob(os.path.join("images",'*.*')))

print(files)
