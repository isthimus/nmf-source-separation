# hunts around for interfaces that don't match SpectInfo.
# call as below
#   cd <codebase_root>
#   find . -name '*.m' | xargs python scratch/spectInfo/check_spectInfo_interface.py

import sys
args = sys.argv

import os

# check if a line has one of the spectInfo "keywords"
def hasSpectInfoWord (s):
    words= [
        "wlen",
        "audio_len_samp",
        "hop",
        "nfft",
        "num_freq_bins",
        "num_time_bins",
        "fs",
    ]

    for word in words:
        if word in s:
            return True
    return False

# interfaces that are definitely a problem (has a spectinfo word)
exceptions = ["find_window_hop.m","find_window_hop_multi.m", "hop_add_win.m"]
print ("----- BAD -----")
for filename in args [1:]:
    if 'third_party' in filename or os.path.split(filename)[1] in exceptions:
        continue

    with open(filename, mode='r') as f:
        firstLine = f.readline()[:-1] # remove the \n
        if 'function' in firstLine and hasSpectInfoWord(firstLine):
            print (f'{firstLine}')
print('')

# files for which this script cant tell
# (ie if theres a function declared later - first line could be comment or smth)
print ("----- MAYBE -----")
exceptions = []
for filename in args[1:]:
    if 'third_party' in filename or filename in exceptions:
        continue

    with open(filename, mode='r') as f:
        lines = f.readlines()
        for l in lines[1:]: # check lines that arent the first line
            if l.strip().startswith("function") and hasSpectInfoWord(l):
                print(l[:-1])
                #print(filename)
                #print('\t', l[:-1])
                continue
print('')


# interfaces that already have spectinfo
# and which dont have any remaining spectinfo words
print ("----- GOOD -----")
for filename in args [1:]:
    if 'third_party' in filename:
        continue

    with open(filename, mode='r') as f:
        firstLine = f.readline()[:-1] # remove the \n
        if'spectInfo' in firstLine and not hasSpectInfoWord(firstLine):
            print (f'{firstLine}')
