## list of function arguments
aov_args <- as.list(formals(aov))

## list of function inputs selected by user
aov_inputs <- reactive({
  ## loop needed because reactive values don't allow single bracket indexing

  for (i in r_drop(names(aov_args))) {
    aov_args[[i]] <- input[[paste0("aov_", i)]]
  }
  aov_args$data <- get_data(input$dataset, filt = "", arr = "", rows = "", na.rm = FALSE, envir=r_data)
  
  evars <- input$aov_evar
  formula <- input$aov_rvar
  for (evar in evars) {
    if (grepl("~", formula)) {
      formula <- paste0(formula, ' + ', evar)
    } else {
      formula <- paste0(formula, ' ~ ', evar)
    }
  }
  aov_args$formula <- as.formula(formula)
  aov_args
})

output$ui_aov_projections <- renderUI({
  vars <- c(TRUE, FALSE)
  selectInput(
    inputId = "aov_projections", label = "Projections:", choices = vars,
    selected = state_single("aov_projections", vars), multiple = FALSE
  )
})

output$ui_aov_qr <- renderUI({
  vars <- c(TRUE, FALSE)
  selectInput(
    inputId = "aov_qr", label = "QR:", choices = vars,
    selected = state_single("aov_qr", vars), multiple = FALSE
  )
})

output$ui_aov_rvar <- renderUI({
  withProgress(message = "Acquiring variable information", value = 1, {
    isNum <- .get_class() %in% c("integer", "numeric", "ts")
    vars <- varnames()[isNum]
  })
  selectInput(
    inputId = "aov_rvar", label = "Response variable:", choices = vars,
    selected = state_single("aov_rvar", vars), multiple = FALSE
  )
})

output$ui_aov_evar <- renderUI({
  req(available(input$aov_rvar))
  vars <- varnames()
  ## don't use setdiff, removes names
  if (length(vars) > 0 && input$aov_rvar %in% vars) {
    vars <- vars[-which(vars == input$aov_rvar)]
  }

  selectInput(
    inputId = "aov_evar", label = "Explanatory variables:", choices = vars,
    selected = state_multiple("aov_evar", vars, isolate(input$aov_evar)),
    multiple = TRUE, size = min(10, length(vars)), selectize = FALSE
  )
})

## add a spinning refresh icon if the map needs to be (re)created
run_refresh(aov_args, "aov", init = "projections", tabs = "tabs_aov", label = "Estimate model", relabel = "Re-estimate model")

output$ui_aov <- renderUI({
  req(input$dataset)
  tagList(
    conditionalPanel(
      condition = "input.tabs_aov == 'Summary'",
      wellPanel(
        actionButton("aov_run", "Estimate model", width = "100%", icon = icon("play", verify_fa = FALSE), class = "btn-success")
      )
    ),
    wellPanel(
      conditionalPanel(
        condition = "input.tabs_aov == 'Summary'",
        uiOutput("ui_aov_rvar"),
        uiOutput("ui_aov_evar"),
        uiOutput("ui_aov_projections"),
        uiOutput("ui_aov_qr")
      ),
    ),
  )
})

# mds_plot_width <- function() {
#   mds_plot() %>%
#     (function(x) if (is.list(x)) x$plot_width else 650)
# }
# 
# mds_plot_height <- function() {
#   mds_plot() %>%
#     (function(x) if (is.list(x)) x$plot_height else 650)
# }

output$aov <- renderUI({
  register_print_output("summary_aov", ".summary_aov")
  
  aov_output_panels <- tabsetPanel(
    id = "tabs_aov",
    tabPanel(
      "Summary",
      download_link("dl_aov_coord"), br(),
      verbatimTextOutput("summary_aov")
    ),
  )
  
  stat_tab_panel(
    menu = "Multivariate > ANOVA",
    tool = "ANOVA",
    tool_ui = "ui_aov",
    output_panels = aov_output_panels
  )
})

.aov_available <- reactive({
  "available"
  # if (not_pressed(input$aov_run)) {
  #   "** Press the Estimate button to generate maps **"
  # } else if (not_available(input$aov_projections) || not_available(input$aov_qr)) {
  #   "Error: triggered the following statement: else if (not_available(input$aov_projections) || not_available(input$aov_qr))" %>%
  #     suggest_data("city")
  # } else {
  #   "available"
  # }
})

.aov <- eventReactive(input$aov_run, {
  req(input$aov_projections)
  withProgress(message = "Generating ANOVA solution", value = 1, {
    aovi <- aov_inputs()
    # print(aovi)
    do.call(aov, aovi)
  })
})

.summary_aov <- reactive({
  if (.aov_available() != "available") {
    return(.aov_available())
  }
  .aov() %>%
    summary(., dec = 2) %>% print()

})

aov_report <- function() {
  outputs <- c("summary")
  inp_out <- list(list(dec = 2), "")
  inp <- aov_inputs()
  # inp$nr_dim <- as.integer(inp$nr_dim)
  # if (length(mpi$rev_dim) > 0) mpi$rev_dim <- as.integer(mpi$rev_dim)
  inp_out[[2]] <- clean_args(mpi)
  update_report(
    inp_main = clean_args(inp, aov_args),
    fun_name = "aov",
    inp_out = inp_out,
    fig.width = mds_plot_width(),
    fig.height = mds_plot_height()
  )
}

# dl_aov_coord <- function(path) {
#   if (pressed(input$aov_run)) {
#     .aov()$res$points %>%
#       (function(x) set_colnames(x, paste0("Dimension", 1:ncol(x)))) %>%
#       write.csv(file = path, row.names = FALSE)
#   } else {
#     cat("No output available. Press the Estimate button to generate results", file = path)
#   }
# }
# 
# download_handler(
#   id = "dl_mds_coord",
#   fun = dl_mds_coord,
#   fn = function() paste0(input$dataset, "_mds_coordinates"),
#   type = "csv",
#   caption = "Save MDS coordinates"
# )
# 
# download_handler(
#   id = "dlp_mds",
#   fun = download_handler_plot,
#   fn = function() paste0(input$dataset, "_mds"),
#   type = "png",
#   caption = "Save MDS plot",
#   plot = .plot_mds,
#   width = mds_plot_width,
#   height = mds_plot_height
# )

observeEvent(input$aov_report, {
  r_info[["latest_screenshot"]] <- NULL
  aov_report()
})

observeEvent(input$aov_screenshot, {
  r_info[["latest_screenshot"]] <- NULL
  radiant_screenshot_modal("modal_aov_screenshot")
})

observeEvent(input$modal_aov_screenshot, {
  aov_report()
  removeModal() ## remove shiny modal after save
})