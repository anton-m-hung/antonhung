## list of function arguments
plsda_args <- as.list(pairlist(X=NULL, Y=NULL, ncomp=NULL))
# predict_args <- as.list(pairlist(object=NULL, newdata=NULL, ncomp=NULL))

data_unfiltered <- reactive({
  # This exists so we can retrieve the variable names of the dataset
  out <- get_data(input$dataset, filt = "", arr = "", rows = "", na.rm = FALSE, envir=r_data)
})

data_filtered <- reactive({
  # This is needed to allow interactive elements of the UI to access the subsetted data
  
  # Filters the dataset based on:
  #   1. which visit (visit 1, visit 2, delivery visit)
  #   2. detection method must be LumBAA
  
  # Converts the dataset from long to wide:
  #   1. Each subject has a separate value_reported for every analyte_reported
  #   2. Every analyte_reported becomes a column in the wide dataframe
  
  out <- data_unfiltered()
  # out <- out[which(out[[input$plsda_visitColumn]] == input$plsda_visitName),] # filter visit_name
  # if (input$check_detectmethod == T){
  #   out <- out[which(out[[input$plsda_detectmethod]] %in% input$plsda_detectlevels),]
  #   # out <- out[grep("LumBAA", out[,input$plsda_detectmethod]),] # filter detectmethod == LumBAA
  # }
  
  # if (input$plsda_visitName == "Delivery Visit"){
  # out <- out[which(out[[input$plsda_biosampleColumn]] == input$plsda_biosampleType),]
  # }
  
  for (var in input$plsda_filter_variables) {
    levels_to_keep <- paste0("plsda_", var)
    out <- out[which(out[[var]] %in% input[[levels_to_keep]]), ]
  }

  ### make the data wide instead of long
  out <- reshape(out, 
                 idvar = c("subject_accession"), 
                 timevar = c(input$plsda_analytereported),
                 v.names = input$plsda_valuereported, 
                 direction = "wide")
  names(out) = gsub(paste0(input$plsda_valuereported,"."), "", names(out))
  out
})

## list of function inputs selected by user
plsda_inputs <- reactive({
  plsda_args$ncomp <- input$plsda_ncomp
  plsda_args$X <- data_filtered()[,input$plsda_evars]
  plsda_args$Y <- as.factor(data_filtered()[,input$plsda_rvar])
  plsda_args
})

##############################################################################
##  This section defines all the UI user input objects in the SUMMARY PANEL ##
##############################################################################

my_selectInput <- function(method, id, label, choices, selected, multiple){
  selectInput(
    inputId = paste0(method, "_", id), 
    label = label, 
    choices = choices,
    selected = selected,
    multiple = multiple, 
    size = ifelse(multiple == 10, 10, ifelse(multiple == 5, 5, 1)), 
    selectize = FALSE
  )
}

#--------------------------------------------------------------------------------#
#  This section contains parameters found in the "Preparing the data" wellpanel  #
#--------------------------------------------------------------------------------#

# UI element - selecting which variables the user would like to filter on
output$ui_filter_variables <- renderUI({
  vars <- data_unfiltered() %>% dplyr::select_if(is.character) %>% names()
  # my_selectInput("plsda", "filter_variables", "Select the variables to filter on:", vars, NULL, 10)
  checkboxGroupInput("plsda_filter_variables", "Select the variables to filter on:", vars, NULL)
})


observeEvent(input$plsda_filter_variables, {
  vars <- data_unfiltered() %>% dplyr::select_if(is.character) %>% names()
  lapply(vars, function (var) {
    removeUI(paste0("#ui_", var))
  })

  ui_elements <- lapply(input$plsda_filter_variables,
                        function(var) { 
                          output_name <- paste0("ui_", var)
                          output[[output_name]] <- renderUI({
                            vars <- levels(as.factor(data_unfiltered()[[var]]))
                            my_selectInput("plsda", var, paste0("Filtering on ", var, ":"), vars, vars, 5)
                          }) 
                          
                          tags$div(
                            style = "margin-top: 20px;",
                            uiOutput(output_name),
                          )
                          })
  insertUI(selector = "#ui_filter_variables", where = "afterEnd", ui = ui_elements)
          
})

# UI element - radio button that should be selected if the dataset contains a detection method column
#   and specifies which column of the dataset to use as the detection method
output$ui_check_detectmethod <- renderUI({
  checkboxInput(inputId = "check_detectmethod", label = "Detection method:", value = T)
})
output$ui_choose_detectmethod <- renderUI({
  req(input$check_detectmethod == T)
  vars <- data_unfiltered() %>% dplyr::select_if(is.character) %>% names()
  my_selectInput("plsda", "detectmethod", NULL, vars, "detect_method", F)
})
output$ui_detect_levels <- renderUI({
  req(isTruthy(input$check_detectmethod == T) & isTruthy(input$plsda_detectmethod))
  vars <- levels(as.factor(data_unfiltered()[[input$plsda_detectmethod]]))
  my_selectInput("plsda", "detectlevels", NULL, vars, vars, T)
})

# UI element - radio button that should be selected if the dataset contains a analyte reported column
#   and specifies which column of the dataset to use as the analyte reported
output$ui_check_analytereported <- renderUI({
  checkboxInput(inputId = "check_analytereported", label = "Analyte reported:", value = T)
})
output$ui_choose_analytereported <- renderUI({
  # req(input$check_analytereported == T)
  vars <- data_unfiltered() %>% dplyr::select_if(is.character) %>% names()
  my_selectInput("plsda", "analytereported", "Pull Explanatory Variables from:", vars, "analyte_reported", F)
})

# UI element - radio button that should be selected if the dataset contains a value reported column
#   and specifies which column of the dataset to use as the value reported
output$ui_check_valuereported <- renderUI({
  checkboxInput(inputId = "check_valuereported", label = "Value reported:", value = T)
})
output$ui_choose_valuereported <- renderUI({
  req(input$check_valuereported == T)
  vars <- data_unfiltered() %>% dplyr::select_if(is.numeric) %>% names()
  my_selectInput("plsda", "valuereported", NULL, vars, "value_reported", F)
})

#--------------------------------------------------------------------------------#
#  This section contains parameters found in the "Fitting parameters" wellpanel  #
#--------------------------------------------------------------------------------#
# UI element - Specifies which column to pull visit names from
output$ui_visitColumn <- renderUI({
  vars <- data_unfiltered() %>% dplyr::select_if(is.character) %>% names()
  my_selectInput("plsda", "visitColumn", "Select the column to filter on:", vars, "visit_name", F)
})

# UI element - Specifies which visit name to subset the dataset by
output$ui_visitName <- renderUI({
  req(input$plsda_visitColumn)
  vars <- levels(as.factor(data_unfiltered()[[input$plsda_visitColumn]]))
  radioButtons(inputId = "plsda_visitName", label = NULL, vars, inline = F)
})

# UI element - Specifies which column to pull biosample types from
output$ui_biosampleColumn <- renderUI({
  # req(input$plsda_visitName == "Delivery Visit")
  vars <- data_unfiltered() %>% dplyr::select_if(is.character) %>% names()
  my_selectInput("plsda", "biosampleColumn", "Select the biosample type column:", vars, "biosample_type", F)
})

# UI element - If delivery visit is selected, then there are also options for the biosample type
output$ui_biosampleType <- renderUI({
  # req(isTruthy(input$plsda_visitName == "Delivery Visit") & isTruthy(input$plsda_biosampleColumn))
  req(input$plsda_biosampleColumn)
  vars <- levels(as.factor(data_unfiltered()[[input$plsda_biosampleColumn]]))
  radioButtons(inputId = "plsda_biosampleType", label = NULL, vars, inline = F)
})

# UI element - Selecting which variable to be used as the response variable
output$ui_rvar <- renderUI({
  withProgress(message = "Acquiring variable information", value = 1, {
    chr_vars <- data_filtered() %>% dplyr::select_if(is.character) %>% names()

    # this filters out variables that don't have multiple levels, as they cannot be used as a valid classification set
    vars <- unlist(lapply(chr_vars, function(var) {
      if (nlevels(as.factor(data_filtered()[, var])) > 1) {
        return(var)
      }
    }))
  })
  my_selectInput("plsda", "rvar", "Discriminant variable:", vars, state_single("plsda_rvar", vars), F)
})

# UI element - Selecting which variables to be used as the explanatory variables
output$ui_evars <- renderUI({
  req(data_filtered)
  vars <- data_filtered() %>% dplyr::select_if(is.numeric) %>% names()
  my_selectInput("plsda", "evars", "Explanatory variables:", vars, vars, 10)
})

# UI element - Specifying how many components our output model should include
output$ui_ncomp <- renderUI({
  req(input$plsda_evars)
  slider_max <- length(input$plsda_evars)
  sliderInput(
    "plsda_ncomp", label = "Number of components:", 
    min = 1, max = min(slider_max,20),
    value = min(slider_max,2), step = 1
  )
})

####################################################################################
##  This section defines all the UI user input objects in the CLUSTER PLOT PANEL  ##
####################################################################################
# UI element - enable or disable ellipses drawn on the cluster plot
output$plot_ellipses <- renderUI({
  vars <- c("On" = T, "Off" = F)
  radioButtons(inputId = "plot_ellipses", label = "Ellipses:", vars, inline = TRUE)
})

# UI element - which plsda component to plot on the x-axis
output$plot_comp1 <- renderUI({
  numeric_max = input$plsda_ncomp
  numericInput("plot_comp1", "x component:", 
               min = 1, max = numeric_max, 
               value = 1, step=1)
})

# UI element - which plsda component to plot on the y-axis
output$plot_comp2 <- renderUI({ 
  numeric_max = input$plsda_ncomp
  numericInput("plot_comp2", "y component:", 
               min = 1, max = numeric_max, 
               value = 2, step=1)
})

#####################################################################################
##  This section defines user input objects in the VARIABLE IMPORTANCE PLOT PANEL  ##
#####################################################################################
output$ui_nvip <- renderUI({
  number_max <- length(input$plsda_evars)
  numericInput("plsda_nvip", "Number of variables to display:", 
               min = 1, max = number_max, 
               value = min(number_max, 10), step=1)
})

####################################################################
##  This section defines user input objects in the SUMMARY BODY  ##
####################################################################
output$body_whichsummary <- renderUI({
  req(input$plsda_run)
  vars <- c("call", "X", "Y", "ind.mat", "ncomp", "mode", "variates", "loadings",
            "loadings.star", "names", "tol", "iter", "max.iter", "nzv", "scale",
            "logratio", "prop_expl_var", "input.X", "mat.c")
  
  # my_selectInput("plsda", "whichsummary", "Display a summary of which variable?", vars, "variates", T)
  checkboxGroupInput(inputId = "plsda_whichsummary", label = "Display a summary of which variable?", choices = vars, width = "300px", selected = "variates")
  
})

## add a spinning refresh icon if the map needs to be (re)created
run_refresh(plsda_args, "plsda", init = "x", tabs = "tabs_plsda", label = "Estimate model", relabel = "Re-estimate model")

##############################################################################
##  This section specifies the appearance and layout of the sidebar panels  ##
##############################################################################
output$ui_plsda <- renderUI({
  req(input$dataset)
  tagList(
    conditionalPanel(
      condition = "input.tabs_plsda == 'Summary' || input.tabs_plsda == 'Filtered Data'",
      wellPanel(
        actionButton("plsda_run", "Estimate model", width = "100%", icon = icon("play", verify_fa = FALSE), class = "btn-success")
      ),

    # Displayed in the summary tab, this panel shows options for telling the program which variables to use as the 
    # detectmethod, analytereported and valuereported
    # conditionalPanel(
    #   condition = "input.tabs_plsda == 'Summary'",
      wellPanel(
        tags$p(tags$strong("Preparing the data:")),
        uiOutput("ui_filter_variables"),
        # lapply(input$ui_filter_variables, function(var) {
        #   uiOutput(paste0("plsda_", var))
        # })
        # renderText({paste(input$plsda_filter_variables)})
        # renderText({
        #   paste('If your dataset contains variables that fit the following descriptions, please check the appropriate boxes and select the variables from the dropdown menus:')
        # }),
        # br(),
        # uiOutput("ui_check_detectmethod"),
        # uiOutput("ui_choose_detectmethod"),
        # uiOutput("ui_detect_levels"),
        # # br(),
        # # uiOutput("ui_check_analytereported"),
        # # uiOutput("ui_choose_analytereported"),
        # br(),
        uiOutput("ui_check_valuereported"),
        uiOutput("ui_choose_valuereported")
      ),

      wellPanel(
        tags$p(tags$strong("Fitting Parameters:")),
        # tags$div(
        #   style = "margin-bottom: 20px;",
        #   uiOutput("ui_visitColumn"),
        # ),
        # 
        # tags$div(
        #   style = "margin-bottom: 20px;",
        #   uiOutput("ui_visitName")
        # ),
        # 
        # tags$div(
        #   style = "margin-bottom: 20px;",
        #   uiOutput("ui_biosampleColumn")
        # ),
        # 
        # tags$div(
        #   style = "margin-bottom: 20px;",
        #   uiOutput("ui_biosampleType")
        # ),
        
        tags$div(
          style = "margin-bottom: 20px;",
        uiOutput("ui_rvar")
        ),
        
        uiOutput("ui_choose_analytereported"),
        uiOutput("ui_evars"),
        renderText({paste(length(input$plsda_evars), ' selected')}),
        br(),
        uiOutput("ui_ncomp"),
      ),
      
      # If the selected dataset is not valid, then a warning message is displayed here 
      # conditionalPanel(
      #   condition = "input.tabs_plsda == 'Summary' && input.dataset.indexOf('EXT') == -1",
      #   renderText({
      #     paste('PLSDA is currently not available for the dataset "', input$dataset, '". Only EXT datasets are accepted. They must contain the following variables: "Analyte Reported", "Detect Method", and "Value Reported".')
      #   })
      # ),
      
      # The cluster plot tab displays different plotting parameters in the sidebar
      conditionalPanel(
        condition = "input.tabs_plsda == 'Cluster Plot'",
        tags$p(tags$strong("Plot Parameters:")),
        renderText({"Components to plot:"}),
        uiOutput("plot_comp1"),
        uiOutput("plot_comp2"),
        uiOutput("plot_ellipses"),
      ),
      # The variable importance plot displays different plotting parameters in the sidebar
      conditionalPanel(
        condition = "input.tabs_plsda == 'Variable Importance Plot'",
        tags$p(tags$strong("Plot Parameters:")),
        uiOutput("ui_nvip")
      )
    ),
    help_and_report(
      modal_title = "plsda: Partial Least Squares Discriminant Analysis (PLS-DA)",
      fun_name = "plsda",
      help_file = inclMD(file.path(getOption("radiant.path.multivariate"), "app/tools/help/plsda.md"))
    )
  )
})

output$plsda <- renderUI({
  register_print_output("wrangled_data", ".wrangled_data")
  register_print_output("summary_plsda", ".summary_plsda")
  register_plot_output(
    "plot_plsda", ".plot_plsda",
    # width_fun = "mds_plot_width",
    # height_fun = "mds_plot_height"
  )
  register_plot_output(
    "plot_vip", ".plot_vip",
    # width_fun = "mds_plot_width",
    # height_fun = "mds_plot_height"
  )
  
  plsda_output_panels <- tabsetPanel(
    id = "tabs_plsda",
    tabPanel(
      "Filtered Data",
      verbatimTextOutput("wrangled_data")
    ),
    tabPanel(
      "Summary",
      download_link("dl_plsda_coord"), br(),
      # fluidRow(
      #   column(1, div(style="height:20px;font-size: 35px;"), queryBuilderOutput('querybuilder', width = 1000, height = 300))
      # ),
      # # uiOutput('txtFilterText'),
      # # fluidRow(tableOutput('dt')),
      # # verbatimTextOutput('txtFilterList'),
      # # verbatimTextOutput('txtSQL'),
      uiOutput("body_whichsummary"),
      br(),
      verbatimTextOutput("summary_plsda"),
      # dataTableOutput("plsda_table")
    ),
    tabPanel(
      "Cluster Plot",
      download_link("dlp_plsda"),
      plotOutput("plot_plsda", height = "100%")
    ),
    tabPanel(
      "Variable Importance Plot",
      download_link("dlp_vip"),
      plotOutput("plot_vip", height = "100%"),
    )
  )
  
  stat_tab_panel(
    menu = "Multivariate > PLSDA",
    tool = "PLSDA",
    tool_ui = "ui_plsda",
    output_panels = plsda_output_panels
  )
})

.plsda_available <- reactive({
  if (not_pressed(input$plsda_run)) {
    "** Press the Estimate button to generate maps **"
  } else {
    "available"
  }
})

.plsda <- eventReactive(input$plsda_run, {
  req(input$plsda_rvar)
  withProgress(message = "Generating PLSDA solution", value = 1, {
    plsdai <- plsda_inputs()
    
    ### fitting
    plsda_object <- do.call(mixOmics::plsda, plsdai)

  })
})

.summary_plsda <- reactive({
  if (.plsda_available() != "available") {
    return(.plsda_available())
  }
  # print(dim(unique(data_filtered())))
  # print(data_filtered())
  
  # print(unique(data_unfiltered()[which(data_unfiltered()[["analyte_reported"]] == "FcgR2A131_WI558_HA" & data_unfiltered()[["subject_accession"]] == "SUB8888067"),]))
  
  for (summary in input$plsda_whichsummary) {
    print(.plsda()[summary])
  }
  # print("Input dataset:")
  # print(paste0("Number of subjects: ", nrow(data_filtered())))
  # print(data_filtered())
  
  # print(.plsda()[input$plsda_whichsummary])

})

# .wrangled_data <- renderDataTable({
#     data_filtered()
#   }
#   , options = list(scrollX = TRUE)
#   , escape = FALSE
# )

.wrangled_data <- reactive({
  req(data_filtered())
  print(data_filtered())
})

.plot_plsda <- reactive({
  if (.plsda_available() != "available") {
    return(.plsda_available())
  }
  # req("mds_rev_dim" %in% names(input))
  pda <- .plsda()
  if (is.character(pda)) {
    return(pda)
  }
  withProgress(message = "Generating PLSDA plots", value = 1, {
    # Clustering Plot
    clin2<-c("#E04C5C", "#7DAF4C", "#23AECE")
    x1=pda$variates$X[,input$plot_comp1]
    x2=pda$variates$X[,input$plot_comp2]
    plsdai <- plsda_inputs()
    plotdata=data.frame(x1,x2,Arms=plsdai$Y)
    pp=ggplot(plotdata,aes(x=x1,y=x2,color=Arms))+
      scale_color_manual(values=clin2)+
      geom_point(aes(color=Arms))+
      labs(x=paste0("X-variate ",
                    input$plot_comp1,
                    ": " , 
                    round(pda$prop_expl_var$X[input$plot_comp1]*100, 1), 
                    "% expl.var"), 
           y=paste0("X-variate ",
                    input$plot_comp2,
                    ": " , 
                    round(pda$prop_expl_var$X[input$plot_comp2]*100, 1), 
                    "% expl.var")) +
      ggtitle(paste("PLS-Discriminant Analysis for ", input$plsda_visitName))
    if (input$plot_ellipses){
      pp = pp + stat_ellipse()
    }
    # print(pp)
    # dev.off()
    pp
  })
  
})

.plot_vip <- reactive({
  if (.plsda_available() != "available") {
    return(.plsda_available())
  }
  # req("mds_rev_dim" %in% names(input))
  pda <- .plsda()
  if (is.character(pda)) {
    return(pda)
  }
  withProgress(message = "Generating PLSDA plots", value = 1, {
    
    # Variable Important Plot
    vip = vip(pda)
    vip = vip[order(vip[,1],decreasing = T),]
    top_vars = rownames(vip)[1:input$plsda_nvip]
    plotdata = na.omit(data.frame(x1=vip[,1],x2=vip[,2],feature=rownames(vip)))[1:input$plsda_nvip,]
    plotdata = plotdata[order(plotdata$x1),]
    
    colfunc <- colorRampPalette(c("springgreen", "royalblue"))
    
    # pp = ggplot(plotdata, aes(y=feature, x=x1, fill = feature)) +
    #   geom_bar(stat ="identity") +
    #   scale_fill_brewer(palette="Blues")
    
    barplot(plotdata[,1],
            beside = TRUE, xlim=c(0,1.7*max(plotdata[,1])), col=colfunc(input$plsda_nvip),
            # names.arg = top_vars,
            # las=2,
            main = paste("Variable Importance in the Projection: ", input$plsda_visitName),
            horiz = T)
    if (length(top_vars) <= 25){
      legend("right", 
             # inset = c(-0.35, 0), 
             legend=top_vars, bty="n", fill=rev(colfunc(input$plsda_nvip)), cex=0.8)
    }
    pp = recordPlot()
    pp
  })
})

plsda_report <- function() {
  outputs <- c("summary")
  inp_out <- list(list(dec = 2), "")
  inp <- plsda_inputs()
  # inp$nr_dim <- as.integer(inp$nr_dim)
  # if (length(mpi$rev_dim) > 0) mpi$rev_dim <- as.integer(mpi$rev_dim)
  # mpi <- mds_plot_inputs()
  # inp_out[[2]] <- clean_args(mpi)
  update_report(
    inp_main = clean_args(inp, plsda_args),
    fun_name = "plsda",
    inp_out = inp_out#,
    # fig.width = mds_plot_width(),
    # fig.height = mds_plot_height()
  )
}

# dl_plsda_coord <- function(path) {
#   if (pressed(input$plsda_run)) {
#     .plsda()$res$points %>%
#       (function(x) set_colnames(x, paste0("Dimension", 1:ncol(x)))) %>%
#       write.csv(file = path, row.names = FALSE)
#   } else {
#     cat("No output available. Press the Estimate button to generate results", file = path)
#   }
# }

# download_handler(
#   id = "dl_plsda_coord",
#   fun = dl_plsda_coord,
#   fn = function() paste0(input$dataset, "_plsda_coordinates"),
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

observeEvent(input$plsda_report, {
  r_info[["latest_screenshot"]] <- NULL
  plsda_report()
})

observeEvent(input$plsda_screenshot, {
  r_info[["latest_screenshot"]] <- NULL
  radiant_screenshot_modal("modal_plsda_screenshot")
})

observeEvent(input$modal_plsda_screenshot, {
  plsda_report()
  removeModal() ## remove shiny modal after save
})

output$querybuilder <- renderQueryBuilder({
  queryBuilder(data = data_filtered(), filters = list(list(name = 'mpg', type = 'double', min=1, max=60, step=0.1),
                                              list(name = 'disp', type = 'integer', min=60, step=1),
                                              list(name = 'gear', type = 'integer', input = 'select', values = c(2, 3, 4)),
                                              list(name = 'name', type = 'string'),
                                              list(name = 'nameFactor', type = 'string', input = 'selectize'),
                                              list(name = 'date', type = 'date', mask = 'yy-mm-dd'),
                                              list(name = 'logical', type = 'boolean', input = 'radio'),
                                              list(name = 'carb', type = 'string', input = 'selectize')),
               autoassign = FALSE,
               default_condition = 'AND',
               allow_empty = TRUE,
               display_errors = FALSE,
               display_empty_filter = FALSE,
  )
})

output$txtValidation <- renderUI({
  if(input$querybuilder_validate == TRUE) {
    h3('VALID QUERY', style="color:green")
  } else {
    h3('INVALID QUERY', style="color:red")
  }
})

output$txtFilterText <- renderUI({
  req(input$querybuilder_validate)
  h4(span('Filter sent to dplyr: ', style="color:blue"), span(filterTable(input$querybuilder_out, df.data, 'text'), style="color:green"))
})

output$txtFilterList <- renderPrint({
  req(input$querybuilder_validate)
  input$querybuilder_out
})

output$txtSQL <- renderPrint({
  req(input$querybuilder_validate)
  input$querybuilder_sql
})


output$dt <- renderTable({
  req(input$querybuilder_validate)
  df <- filterTable(input$querybuilder_out, df.data, 'table')
  df$date <- strftime(df$date, format="%Y-%m-%d")
  df
})



################
## Unused stuff
################

# output$ui_probMethod <- renderUI({
#   vars <- c("softmax" = "softmax", "Bayes" = "Bayes")
#   radioButtons(
#     inputId = "plsda_probMethod", label = "Probability method:", vars,
#     selected = state_init("plsda_probMethod", "softmax"),
#     inline = TRUE
#   )
# })