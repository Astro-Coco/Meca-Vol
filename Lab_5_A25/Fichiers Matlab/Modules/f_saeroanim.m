%SAEROANIM S-Function for displaying 6DoF trajectories
%

% Copyright 1990-2002 The MathWorks, Inc.
% J.Hodgson
% $Revision: 1.2 $  $Date: 2002/03/29 17:56:19 $

function [sys,x0,str,ts] = f_saeroanim(t,x,u,flag,Config)

switch flag,
    % Initialisation du syst?me
    case 0,
        [sys,x0,str,ts]=mdlInitializeSizes(Config);
        
        % D?finition des cas de simulation
    case {1 , 3, 9},
        sys=[];
    case 2,
        sys = [];
        if Config.Animenable
            mdlUpdate(t,x,u,Config);
        end
    case 4,
        sys=mdlGetTimeOfNextVarHit(t,x,u,Config);
    otherwise
        error(['Unhandled flag = ',num2str(flag)]);
end
end

function [sys, x0, str, ts]=mdlInitializeSizes(Config)

sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 6;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

% Initialisation des vecteurs
x0  = [];
str = [];
ts  = [-2 0];

if ~Config.Animenable
    return
end

% Cr?ation d'une fenetre
h_f=findobj('type','figure','Tag','6DOF anim');

if isempty(h_f)
    h_anim=figure;
else
    h_anim=h_f;
end

set(h_anim,'name','Animation Figure', ...
    'renderer','z','resize','on', ...
    'position',[553 112 546 449],'clipping','off', ...
    'Tag','6DOF anim');

if ~isempty(h_anim)
    h_del = findobj(h_anim,'type','axes');
    delete(h_del);
    figure(h_anim);
end

% Cr?ation des axes pour le graphique
handle.axes(1)=axes;
axis(Config.axes);
set(handle.axes(1),'visible','on','xtick',[],'ytick',[],'ztick',[],'box','on', ...
    'dataaspectratio',[1 1 1], ...
    'projection','pers', ...
    'units','normal', ...
    'position',[0.1 0.1 0.75 0.75], ...
    'Color',[.8 .8 .8], ...
    'SortMethod','depth', ...
    'clipping','off');

% Initalisation de la trajectoire
handle.line(1) = line(0,0,0);
set(handle.line(1),'linestyle','-','color',[1 0 0],'userdata',0,'clipping','off');
handle.line(2) = line(0,0,0);
set(handle.line(2),'linestyle',':','color',[0 0 0],'clipping','off');

% Affichage d'une piste (au besoin)
LandL = 10000;
LandW = 150;
X = [30000-LandL 30000 30000 30000-LandL];
Y = [-LandW -LandW LandW LandW];
Z = [0 0 0 0];
handle.target = patch(X,Y,-Z);
set(handle.target,'facecolor',[0 0.4 0], ...
    'edgecolor',[0 0 0]);

% Affichage de l'avion
[xm,ym,zm] = miss_shape;
handle.craft = patch(xm,ym,zm,[0 0.5 0.7]);
vert = Config.craft*get(handle.craft,'vertices');
set(handle.axes(1),'userdata',vert)
set(handle.craft,'edgecolor',[0 0 0],'clipping','off');
set(h_anim,'userdata',handle);

end

function mdlUpdate(t,x,u,Config,count)

handle = get(findobj('type','figure','Tag','6DOF anim'),'userdata');

if isempty(findobj('type','figure','Tag','6DOF anim'))
    return
end

cph = cos(u(4));
sph = sin(u(4));
cth = cos(u(5));
sth = sin(u(5));
cps = cos(u(6));
sps = sin(u(6));

attitude = [cth*cps sph*sth*cps-cph*sps cph*sth*cps+sph*sps
    cth*sps sph*sth*sps+cph*cps cph*sth*sps-sph*cps
    -sth         sph*cth         cph*cth];

vert = get(handle.axes(1),'userdata');
[a,b]=size(vert);
dum =attitude*vert'+u(1:3,1)*ones(1,a);
set(handle.craft,'vertices',dum');

x1 = get(handle.line(1),'Xdata');
x2 = get(handle.line(1),'Ydata');
x3 = get(handle.line(1),'Zdata');
init = get(handle.line(1),'userdata');
if init
    x1 = [x1 u(1)];
    x2 = [x2 u(2)];
    x3 = [x3 u(3)];
else
    x1 = [u(1)];
    x2 = [u(2)];
    x3 = [u(3)];
    set(handle.line(1),'userdata',1);
end

set(handle.line(1),'Xdata',x1, ...
    'Ydata',x2, ...
    'Zdata',x3);

set(handle.line(2),'Xdata',x1, ...
    'Ydata',x2, ...
    'Zdata',Config.axes(6)*ones(length(x1),1));

switch Config.camera_view
    
    case 1,
        set(handle.axes(1),'cameraupvector',[0 0 -1], ...
            'cameraposition',Config.camera_pos, ...
            'cameratarget',u(1:3), ...
            'cameraviewangle',Config.view);
    case 2,
        Target= Config.target';
        ax = Config.axes;
        seeker_dir = sqrt(sum((ax(2)-ax(1))^2+(ax(4)-ax(3))^2+(ax(6)-ax(5))^2))*attitude*[1;0;0];
        seeker_pos = attitude*[Config.craft 0 0]';
        set(handle.axes(1),'cameraupvector',attitude*[0 0 -1]', ...
            'cameraposition',u(1:3)+seeker_pos, ...
            'cameratarget',u(1:3)+seeker_dir, ...
            'cameraviewangle',Config.view);
    case 3,
        set(handle.axes(1),'cameraupvector',[0 0 -1], ...
            'cameraposition',u(1:3)+Config.camera_pos', ...
            'cameratarget',u(1:3), ...
            'cameraviewangle',Config.view);
end

drawnow

end

function sys=mdlGetTimeOfNextVarHit(t,x,u,Config)

sys = ceil(t/Config.update)*Config.update+Config.update;

end

function [x,y,z]=miss_shape

num=12;
count=1;
theta=[0:360/num:(360+360/2/num)]*pi/180;

len		= 187;				% Total Length (no units)
start	= 15;				% Start of main body (w.r.t. nose)
endb    = 145;              % end body
rad1	= 7.5;				% Radius of body
rad2    = 3.5;              % Radius of engines
rad3	= 1.5;			    % radius of motor exit
thr 	= 10;				% Length of Motor exit
leng    = 9;                % Length of engines
lcabin  = start;			% Length of cabin
c_g 	= 93;				% Position of c.g. w.r.t nose

%
% Body Shape
%
yb =  rad1*sin(theta);
zb = -rad1*cos(theta);
for i = 1:num
    xcraft{i}=[start start endb endb]-c_g;
    ycraft{i}=[yb(i) yb(i+1) yb(i+1) yb(i)];
    zcraft{i}=[zb(i) zb(i+1) zb(i+1) zb(i)];
end
count=num+1;

%
% Engines Shape
%
yc =  rad2*sin(theta);
zc = -rad2*cos(theta);
for i = 1:num
    xcraft{count}=[68 68 68+leng 68+leng ]-c_g;
    ycraft{count}=[yc(i)+27 yc(i+1)+27 yc(i+1)+27 yc(i)+27];
    zcraft{count}=[zc(i)+7 zc(i+1)+7 zc(i+1)+7 zc(i)+7];
    count=count+1;
end

for i = 1:num
    xcraft{count}=[68 68 68+leng 68+leng ]-c_g;
    ycraft{count}=[yc(i)-27 yc(i+1)-27 yc(i+1)-27 yc(i)-27];
    zcraft{count}=[zc(i)+7 zc(i+1)+7 zc(i+1)+7 zc(i)+7];
    count=count+1;
end

for i = 1:num
    xcraft{count}=[80 80 80+leng 80+leng ]-c_g;
    ycraft{count}=[yc(i)+46 yc(i+1)+46 yc(i+1)+46 yc(i)+46];
    zcraft{count}=[zc(i)+6 zc(i+1)+6 zc(i+1)+6 zc(i)+6];
    count=count+1;
end

for i = 1:num
    xcraft{count}=[80 80 80+leng 80+leng ]-c_g;
    ycraft{count}=[yc(i)-46 yc(i+1)-46 yc(i+1)-46 yc(i)-46];
    zcraft{count}=[zc(i)+6 zc(i+1)+6 zc(i+1)+6 zc(i)+6];
    count=count+1;
end

%
% Eng exhaust Shape
%
yc2 =  rad3*sin(theta);
zc2 = -rad3*cos(theta);
for i = 1:num
    xcraft{count}=[68+leng 68+leng 68+leng+thr 68+leng+thr]-c_g;
    ycraft{count}=[yc(i)+27 yc(i+1)+27 yc2(i+1)+27 yc2(i)+27];
    zcraft{count}=[zc(i)+7 zc(i+1)+7 zc2(i+1)+7 zc2(i)+7];
    count=count+1;
end

for i = 1:num
    xcraft{count}=[68+leng 68+leng 68+leng+thr 68+leng+thr]-c_g;
    ycraft{count}=[yc(i)-27 yc(i+1)-27 yc2(i+1)-27 yc2(i)-27];
    zcraft{count}=[zc(i)+7 zc(i+1)+7 zc2(i+1)+7 zc2(i)+7];
    count=count+1;
end

for i = 1:num
    xcraft{count}=[80+leng 80+leng 80+leng+thr 80+leng+thr]-c_g;
    ycraft{count}=[yc(i)+46 yc(i+1)+46 yc2(i+1)+46 yc2(i)+46];
    zcraft{count}=[zc(i)+6 zc(i+1)+6 zc2(i+1)+6 zc2(i)+6];
    count=count+1;
end

for i = 1:num
    xcraft{count}=[80+leng 80+leng 80+leng+thr 80+leng+thr]-c_g;
    ycraft{count}=[yc(i)-46 yc(i+1)-46 yc2(i+1)-46 yc2(i)-46];
    zcraft{count}=[zc(i)+6 zc(i+1)+6 zc2(i+1)+6 zc2(i)+6];
    count=count+1;
end

%
% Nose Shape
%
yc = rad1*sin(theta);
zc = rad1*cos(theta);
for i = 1:num
    xcraft{count}=[lcabin lcabin 0 0]-c_g;
    ycraft{count}=[yc(i) yc(i+1) 0 0];
    zcraft{count}=[zc(i) zc(i+1) 3 3];
    count=count+1;
end

%
% Tail cone Shape
%
for i = 1:num
    xcraft{count}=[endb endb len len ]-c_g;
    ycraft{count}=[yb(i) yb(i+1) 0 0];
    zcraft{count}=[zb(i) zb(i+1) -7.5 -7.5];
    count=count+1;
end

%
% Wing  shapes
%
xcraft{count}=[67 115 123 100]-c_g;
ycraft{count}=[0 74 74 0];
zcraft{count}=[6 -3 -3 6];
xcraft{count+1}=xcraft{count};
ycraft{count+1}=-ycraft{count};
zcraft{count+1}=zcraft{count};
count=count+2;

%
% horiz tail shapes
%
xcraft{count}=[165 183 190 183]-c_g;
ycraft{count}=[0 25 25 0];
zcraft{count}=[-3 -7.5 -7.5 -3];
xcraft{count+1}=xcraft{count};
ycraft{count+1}=-ycraft{count};
zcraft{count+1}=zcraft{count};
count=count+2;


%
% vert tail shapes
%
xcraft{count}=[160 178 183 178]-c_g;
ycraft{count}=[0 0 0 0];
zcraft{count}=[-7.5 -30 -30 -7.5 ];
count=count+1;

%
% wing strut shapes
%
xcraft{count}=[72 83 93 83]-c_g;
ycraft{count}=[27 27 27 27];
zcraft{count}=[3.5 2.5 2.5 5];
xcraft{count+1}=xcraft{count};
ycraft{count+1}=-ycraft{count};
zcraft{count+1}=zcraft{count};
count=count+2;

xcraft{count}=[84 95 105 95]-c_g;
ycraft{count}=[46 46 46 46];
zcraft{count}=[2.5 0.5 0.5 4];
xcraft{count+1}=xcraft{count};
ycraft{count+1}=-ycraft{count};
zcraft{count+1}=zcraft{count};
count=count+1;


x=[];y=[];z=[];

roll = eye(3);
for i = 1:count
    x = [x xcraft{i}'];
    y = [y ycraft{i}'];
    z = [z zcraft{i}'];
end

for i =1:4
    dum = [x(i,:);y(i,:);z(i,:)];
    dum = roll*dum;
    x(i,:)=dum(1,:);
    y(i,:)=dum(2,:);
    z(i,:)=dum(3,:);
end

x = -x/len;
y = y/len;
z = z/len;

end