function  [t, x] = f_simuler_avion(x0, Tf, pas, conditions, avion, simulation)

% Definition des parametres internes de la fonction
func = 'm_edm.f_equations_mouvement';
method = 'rk4'; h = pas;

% Initialisation des param?tres de calcul :
% Cr?ation de la barre de progression :
if strcmpi(method, 'euler')
    euler_flag = true; 
    titre      = 'Calcul avec methode d''Euler';
elseif strcmpi(method, 'rk4')
    euler_flag = false; 
    titre      = 'Calcul avec methode de Runge Kutta 4';
else 
    error('myApp:argChk', 'M?thode de r?solution inconnue..');
end

barre = waitbar(0,'Calcul a : 00.00%%','Name',titre);

% Nombre d'?quations d?finissant le syst?me:
if size(x0,2) > size(x0,1)
    x0 = x0';
end
nbEquations = length(x0);

% Cr?ation du vecteur d'etat de sortie :
x = zeros(1,nbEquations);
x(1,:) = x0';

% Calcul du nombre d'itt?ration max :
Nmax = round(Tf/h);

% Cr?ation du vecteur temps :
t = zeros(Nmax,1);

for n = 1:Nmax
    
    waitbar(n/Nmax,barre,sprintf('Calcul a : %.2f%%',100*(n/Nmax)));
    
    if euler_flag
        
        % Calcul des constantes pour Euler (k1) et Runge Kutta :
        k1 = h*feval(func,t(n),x0,...
            conditions, avion, simulation, h);

        % M?thode d'Euler :
        x0 = x0 + k1;
    else
        k1 = h*feval(func,t(n),x0,...
            conditions, avion, simulation, h);
        k2 = h*feval(func,t(n)+h/2,x0+k1/2,...
            conditions, avion, simulation, h);
        k3 = h*feval(func,t(n)+h/2,x0+k2/2,...
            conditions, avion, simulation, h);
        k4 = h*feval(func,t(n)+h,x0+k3,...
            conditions, avion, simulation, h);
        
        % M?thode de Runge Kutta 4 :
        x0 = x0 + (1/6)*(k1+2*(k2+k3)+k4);
    end
    
    % On sauvegarde les donn?es :
    x(n+1,:) = x0';
    
    % On passe qu temps suivant :
    t(n+1) = t(n) + h;
    
end
delete(barre);