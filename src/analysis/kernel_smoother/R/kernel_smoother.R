# Libraries
try(library(KernSmooth), silent=TRUE)
try(library(doParallel), silent=TRUE)
try(library(foreach), silent=TRUE)

# IO files
args=commandArgs(trailingOnly = TRUE)
input=args[1]
kernel_type=args[2]
bandwidth=args[3]
gridsize=4*as.numeric(bandwidth)+1
threads=args[4]

# Read in the file
counts=read.table(input)
colnames(counts)=c("chr","pos","raw_counts")

# Initialize output
output=as.data.frame(matrix(ncol=3))
colnames(output)=c("chr","pos","score")

# Prepare for the parallel processing
registerDoParallel(cores=threads)

# For each chromosome
nchr=nlevels(counts$chr) # Number of chromosomes
for(chr in 1:nchr){
    # Get chr name
    actual_chr=levels(counts$chr)[chr]
    # Select the data belonging to that chr
    compact=counts[counts$chr==actual_chr,]
    # Get maximum coordinates
    max_pos=which.max(compact$pos)
    max_pos=compact$pos[max_pos]
    # Give some wiggle room to kernel
    max_pos=as.numeric(max_pos)+200
    # Initialize all the positions with 0s
    extended_pos=as.vector(seq(1,max_pos))
    extended_smooth=as.vector(rep(0,max_pos))
    extended=data.frame(cbind(extended_pos,extended_smooth))
    colnames(extended)=c("pos","smooth")
    # For every midpoint
    parallel_out<-foreach(midpoint=1:nrow(compact),.combine=rbind) %dopar% {
        # Get center
        center=compact$pos[midpoint]
        nreads=compact$raw_counts[midpoint]
        # Apply kernel
        kernel_out=bkde(compact$raw_counts[midpoint],
                        kernel=kernel_type,
                        bandwidth=as.numeric(bandwidth),
                        gridsize=gridsize)
        kernel_smooth=kernel_out$y
        # Scale output with number of midpoints
        kernel_smooth=nreads*kernel_smooth
        kernel_grid=as.vector(seq(-(gridsize-1)/2,(gridsize-1)/2)
                              +as.numeric(center))
        # Format it
        new_points=data.frame(actual_chr,kernel_grid,kernel_smooth)
        colnames(new_points)=c("chr","pos","score")
        # Join to the rest of data
        new_points=new_points[new_points$pos>0,]
        new_points=new_points[new_points$pos<=max_pos,]
        new_points
    }
    output=rbind(output,parallel_out)
}

# Clean output
output=data.frame(output[2:nrow(output),])
# Print output
write.table(output,col.names=FALSE,row.names=FALSE,sep="\t",quote=FALSE)
