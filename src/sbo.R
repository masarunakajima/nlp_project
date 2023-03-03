
library(dplyr, quietly = T)
library(sbo, quietly=T)


names <- c("blogs","twitter","news")
dirname <- "/scratch1/masarun/nlp/data/final/en_US/en_US."
outdir <- paste0("/scratch1/masarun/nlp/sbo/")

args <- commandArgs(trailingOnly = TRUE)
k <- as.integer(args[1])

## Get all the lines from the files
all_lines <- readLines("split_data/test.txt")
N <- length(all_lines)


## percentage of the entire lines to use for training
percentages <- c(0.10, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1)



test <- readLines("split_data/test.txt")
n_test <- length(test)

for (perc in percentages) {
  print(paste("Working on: ", perc))
  n <- as.integer(perc*N)
  #train_mask <- sample(c(T, F), N, prob= c(perc, 1-perc), replace=T)
  train <- all_lines[1:n]


  start <- Sys.time()
  ## Train
  t <- sbo_predtable(object = train,
                     N = k,
                     dict = target ~ 0.75,
                     .preprocess = sbo::preprocess,
                     EOS = ".?!:;",
                     lambda = 0.4,
                     L = 3L,
                     filtered = "<UNK>")
  end <- Sys.time()
  diff_s_train <- as.character(difftime(end, start, units="secs"))

  fname <- file.path(outdir, 
                     paste0(k, "-gram_", as.integer(perc*100), ".rda") )
  ## Save the model for later use
  save(t, file=fname)
  p <- sbo_predictor(t)

  start <- Sys.time()
  ## Test
  evaluation <- eval_sbo_predictor(p, test = test)
  end <- Sys.time()

  diff_s <- as.character(difftime(end, start, units="secs"))

  eval_out <- evaluation %>% 
    summarise(accuracy = sum(correct)/n(),
              uncertainty = sqrt(accuracy * (1 - accuracy) / n()))

  ## output summary to file

  fname <- file.path(outdir, 
                     paste0(k, "-gram_", as.integer(perc*100), "_eval.txt") )
  sink(fname)
  print(paste( "n gram model: ", k))
  print(paste("fraction of entire data:", perc))
  print(paste("train lines: ", n))
  print(paste("train data size (byte): ", object.size(train)))
  print(paste("train time (s): ", diff_s_train))
  print(paste("predictor size (byte): ", object.size(t)))
  print("evaluation summary")
  print(paste("test lines: ", n))
  print(paste("test size (byte): ", object.size(test)))
  print(paste("accuracy: ", eval_out$accuracy[1]))
  print(paste("uncertainty: ", eval_out$uncertainty[1]))
  print(paste("evaluation time (s): ", diff_s))
  sink()
  #write.table(eval_out, file= fname)



}


