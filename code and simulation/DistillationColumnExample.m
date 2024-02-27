

s = tf('s');
G = [87.8 -86.4 ; 108.2 -109.6]/(75*s+1);
G.InputName = {'L','V'};
G.OutputName = {'xD','xB'};


open_system('rct_distillation')
%%set block
ST0 = slTuner('rct_distillation',{'PI_L','PI_V','DM'});
%%add element to the block ST0
addPoint(ST0,{'r','dL','dV','L','V','y'})

%% crossover frequency should be approximately 2/4 = 0.5 rad/min.
wc = 0.5;

%%set the goal overshoot <15%, rejection damped in 20 minutes, amplitude<4
OS = TuningGoal.Overshoot('r','y',15);

DR = TuningGoal.StepRejection({'dL','dV'},'y',4,20);

%%  use |looptune| to tune the controller blocks |PI_L|, |PI_V|

Controls = {'L','V'};
Measurements = 'y';
[ST,gam,Info] = looptune(ST0,Controls,Measurements,wc,OS,DR);

%%plot graph in 40s with setpoint
figure
Ttrack = getIOTransfer(ST,'r','y');
step(Ttrack,40), grid, title('Setpoint tracking')

%%plot graph in 40s with disturbance
figure
Treject = getIOTransfer(ST,{'dV','dL'},'y');
step(Treject,40), grid, title('Disturbance rejection')

%% get parameter of controller form tuning
getBlockValue(ST,'PI_V')
getBlockValue(ST,'PI_L')


