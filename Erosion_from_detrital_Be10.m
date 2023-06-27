% This script use cosmogenic nuclide concentration to calculate
% conventional erosion rate
% Author: yanyan.wang@erdw.ethz.ch


clear; close all

%% Inputs
% 1) UTM zone of the detrital Be10 basin
ZONE = -22; % UTM zone number, for south hemisphere, use negative value

% 2) to prepare DEM 
demtxt = 'MDG_1122C1.tif' ; %  DEM file name
DEM = GRIDobj(demtxt); % convert to GRIDobj
cs = DEM.cellsize; % cellsize of DEM
IDnan =find(~isnan(DEM.Z));% index of non-nan data point


% 3) Be10 concentration and error of this basin
conc = 2e5; % concentration, atoms/gram of quartz
conc_std = 1e4; % error of concentration, atoms/gram of quartz

% 4) shielding flag, 0 or 1. 0-not correct for shielding. 1-correct for
% shielding. Check DiBiase 2018 ESurf paper to see if shielding should be
% applied to your detrital Be10 basin.
shielding_flag = 0;

%% calculate production 
% UTM zone of DEM, for south hemisphere, use negative values
production = CNP(DEM, ZONE, 0); % this step will take some time, please be patient

%% Constants accepted in the community, DON'T change unless for good reasons.
rho_rock = 2.65; % density of rock, [g/cm^3]
attN = 160; %Spallation attenuation length (Braucher et al., 2011) [g/cm2]
attMs = 1500; % Slow muons attenuation length (Braucher et al., 2011) [g/cm2]
attMf = 4320;% Fast muons attenuation length (Braucher et al., 2011) [g/cm2]

muN=attN/rho_rock;
muMs=attMs/rho_rock;
muMf=attMf/rho_rock;

%% calculate erosio rate
M_Be = muN*sum(production.neutron.Z(:),'omitnan')*cs^2+muMs*sum(production.smuon.Z(:),'omitnan')*cs^2+ ...
       muMf*sum(production.fmuon.Z(:),'omitnan')*cs^2; % total atoms equation
   
erosion = (1/conc*M_Be./(length(IDnan)*cs^2)*1e+4); % conventional "erosion rate", [m/Myr]


%% calculate 1 sigma of uncertainty of erosion rate

% Randomly selected number
n_rand=1e4; % number of simulations
C_rand=truncnormrnd([n_rand,1],conc,conc_std,0,inf);
Pn = mean(production.neutron.Z(:),'omitnan');
Pms = mean(production.smuon.Z(:),'omitnan');
Pmf = mean(production.fmuon.Z(:),'omitnan');
IDnan =find(~isnan(production.neutron.Z));% index of non-nan data point
PnStd=sqrt((Pn*0.025).^2+(Pn*0.09).^2);
Pn_rand=truncnormrnd([n_rand,1],Pn,PnStd,0,inf); % random spallation prod rate
    
% Propagation of Uncertainties for production by muons (50%), added to scaling scheme (9%)
PmsStd=sqrt((Pms*0.5).^2+(Pms*0.09).^2);
Pms_rand=truncnormrnd([n_rand,1],Pms,PmsStd,0,inf); % random slow muon prod rate

PmfStd=sqrt((Pmf*0.5).^2+(Pmf*0.09).^2);
Pmf_rand=truncnormrnd([n_rand,1],Pmf,PmfStd,0,inf); % random fast muon prod rate

% Propagation of Uncertainties to total cosmo nuclides atoms 
M_Be_rand = (muN*Pn_rand+muMs*Pms_rand+muMf*Pmf_rand)*cs^2*length(IDnan);

% (2) calculate uncertainty for conventional erosion rate: fluxVertical
VTCrate_avg = zeros(length(erosion),length(C_rand));  
VTCRate1Std_low = zeros(size(erosion));
VTCRate1Std_up = zeros(size(erosion));
for i = 1:length(erosion)
    
    for j=1:n_rand
        if C_rand(j)~=0
            VTCrate_avg(i,j)=(1/C_rand(j))*M_Be_rand(j)./(length(IDnan)*cs^2)*1e+4;
          
        end
    end
    
    % generate production rate function and find upper and lower uncertainty
    VTCrate_means=VTCrate_avg(i,:);  % simulated rates for a sample
    VTCrate_d = erosion(i);       % rate calculated from the measured concentration and given prod rates

    VTCmax_r=min(max(VTCrate_means),1e+4); % max simulated rate
    VTCmin_r=min(VTCrate_means);         % min simulated rate)

    x = linspace(VTCmin_r,VTCmax_r, 3000); % generate 3000 points in between min_r and max_r
    pd=fitdist(VTCrate_means.','kernel');

    y=pdf(pd,x);

    %calculate cumulative distribution function for specified distribution
    mcdf=cdf(pd,x);
    [~,ind]=min(abs(x-VTCrate_d)); 

    % find the one standard deviation
    mid_cdf=mcdf(1,ind); 
    VTClow_cdf=mid_cdf-0.34; % 1 sigma 
    VTCup_cdf=mid_cdf+0.34;  % 1 sigma

    [~,ind]=min(abs(mcdf-VTClow_cdf));
    VTClow_std=VTCrate_d-x(1,ind);

    [~,ind]=min(abs(mcdf-VTCup_cdf));
    VTCup_std=x(1,ind)-VTCrate_d;
    VTCRate1Std_low(i) = VTClow_std;
    VTCRate1Std_up(i) = VTCup_std;
end

%% Summary of data
% erosion rate and the -sigma, +sigma
rate = [erosion VTCRate1Std_low VTCRate1Std_up ];

% mean surface production rate of neutrons, slow muons and fast mouns
P0 = [sum(production.neutron.Z(:),'omitnan'), sum(production.smuon.Z(:),'omitnan'),sum(production.fmuon.Z(:),'omitnan') ]/sum(IDnan(:));

% basin area
basinArea =  length(IDnan(:))*cs^2/1e6; % km2


