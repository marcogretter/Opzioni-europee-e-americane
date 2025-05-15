function P=european_option(S_0,sigma,r,K,T,N,flag)
% Funzione che calcola con metodo CRR il valore di un'opzione europea.
% S_0= Prezzo stock attuale
% sigma=volatilità
% r= tasso di interesse risk-free di mercato
% K= Strike price
% T= Maturity
% N= Numero step temporali dell'albero
% flag= Determina quale opzione prezzare. 1 per le Call, -1 per le put

if nargin==6 % se non metto flag in input, prezzo una call
    flag=1;
end

if flag~=1 && flag~=-1
    error('flag non è compatibile')
end

%Definisco tutti i valori utili
delta=T/N;
u=exp(sigma*sqrt(delta));
d=exp(-sigma*sqrt(delta)); %d=1/u;
rf=exp(r*delta);
p=(rf-d)/(u-d);
q=1-p;

%Inizializzo il vettore che conterrà tutti i valori possibili di S_T
S_T=zeros(N+1,1);

for i=1:N+1
    S_T(i)=S_0*(d^(i-1))*(u^(N+1-i)); %Li salvo in ordine, dal più grande al più piccolo
end

    payoffs= max(flag*(S_T-K),0); %calcolo i payoff sulle foglie dell'albero
    for i=1:N+1
    upwards= N+1-i; %Quante volte sono andato su?
    downwards= i-1; %Quante volte sono andato giù?
    Npaths=nchoosek(N,upwards); %numero di cammini
    payoffs(i)=exp(-r*T)*Npaths*(p^(upwards))*(q^(downwards))*payoffs(i); %Li sconto e li moltiplico per le probabilità di raggiungerli
    end
    P=sum(payoffs);


