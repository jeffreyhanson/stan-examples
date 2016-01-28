#### Initialization
# prepare session
rm(list=ls())
options(error=NULL)
setwd('/home/jeff/GitHub/stan-examples/nlmm-negative-exponential')

# set user params

# load deps
library(plyr)
library(dplyr)
library(ggplot2)
library(rstan)

# define functions
test=function(){source('/home/jeff/GitHub/stan-examples/nlmm-negative-exponential/analyse.R')}

#### Prelimianry processing
# load data
inpDF = readRDS('data.rds')

#### Main processing
# run stan

#### Exports
# plot results

# print summaries of parameters


