function fl = fluorophoreSet(fl,param,val,varargin)

% fl = fluorophoreSet(fl,param,val,...)
% 
% The setter method of the fluorophore object. This function is used to
% set a property of the fluorophore object defined by param to a new value 
% given in val.
%
% Examples:
%   fl = fluorophoreSet(fl,'name','Alexa Fluor');
%   fl = fluorophoreSet(fl,'wave',400:2:1000);
%
% Inputs:
%   fl - a fluorophore structure
%   param - a string describing the parameter of the fluorophore to be
%      set. Param can have the following values
%
%      'name'                     - fluorophore name
%      'solvent'                  - fluorophore solvent
%      'type'                     - always 'fluorophore'
%
%      'emission photons'         - fluorophore's emission spectrum. Will
%                                   be normalized if integral over wavebands 
%                                   is different from 1
%
%      'excitation photons'       - fluorophore's excitation spectrum. Will
%                                   be normalized if maximum is different 
%                                   from 1
%      'qe'                       - fluorophore's quantum efficiency
%
%      'eem photons'              - fluorophore's excitation emission
%                                   matrix, also known as the Donaldson matrix 
%
%      'wave'                     - spectral sampling vector
%
% Outputs:
%    fl - the fluorophore structure with the updated property.
%
% Copyright Henryk Blasinski, 2016

%%
if ~exist('fl','var') || isempty(fl), error('Fluorophore structure required'); end
if ~exist('param','var') || isempty(param), error('param required'); end
if ~exist('val','var') , error('val is required'); end

%%

% Lower case and remove spaces
param = ieParamFormat(param);

switch param
    case 'name'
        fl.name = val;
        
    case 'type'
        if ~strcmpi(val,'fluoropohore'), error('Type must be ''fluorophore'''); end
        fl.type = val;
        
    case 'qe'
        % if (val > 1), warning('Qe greater than one, truncating to 1'); end
        val = min(max(val,0),1);
        
        % We only set qe for the excitation-emission representation
        if ~isfield(fl,'donaldsonMatrix')
            fl.qe = val;
        end
        
    case {'emissionphotons','emission'}
        % We normally store the emission spectrum as relative (peak set to
        % 1) because we do not have a meaningful scale for the emission
        % spectrum.  It will depend on the concentration of the molecules
        % and properties of the solvent w.r.t. efficacy.  So the scaling
        % needs to be done by the user.
        
        if length(fluorophoreGet(fl,'wave')) ~= length(val) 
            error('Wavelength sampling mismatch'); 
        end
        
        % If the fluorophore happened to be defined with a Donaldson
        % matrix, remove the matrix from the structure;
        if isfield(fl,'donaldsonMatrix') 
            fl = rmfield(fl,'donaldsonMatrix');
        end
        

        % if sum(val<0) > 0, warning('Emission less than zero, truncating'); end
        val = max(val,0);
        
        % HB set for unit area under the curve.  I think we might just
        % normalize to a peak of one going forward.  But need to check.
        deltaL = fluorophoreGet(fl,'deltaWave');
        qe = 1/(sum(val)*deltaL);
        % if qe ~= 1, warning('Emission not normalized'); end
        
        val = val*qe;
        %}
        
        % Set the NaN values to be zero.
        val(isnan(val)) = 0;
        
        fl.emission = val(:);
        

    case {'excitationphotons','excitation photons','Excitation photons'}
        
        if length(fluorophoreGet(fl,'wave')) ~= length(val), error('Wavelength sampling mismatch'); end
        
        % If the fluorophore happened to be defined with a Donaldson
        % matrix, remove the matrix from the structure;
        if isfield(fl,'donaldsonMatrix') 
            fl = rmfield(fl,'donaldsonMatrix');
        end
        
        if sum(val<0) > 0, warning('Excitation less than zero, truncating'); end
        val = max(val,0);
        
        % if max(val) ~= 1, warning('Peak excitation different from 1, rescaling'); end
        val = val/max(val);
        
        % Set the NaN values to be zero.
        val(isnan(val)) = 0;
        
        fl.excitation = val(:);
        
    case {'eemphotons','donaldsonmatrix', 'eem'}
        if length(fluorophoreGet(fl,'wave')) ~= size(val,1) || ...
                length(fluorophoreGet(fl,'wave')) ~= size(val,2)
            error('Wavelength sampling mismatch'); 
        end
        
        if max(val(:)) < 1
            warning('Guessing this is in energy units, not photons.  Please fix.'); 
        end
        
        % We used to remove all fields that are no longer relevant because
        % we have the EEM.  But sometimes we have the EEM and we use
        % parafac to derive excitation and emission.  In that case, we
        % create the fluorophore with the excitation and emission, and then
        % add the EEM that was used to derive.  So we no longer delete the
        % excitation and emission.
        if isfield(fl,'excitation')
            disp("Adding the measured EEM to a fluorophore that has a excitation and emission.")
        end
        %{
        if isfield(fl,'excitation') 
            fl = rmfield(fl,'excitation');
            fl = rmfield(fl,'emission');
            fl = rmfield(fl,'qe');
        end
        %}
        
        fl.eem = val;
                
    case {'wave','wavelength'}
        
        % Need to interpolate data sets and reset when wave is adjusted.
        oldW = fluorophoreGet(fl,'wave');
        newW = val(:);

        % Interpolate excitation and emission spectra or the Donaldson
        % matrix
        if isfield(fl,'donaldsonMatrix')
            % Changed but not properly tested.  FInd a test.
            [oldWem, oldWex] = meshgrid(oldW,oldW);
            [newWem, newWex] = meshgrid(newW,newW);

            newDM = interp2(oldWem,oldWex,fluorophoreGet(fl,'Donaldson matrix'),newWem,newWex,'linear',0);
            fl.spectrum.wave = newW;
            fl = fluorophoreSet(fl,'Donaldson matrix',newDM);

        else
            excitation = fluorophoreGet(fl,'excitation photons','wave',oldW);
            newExcitation = interp1(oldW,excitation,newW);
            % plot(oldW,excitation,'k-',newW,newExcitation,'r:');
            if max(newExcitation) <= eps
                warning('No excitation sensitivity in this waveband');
            end
            emission = fluorophoreGet(fl,'emission photons','wave',oldW);
            newEmission = interp1(oldW,emission,newW,'linear',0);

            fl.spectrum.wave = newW;
            fl = fluorophoreSet(fl,'excitation photons',newExcitation);
            fl = fluorophoreSet(fl,'emission photons',newEmission);

        end

    case 'solvent'
        fl.solvent = val;
        
    otherwise
        error('Unknown fluorophore parameter %s\n',param)
end

end
