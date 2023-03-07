# Erosion_from_detrital_Be10
## 1) The algorithm
This repository includes functions and scripts needed for erosion rate calculation from detrital Be10 concentrations. The core algorithm is from [Lupker et al. 2012](https://doi.org/10.1016/j.epsl.2012.04.020). Please cite the paper if you use the codes here. The core algorithm is presented in the Lupker et al 2012 paper: 
<img width="544" alt="Lupker_2012" src="https://user-images.githubusercontent.com/108676831/223412837-dbad34ec-8fd3-46f6-b9fd-a925d242c051.png">


## 2) Contributors
The implementation of the core algorithm was contributed by Drs Chia-Yu Chen, Erica Erlanger, Richard Ott, and Yanyan Wang. 

## 3) Using it
* Users would need [Topotoolbox](https://topotoolbox.wordpress.com/) in addition to the codes in this repository.
* The script _Erosion_from_detrital_Be10.m_ is the script to calculate erosion rate from inputs. The inputs are Be10 basin DEM, the basin UTM zone, and the measured cosmogenic Be10 concentration and error. The outputs are the erosion rate, standard deviation, and basin-averged production rate of neutrons, fast and slow muons.


## 4) A list of publications applied this algorithm
* [Chen et al. 2020](https://onlinelibrary.wiley.com/doi/full/10.1002/esp.4753)
* [Wang et al. 2021](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2021GC009979)
* [Ott et al. 2019](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2019JF005142)
* More to be added...

## 5) Technical support
Is possible via email to wangyanyan0607@hotmail.com
