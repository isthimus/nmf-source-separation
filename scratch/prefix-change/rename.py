import sys
import subprocess
import os.path

args = sys.argv[1:]
for arg in args:
    hd = os.path.split(arg)[0]
    print(fn)
    fn = os.path.split(arg)[1]

    if fn.startswith("nmf"):
        out = hd+fn.replace("nmf", "nss")
    elif fn.startswith("align"):
        out = hd+fn.replace("align", "aln")
    else:
        continue

    print (arg,out)
    subprocess.call(["git", "mv", arg, out])