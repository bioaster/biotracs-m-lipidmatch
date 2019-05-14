classdef LipidMatchWorkflowTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/lipidmatch/LipidMatchWorkflowTests');
    end
    
    methods (Test)
        
        
        function testLipidMatchWorkflow(testCase)
            
            
            lipidWorkflow = biotracs.lipidmatch.model.LipidMatchWorkflow();
            lipidWorkflow.getConfig()...
                .updateParamValue('WorkingDirectory', testCase.workingDir );
            
            mzFileImporter = lipidWorkflow.getNode('NegRawFileImporter');
            
            mzFileImporter.addInputFilePath( [pwd,'/../../../../tests/testdata/ms2Neg/'] );
            mzFileImporter.getConfig()...
                .updateParamValue('FileExtensionFilter', '.mzXML');
            
            zFileImporter = lipidWorkflow.getNode('PosRawFileImporter');
            
            zFileImporter.addInputFilePath( [pwd,'/../../../../tests/testdata/ms2Pos/'] );
            zFileImporter.getConfig()...
                .updateParamValue('FileExtensionFilter', '.mzXML');
         
            featureTable = lipidWorkflow.getNode('FeatureTableImporter');
            featureTable.addInputFilePath([pwd, '/../../../../tests/testdata/features_new.csv'])
            
            lipidWorkflow.run();
          
            
                
        end
        
    end
end