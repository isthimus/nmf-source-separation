# given a list of identifiers in args, lists all the places those identifiers are referenced
# call using
#     cat badFuncs.txt | xargs python check_calls_to.py > calls.txt

import sys
args = sys.argv

# pick up list of m files from mfiles.txt
mfiles = []
with open('mfiles.txt') as f:
	mfiles = [i[:-1] for i in f.readlines()]

# declare lists for function names and  calls
fnames = args[1:]
calls = [[] for i in fnames]
print ('FNAMES:')
for i in fnames:
	print(f'\t{i}')
print('')

for path in mfiles:           # go through every path
	with open(path) as f:     # open that path
		lines = [l[:-1] for l in f.readlines()] # extract lines array
		for (linenum, line) in enumerate(lines):    # for each line...
			for name in fnames:                     # ... and name
				if name.lower() in line.lower(): # check if the name is in the line

					# if so put the filename and line number into calls list
					calls[fnames.index(name)].append((path, linenum+1, line)) # lol off by one
																			  # BAD CODE BAD CODE

# print results
lastPath = None
for i, name in enumerate(fnames):
	print('-----', name, '-----')
	for call in calls[i]:
		path, linenum, line = call
		if path == lastPath:
			print(f'\t\t{linenum}: {line}')
		else:
			print(f'\t{path}:\n\t\t{linenum}: {line}')
		lastPath = path