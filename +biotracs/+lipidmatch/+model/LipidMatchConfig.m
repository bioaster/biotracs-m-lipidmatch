% BIOASTER
%> @file		LipidMatchConfig.m
%> @class		biotracs.lipidmatch.model.LipidMatchConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018


classdef LipidMatchConfig < biotracs.core.shell.model.ShellConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
		  %> @param[in] iInstrument The instrument of which this configuration is addressed
		  function this = LipidMatchConfig( )
				this@biotracs.core.shell.model.ShellConfig( );
                this.updateParamValue('ExecutableFilePath', biotracs.core.env.Env.vars('RExecutableFilePath'));
                this.createParam('RScript', [' --vanilla "' , biotracs.core.env.Env.vars('LipidMatchFilePath'), '"'], 'Constraint', biotracs.core.constraint.IsText());
                this.createParam('RtWindow', 1, 'Constraint', biotracs.core.constraint.IsNumeric(), ...
                    'Description', 'Retention Time plus or minus');
				this.createParam('PpmWindow',10, 'Constraint', biotracs.core.constraint.IsNumeric(), ...
                    'Description', 'parts-per-million window for matching the m/z of fragments obtained in the library to those in experimentally obtained');
                this.createParam('PrecursorMassAccuracy', 0.005, 'Constraint', biotracs.core.constraint.IsNumeric(),...
                    'Description', 'Tolerance for mass-to-charge matching at ms1 level (Window)');
                this.createParam('SelectionAccuracy', 0.4, 'Constraint', biotracs.core.constraint.IsNumeric(), ...
                    'Description', 'Plus minus range for the mass given after targeting parent ions portrayed in excalibur to match exact mass of Lipid in library');
                this.createParam('LoQ', 1000, 'Constraint', biotracs.core.constraint.IsNumeric(), ...
                    'Description', 'Threshold for determining that the average signal intensity for a given MS/MS ion should be used for confirmation');
				this.createParam('IdColumnIndex', 1, 'Constraint', biotracs.core.constraint.IsNumeric(), ...
                    'Description','index of idColumn');
				this.createParam('MzColumnIndex', 8, 'Constraint',biotracs.core.constraint.IsNumeric(), ...
                    'Description','index of  MzColumn');
				this.createParam('RtColumnIndex', 10 ,'Constraint', biotracs.core.constraint.IsNumeric(), ...
                   'Description','index of rtColumn in minutes' );
				this.createParam('RowStartDataIndex',2 ,'Constraint', biotracs.core.constraint.IsNumeric(), ...
                    'Description','index of RowStartData');
                this.createParam('ScanCutOff', 1, 'Constraint', biotracs.core.constraint.IsNumeric(), ...
                    'Description', 'The minimum number of scans required for the result to be a confirmation');
                this.createParam('LipidLibraryPath', biotracs.core.env.Env.vars('LipidMatchLibraryPath'),...
                    'Constraint', biotracs.core.constraint.IsText(), ...
                    'Description', 'Input Directory for Libraries ...must have \\ (double backslash) at the end of the directory');
                 
%                 this.createParam('LipidLibraryPath', strcat(biotracs.core.env.Env.externalDir,'/R/LipidMatch/v2/LipidMatch_Libraries_acetate//'),...
%                     'Constraint', biotracs.core.constraint.IsText(), ...
%                     'Description', 'Input Directory for Libraries ...must have \\ (double backslash) at the end of the directory');
               this.createParam('Ms2PosPath', '',...
                    'Constraint', biotracs.core.constraint.IsPath(), ...
                    'Description', 'Input Directory for Ms2 Files in Positive mode ...must have \\ (double backslash) at the end of the directory');
                this.createParam('Ms2NegPath', '',...
                    'Constraint', biotracs.core.constraint.IsPath(), ...
                    'Description', 'Input Directory for Ms2 Files in Negative mode ...must have \\ (double backslash) at the end of the directory');
               
                c = this.getParam('InputFilePath').getConstraint();
                c.setApplyFilter(false);
                c = this.getParam('Ms2NegPath').getConstraint();
                c.setApplyFilter(false);
                c = this.getParam('Ms2PosPath').getConstraint();
                c.setApplyFilter(false);
                
                c = this.getParam('WorkingDirectory').getConstraint();
                c.setApplyFilter(false);
                
                this.optionSet.addElements(...
                    'RScript', biotracs.core.shell.model.Option('%s'),...
                    'InputFilePath',        biotracs.core.shell.model.Option('-i "%s"'), ...
                    'Ms2PosPath',        biotracs.core.shell.model.Option('-k "%s"'), ...
                    'Ms2NegPath',        biotracs.core.shell.model.Option('-n "%s"'), ...
                    'WorkingDirectory',     biotracs.core.shell.model.Option('-o "%s"'), ...
                    'RtWindow',  biotracs.core.shell.model.Option('-r %g%'), ...
                    'PpmWindow',         biotracs.core.shell.model.Option('-p %g'), ...
                    'PrecursorMassAccuracy',         biotracs.core.shell.model.Option('-m %g'), ...
                    'SelectionAccuracy',   biotracs.core.shell.model.Option('-a  %g'), ...
                    'LoQ',            biotracs.core.shell.model.Option('-q %g'), ...
                    'IdColumnIndex',              biotracs.core.shell.model.Option('-d %g'), ...
                    'MzColumnIndex',            biotracs.core.shell.model.Option('-z %g'), ...
                    'RtColumnIndex',              biotracs.core.shell.model.Option('-t %g'), ...
                    'RowStartDataIndex', biotracs.core.shell.model.Option('-w %g'), ...
                    'ScanCutOff',          biotracs.core.shell.model.Option('-s %g'), ...
                    'LipidLibraryPath',      biotracs.core.shell.model.Option('-l "%s"') ...
                );
            

            
          end

	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
     
     methods(Access = protected)
  
      
         
     end

end
