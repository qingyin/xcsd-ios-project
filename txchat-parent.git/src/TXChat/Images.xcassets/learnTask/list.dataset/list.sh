#! /bin/sh
for eachfile in `ls -B`
do
  filename=`echo $eachfile | awk -F .png '{print $1 }'`
  echo "$filename : \"res/learnTask/$eachfile\","
done

