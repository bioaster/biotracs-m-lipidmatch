classdef LipidMatchTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/lipidmatch/LipidMatchTests');
    end
    
    methods (Test)
        
        
        function testLipidMatch(testCase)
            feature= biotracs.data.model.DataTable.import('../../../testdata/features_new.csv', 'ReadRowNames', false);
            ms2pos = biotracs.data.model.DataFile(fullfile(pwd, '../../../testdata/ms2Pos/'));
            dsPos = biotracs.data.model.DataFileSet();
            dsPos.add(ms2pos);
            
            ms2neg = biotracs.data.model.DataFile(fullfile(pwd, '../../../../testdata/ms2Neg/'));
            dsNeg = biotracs.data.model.DataFileSet();
            dsNeg.add(ms2neg);

            process = biotracs.lipidmatch.model.LipidMatch();
            c = process.getConfig();
            process.setInputPortData('DataTable', feature);
            process.setInputPortData('NegMs2Path', dsNeg);
            process.setInputPortData('PosMs2Path', dsPos);
            c.updateParamValue('WorkingDirectory', testCase.workingDir);

            process.run();
            result = process.getOutputPortData('DataFileSet');
            result.summary   
        end
        
    end
end