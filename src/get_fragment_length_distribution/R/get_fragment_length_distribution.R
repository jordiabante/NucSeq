args <- commandArgs(trailingOnly = TRUE)
read.table(args[1],sep="\t")->frag
library(ggplot2)
ggplot(frag) + geom_bar(alpha = 0.35, position = 'identity',aes(x=V1,y=V2),stat='identity')->plot
ggsave(filename=args[2],plot)
dev.off()
