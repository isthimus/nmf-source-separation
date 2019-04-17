# given a list of identifiers in args, lists all the places those identifiers are referenced
# call using
#     cat badFuncs.txt | xargs python review_calls.py

import sys
args = sys.argv

# pick up list of m files from mfiles.txt
mfiles = []
with open('mfiles.txt') as f:
	mfiles = [i[:-1] for i in f.readlines()]

# pick up function names list
fnames = args[1:]
print ('FNAMES:')
for i in fnames:
	print(f'\t{i}')
print('')

for path in mfiles:           # go through every path
	with open(path) as f:     # open that path
		path_printed = False
		lines = [l[:-1] for l in f.readlines()] # extract lines array
		for line in lines:    # for each line...
			for name in fnames:                     # ... and name
				if name.lower() in line.lower() and not line.strip().startswith('%'):  # check if the name is in the line
					# if so put the filename and line number into calls list
					if not path_printed: 
						print ("\n----", path, '----\n')
						path_printed = True
					print("\t" + line.strip())