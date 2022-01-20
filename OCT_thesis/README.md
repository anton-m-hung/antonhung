octrun.m is the main file. All other files are called from within octrun.m
Simply type octrun in the matlab command window to open the application GUI

* a sample OCT dataset file is provided here named 1_percent_1.csv *

Here, you can use the listbox to select (an) OCT dataset(s) with the appropriate file format (.csv). Use cmd/ctrl + click to select multiple datasets
OCT datasets are matrices containing log20(e)-transformed intensity values.

Within the GUI, you can set parameters for performing your computation of the attenuation coefficient of a tissue.
Parameters include:
- top and bottom limits of the region of interest (depth)
- size of blocks used for averaging
	- Meaning: the attenuation coefficient is calculated as a line of best fit through every 5x5 pixel block in the intensity image, where the line of best fit is a function of the decrease in intensity over a change in depth.
- you can also select which types of graphs you would like to save, and specify a filename to save the files under
- refractive index of the tissue
- zcf confocal position
- zr releigh length

Once you select your dataset, and all parameters are set, you can choose to perform either a simple beer calculation or modified beer calculation

The ouput (if all checkboxes are selected) include:
1) a figure containing two subplots
	- a) the OCT intensity image
	- b) an attenuation image map, where every pixel represents the attenuation coefficient for every 5x5 pixel block in the original image
		- this is a heatmap more-or-less, where the attenuation coefficient values can be estimated using the colorbar on the right.
2) a plot of intensity and depth (blue)
	- Additionally, the average attenuation coefficient within the region of interest (chosen in the paramters under "Enter parameters") is represented as a red line overlayed onto the graph, where the slope of the red line is equal to the average attenuation coefficient. It represents the decay of intensity as a function of depth.
