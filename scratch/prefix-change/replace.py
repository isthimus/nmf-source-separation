import sys
args = sys.argv

# call with 
#    python replace.py mfiles.txt funcs.txt nmf_ nss_

# command line args

# mfiles list
with open(args[1]) as f:
    mfiles = [i[:-1] for i in f.readlines() if i != "\n"]

# functions to fix
with open(args[2]) as f:
    funcs = [i[:-1] for i in f.readlines() if i != "\n"]

# string in the functions to change 
findStr_base = args[3]
repStr_base  = args[4]
#print(funcs)


for fileName in mfiles:
    with open(fileName, "r+") as f:
        print(fileName)
        s = f.read()
        for func in funcs:
            findStr = func
            repStr = func.replace(findStr_base, repStr_base);
            #print(findStr, repStr)

            s = s.replace(findStr, repStr)
            #print(s)
        f.seek(0)
        f.write(s)
        f.truncate()

