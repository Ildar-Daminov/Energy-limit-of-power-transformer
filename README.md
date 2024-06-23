[![DOI](https://zenodo.org/badge/416073689.svg)](https://zenodo.org/doi/10.5281/zenodo.12510053)
[![DOI:10.1049/gtd2.12036](http://img.shields.io/badge/DOI-10.1049/gtd2.12036-B31B1B.svg)](https://doi.org/10.1049/gtd2.12036)

# Energy limit of oil-immersed transformers: A concept and its application in different climate conditions

This repository shares the MATLAB code and data for the research article :
  
I. Daminov, A. Prokhorov, R. Caire, M-C Alvarez-Herault, [“Energy limit of oil‐immersed transformers: A concept and its application in different climate conditions”](https://doi.org/10.1049/gtd2.12036) in IET Generation, Transmission & Distribution (IF: 2,862, Q1), 2021, 

## Article's abstract
The reality of modern power grids requires the use of flexibilities from generation, load and storage. These flexibilities allow system operators to modify a transformer loading in a smart way. Therefore, power constraints of transformers can be overcome by using the appropriate flexibility. However, transformers have a physical limit of energy transfer which cannot be overpassed. This energy limit represents the unique transformer's loading profile, ensuring the highest energy transfer under a given ambient temperature profile.

The paper explains how the energy limit can be calculated. Typical characteristics of an energy limit are estimated in cold continental climate of Russia and warm temperate climate in France. Maximal, minimal and mean loadings are identified for each month. Loading durations of energy limit are determined for each cooling system. It is found that winding temperatures of transformers, operating at energy limits, remain in the vicinity of design winding temperature. Therefore, transformer operation at energy limit avoids a high temperature stress and simultaneously maximizes the energy transfer.

The application of energy limits for power system problems is briefly explained along the paper. Energy limit application can reduce an energy cost, maximize a renewable generation and increase a hosting capacity of distribution network.

## How to run a code 
There are two ways how you may run this code:
  
I. Launching all calculations at once. This will reproduce all figures in the article but it would take 30 minutes:
1. Copy this repository to your computer 
2. Open the script main.m
3. Launch the script "main.m" by clicking on the button "Run" (usually located at the top of MATLAB bar).\
As alternative, you may type ```main``` 
in Command Window to launch the entire script. 


II. Launching the specific section of the code to reproduce the particular figure: 
1. Copy this repository to your computer 
2. Open the script main.m 
3. Find the section (Plotting the Figure XX) corresponding to the Figure you would like to reproduce. 
4. Put the cursor at any place of this section and click on the button "Run Section" (usually located at the top of MATLAB bar)
  
Attention! The code uses [fcn2optimexpr](https://fr.mathworks.com/help/optim/ug/fcn2optimexpr.html), which becomes available since the version MATLAB 2019a! For previous MATLAB version fcn2optimexpr, as far as we know, does not work

## Files description
Main script:
* main.m - the principal script which launches all calculations
  
Additional functions: 
* approximated_energy_limit.m - this function calculates the approximate energy limit of power transformers
* Convert2minute.m - this function converts data from hour format to minute format e.g. Vector of 24x1 to vector of 1440x1
* distribution_transformer.m - a thermal model of distribution transformer (up to 2.5 MVA) per the loading guide IEC 60076-7
* OD.m - a thermal model of OD power transformer (up to 100 MVA) per the loading guide IEC 60076-7. OD stand for a cooling system : Oil Directed
* OF.m - a thermal model of OF power transformer (up to 100 MVA) per the loading guide IEC 60076-7. OF stand for a cooling system : Oil Forced
* ONAF.m - a thermal model of ONAF power transformer (up to 100 MVA) per the loading guide IEC 60076-7. ONAF stand for a cooling system : Oil Natural Air Forced
* ONAN.m - a thermal model of ONAN power transformer (up to 100 MVA) per the loading guide IEC 60076-7. ONAN stand for a cooling system : Oil Natural Air Natural
  
More details are given inside of functions and script "main.m"

Initial data:
* distribution_transformer_temp_ageing.mat - precalculated data for distrbution transformer (up to 2.5 MVA)
* initial_data.mat - daily load profile + ambient temperature.
* OD_temp_ageing.mat - precalculated data for OD power transformer (up to 100 MVA).  
* OF_temp_ageing.mat - precalculated data for OF power transformer (up to 100 MVA).  
* ONAF_temp_ageing.mat - precalculated data for ONAF power transformer (up to 100 MVA).  
* ONAN_temp_ageing.mat - precalculated data for ONAN power transformer (up to 100 MVA).  
* T_history_Grenoble.mat - historical ambient temperature in Grenoble, France ([weather data](https://www.meteoblue.com/en/historyplus) provided by [meteoblue](https://www.meteoblue.com/))
* T_history_Tomsk.mat - historical ambient temperature in Tomsk, Russia ([weather data](https://www.meteoblue.com/en/historyplus) provided by [meteoblue](https://www.meteoblue.com/))
* Tamb_february_1_2019.mat - profile of ambient temperature 

## How to cite this article 
Ildar Daminov, Anton Prokhorov, Raphael Caire, Marie-Cécile Alvarez-Herault, "Energy limit of oil‐immersed transformers: A concept and its application in different climate conditions". IET Generation, Transmission & Distribution, 15(3), 495-507.  https://doi.org/10.1049/gtd2.12036 

## More about DTR of power transformers 
<img align="left" alt="Coding" width="250" src="https://sun9-19.userapi.com/impg/3dcwjraHJPNgrxtWv7gEjZTQkvv5T0BttTDwVg/e9rt2Xs8Y5A.jpg?size=763x1080&quality=95&sign=7c57483971f31f7009fbcdce5aafd97e&type=album">This paper research is a part of PhD thesis "Dynamic Thermal Rating of Power Transformers: Modelling, Concepts, and Application case". The full text of PhD thesis is available on [Researchgate](https://www.researchgate.net/publication/363383515_Dynamic_Thermal_Rating_of_Power_Transformers_Modelling_Concepts_and_Application_case) or [HAL theses](https://tel.archives-ouvertes.fr/tel-03772184). Other GitHub repositories on DTR of power transformers:
* Article: Assessment of dynamic transformer rating, considering current and temperature limitations. [GitHub repository](https://github.com/Ildar-Daminov/Assessment_Dynamic_Thermal_Rating_of_Transformers)
* Article: Demand Response Coupled with Dynamic Thermal Rating for Increased Transformer Reserve and Lifetime. [GitHub repository](https://github.com/Ildar-Daminov/Demand-response-coupled-with-DTR-of-transformers)
* Conference paper: Optimal ageing limit of oil-immersed transformers in flexible power systems [GitHub repository](https://github.com/Ildar-Daminov/MATLAB-code-for-CIRED-paper)
* Conference paper: Application of dynamic transformer ratings to increase the reserve of primary substations for new load interconnection. [GitHub repository](https://github.com/Ildar-Daminov/Reserve-capacity-of-transformer-for-load-connection)
* Conference paper: Receding horizon algorithm for dynamic transformer rating and its application for real-time economic dispatch. [GitHub repository](https://github.com/Ildar-Daminov/Receding-horizon-algorithm-for-dynamic-transformer-rating)

