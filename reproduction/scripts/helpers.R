# Helper functions for reproduction.qmd


run_model <- function(angio_inr = 1,
                      angio_ir = 1,
                      ir = 2,
                      ed_staff = 10,
                      angio_staff = 6,
                      ed_pt = 107700,
                      ecr_pt = 58,
                      inr_pt = 104,
                      eir_pt= 468,
                      ir_pt = 3805,
                      shifts = c(8,17),
                      run_t = 365,
                      nsim = 30,
                      exclusive_use = FALSE,
                      seed = 42,
                      ed_triage = c(20,10),
                      fig5 = FALSE) {
  #' Run model and get results
  #'
  #' @param angio_inr number of AngioINR machines
  #' @param angio_ir number of AngioIR machines
  #' @param ir number of interventional radiologists on day shift
  #' @param ed_staff number of emergency department staff on 24h shift
  #' @param angio_staff number of angiography staff on day shift
  #' @param ed_pt number of ED patients
  #' @param ecr_pt number of ECR patients
  #' @param inr_pt number of elective INR patients
  #' @param eir_pt number of emergency IR patients
  #' @param ir_pt number of elective IR patients
  #' @param shifts tuple with start and finish time of day shift
  #' @param run_t simulation runtime in days
  #' @param nsim number of replications
  #' @param exclusive_use whether angioINR has exclusive use (i.e. no elective
  #' IR patients allowed to use the machine)
  #' @param seed integer that provides seed to be incremented on in each
  #' replication (e.g. run 1 is seed+=1, run 2 is seed+=2)
  #' @param ed_triage tuple with mean and SD of normal distribution for
  #'sampling the length of the emergency department triage
  #'@param fig5 boolean indicating whether to filter the results as normal or
  #'differently (as different for Figure 5)

  # Run the model
  list_containing_output <- simulate_nav(
    angio_inr = angio_inr,
    angio_ir = angio_ir,
    ir = ir,
    ed_staff = ed_staff,
    angio_staff = angio_staff,
    ed_pt = ed_pt,
    ecr_pt = ecr_pt,
    inr_pt = inr_pt,
    eir_pt = eir_pt,
    ir_pt = ir_pt,
    shifts = shifts,
    run_t = run_t,
    nsim = nsim,
    exclusive_use = exclusive_use,
    seed = seed,
    ed_triage = ed_triage
  )

  # Get arrivals (not interested in resources - list_containing_output[[2]]))
  # Filter to the relevant results (ED + resource and wait_time)
  # OR just return the raw output
  if (isTRUE(fig5)) {
    result <- copy(list_containing_output[[2]]) %>%
      filter(resource=="angio_inr")
  } else {
    result <- data.frame(list_containing_output[[1]]) %>%
      filter(category == "ed") %>%
      select(resource, wait_time)
  }

  return(result)
}


process_f3_data <- function(df5, df6, df7, save_path) {
  #' Process model results to create data for Figure 3
  #'
  #' @param df5 Dataframe with results from model where shifts end at 5pm
  #' @param df6 Dataframe with results from model where shifts end at 6pm
  #' @param df7 Dataframe with results from model where shifts end at 7pm
  #' @param save_path String with path to save results to

  # Add shift time
  df5$shift = "5pm"
  df6$shift = "6pm"
  df7$shift = "7pm"

  # Combine into single dataframe, then filter to just angioINR wait times
  baseline_hours <- dplyr::bind_rows(df5, df6, df7) %>%
    filter(resource == "angio_inr")

  # Save to provided path
  data.table::fwrite(baseline_hours, save_path)
}


import_results <- function(path, scenario) {
  #' Import the file and add a column with the scenario
  #'
  #' @param path path to file to import
  #' @param scenario string to population "scenario" column with
  return(data.table::fread(path) %>% mutate(scenario=scenario))
}


create_plot <- function(df, group, title, xlab="", ylab="", xlim=c(0, 200),
                        breaks_width=50) {
  #' Create sub-plots for Figure 2A
  #'
  #' @param df Dataframe with wait times across replications
  #' @param group String indicating which column to group by in plot
  #' @param title String to use as title for plot
  #' @param xlab String to use as title for X axis
  #' @param ylab String to use as title for Y axis
  #' @param xlim Tuple with limits for x axis
  #' @param breaks_width Integer indicating frequency of X ticks

  # Set negative wait times to 0
  df$wait_time[df$wait_time < 0] <- 0

  # Create the plot, scaling the density estimate to a maximum of 1
  # Remove INR resources as they hide the angio_staff line, which is on top
  # in the figures in the paper
  ggplot(df %>% filter(resource!="inr"),
         aes(x = wait_time,
             colour = .data[[group]],
             y = after_stat(scaled))) +
    geom_density() +
    geom_density(aes(x = wait_time, y = after_stat(scaled))) +
    # Apply square transformation to each axis, removing x points beyond limits
    scale_y_continuous(transform = "sqrt") +
    scale_x_continuous(transform = "sqrt",
                       breaks = scales::breaks_width(breaks_width),
                       limits = xlim,
                       oob = scales::censor,
                       guide = guide_axis(angle=45)) +
    # Titles and styling
    ggtitle(title) +
    xlab(xlab) +
    ylab(ylab) +
    theme_minimal(base_size=10) +
    theme(plot.title = element_text(hjust = 0.5),
          axis.text.x = element_text(colour="black"),
          axis.text.y = element_text(colour="black"),
          legend.title=element_blank()) +
    guides(colour = guide_legend(nrow = 1))
}
