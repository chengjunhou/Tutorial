library(data.table)
library(RDota2)
setwd("~")
key_actions(action='register_key', value='XXXXXXXXXXXX')


################ Input ################
# match_id to get started
mid.a <- 3097027819
# total number of records
N <- 100000
# number of records per file
nnn <- 1000
# number of requested matches per pull
rrr <- 10
#######################################


# create folder
ifelse(!dir.exists(paste0("M",mid.a)), dir.create(paste0("M",mid.a)), FALSE)
# initial match info
M.a = get_match_details(match_id=mid.a)$content
sid.a = M.a$match_seq_num
stime.a = as.POSIXct(M.a$start_time, origin = '1970-01-01', tz = 'GMT')
sid = sid.a


# use API to get data
over.time = Sys.time()
for (p in 1:round(N/nnn)) {
  # row index
  i = 1
  # iteration number
  iter = 1
  
  ###### info of initial match ######
  dt = data.table(mid=rep(NA_integer_,nnn), 
                  lobby=rep(NA_integer_,nnn),
                  gmode=rep(NA_integer_,nnn),
                  leagueid=rep(NA_integer_,nnn),
                  R1=rep(NA_integer_,nnn), R2=rep(NA_integer_,nnn),
                  R3=rep(NA_integer_,nnn), R4=rep(NA_integer_,nnn), R5=rep(NA_integer_,nnn),
                  D1=rep(NA_integer_,nnn), D2=rep(NA_integer_,nnn),
                  D3=rep(NA_integer_,nnn), D4=rep(NA_integer_,nnn), D5=rep(NA_integer_,nnn),
                  st=rep(NA_integer_,nnn), 
                  duration=rep(NA_integer_,nnn), 
                  Rscore=rep(NA_integer_,nnn), Dscore=rep(NA_integer_,nnn), 
                  Rwin=rep(NA,nnn))
  
  ###### pull matches ######
  start.time = Sys.time()
  while (i <= nnn) {
    tryCatch({
      M <- get_match_history_by_sequence_num(matches_requested=rrr, start_at_match_seq_num=sid)$content
      for (r in 1:rrr) {
        ltype = M$matches[[r]]$lobby_type
        gmode = M$matches[[r]]$game_mode
        human = M$matches[[r]]$human_players
        if ((ltype==1&gmode==2&human==10) | (ltype==7&human==10)) {
          dt$mid[i] = M$matches[[r]]$match_id
          dt$lobby[i] = ltype
          dt$gmode[i] = gmode
          dt$leagueid[i] = M$matches[[r]]$leagueid
          dt$R1[i] = M$matches[[r]][[1]][[1]]$hero_id
          dt$R2[i] = M$matches[[r]][[1]][[2]]$hero_id
          dt$R3[i] = M$matches[[r]][[1]][[3]]$hero_id
          dt$R4[i] = M$matches[[r]][[1]][[4]]$hero_id
          dt$R5[i] = M$matches[[r]][[1]][[5]]$hero_id
          dt$D1[i] = M$matches[[r]][[1]][[6]]$hero_id
          dt$D2[i] = M$matches[[r]][[1]][[7]]$hero_id
          dt$D3[i] = M$matches[[r]][[1]][[8]]$hero_id
          dt$D4[i] = M$matches[[r]][[1]][[9]]$hero_id
          dt$D5[i] = M$matches[[r]][[1]][[10]]$hero_id
          dt$st[i] = M$matches[[r]]$start_time
          dt$duration[i] = M$matches[[r]]$duration
          dt$Rscore[i] = M$matches[[r]]$radiant_score
          dt$Dscore[i] = M$matches[[r]]$dire_score
          dt$Rwin[i] = M$matches[[r]]$radiant_win
        }
        i = i+1
      }
      cat("--- ", iter*rrr,"/", nnn, " ---\n", sep="")
      iter = iter + 1
      sid = M$matches[[rrr]]$match_seq_num + 1
      #Sys.sleep(1)
    }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
  }
  print(Sys.time() - start.time)
  
  ###### save data ######
  dt = dt[!is.na(dt$mid),]
  saveRDS(dt, paste0("M",mid.a,"/f",p))
  sid = sid + 1
  cat("++++++++++++", p, "++++++++++++\n")
}
print(Sys.time() - over.time)


# process data to save as rds
data <- list()
for (i in 1:round(N/nnn)) {
  data[[i]] <- readRDS(paste0("M",mid.a,"/f",i))
  print(i)
}
dt = rbindlist(data)

saveRDS(dt, paste0("RDS",mid.a))


