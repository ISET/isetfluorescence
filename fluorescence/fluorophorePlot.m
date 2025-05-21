function figHdl = fluorophorePlot(fl,pType,varargin)
% Gateway routine for plotting fluorophore data
%
% Input
%   fl - Fluorophore structure
%   pType - plot type.  
%      'eem mesh'      - EEM as a mesh
%      'eem image'     - EEM as an image
%      'excitation'    - Excitation sensitivity
%      'emission'      - Emissions spectrum.  Specify excitation
%                        wavelength, if there is a full EEM
%
% Optional key/value pairs
%    fighdl
%    normalize       - Scale the emission to peak of 1
%    excitation wave - When there is an EEM, specify the excitation wave
%                      here.
%    linewidth       - Default: 1.2
%    linecolor       - Default:  'k'
%    linestyle       - Default '-'
%
% Returns
%    fighdl
%
% See also
%  fluorophoreRead
%

% Examples:
%{
fl = fluorophoreRead('alamarBlue');
fluorophorePlot(fl,'excitation');
%}
%{
fl = fluorophoreRead('alamarBlue');
fluorophorePlot(fl,'emission');
%}
%{
fl = fluorophoreRead('alamarBlue');
fluorophorePlot(fl,'eem mesh');
%}
%{
fl = fluorophoreRead('alamarBlue');
fluorophorePlot(fl,'eem image');
%}

%%
p = inputParser;

pType = ieParamFormat(pType);
varargin = ieParamFormat(varargin);

p.addRequired('fl',@isstruct);
p.addRequired('pType',@ischar)
p.addParameter('normalize',false,@islogical);
p.addParameter('excitationwave',[],@isnumeric);
p.addParameter('fighdl',[],@(x)(isa(x,'matlab.ui.Figure')));
p.addParameter('linewidth',1.2,@isnumeric);
p.addParameter('linecolor','k',@ischar);
p.addParameter('linestyle','-',@ischar);

p.parse(fl,pType,varargin{:});
normalize = p.Results.normalize;
figHdl    = p.Results.fighdl;

if isempty(figHdl)
    figHdl = ieNewGraphWin;
else
    figure(figHdl);
end

%%
switch pType
    case {'eem','eemimage','donaldsonimage','donaldsonmatrix'}
        % fluorophorePlot(fl,'donaldson image');
        %
        % Computed for photons
        
        wave = fluorophoreGet(fl,'wave');
        dMatrix = fluorophoreGet(fl,'eem');
        imagesc(wave,wave,dMatrix);
        grid on; set(gca,'GridColor',[1 1 1])
        line([min(wave),max(wave)],[min(wave),max(wave)],'Color','w')
        xlabel('Excitation wave (nm)'); ylabel('Emission wave (nm)');
        colorbar; axis image
        title(sprintf('%s',fluorophoreGet(fl,'name')));

    case {'donaldsonmesh','eemmesh'}
        % fluorophorePlot(fl,'donaldson mesh');
        %
        % Computed for photons (not energy)
        
        wave = fluorophoreGet(fl,'wave');
        dMatrix = fluorophoreGet(fl,'eem');
        if normalize, dMatrix = dMatrix/max(dMatrix(:)); end

        mesh(wave,wave,dMatrix);
        line([min(wave),max(wave)],[min(wave),max(wave)],[0 0],'Color','k');
        grid on; xlabel('Excitation wave (nm)'); ylabel('Emission wave (nm)');
        colorbar; 
        title(sprintf('%s',fluorophoreGet(fl,'name')));

    case {'eemwave'}
        % fluorophorePlot(fl,'eem wave','excitation wave',val);
        %
        % To plot the column of the EEM matrix for a wavelength, use this.
        % There should be a fluorophoreGet() for this, also.  Not sure
        % there is.
        %
        if isempty(p.Results.excitationwave), error('Excitation wave required.'); 
        else
            exWave = p.Results.excitationwave;
        end
        wave = fluorophoreGet(fl,'wave');
        dMatrix = fluorophoreGet(fl,'eem');
        if normalize, dMatrix = dMatrix/max(dMatrix(:)); end
        emission = interp2(wave,wave,dMatrix,exWave,wave);

        plotRadiance(wave,emission,'hdl',figHdl);
        title(sprintf('%s EEM (@ %d nm excite)',fl.name,exWave));

    case {'emission','emissionphotons'}
        % fluorophorePlot(fl,'emission photons');
        %
        % If there is a single emission function, we plot it this way.
        wave = fluorophoreGet(fl,'wave');
        data = fluorophoreGet(fl,'emission');

        if normalize, data = data/max(data(:)); end
        
        plot(wave,data,'k-','LineWidth',p.Results.linewidth, ...
            'Color',p.Results.linecolor,...
            'LineStyle',p.Results.linestyle);
        grid on; xlabel('Wavelength (nm)'); ylabel('Emission (photons, a.u.)');
        title(sprintf('%s: emission',fluorophoreGet(fl,'name')));

    case {'excitation','excitationphotons'}
        % fluorophorePlot(fl,'excitation photons');
        %
        % If there is a single excitation function, we plot it this way.

        wave = fluorophoreGet(fl,'wave');
        data = fluorophoreGet(fl,'excitation');

        if normalize, data = data/max(data(:)); end

        plot(wave,data,'k-','LineWidth',p.Results.linewidth, ...
            'Color',p.Results.linecolor,...
            'LineStyle',p.Results.linestyle);
        grid on; xlabel('Wavelength (nm)'); ylabel('Excitation (photons, a.u.)');
        title(sprintf('%s: excitation',fluorophoreGet(fl,'name')));

    case {'exemphotons','exem'}
        % Plot the excitation and emission curves on one graph.
        % normalize both, I suppose.
        wave = fluorophoreGet(fl,'wave');
        ex = fluorophoreGet(fl,'excitation photons');
        em = fluorophoreGet(fl,'emission photons');

        if normalize, ex = ex/max(ex(:)); em = em/max(em(:)); end
        plot(wave,ex,'b-','linewidth',1); hold on;
        plot(wave,em,'r-','linewidth',1); 
        grid on; xlabel('Wavelength (nm)'); ylabel('Photons (a.u.)');
        legend({'Excitation','Emission'})

    otherwise
        error('Unknown plot type %s\n',pType);
end