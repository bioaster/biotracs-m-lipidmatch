%"""
%Unit tests for biotracs.lipidmatch.*
%* License: BIOASTER License
%Bioinformatics team, Omics Hub, BIOASTER Technology Research Institute (http://www.bioaster.org), 2018
%"""

function testLipidMatch( cleanAll )
    if nargin == 0 || cleanAll
        clc; close all force;
        restoredefaultpath();
    end

    addpath('../../');
    autoload( ...
        'PkgPaths', {fullfile(pwd, '../../../../')}, ...
        'Dependencies', {...
            'biotracs-m-lipidmatch', ...
        } ...
    );

    %% Tests
    import matlab.unittest.TestSuite;
    Tests = TestSuite.fromFolder('./', 'IncludingSubfolders', true);
%     Tests = TestSuite.fromFile('./model/LipidMatchWorkflowTests.m');
%     Tests = TestSuite.fromFile('./model/LipidMatchTests.m');

    Tests.run();
end