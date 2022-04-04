# Dstats-topology-test
Basic scripts for filtering and plotting ABBA/BABA or D-statistics outputs to test for population structure. D-statistics uses a predefined topology of (((H1,H2), H3), Outgroup) which we can leverage for population structure analyses.

If you use it please cite https://doi.org/10.1098/rsos.201788

## Background
D-statistics is most commonly used to find evidence of gene flow, represented by a high D-score, a high D-score can also be caused by more recent common ancestry brought about by an incorrect predefined topology. 

Taking the latter into account, by placing individuals into predefined "populations" and comparing the average D values produced from “correct” topologies, that is, topologies where branches H1 and H2 contain individuals from the same "population" but H3 contains indiviuals from another "population", and “incorrect” topologies, that is, topologies in which branches H2 and H3 have individuals from the same "population" while H1 is from a different "population". 

Using this same approach we can also investigate for evidence of subpopulation structure within "populations" in which all branches contain individuals from a single "population".

## How-to

First run Dstatistics using ANGSD http://www.popgen.dk/angsd/index.php/Abbababa

Example command: 


 - Run block jackknifing on the abbababa output from ANGSD using the R script available in the ANGSD toolsuite

`Rscript jackKnife.R file=output.abbababa indNames=Individual_names.txt outfile=dstats_jackknifed`

 - Run a loop to produce commands for all "population" comparisons

`while read -r line; do while read -r line2; do echo sh Dstats-topology-test.sh $line $line2 dstats_jackknifed.txt; done < Populations.txt ; done < Populations.txt | awk '$3!=$4{print}'`

 - Put all relevent population comparisons together and add a header

`while read -r line; do sh Combining_outputs.sh $line ; done < Populations.txt`

This will give the output Pop_vs_rest.txt 

 - To evaluate the significance of these results we can look for a non-parametric value of |Z|>3 using a one sample Wilcoxon signed rank test
http://www.sthda.com/english/wiki/one-sample-wilcoxon-signed-rank-test-in-r

```R
a=read.table("Pop_vs_rest.txt",header=TRUE)
# If the mean Z looks greater than 3
wilcox.test(a$V4,mu=3,conf.int=TRUE,alternative=c("greater"),conf.level=0.95)
# If it looks lower than -3
wilcox.test(a$V4,mu=-3,conf.int=TRUE,alternative=c("less"),conf.level=0.95)
```

## Plot the results using R

Example

```R
library(RColorBrewer)
library(ggplot2)
library(ggpubr)
my.palette <- brewer.pal(3, "Set2")

NZ=read.table("Pop_vs_rest.txt",header=TRUE)
# Plot the Z scores
p=ggviolin(NZ,
           x = "Topology",
           y = "Z",
           add = c("boxplot"),
           fill = "Type",
           palette = my.palette,
           ylab = expression("Z-score"),
           xlab = expression(""),
           ylim = c(-10,10),
           order = c("NewZealand_NewZealand_NewZealand","NewZealand_NewZealand_SouthAfrica","SouthAfrica_NewZealand_NewZealand","NewZealand_NewZealand_SouthAustralia","SouthAustralia_NewZealand_NewZealand","NewZealand_NewZealand_WestAustralia","WestAustralia_NewZealand_NewZealand"),
           add.params = list(alpha = .1)) + rotate_x_text(angle = 90)
p + font("x.text", size = 9)+ geom_hline(yintercept=-3,color = "black", size=0.5,linetype="dashed")+ geom_hline(yintercept=3,color = "black", size=0.5,linetype="dashed") + rremove("legend")

## Plot the D scores
p=ggviolin(NZ,
           x = "Topology",
           y = "D",
           add = c("boxplot"),
           fill = "Type",
           palette = my.palette,
           ylab = expression("D-score"),
           xlab = expression(""),
           ylim = c(-0.06,0.06),
           order = c("NewZealand_NewZealand_NewZealand","NewZealand_NewZealand_SouthAfrica","SouthAfrica_NewZealand_NewZealand","NewZealand_NewZealand_SouthAustralia","SouthAustralia_NewZealand_NewZealand","NewZealand_NewZealand_WestAustralia","WestAustralia_NewZealand_NewZealand"),
           add.params = list(alpha = .1)) + rotate_x_text(angle = 90)
p + font("x.text", size = 9)+ geom_hline(yintercept=0,color = "black", size=0.5,linetype="dashed") + rremove("legend")`
```
