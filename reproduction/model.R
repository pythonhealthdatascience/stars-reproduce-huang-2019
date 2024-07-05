library(simmer)
library(simmer.plot)
library(parallel)
library(dplyr)
library(plotly)
library("gridExtra")


paramNames <- c("ct", "angio_inr", "angio_ir",
                "stroke_staff", "ed_staff", "angio_staff", "ir", "inr", "angio_staff_night", "ir_night", "inr_night",
                "ed_pt", "st_pt", "ais_pt", "ecr_pt", "inr_pt", "eir_pt", "ir_pt",
                "shifts",
                "nsim", "run_t")
##################
## Shiny inputs ##
##################
simulate_nav <- function(ct = 2, angio_inr = 1, angio_ir = 1,
                         stroke_staff = 1, ed_staff = 10, angio_staff = 10, ir = 1, inr = 1, angio_staff_night = 3, ir_night = 1, inr_night = 1,
                         ed_pt = 107000, st_pt = 750, ais_pt = 450, ecr_pt = 58, inr_pt = 300, eir_pt= 1000, ir_pt = 4000,
                         shifts = c(8,17),
                         nsim = 1, run_t = 10000) {

  ###################
  #Model variables ##
  ###################
  #physical resources
  CT = ct
  ANGIO_INR = angio_inr
  ANGIO_IR  = angio_ir

  #human resources
  ED_STAFF  = ed_staff
  ST_STAFF  = stroke_staff
  ANGIO_STAFF  = angio_staff
  INR       = inr
  IR        = ir
  ANGIO_STAFF_NIGHT  = angio_staff_night
  INR_NIGHT       = inr_night
  IR_NIGHT        = ir_night

  #proportions of stroke pt
  PROB_STROKE = st_pt / ed_pt
  PROB_AIS = ais_pt / st_pt
  PROB_ECR = ecr_pt / ais_pt

  #interarrival t
  year2min = 525600
  I_ED  = round(year2min/ed_pt)
  I_ST  = round(year2min/st_pt)
  I_AIS = round(year2min/ais_pt)
  I_ECR = round(year2min/ecr_pt)
  I_INR = round(year2min/inr_pt)
  I_EIR = round(year2min/eir_pt)
  I_IR  = round(year2min/ir_pt)

  #dayshift start and end
  T_START = shifts[1] * 60
  T_END = shifts[2] * 60

  #sim setup
  RUN_T = run_t * 40320
  N_SIM = nsim

  #######################
  ##model
  #######################
  ecr_traj <-trajectory("ecr trajectory") %>%
    seize("angio_inr", 1) %>%
    seize("inr", 1) %>%
    seize("angio_staff", 3) %>%
    timeout(function() rnorm(1, 120,60)) %>%
    release("angio_inr", 1) %>%
    release("inr", 1) %>%
    release("angio_staff", 3) #%>%

  ais_traj <- trajectory("LVO trajectory") %>%
    # set_attribute("priority", 3) %>%
    # set_prioritization(values = c(3, 3, FALSE)) %>%
    branch(option = function() sample(1:2, 1, prob = c(PROB_ECR, (1-PROB_ECR))),
           continue = c(T,F),
           ecr_traj,

           trajectory("tpa only") %>%
             timeout(1)
    )

  nonstroke_traj <- trajectory(name = "non stroke traj") %>%
    branch(option = function() sample(1:2, 1, prob = c(.9, .1)),
           continue = c(F,F),
           trajectory("discharge path") %>%
             timeout(1) %>%
             leave(prob=1),

           trajectory("ct review") %>%
             seize("ct",1) %>%
             timeout(20) %>%
             release("ct",1) %>%
             leave(prob=1)
    )

  stroke_traj <- trajectory("stroke trajectory") %>%
    set_attribute("priority", 3) %>%
    set_prioritization(values = c(3, 3, FALSE)) %>%

    seize("stroke_doctor",1) %>%
    timeout(function() rnorm(1, 30, 10)) %>%
    release("stroke_doctor",1) %>%

    seize("ct",1) %>%
    timeout(function() rnorm(1, 20,10)) %>%
    release("ct",1) %>%

    branch(option = function() sample(1:2, 1, prob = c(PROB_AIS, (1-PROB_AIS))),
           continue = c(F,T),
           ais_traj,

           trajectory("not ais") %>%
             timeout(1) %>%
             leave(prob =1)
    )

  new_patient_traj <- trajectory(name = "new patient's path") %>%
    seize("ed_staff", 1) %>%
    timeout(function() rnorm(1, 20,10)) %>%
    release("ed_staff", 1) %>%

    branch(option = function() sample(1:2, 1, prob = c(PROB_STROKE, (1-PROB_STROKE) ) ),
           continue = c(F,T),
           stroke_traj,

           nonstroke_traj
    )

  ir_traj <-trajectory("ir traj") %>%
    seize("door", 1)  %>%
    release("door", 1) %>%

    seize("angio_staff", 1) %>%
    timeout(function() rnorm(1, 20,10)) %>%
    release("angio_staff", 1) %>%

    #random, first-available  **#**
    simmer::select(resources = c("angio_ir", "angio_inr"), policy = "shortest-queue") %>%
    seize_selected(amount = 1) %>%
    seize("ir", 1) %>%
    seize("angio_staff", 3) %>%
    timeout(function() rnorm(1, 60,30)) %>%
    release_selected(amount =1) %>%
    release("ir",1) %>%
    release("angio_staff",3)

  inr_traj <-trajectory("inr traj") %>%
    seize("door", 1)  %>%
    release("door", 1) %>%

    seize("angio_staff", 1) %>%
    timeout(function() rnorm(1, 20,10)) %>%
    release("angio_staff", 1) %>%

    seize("angio_inr", 1) %>%
    seize("inr", 1) %>%
    seize("angio_staff", 3) %>%
    timeout(function() rnorm(1, 60,30)) %>%
    release("inr",1) %>%
    release("angio_staff",3) %>%
    release("angio_inr", 1)

  eir_traj <- trajectory("eir traj") %>%
    seize("angio_staff", 1) %>%
    timeout(function() rnorm(1, 20,10)) %>%
    release("angio_staff", 1) %>%

    simmer::select(resources = c("angio_ir", "angio_inr"), policy = "shortest-queue") %>%
    seize_selected(amount = 1) %>%
    seize("angio_staff", 3) %>%
    seize("ir", 1) %>%
    timeout(function() rnorm(1, 60,30)) %>%
    release_selected(amount =1) %>%
    release("ir",1) %>%
    release("angio_staff",3)


  ########################
  ## model simulation   ##
  ########################

  #capacity schedule
  DOOR_SCHEDULE       <- schedule(c(T_START, T_END), c(Inf, 0), period = 1440)
  STAFF_SCHEDULE      <- schedule(c(T_START, T_END), c(ANGIO_STAFF, ANGIO_STAFF_NIGHT), period =1440)
  IR_SCHEDULE         <- schedule(c(T_START, T_END), c(IR, IR_NIGHT), period =1440)
  INR_SCHEDULE        <- schedule(c(T_START, T_END), c(INR, INR_NIGHT), period =1440)

  env <-lapply(1:N_SIM, function(i) {
    simmer() %>%
      add_resource("door", DOOR_SCHEDULE) %>%

      add_resource("ct", capacity = CT) %>%
      add_resource("angio_inr", capacity = ANGIO_INR) %>%
      add_resource("angio_ir", capacity = ANGIO_IR) %>%

      add_resource("ed_staff", capacity = ED_STAFF) %>%
      add_resource("stroke_doctor", capacity = ST_STAFF) %>%
      add_resource("angio_staff", STAFF_SCHEDULE) %>%
      add_resource("inr", INR_SCHEDULE) %>%
      add_resource("ir", IR_SCHEDULE) %>%

      add_generator("pt_ed", new_patient_traj, function() rpois(1, I_ED) ) %>%
      add_generator("pt_inr", inr_traj, function() rpois(1, I_INR) ) %>%
      add_generator("pt_eir", eir_traj, priority = 1, function() rpois(1, I_EIR) ) %>%
      add_generator("pt_ir", ir_traj, function() rpois(1, I_IR) ) %>%

      run(RUN_T) #%>%
    #wrap()
  })

  ########################
  ## return sim output ###
  ########################
  resources <- get_mon_resources(env)
  monArr <- get_mon_arrivals(env, per_resource =TRUE)

  arrivals <- data.frame(get_mon_arrivals(env, per_resource =T)) %>%
    transmute(name,
              resource,
              replication,
              start_time,
              wait_time = end_time - start_time - activity_time) %>%
    mutate(category = gsub("pt_([a-z]+)\\d+","\\1", name))


  arrivalsCounts <- arrivals %>%
    select(name, category, replication) %>%
    group_by(replication) %>%
    unique(.) %>%
    summarize(total = n(),
              totalEd = sum(category == "ed"),
              totalElectInr = sum(category == "inr"),
              totalElectIr = sum(category == "ir"),
              totalEmergIr = sum(category == "eir")
    )

  arrivalsAngioInr <- subset(arrivals, resource == "angio_inr") %>%
    group_by(replication) %>%  #execute subsequent commands for each group
    summarize(total = n(),
              totalStroke = sum(category == "ed"),
              totalElectInr = sum(category == "inr"),
              totalElectIr = sum(category == "ir"),
              totalEmergIr = sum(category == "eir")
    )

  arrivalsAngioIr <- subset(arrivals, resource == "angio_ir") %>%
    group_by(replication) %>%  #execute subsequent commands for each group
    summarize(total = n(),
              totalStroke = sum(category == "ed"),
              totalElectInr = sum(category == "inr"),
              totalElectIr = sum(category == "ir"),
              totalEmergIr = sum(category == "eir")
    )

  print(arrivalsCounts)
  print(arrivalsAngioInr)
  print(arrivalsAngioIr)
  print("")

  list_containing_output <- list(arrivals, resources)

  return(list_containing_output)
}
