#!/bin/bash

IFS=$'\n'
for i in $(find $1 -name '*_unittest.m' ); 
do
    echo "running $i..."
    matlab -nodisplay -nosplash -nodesktop -r "try, run('$i'), catch me, fprintf('\t!!! %s / %s\n', me.identifier, me.message), end,  exit" > unittest_tmp
    cat unittest_tmp | grep '!!!'

done
unset IFS

echo ""
rm unittest_tmp
