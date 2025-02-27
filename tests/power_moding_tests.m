classdef TestBMSControlSystem < matlab.unittest.TestCase
    
    properties (ClassSetupParameter)
        ModelPath = {'../BMS_Control_System.slx'}; % Relative path to model
    end
    
    properties
        ModelName = 'BMS_Control_System'; % Model name without extension
    end
    
    methods (TestClassSetup)
        function loadModel(testCase, ModelPath)
            % Load the model once before all tests
            if ~bdIsLoaded(testCase.ModelName)
                load_system(ModelPath);
            end
            testCase.addTeardown(@() close_system(testCase.ModelName, 0)); % Close when done
        end
    end
    
    methods (Test)
        function testAllInputCombinations(testCase)
            % Test all 64 input combinations and verify binary outputs
            
            % Generate all 6-bit input combinations (64x6 matrix)
            numInputs = 6;
            numCombinations = 2^numInputs;
            inputMatrix = dec2bin(0:numCombinations-1) - '0';
            
            % Preallocate output matrix
            outputMatrix = zeros(numCombinations, 4);
            
            % Simulate for each input combination
            for i = 1:numCombinations
                simIn = Simulink.SimulationInput(testCase.ModelName);
                currentInputs = inputMatrix(i, :);
                simIn = simIn.setBlockParameter([testCase.ModelName '/In1'], 'Value', num2str(currentInputs(1)));
                simIn = simIn.setBlockParameter([testCase.ModelName '/In2'], 'Value', num2str(currentInputs(2)));
                simIn = simIn.setBlockParameter([testCase.ModelName '/In3'], 'Value', num2str(currentInputs(3)));
                simIn = simIn.setBlockParameter([testCase.ModelName '/In4'], 'Value', num2str(currentInputs(4)));
                simIn = simIn.setBlockParameter([testCase.ModelName '/In5'], 'Value', num2str(currentInputs(5)));
                simIn = simIn.setBlockParameter([testCase.ModelName '/In6'], 'Value', num2str(currentInputs(6)));
                
                % Run simulation
                simOut = sim(simIn);
                
                outputMatrix(i, :) = round([simOut.get('Out1') simOut.get('Out2') ...
                                           simOut.get('Out3') simOut.get('Out4')]);
            end
            
            testCase.verifyTrue(all(outputMatrix(:) == 0 | outputMatrix(:) == 1), ...
                'Some outputs are not binary (0 or 1).');
        end
    end
end