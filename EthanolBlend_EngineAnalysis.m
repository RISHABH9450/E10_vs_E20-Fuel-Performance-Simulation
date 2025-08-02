% ------------------------------------------------------------
% Project: E10 vs E20 Fuel Performance Simulation
% Author: Rishabh Singh
% Date: 2025-08-02
% Description:
%   Comparative simulation of engine performance using E10 and E20 fuels
%   in spark-ignition engines. Models brake power, torque, BSFC, and
%   thermal efficiency with realistic volumetric efficiency and
%   brake thermal efficiency variations. Adds Gaussian noise to emulate
%   real-world dynamometer data and exports plots.
% ------------------------------------------------------------

clc; clear; close all;

% ---------------- ENGINE PARAMETERS ----------------
CR = 10;              % Compression ratio
Bore = 0.08;          % m
Stroke = 0.09;        % m
RPM = 1000:500:5000;  % Engine speed range
Vs = (pi/4) * Bore^2 * Stroke; % Swept volume (m^3)

% ---------------- FUEL PROPERTIES ----------------
% E10
LHV_E10 = 43.54e6; % J/kg
AFR_E10 = 14.1;

% E20
LHV_E20 = 41.93e6; % J/kg
AFR_E20 = 13.5;

% Preallocate results
BP_E10 = zeros(size(RPM)); BP_E20 = zeros(size(RPM));
T_E10 = zeros(size(RPM));  T_E20 = zeros(size(RPM));
BSFC_E10 = zeros(size(RPM)); BSFC_E20 = zeros(size(RPM));
eta_E10 = zeros(size(RPM)); eta_E20 = zeros(size(RPM));

% ---------------- SIMULATION LOOP ----------------
for i = 1:length(RPM)
    
    % Volumetric efficiency drop at low & high RPM
    VE = 0.90 - 0.000002*(RPM(i) - 3000)^2; 
    if VE < 0.7, VE = 0.7; end
    
    % Air mass flow rate (kg/s)
    maf = (RPM(i)/2) * Vs * 1.225 * VE;
    
    % Fuel mass flow rate
    mf_E10 = maf / AFR_E10;
    mf_E20 = maf / AFR_E20;
    
    % Thermal efficiency variation with RPM
    eta10 = 0.32 - 0.0000025*(RPM(i) - 3000)^2; 
    eta20 = 0.33 - 0.0000020*(RPM(i) - 3000)^2; 
    if eta10 < 0.25, eta10 = 0.25; end
    if eta20 < 0.26, eta20 = 0.26; end
    
    % Brake Power (kW)
    BP_E10(i) = (mf_E10 * LHV_E10 * eta10) / 1000;
    BP_E20(i) = (mf_E20 * LHV_E20 * eta20) / 1000;
    
    % Torque (Nm)
    T_E10(i) = (BP_E10(i) * 9550) / RPM(i);
    T_E20(i) = (BP_E20(i) * 9550) / RPM(i);
    
    % BSFC (g/kWh)
    BSFC_E10(i) = (mf_E10 * 3600) / BP_E10(i);
    BSFC_E20(i) = (mf_E20 * 3600) / BP_E20(i);
    
    % Store efficiencies
    eta_E10(i) = eta10;
    eta_E20(i) = eta20;
end

% ---------------- ADD EXPERIMENTAL NOISE ----------------
rng(1); % For reproducibility
noise_factor = 0.02; % 2% variation

BP_E10 = BP_E10 .* (1 + noise_factor*randn(size(BP_E10)));
BP_E20 = BP_E20 .* (1 + noise_factor*randn(size(BP_E20)));
T_E10 = T_E10 .* (1 + noise_factor*randn(size(T_E10)));
T_E20 = T_E20 .* (1 + noise_factor*randn(size(T_E20)));
BSFC_E10 = BSFC_E10 .* (1 + noise_factor*randn(size(BSFC_E10)));
BSFC_E20 = BSFC_E20 .* (1 + noise_factor*randn(size(BSFC_E20)));
eta_E10 = eta_E10 .* (1 + noise_factor*randn(size(eta_E10)));
eta_E20 = eta_E20 .* (1 + noise_factor*randn(size(eta_E20)));

% ---------------- PLOTTING ----------------
fig = figure('Position', [100 100 1000 800]);

subplot(2,2,1);
plot(RPM, BP_E10, 'r-o', RPM, BP_E20, 'b-s', 'LineWidth', 1.5);
xlabel('RPM'); ylabel('Brake Power (kW)');
legend('E10','E20'); title('Brake Power vs RPM'); grid on;

subplot(2,2,2);
plot(RPM, T_E10, 'r-o', RPM, T_E20, 'b-s', 'LineWidth', 1.5);
xlabel('RPM'); ylabel('Torque (Nm)');
legend('E10','E20'); title('Torque vs RPM'); grid on;

subplot(2,2,3);
plot(RPM, BSFC_E10*1000, 'r-o', RPM, BSFC_E20*1000, 'b-s', 'LineWidth', 1.5);
xlabel('RPM'); ylabel('BSFC (g/kWh)');
legend('E10','E20'); title('BSFC vs RPM'); grid on;

subplot(2,2,4);
plot(RPM, eta_E10*100, 'r-o', RPM, eta_E20*100, 'b-s', 'LineWidth', 1.5);
xlabel('RPM'); ylabel('Thermal Efficiency (%)');
legend('E10','E20'); title('Thermal Efficiency vs RPM'); grid on;

% ---------------- EXPORT ----------------
saveas(fig, 'E10_E20_PerformanceGraphs.png');
print(fig, 'E10_E20_PerformanceGraphs', '-dpdf', '-bestfit');

disp('Simulation complete. Graphs saved as PNG and PDF.');
