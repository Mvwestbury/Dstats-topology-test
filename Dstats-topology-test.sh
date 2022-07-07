# Example sh Dstats_topology_test.sh Pop1 Pop2 dstats_jacknifed.txt

##Note: Jacknife file names start with population_ which is then followed by sample name

# $1 = Population that appears twice
# $2 = Population that appears once
# $3 = Input Dstats txt file


## "Incorrect" topolgies
awk -v doub=$1 -v sing=$2 '{if (($2~sing && $1~doub && $3~doub) || ($1~sing && $2~doub && $3~doub)) print $1,$2,$3,$6,$9;}' $3 | awk -v doub=$1 -v sing=$2 '{if ($2~doub && $1~sing && $3~doub) print $1,$2,$3,$4,$5; else print $2,$1,$3,$4*-1,$5*-1;}' | awk -v doub=$1 -v sing=$2 '{print "Wrong "sing"_"doub"_"doub,$4,$5,$6}' > $1_vs_$2_incorrect_top.txt

## "Correct" topologies
awk -v doub=$1 -v sing=$2 '{if ($3~sing && $1~doub && $2~doub) print $1,$2,$3,$6,$9}' $3 | awk -v doub=$1 -v sing=$2 '{print "Right "doub"_"doub"_"sing,$4,$5}' > $1_vs_$2_correct_top.txt

## Within population comparisons for substructure
awk -v doub=$1 '{if ($3~doub && $1~doub && $2~doub) print $1,$2,$3,$6,$9}' $3 | awk -v doub=$1 -v sing=$2 '{print "Within "doub"_"doub"_"doub,$4,$5}' > $1_only_top.txt

