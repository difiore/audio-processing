library(seewave)
library(warbleR)
library(tuneR)
library(soundecology)
library(tools)
library(progress)



f <- "~/Desktop/AM001-20190815-050044.wav"
pb <- progress_bar$new(
	format = "  downloading [:bar] :percent eta: :eta",
	total = 100, clear = FALSE, width= 60)

s <- readWave(f)
# s@right <- s@left # uncomment if want to convert mono to stereo
# s@stereo <- TRUE

str(s)
freq <- 48000
totlen <- length(s)
totsec <- totlen/freq
seglen <- 600
breaks <- unique(c(seq(0, totsec,seglen),totsec))
index <- 1:(length(breaks)-1)
leftmat<-matrix(s@left, ncol=(length(breaks)-2), nrow=seglen*freq)
# rightmat<-matrix(s@right, ncol=(length(breaks)-2), nrow=seglen*freq) # uncomment if stereo

# convert to list of Wave objects
# subsamps <- lapply(1:ncol(leftmat), function(x)Wave(left=leftmat[,x],right=rightmat[,x], samp.rate=s@samp.rate,bit=s@bit)) # uncomment for stereo

# keep in mono
subsamps <- lapply(1:ncol(leftmat), function(x)Wave(left=leftmat[,x],samp.rate=s@samp.rate,bit=s@bit))

# get the last part of the audio file.  the part that is < seglen
lastbitleft <- s@left[(breaks[length(breaks)-1]*freq):length(s)]

# lastbitright <- s@right[(breaks[length(breaks)-1]*freq):length(s)] # uncomment for stereo

# subsamps[[length(subsamps)+1]] <- Wave(left=lastbitleft, right=lastbitright, samp.rate=s@samp.rate, bit=s@bit) # uncomment for stereo

# keep in mono
subsamps[[length(subsamps)+1]] <- Wave(left=lastbitleft, samp.rate=s@samp.rate, bit=s@bit)

# finally, save the Wave objects
setwd("~/Desktop/output")

# set output filenames
n <- file_path_sans_ext(basename(f))
filenames <- paste0(n,"-split-",index,".wav")

# To deal with some memory management issues use rm() and gc()
# which seem to resolve the problems I had with allocating memory.
# rm("s", "freq", "breaks", "index", "lastbitleft","lastbitright","leftmat", "rightmat","seglen","totlen","totsec") # uncomment for stereo

# keep in mono
rm("s", "freq", "breaks", "index", "lastbitleft","leftmat", "seglen","totlen","totsec")
gc() # run garbage collection

# Save the files
sapply(1:length(subsamps), function(x) writeWave(subsamps[[x]], filename=filenames[x]))
