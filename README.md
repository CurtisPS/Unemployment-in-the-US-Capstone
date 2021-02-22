# Unemployment-in-the-US-Capstone

Capstone project for the Data Science Specialist Track at Bay Path University

All unemployment data was collected from the U.S. Bureau of Labor Statistics. S&P 500 data was collected from Yahoo! Finance.

Please refer to the YouTube link for a presenation on the data contained in this module and the link to the Tableau visualizations.

YouTube:

Tableau:

NOTE: Files titled "Macro of Industry MoM with comparions2000-2019", "Macro of States MoM with comparions2000-2019", "Master Correlation", and "Master CorrelationRI" are the files to be used to explore the data and should be used in conjunction with the Tableau visualizations. All other files may be used to review my code and calculations.

Description of files

Original data files across full time frames that were preprocessed and condensed for the final analysis.

All States Percent Date: This file contains the original data for all the states across the full timeframe, as well as some minor preprocessing to get more specific unemployment percentages for the states as well as the US as a whole. This is saved as a macro enabled workbook. The code for the preprocessing can be found there.

SandP 500 Month: This file is the original data for the monthly closing price of the S&P 500 across the full timeframe.

Industry: This file is the original data for unemployment for 17 different industries in the US for the full timeframe. More granular data than just the percent is not available.

States MoM Calculations: This file shows the calculations for the month over month change for all the states and the United States as a whole.

States MoM for R.csv: This is just the “States MoM Calculations” that was put in csv format for R for anyone who wants to run the R code on their own.
The remainder of these files have had the timeframe reduced to at least 2000-2019. More details are provided for each file. 

MasterData2000-2019: All data (S&P 500 and US, State, and Industry Unemployment) from 2000-2019. Month over month data was also calculated here by taking each month, subtracting from the previous month, and dividing by the previous month. The structure of the columns is row 1: Date, 2: UNITED STATES, 3:S&P 500, 4-55: States, 56-72: Industry, 73-77:States by region.

Macro of States MoM with comparison2000-2019 and Macro of Industry MoM with comparison2000-2019: This macro creates a Euclidian distance matrix for each state and the US as a whole, or the industries in the US. The higher the number on the final tab, the more dissimilar the two pieces are. This is incredibly useful for seeing which states and industries are most dissimilar to each other and the US overall.

Industry2000-2019.xlsx and Industry2000-2019.csv: Industry data edited to only be from 2000-2019. Used in the Capstone Complete.R file.

Master Correlation: This is the correlation coefficient taken from R for data between the S&P 500, overall US Unemployment data, all states, and all 17 industries from the data from 2000-2019. How this was created can be found in the “Capstone Complete” R file.

Capstone Complete.R : This is the R file that contains everything I did in one file. I have broken it down into sections and lines

Overall US Unemployment Analysis (lines 1-211):

	Lines 1-62: Data analysis and visualization

	Lines 64-121: Basic forecasting methods

	Lines 122-127: Check if Box-Cox transformation is worthwhile. It isn’t as there is no constant in the data.
	
	Lines 128-178: Additional forecasting methods. ARIMA turns out the best.
	
	Lines 179-190: Check for data differencing and seasonality and replot.
	
	Lines 190-211: ARIMA modeling.
	
Industry Decomposition and Visuals

	Lines 220-276: Create time series datasets.
	
Lines 277-429: Decompose each time series, view seasonal data, and see if it should be differenced normally or for seasonal differencing.

Industry Dendrogram

	Lines 435-457
	
State Dendrogram

	Lines 461-482
	
Correlation Coefficients

Lines 485-500: Reads in all the data on one sheet and extracts correlation coefficients. This will also save the code to your desired location.

Correlation Coefficients across states, industries, and states and industry combined

	Lines 501-521
	
PCA Analysis

	Lines 526-546: PCA for all data
	
	Lines 548-574: PCA for states
	
	Lines 577-598: PCA for industry
	
	Lines 600-621: PCA for region
	
Correlation Coefficients for Region and Industry

	Lines 623-645: Create correlation plot and dot plot for region and industry
	
PCA revisited for Region and Industry combined

	Lines 647-668
	
Heat Maps for All Data

	Lines 671-700

	

Complete Industry Name	                                   Abbreviation

Nonagriculture Industries----------------------------------Non-Agriculture

Mining, quarrying, and oil and gas extraction--------------Mining

Construction-----------------------------------------------Construction

Manufacturing----------------------------------------------Manufacturing

Durable Goods Manufacturing--------------------------------Durable Goods

Nondurable Goods Manufacturing-----------------------------Nondurable Goods

Wholesale and retail trade---------------------------------Wholesale

Transportation and Utilities-------------------------------Transport

Information------------------------------------------------Info

Financial Activities---------------------------------------Finance

Professional and Business Services-------------------------Professional Services

Education and Health Services------------------------------Health and Edu

Leisure and Hospitality------------------------------------Leisure

Other Services---------------------------------------------Other

Agriculture, forestry, fishing, and hunting----------------Agriculture

Government Wage and Salary Workers-------------------------Government

Self-employed unincorporated, and unpaid family workers----Self-Employed
