% BIOASTER
%> @file		LipidMatchWorkflow.m
%> @class		biotracs.lipidmatch.model.LipidMatchWorkflow
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef LipidMatchWorkflow < biotracs.core.mvc.model.Workflow
    
    properties(SetAccess = protected)
        workflow;
    end
    
    methods
        % Constructor
        function this = LipidMatchWorkflow( )
            this@biotracs.core.mvc.model.Workflow();
            this.doLipidMatchWorkflow();
        end
    end
    
    methods(Access = protected)
        
        
        function this = doLipidMatchWorkflow( this )
            %Add FileImporter 'Neg raw'
            negRawFileImporter = biotracs.core.adapter.model.FileImporter();
            this.addNode( negRawFileImporter, 'NegRawFileImporter' );
            
            %Add FileConverter Experiment 'raw' => 'ms2'
            negMzConverter = biotracs.mzconvert.model.Converter();
            negMzConverter.getConfig()...
                .updateParamValue('OutputFormat','ms2') ...
                .updateParamValue('IntensityThreshold', 100); 
            this.addNode( negMzConverter, 'NegMzConvert' );
            
            %Add FileImporter 'Pos raw'
            posRawFileImporter = biotracs.core.adapter.model.FileImporter();
            this.addNode( posRawFileImporter, 'PosRawFileImporter' );
            
            %Add FileConverter Experiment 'raw' => 'ms2'
            posMzConverter = biotracs.mzconvert.model.Converter();
            posMzConverter.getConfig()...
                .updateParamValue('OutputFormat','ms2') ...
                .updateParamValue('IntensityThreshold', 100); 
            
            this.addNode( posMzConverter, 'PosMzConvert' );
            
              %Add FileImporter 'xls'
            inputAdapter = biotracs.core.adapter.model.FileImporter();
            this.addNode( inputAdapter, 'FeatureTableImporter' );
            
               %GroupTableParser
            groupTableParser = biotracs.parser.model.TableParser();
            groupTableParser.getConfig()...
                .updateParamValue('ReadRowNames', false )...
                .updateParamValue('TableClass', 'biotracs.data.model.DataTable' );
            
            this.addNode( groupTableParser, 'IdentifTableParser' );
            
            % Add Demux adapter
            groupTableParserDemux = biotracs.core.adapter.model.Demux();
            groupTableParserDemux.getOutput()...
                .resize(1, 'biotracs.data.model.DataTable')...
                .setIsResizable(false);
            this.addNode( groupTableParserDemux, 'MetaParserDemux' );
            
            %Add FeatureFinder 'mzML' => 'featureXML'
            lipidMatch = biotracs.lipidmatch.model.LipidMatch();
            this.addNode( lipidMatch, 'LipidMatch' );

            
            negRawFileImporter.getOutputPort('DataFileSet').connectTo( negMzConverter.getInputPort('DataFileSet') );
            posRawFileImporter.getOutputPort('DataFileSet').connectTo( posMzConverter.getInputPort('DataFileSet') );

            inputAdapter.getOutputPort('DataFileSet').connectTo( groupTableParser.getInputPort('DataFile'));
            groupTableParser.getOutputPort('ResourceSet').connectTo( groupTableParserDemux.getInputPort('ResourceSet'));
            
            groupTableParserDemux.getOutputPort('Resource').connectTo( lipidMatch.getInputPort('DataTable') );
            negMzConverter.getOutputPort('DataFileSet').connectTo( lipidMatch.getInputPort('NegMs2Path') );
            posMzConverter.getOutputPort('DataFileSet').connectTo( lipidMatch.getInputPort('PosMs2Path') );
            
        end
        
    end
end
    
