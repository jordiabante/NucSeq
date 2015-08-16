# Arguments
args <- commandArgs(trailingOnly = TRUE)

# Read input
read.table(args[1],sep="\t")->input
read.table(args[2],sep="\t")->output

# Adapt the input
sample1=input[,3]
sample2=input[,4]
sample1[is.na(sample1)]=0
sample2[is.na(sample2)]=0

# Perform Wilcoxon signed rank test
stats=wilcox.test(sample1,sample2, correct = FALSE, paired=TRUE, conf.level = 0.95)

# Fill output file
output=matrix(nrow=4,ncol=1)
rownames(output)=c("Method","Test","Statistics","p-value")
colnames(output)=c("Value")

output[1,1]=stats$method
output[2,1]=stats$alternative
output[3,1]=stats$statistic  
output[4,1]=stats$p.value  

# Print output
write.table(output,sep="\t",file=args[2],quote=FALSE)
