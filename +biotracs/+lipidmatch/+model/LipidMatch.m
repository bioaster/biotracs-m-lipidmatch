%"""
%biotracs.lipidmatch.model.LipidMatch
%Wrapper of the R script LipiMatch 
%* License: BIOASTER License
%Bioinformatics team, Omics Hub, BIOASTER Technology Research Institute (http://www.bioaster.org), 2018
%"""

classdef LipidMatch < biotracs.core.shell.model.Shell
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = LipidMatch()
            this@biotracs.core.shell.model.Shell();
            this.configType = 'biotracs.lipidmatch.model.LipidMatchConfig';
            
%             enhance inputs specs
            this.addInputSpecs({...
                struct(...
                'name', 'DataTable',...
                'class', 'biotracs.data.model.DataTable' ...
                ), ...
                struct(...
                'name', 'NegMs2Path',...
                'class', 'biotracs.data.model.DataFileSet' ...
                ),...
                struct(...
                'name', 'PosMs2Path',...
                'class', 'biotracs.data.model.DataFileSet' ...
                )...
                });

            % enhance outputs specs
            this.addOutputSpecs({...
                struct(...
                'name', 'DataFileSet',...
                'class', 'biotracs.data.model.DataFileSet' ...
                )...
                });
        end

    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doBeforeRun( this )
            inputDataFile = this.getInputPortData('DataTable');
            neg = inputDataFile.select('WhereColumns', 'Polarity', 'MatchAgainst', 'Neg');
            [ neg ] = this.doRemoveDuplicateFeatures ( neg );
            [~ , ~ , ~ , ~ ]= this.doWriteFeatureByPolarityFile( neg, 'Neg' );
            pos = inputDataFile.select('WhereColumns', 'Polarity', 'MatchAgainst', 'Pos');
            [ pos ] = this.doRemoveDuplicateFeatures ( pos );
            [~ , iId, iMz, iRt ] = this.doWriteFeatureByPolarityFile(pos, 'Pos' );
           
            this.config.updateParamValue('IdColumnIndex', iId);
            this.config.updateParamValue('MzColumnIndex', iMz);
            this.config.updateParamValue('RtColumnIndex', iRt);
            negMs2Path = this.getInputPortData('NegMs2Path');
            negMs2 = negMs2Path.getAt(1).getDirPath();
            negMs2 = regexprep([negMs2, '/'], '(/|\\)+', '//');
            this.config.updateParamValue('Ms2NegPath', negMs2);

            posMs2Path = this.getInputPortData('PosMs2Path');
            posMs2 = posMs2Path.getAt(1).getDirPath();
            posMs2 = regexprep([posMs2, '/'], '(/|\\)+', '//');
            this.config.updateParamValue('Ms2PosPath', posMs2);
        end

        
        function [featureTable] = doRemoveDuplicateFeatures(~, polarityTable)
            rTs = polarityTable.getDataByColumnName('^RtSearchedPrecursor$');
            mZs = polarityTable.getDataByColumnName('^MzSearchedPrecursor$');
            features = strcat(rTs,'_', mZs);
            [~, ia, ~] = unique(  features );
            featureTable= polarityTable.selectByRowIndexes(ia);

        end
        
        function [featureTable, iId, iMz, iRt ] = doWriteFeatureByPolarityFile(this, polarityTable, polarity)
            rTs = polarityTable.getDataByColumnName('RtSearchedPrecursor');
            rTMinute = cellfun(@(x)(str2double(x)/60), rTs);
            [n, ~]= getSize(polarityTable);

            newData = num2cell(transpose([1:n; transpose(rTMinute)]));
            dataTable = biotracs.data.model.DataTable( newData);
            dataTable.setColumnNames({'Id', 'RtMinutes'});

            featureTable = horzcat(dataTable, polarityTable);
            outputDirectoryPath = this.config.getParamValue('WorkingDirectory');
            featureTable.export([outputDirectoryPath, '\feature_', polarity,'.csv'], 'Delimiter', ',')
            iId= featureTable.getColumnIndexesByName('^Id$');
            iMz= featureTable.getColumnIndexesByName('^MzSearchedPrecursor$');
            iRt = featureTable.getColumnIndexesByName('^RtMinutes$');

        end
        

        function [ outputDataFilePath ] = doPrepareInputAndOutputFilePaths( this, ~ )

            outputDirectoryPath = this.config.getParamValue('WorkingDirectory');
            inputDataFilePath = regexprep([outputDirectoryPath, '\'], '(/|\\)+', '//');
            inputDataFilePath = regexprep(inputDataFilePath, '(/|\\)+', '//');
            outputDataFilePath = regexprep([outputDirectoryPath, '/'], '(/|\\)+', '//');
            outputDataFilePath = regexprep(outputDataFilePath, '(/|\\)+', '//');
            
            this.config.updateParamValue('InputFilePath', inputDataFilePath);
            this.config.updateParamValue('OutputFilePath', outputDataFilePath);
        end
        
        function [ n ] = doComputeNbCmdToPrepare( ~ )
           n=1;
        end
        
        function [ mergeIDFile ] = doMergePosAndNegId(this, outputDataFilePaths,outputFileName )
            posIDFilePath = fullfile(strcat(outputDataFilePaths,'../', outputFileName , '/Output/', 'PosIDed.csv'));
            posIDFile = biotracs.data.model.DataTable.import(posIDFilePath{1});
            negIDFilePath = fullfile(strcat(outputDataFilePaths,'../', outputFileName ,  '/Output/', 'NegIDed.csv'));
            negIDFile = biotracs.data.model.DataTable.import(negIDFilePath{1});
            outputDirectoryPath = this.config.getParamValue('WorkingDirectory');
            mergeIDFile = vertmerge(posIDFile, negIDFile);
            workingDir = fullfile(strcat(outputDirectoryPath,'/../', outputFileName, '/Output/'));
            mz = mergeIDFile.getDataByColumnName('^MzSearchedPrecursor$');
            rt = mergeIDFile.getDataByColumnName('^RtSearchedPrecursor$');
            pol = mergeIDFile.getDataByColumnName('^Polarity$');
            
            newRowName = strcat('M', mz, '_T', rt, '_', pol);
            mergeIDFile = mergeIDFile.setRowNames(newRowName);
            
            mergeIDFile.export(fullfile(workingDir{1} ,  'NegPosIDed.csv'));
        end
        
        
        function doRun( this )
            [listOfCmd, outputDataFilePaths, nbOut] = this.doPrepareCommand(); 
            nbCmd = length(listOfCmd);
            cmdout = cell(1,nbOut);
            outputFileName = cell(1,nbOut);
            biotracs.core.parallel.startpool();
            if nbOut == 0
                fprintf('No input data found\n');
            else
                parfor sliceIndex=1:nbCmd
                    outputDataFilePath = outputDataFilePaths{sliceIndex};
                    [~, cmdout{sliceIndex}] = system( listOfCmd{sliceIndex} );
                    [~, outputFileName{sliceIndex}, ~] = fileparts( outputDataFilePath(1:end-2) );
                end
            end
            this.doSetResultAndWriteOutLog(nbOut, outputFileName, listOfCmd, cmdout, outputDataFilePaths);
            this.doMergePosAndNegId(outputDataFilePaths, outputFileName);
        end
    end

end
