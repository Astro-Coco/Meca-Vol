function f_compensateur(conditions, avion)

%%% Linearisation du system autour de l'equilibre
[~, ~, model] = m_mdl.f_stabilite(conditions, avion);

%%% Recuperation du system lineaire: model du mouvement longitudinal 
%%% uniquement
a_long = model.long.a;
b_long = model.long.b(:,1);
c_long = [0 0 1 0];

%%% Appel de la fonction pour l'initialisation de l'interface
[figureaxes, sliders, textbox] = l_init_interface();

while ishandle(figureaxes.q)
    
    %%% Recuperation des positions des sliders
    kq = get(sliders.kq, 'Value');
    kp = get(sliders.kp, 'Value');
    ki = get(sliders.ki, 'Value');
    
    %%% Application du retour sur l'avion
    kx = [0, 0, kq, 0];
    closed_loop = ss([a_long-b_long*kx, -b_long*ki; -c_long, 0], ...
        [b_long*kp; 1], eye(5), zeros(5,1));
    
    %%% Simulation de la reponse de l'avion
    tim_sim = 0 : 0.1 : 10;
    input_delev = ones(size(tim_sim))*pi/180;
    ac_outputs = lsim(closed_loop, input_delev, tim_sim);
    delev_output = - kq*ac_outputs(:,3) + ...
        kp*(input_delev' - ac_outputs(:,3)) - ki*ac_outputs(:,5);
    
    %%% Calcul des performance (stabilite) de l'avion
    [wn, zeta] = damp(closed_loop);
    
    %%% Affichage de la reponse de l'avion
    % Reponse de la vitesse en tangage
    plot(figureaxes.q, tim_sim, ac_outputs(:,3)*180/pi, ...
        tim_sim, ones(size(tim_sim)), '--r');
    title(figureaxes.q, 'Vitesse de tangage de q [deg/s]', 'fontsize', 8);
    set(figureaxes.q, 'xgrid', 'on', 'ygrid', 'on');
    set(figureaxes.q, 'xlim', [0 10], 'ylim', [-0.2 1.5]);
    xlabel(figureaxes.q, 'Temps [sec]', 'fontsize', 8);
    legend(figureaxes.q, 'Reponse de l''avion', 'Reference', ...
        'location', 'southeast');
    
    % Reponse du stabilisateur
    plot(figureaxes.delev, tim_sim, delev_output*180/pi);    
    title(figureaxes.delev, 'Position des elevateurs [deg]', 'fontsize', 8);
    set(figureaxes.delev, 'xgrid', 'on', 'ygrid', 'on');
    set(figureaxes.delev, 'xlim', [0 10], 'ylim', [-10 10]);
    xlabel(figureaxes.delev, 'Temps [sec]', 'fontsize', 8);
    
    %%% Creation du textbox pour l'information
    string{1, :} = ' Conditions de vol: ';
    string{2, :} = sprintf('\t\t- Altitude: %05.0f [ft]', conditions.altitude_m/0.3048);
    string{3, :} = sprintf('\t\t- Vitesse: %03.0f [kts]', conditions.tas_mps/0.5144);
    string{4, :} = '';
    
    string{5, :} = ' Gains du compensateur:';
    string{6, :} = sprintf('\t\t- kq = %+08.4f', kq);
    string{7, :} = sprintf('\t\t- ki = %+08.4f', ki);
    string{8, :} = sprintf('\t\t- kp = %+08.4f', kp);
    string{9, :} = '';
   
    string{10,:} = ' Stabilite de l''avion:';
    string{11,:} = '  # Short Period :';
    string{12,:} = sprintf('\t\t- wn/zeta = %+06.2f / %+06.2f', wn(4), zeta(4));
    string{13,:} = ' ';
    string{14,:} = '  # Phugoide:';
    string{15,:} = sprintf('\t\t- wn/zeta = %+06.2f / %+06.2f', wn(2), zeta(2));

    %%% Mise ? jour de l'information
    set(textbox, 'string', string);
    
    %%% Mise ? jour de l'interface totale
    drawnow; pause(0.01);
end

end

% Local function, this function initialize and manage the main interface of
% the program.
function [figureaxes, sliders, textbox] = l_init_interface()
%% 
%%% Find the size of the screen
screenSize = get(0, 'ScreenSize');
width = 600;
height = 600;
pos = [screenSize(3)/2-width/2 screenSize(4)/2-height/2 width height];

%%% Create a figure and force the position to be midle
figure('units','pixels','position',pos,...
    'color',[.94 .94 .94],'numbertitle','off','MenuBar','none',...
    'name','AER3640 - Mecanique du vol (2017)','ToolBar','none',...
    'resize','on');

%%% Create a first axe for the pitch rate response
figureaxes.q = axes('Units','normalized',...
    'position',[0.51 0.51 0.45 0.29],'box','on');
title(figureaxes.q, 'Vitesse de tangage de q [deg/s]');
set(figureaxes.q, 'xlim', [0 10], 'ylim', [0 1.5]);

%%% Create a second axe for the stabilizer position
figureaxes.delev = axes('Units','normalized',...
    'position',[0.51 0.12 0.45 0.29],'box','on');
title(figureaxes.delev, 'Position du stabilisateur [deg]');
set(figureaxes.delev, 'xlim', [0 10], 'ylim', [-10 10]);
xlabel(figureaxes.delev, 'Temps [sec]');

%%% Create sub-panel for the CSAS gains
panel = uipanel('Title','Gains du compensateur',...
    'FontSize', 8, 'FontWeight', 'bold', 'BackgroundColor',[.94 .94 .94],...
    'ForeGround', 'black', 'Position', [.05 .51 .40 .30]);

sliders.kq = uicontrol('parent', panel, 'Style', 'slider',...
    'Units','normalized', 'Min',-30,'Max',30,'Value',0,...
    'Position', [0.1 0.70 0.8 0.1], 'Callback', '');

sliders.ki = uicontrol('parent', panel, 'Style', 'slider',...
    'Units','normalized', 'Min', 0, 'Max',50, 'Value',0,...
    'Position', [0.1 0.40 0.8 0.1],...
    'Callback', '');

sliders.kp = uicontrol('parent', panel, 'Style', 'slider',...
    'Units','normalized', 'Min',-30,'Max',30,'Value',0,...
    'Position', [0.1 0.10 0.8 0.1],...
    'Callback', '');

%%% Add text for each slider
uicontrol('parent', panel, 'Style', 'text', 'string', 'kq', ...
    'Units', 'normalized', 'Position', [0.1 0.82 0.8 0.1], ...
     'HorizontalAlignment','left', 'FontWeight', 'bold', ...
     'fontsize', 8);
 
uicontrol('parent', panel, 'Style', 'text', 'string', 'ki', ...
    'Units','normalized', 'Position', [0.1 0.50 0.8 0.1], ...
     'HorizontalAlignment','left', 'FontWeight', 'bold', ...
     'fontsize', 8);
 
uicontrol('parent', panel, 'Style', 'text', 'string', 'kp', ...
    'Units','normalized', 'Position', [0.1 0.22 0.8 0.1], ...
     'HorizontalAlignment','left', 'FontWeight', 'bold', ...
     'fontsize', 8);

%%% Add a text boxt to show the gains values
textbox = uicontrol('Style', 'listbox','units','normalized',...
    'Position', [.05 0.1 0.4 0.35], 'BackGroundColor',[1 1 1],...
    'FontName','FixedWidth','FontSize', 8, 'FontUnits','normalized',...
    'SelectionHighlight','off','selected','off', 'string',...
    'Demarrage...');

%%% Additional text for the interface
uicontrol('style','text','units','normalized',...
    'position',[0 -0.03 1 0.1],'BackgroundColor',[.94 .94 .94],...
    'ForegroundColor',[0 0 0],'FontSize',6,'FontWeight','normal',...
    'HorizontalAlignment','center',...
    'string',['__________________________________________________________',...
    '______________________________________________']);

uicontrol('style','text','units','normalized',...
    'position',[0 -0.035 1 0.07],'BackgroundColor',[.94 .94 .94],...
    'ForegroundColor',[0 0 0],'FontSize',8,'FontWeight','normal',...
    'HorizontalAlignment','center',...
    'string','Cop. 2017 G. GHAZI / LARCASE TOUS DROITS RESERVES');

uicontrol('style', 'text', 'units', 'normalized',...
    'position',[0.05 0.9 1 0.07], 'BackgroundColor',[.94 .94 .94],...
    'ForegroundColor',[0 0 0],'FontSize', 14, 'FontWeight', 'bold',...
    'HorizontalAlignment','left', 'string','Laboratoire 6:');

uicontrol('style', 'text', 'units', 'normalized',...
    'position',[0.05 0.85 1 0.07], 'BackgroundColor',[.94 .94 .94],...
    'ForegroundColor',[0 0 0],'FontSize', 12, 'FontWeight', 'bold',...
    'HorizontalAlignment','left', 'string', ...
    'Conception d''un system de commande de vol');

uicontrol('style','text','units','normalized',...
    'position',[0. 0.82 1 0.07],'BackgroundColor',[.94 .94 .94],...
    'ForegroundColor',[0 0 0],'FontSize',8,'FontWeight','normal',...
    'HorizontalAlignment','center',...
     'string',['__________________________________________________________',...
    '___________________________________']);


end

