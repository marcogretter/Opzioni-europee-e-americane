function prezzo = american_option(T,K,N,sigma,r,St,flag)
% La funzione calcola il prezzo di un'opzione Put/Call Americana.

% Input:
%S_0 = valore iniziale sottostante
% T= Maturity
% N= Numero step temporali dell'albero


% Output:
% M_PS: fornisce il prezzo del sottostante ad ogni nodo
% M_US: fornisce il valore del derivato nei vari nodi

% La funzione fornisce istante, valore opzione, posizione (numero up e 
% down), nel caso in quell'istante si possa sfruttare il diritto.

if nargin==6 % se non metto flag in input, prezzo una call
    flag=1;
end

if flag~=1 & flag~=-1
    error('flag non è compatibile')
end


%Definisco tutti i valori utili
delta=T/N;
u=exp(sigma*sqrt(delta));
d=1/exp(-sigma*sqrt(delta)); %d=1/u;
rf=exp(r*delta);
p=(rf-d)/(u-d);
q=1-p;

% Inizializzo le matrici per rappresentare l'albero
% Se N è dispari il numero delle foglie è pari e viceversa:

M_PS=zeros(2*N+1,N+1);
M_payoff=zeros(2*N+1,N+1);
M_PS(N+1,1)=St; % Se ad esempio N=6, il prezzo St viene messo in M_PS(4,1) e M_PS è 7x7

M_cont=zeros(size(M_PS));
% Inizializzo M_cont, che è una matrice che per ogni cella (i,j),
% M_cont(i,j)=1 se (i,j) è un nodo, 0 altrimenti


% Gli alberi vengono distinti in questo modo tra step pari e dispari per
% motivi di simmetria dei nodi.

[r,c]=size(M_PS); %Numero righe e colonne delle due matrici

% In questo ciclo for calcolo il prezzo del sottostante nei vari nodi
for j=1:(c-1)
        for i=1:r
            if (M_PS(i,j)~= 0)
                M_PS(i-1,j+1)=M_PS(i,j)*u;
                M_PS(i+1,j+1)=M_PS(i,j)*d;
                M_cont(i,j)=1;          % Scrivo 1 in tutte le celle che contengono un nodo
                M_cont(i-1,j+1)=1;
                M_cont(i+1,j+1)=1;
            end
        end
end

M_cont;

% Calcolo i payoff:

%Inizializzo il vettore che conterrà tutti i valori possibili di S_T:

S_T=zeros(N+1,1);
payoffs=zeros(N+1,1);

for i=1:N+1
    S_T(i)=St*(d^(i-1))*(u^(N+1-i)); %Li salvo in ordine, dal più grande al più piccolo
    payoffs= max(flag*(S_T-K),0); % calcolo il payoff
end

cont=1;


for i=1:r
%Se nella riga i nell'ultima colonna della matrice dei prezzi c'è un prezzo,
%allora inserisco il payoff all'interno della riga i e ultima colonna
    if M_PS(i,c) ~=0
        M_payoff(i,c)=payoffs(cont);
        M_val(i,c)=payoffs(cont);
        cont=cont+1;
    end
end

% In M_val saranno riportati i valori di ciascun nodo
% In M_prezzi saranno riportati i prezzi di ciascun nodo
 
% I payoff all'ultimo istante sono sia il valore che il prezzo del derivato
% in quell'istante

%Fino a qui quindi ho ottenuto l'albero del derivato che è tutto 
% inizializzato a 0, tranne l'ultima colonna che contiene i payoffs

% Calcolo payoff in tutti i nodi
for i=1:r
    for j=1:c-1 %mi fermo alla penultima colonna in quanto l'ultima ha già i payoff
        if M_cont(i,j)==1
            M_payoff(i,j)=max(flag*(M_PS(i,j) - K),0);
        end
    end
end


% Calcolo il prezzo dell'opzione nei vari nodi:
% Se il prezzo della put europea è maggiore del payoff, allora il prezzo
% del nodo rimane quello della put europea, altrimenti diventa il payoff.
% Questo ciclo segnala quando c'è un esercizio ottimale per l'opzione.
% Cont ha il semplice scopo di contare a quale nodo siamo, viene indicato
% dall'alto verso il basso.

M_PS %Stampo matrice albero prezzi del sottostante
M_payoff % Stampo la matrice dei payoff dell'opzione


for j=(c-1):-1:1 
    for i=1:r
        if (M_cont(i,j)==1)
            cont=cont+1;
            POup=M_val(i-1,j+1);
            POdown=M_val(i+1,j+1);
            M_val(i,j)=exp(-r*delta)*(p*POup + q*POdown);

            if M_payoff(i,j) > M_val(i,j)  
                
                M_val(i,j) = M_payoff(i,j);
                fprintf('Esercizio opzione ottimale al nodo %d al passo %d.\n',cont, j-1);
            end

        end
    end
    cont=0;
end

M_val
% Stampo matrice dei payoff e dei valori, quest'ultima dovuta dal confronto
% ad ogni nodo tra costo della call/put europea e il payoff del nodo

prezzo=M_val(N+1,1);



% A questo punto ho:
% M_US_payoff che contiene i payoff per ogni nodo
% M_PS che è la matrice che contiene i prezzi del sottostante per ogni nodo
% M_US_val che contiene i prezzi di ogni nodo del derivato, aggiornati in
% base al confronto tra payoff e prezzo di una Put Europea. Il prezzo
% dell'opzione sarà pari alla testa di questo nodo.












