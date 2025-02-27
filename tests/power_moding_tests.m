% Step 1: Generate input combinations
numInputs = 6;
numCombinations = 2^numInputs;
inputMatrix = dec2bin(0:numCombinations-1) - '0';


modelPath = '../BMS_Control_System.slx';
modelName = 'BMS_Control_System';
load_system(modelPath);

% Step 3: Simulate all combinations
outputMatrix = zeros(numCombinations, 4);
for i = 1:numCombinations
    simIn = Simulink.SimulationInput(modelName);
    currentInputs = inputMatrix(i, :);
    simIn = simIn.setBlockParameter([modelName '/In1'], 'Value', num2str(currentInputs(1)));
    simIn = simIn.setBlockParameter([modelName '/In2'], 'Value', num2str(currentInputs(2)));
    simIn = simIn.setBlockParameter([modelName '/In3'], 'Value', num2str(currentInputs(3)));
    simIn = simIn.setBlockParameter([modelName '/In4'], 'Value', num2str(currentInputs(4)));
    simIn = simIn.setBlockParameter([modelName '/In5'], 'Value', num2str(currentInputs(5)));
    simIn = simIn.setBlockParameter([modelName '/In6'], 'Value', num2str(currentInputs(6)));
    simOut = sim(simIn);
    outputMatrix(i, :) = round([simOut.get('Out1') simOut.get('Out2') simOut.get('Out3') simOut.get('Out4')]);
end

% Step 4: Verify binary outputs
if any(outputMatrix(:) ~= 0 & outputMatrix(:) ~= 1)
    error('Outputs contain non-binary values after rounding.');
end

% Step 5: Display results
disp('Input Combinations | Outputs');
disp([inputMatrix outputMatrix]);
save('test_results.mat', 'inputMatrix', 'outputMatrix');

% Step 6: Clean up
close_system(modelName, 0);
