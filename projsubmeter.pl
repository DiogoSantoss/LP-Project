%95562 - Diogo Santos

:- [codigo_comum].
:- [puzzles_publicos].

%-------------------------------------------------------------------------------------------------------------
% obtem_letras_palavras(Lst_Pals,Letra), em que Lst_Pals eh uma lista de palavras significa que Letras eh a 
% lista ordenada cujos elementos sao listas com letras de cada palavra de Lst_Pals.

obtem_letras_palavras(Palavras,Letras) :-
    maplist(atom_chars,Palavras,Letras_aux),
    sort(Letras_aux,Letras).


%-------------------------------------------------------------------------------------------------------------
% espaco_fila(Fila,Esp), em que Fila eh uma linha/coluna de uma grelha, significa que Esp eh um espaco de Fila.

espaco_fila(Fila,Esp) :-
    espaco_fila(Fila,Esp,[]). % em que [] eh um acumulador

espaco_fila([],Ac,Ac) :-      % se chegarmos ao fim da Fila, Ac eh um espaco se tiver comprimento >= 3
    length(Ac,C),
    C >= 3.

espaco_fila([P|_],Ac,Ac) :-   % se P==#, Ac eh um espaco se tiver comprimento >= 3
    P == #,
    length(Ac,C),
    C >= 3.

espaco_fila([P|R],Esp,Ac) :-  % se P==#, Ac eh nao eh um espaco se tiver comprimento < 3
    P == #,
    length(Ac,C),
    C < 3,
    espaco_fila(R,Esp,[]).

espaco_fila([P|R],Esp,Ac) :-  % sempre que P\==# vai acumulando em Ac
    P \== #,
    append(Ac,[P],Ac_res),
    espaco_fila(R,Esp,Ac_res).

espaco_fila([P|R],Esp,Ac) :-  % reinicia o Ac apos um ';'
    P == #,
    length(Ac,C),
    C >= 3,
    espaco_fila(R,Esp,[]). 


%-------------------------------------------------------------------------------------------------------------
% espacos_fila(Fila,Espacos), em que Fila eh uma linha/coluna deu ma grelha, significa que Espaco eh a lista
% de todos os espacos de Fila, da esq para dir.

espacos_fila(Fila,Espacos) :-
    bagof(Espaco,espaco_fila(Fila,Espaco),Espacos),!.

espacos_fila(_,[]). % caso terminal


%-------------------------------------------------------------------------------------------------------------
% espacos_puzzle(Grelha, Espacos), em que Grelha eh um grelha, significa que Espacos eh a lista de espacos de
% Grelha.

espacos_puzzle(Grelha,Espacos) :-
    mat_transposta(Grelha,Grelha_transp),
    espacos_puzzle(Grelha,Grelha_transp,Espacos,[]). % em que [] eh um acumulador

espacos_puzzle([P|R],Grelha_transp,Espacos,Ac) :-
    espacos_fila(P,Ac_aux),
    append(Ac,Ac_aux,Ac_res),
    espacos_puzzle(R,Grelha_transp,Espacos,Ac_res).

espacos_puzzle([],[P|R],Espacos,Ac) :-    % quando acabar de verificar a grelha, verifica a sua transposta
    espacos_fila(P,Ac_aux),
    append(Ac,Ac_aux,Ac_res),
    espacos_puzzle([],R,Espacos,Ac_res).

espacos_puzzle([],[],Ac,Ac). % caso terminal


%-------------------------------------------------------------------------------------------------------------
% predicados auxiliares para espacos_com_posicoes_comuns/3.

% contem_membro(L1,L2), em que L1 e L2 sao listas, significa que L1 contem pelo menos um elemento da L2.

contem(X,[P|_]) :- X == P.
contem(X,[_|R]) :- contem(X,R).

% contem(E,L), em que E eh um elemento e L uma lista, significa que L contem E.

contem_membro([P|_],L2) :- contem(P,L2).
contem_membro([_|R],L2) :- contem_membro(R,L2).


%--------------------------------------------------------------------------------------------------------------
% espacos_com_posicoes_comuns(Espacos,Esp,Esps_com), em que Espacos eh uma lista de espacos e Esp eh um espaco,
% significa que Esps_com eh a lista de espacos com variaveis em comum com Esp,exceptuando Esp.

espacos_com_posicoes_comuns(Espacos,Esp,Esps_com) :-
    member(Esp,Espacos),
    espacos_com_posicoes_comuns(Espacos,Esp,Esps_com,[]). % em que [] eh um acumulador 

espacos_com_posicoes_comuns([],_,Ac,Ac). % caso terminal

espacos_com_posicoes_comuns([P|R],Esp,Esps_com,Ac) :- 
    P \== Esp,
    contem_membro(P,Esp),  % significa que P tem um membro em comum com Esp
    append(Ac,[P],Ac_res),
    espacos_com_posicoes_comuns(R,Esp,Esps_com,Ac_res).

espacos_com_posicoes_comuns([P|R],Esp,Esps_com,Ac) :-
    P \== Esp,
    \+contem_membro(P,Esp),
    espacos_com_posicoes_comuns(R,Esp,Esps_com,Ac).

espacos_com_posicoes_comuns([P|R],Esp,Esps_com,Ac) :-
    P == Esp,
    espacos_com_posicoes_comuns(R,Esp,Esps_com,Ac).


%-------------------------------------------------------------------------------------------------------------
% predicados auxiliares para palavra_possivel_esp/4

% copiar(Copia,Esp) em que Esp eh uma espaco, significa que Copia eh uma copia de Esp com variaveis diferentes.

copiar(Copia,Esp) :-
    maplist(copiar_el,Esp,Copia).

copiar_el(El,_) :- 
    var(El),!.
copiar_el(El,El).

% possivel(Pal,Esp) em que Pal eh uma lista de letras de uma palavra e Esp eh um espaco.
% Devolve true se Esp for um sitio possivel para Pal

possivel(Pal,Esp) :-
    copiar(Copia,Esp),
    Copia = Pal.


%-------------------------------------------------------------------------------------------------------------
% predicados auxiliares para palavra_possivel_esp/4

% comuns_possivel(Esps_com,Letras) significa que existe uma Palavra pertencente ah lista Letras que eh possivel
% num espaco de Esps_com

comuns_possivel([],_). % caso terminal

comuns_possivel([P|R],Letras) :-
    member(Palavra_Letras,Letras),    % Palavra_Letras sera uma lista de letras que eh unificavel com P
    possivel(Palavra_Letras,P),!,     % verifica se unifica sem unificar           
    comuns_possivel(R,Letras).


%-------------------------------------------------------------------------------------------------------------
% palavra_possivel_esp(Pal,Esp,Espacos,Letras), em que Pal eh uma lista de letras de uma palavra, Esp 
% eh uma espaco, Espacos eh uma lista de espacos, e Letras eh uma lista de listas de letras de palavras, 
% significa que Pal eh uma palavra possival para o espaco Esp.

palavra_possivel_esp(Pal,Esp,Espacos,Letras) :-
    length(Pal,C1),
    length(Esp,C1),
    Esp=Pal,
    espacos_com_posicoes_comuns(Espacos,Esp,Esps_com),
    comuns_possivel(Esps_com,Letras).


%-------------------------------------------------------------------------------------------------------------
% palavras_possiveis_esp(Letras,Espacos,Esp,Pals_Possiveis), em que Letras eh uma lista de listas de letras 
% de palavras, Espacos eh uma lista de espacos, Esp eh um espaco, significa que Pals_Possiveis eh a lista
% ordenada de palavras possiveis para o espaco Esp.

palavras_possiveis_esp(Letras,Espacos,Esp,Pals_Possiveis) :-
    palavras_possiveis_esp(Letras,Espacos,Esp,Pals_Possiveis,_). % em que _ eh um acumulador

palavras_possiveis_esp(Letras,Espacos,Esp,Pals_Possiveis,Ac) :-
    findall(Palavra,(member(Palavra,Letras),palavra_possivel_esp(Palavra,Esp,Espacos,Letras)),Ac),
    sort(Ac,Pals_Possiveis).  % o predicado sort remove duplicados

%-------------------------------------------------------------------------------------------------------------
% palavras_possiveis(Letras,Espacos,Pals_Possiveis), em que Letras eh uma lista de listas de letras de palavras
% e Espaco eh uma lista de espacos, significa que Pals_Possiveis eh a lista de palavras possiveis.

palavras_possiveis(Letras,Espacos,Pals_Possiveis) :-
    palavras_possiveis(Letras,Espacos,Pals_Possiveis,[],Espacos). % em que [] eh um acumulador
                                                                  % em que Espacos eh uma variavel utilizada para passar
palavras_possiveis(_,[],Ac,Ac,_). % caso terminal                 % como argumento do predicado palavras_possiveis_esp/4

palavras_possiveis(Letras,[P|R],Pals_Possiveis,Ac,Espacos) :-
    palavras_possiveis_esp(Letras,Espacos,P,Pals_Possiveis_aux),
    append([P],[Pals_Possiveis_aux],Ac1),
    append(Ac,[Ac1],Ac_res),
    palavras_possiveis(Letras,R,Pals_Possiveis,Ac_res,Espacos).


%-------------------------------------------------------------------------------------------------------------
% letras_comuns(Lst_Pals, Letras_comuns), em que Lst_Pals eh uma lista de listas de letras, significa que 
% Letras_comuns eh uma lista de pares (pos,letra), significa que todas as listas de Lst_Pals contem a letra
% (_,letra) na posicao (pos,_).

letras_comuns([],[]).

letras_comuns(Lst_Pals,Letras_comuns) :-
    letras_comuns(Lst_Pals,Letras_comuns,1,[]). % em que [] eh um acumulador e 1 eh o Indice

letras_comuns(Lst_Pals,Ac,Ind,Ac) :- % caso terminal
    Lst_Pals=[Palavra|_],
    length(Palavra,Aux),
    Ind > Aux.

letras_comuns(Lst_Pals,Letras_comuns,Ind,Ac) :-
    Lst_Pals=[Palavra|_],
    nth1(Ind,Palavra,Letra),      % Conj_Letra eh uma lista que contem todas as letras iguais a Letra no indice Ind
    findall(Letra,(member(Letras,Lst_Pals),nth1(Ind,Letras,Letra)),Conj_Letra), 
    length(Lst_Pals,Comp),
    length(Conj_Letra,Comp),      % Se a lista tiver comprimento igual ao numero de palavras entao     
    append(Ac,[(Ind,Letra)],Ac1),     % todas as letras sao iguais
    Ind_atual is Ind+1,
    letras_comuns(Lst_Pals,Letras_comuns,Ind_atual,Ac1),!.

letras_comuns(Lst_Pals,Letras_comuns,Ind,Ac) :-
    Ind_atual is Ind+1,
    letras_comuns(Lst_Pals,Letras_comuns,Ind_atual,Ac),!.

%-------------------------------------------------------------------------------------------------------------
% predicado auxiliar de atribui_comuns/1

% atribui_comuns_aux(Espaco,Letras_comuns), significa que Espaco eh o resultado de unificar cada letra de 
% Letras_comuns com a variavel na posicao correspondente.

atribui_comuns_aux(_,[]). % caso terminal

atribui_comuns_aux(Espaco,[(Posicao,Letra)|R]) :-
    nth1(Posicao,Espaco,Letra),
    atribui_comuns_aux(Espaco,R).


%-------------------------------------------------------------------------------------------------------------
% atribui_comuns(Pals_Possiveis), em que Pals_Possiveis eh uma lista de palavras possiveis, atualiza esta 
% lista atribuindo a cada espaco as letras comuns a todas as palavras possiveis para esse espaco.

atribui_comuns([]). % caso terminal

atribui_comuns([[Espaco,Palavras]|R]) :-                   
    letras_comuns(Palavras,Letras_comuns),  
    atribui_comuns_aux(Espaco,Letras_comuns), 
    atribui_comuns(R),!.


%-------------------------------------------------------------------------------------------------------------
% retira_impossiveis(Pals_Possiveis, Novas_Pals_Possiveis), em que Pals_Possiveis eh uma lista de palavras
% possiveis, significa que Novas_Pals_Possiveis eh o resultado de tirar palavras impossiveis de Pals_Possiveis.

retira_impossiveis([],[]). % caso terminal

retira_impossiveis([[Espaco,Palavras]|R],[[Espaco,Nova_Pals]|R_Novas]) :-
    findall(Palavra,(member(Palavra,Palavras),possivel(Palavra,Espaco)),Nova_Pals),
    retira_impossiveis(R,R_Novas).


%-------------------------------------------------------------------------------------------------------------
% obtem_unicas(Pals_Possiveis, Unicas), em que Pals_Possiveis eh uma lista de palavras possiveis, significa
% que Unica eh a lista de palavras unicas de Pals_Possiveis.

obtem_unicas(Pals_Possiveis,Unicas) :-
    obtem_unicas(Pals_Possiveis,Unicas,[]).

obtem_unicas([],Ac,Ac). % caso terminal

obtem_unicas([[_,Palavras]|R],Unicas,Ac) :-
    length(Palavras,1),
    append(Ac,Palavras,Ac1),
    obtem_unicas(R,Unicas,Ac1),!.

obtem_unicas([[_,Palavras]|R],Unicas,Ac) :-
    \+length(Palavras,1),
    obtem_unicas(R,Unicas,Ac),!.


%-------------------------------------------------------------------------------------------------------------
% retira_unicas(Pals_Possiveis,Nova_Pals_Possiveis), em que Pals_Possiveis eh uma lista de palavras possiveis,
% significa que Novas_Pals_Possiveis eh o resultado de retirar de Pals_Possiveis as palavras unicas.

retira_unicas(Pals_Possiveis,Novas_Pals_Possiveis) :-
    obtem_unicas(Pals_Possiveis,Unicas),
    retira_unicas(Pals_Possiveis,Novas_Pals_Possiveis,Unicas).

retira_unicas([],[],_). % caso terminal

retira_unicas([[Espaco,Palavras]|R],[[Espaco,Palavras_Novas]|R_Novas],Unicas) :-
    length(Palavras,C),
    C>=2,
    findall(Palavra,(member(Palavra,Palavras),\+member(Palavra,Unicas)),Palavras_Novas), % retira palavras que sao member de Unicas
    retira_unicas(R,R_Novas,Unicas),!.

retira_unicas([[Espaco|Palavras]|R],[[Espaco|Palavras]|R_Novas],Unicas) :-
    length(Palavras,C),
    C<2,
    retira_unicas(R,R_Novas,Unicas),!.


%-------------------------------------------------------------------------------------------------------------
% simplifica(Pals_Possiveis, Novas_Pals_Possiveis), em que Pals_Possiveis eh uma lista de palavras possiveis,
% significa que Novas_Pals_Possiveis eh o resultado de simplificar Pals_Possiveis.

simplifica(Pals_Possiveis,Nova_Pals_Possiveis) :-
    simplifica(Pals_Possiveis,Nova_Pals_Possiveis,Pals_Possiveis).

simplifica(Pals_Possiveis,Pals_Possiveis_2,Pals_Possiveis_Orig) :-          % caso terminal
    atribui_comuns(Pals_Possiveis),
    retira_impossiveis(Pals_Possiveis,Pals_Possiveis_1),
    retira_unicas(Pals_Possiveis_1,Pals_Possiveis_2),
    Pals_Possiveis_2 == Pals_Possiveis_Orig.                 % nao houveram mudancas

simplifica(Pals_Possiveis,Nova_Pals_Possiveis,Pals_Possiveis_Orig) :-
    atribui_comuns(Pals_Possiveis),
    retira_impossiveis(Pals_Possiveis,Pals_Possiveis_1),
    retira_unicas(Pals_Possiveis_1,Pals_Possiveis_2),
    Pals_Possiveis_2 \== Pals_Possiveis_Orig,                % houveram mudancas
    simplifica(Pals_Possiveis_2,Nova_Pals_Possiveis,Pals_Possiveis_2),!.
     

%-------------------------------------------------------------------------------------------------------------
% inicializa(Puz,Pals_Possiveis) em que Puz eh um puzzle, significa que Pals_Possiveis eh a lista de palavras 
% possiveis simplificada para Puz.

inicializa([Palavras,Grelha],Final) :-
    obtem_letras_palavras(Palavras,Letras),
    espacos_puzzle(Grelha,Espacos),
    palavras_possiveis(Letras,Espacos,Pals_Possiveis),
    simplifica(Pals_Possiveis,Final).


%-------------------------------------------------------------------------------------------------------------
% escolhe_menos_alternativas(Pals_Possiveis,Escolha), em que Pals_Possiveis eh uma lista de palavras possiveis,
% significa que Escolha eh o elemento de Pals_Possiveis escolhido segundo o criterio de primeiro espaco com 
% numero minimo de palavras possiveis.

escolhe_menos_alternativas(Pals_Possiveis,Escolha) :-
    escolhe_menos_alternativas(Pals_Possiveis,Escolha,_).

escolhe_menos_alternativas([],_,Escolha_aux) :-  % Caso nao encontre nenhuma escolha possivel
    var(Escolha_aux),!,fail.

escolhe_menos_alternativas([],Escolha,Escolha). % caso terminal

escolhe_menos_alternativas([P|R],Escolha,Escolha_aux) :-
    P=[_,Palavras],
    length(Palavras,C1),
    C1 > 1,
    Escolha_aux=[_,Palavras_aux],
    length(Palavras_aux,C2),
    C1 < C2,
    escolhe_menos_alternativas(R,Escolha,P),!.

escolhe_menos_alternativas([_|R],Escolha,Escolha_aux) :-
    escolhe_menos_alternativas(R,Escolha,Escolha_aux),!.


%-------------------------------------------------------------------------------------------------------------
% predicado auxiliar de experimenta_pal/3

% substituir(Escolha,Pals_Possiveis,Pal,Novas_Pals_Possiveis), significa que Novas_Pals_Possiveis eh a lista
% Pals_Possiveis com o elemento Escolha substituido por [Esp,Pal].


substituir(Escolha,Pals_Possiveis,Pal,Novas_Pals_Possiveis) :-
    substituir(Escolha,Pals_Possiveis,Pal,Novas_Pals_Possiveis,[]). % em que [] eh um acumulador

substituir(_,[],_,Ac,Ac).  % caso terminal

substituir(Escolha,[P|R],Pal,Novas_Pals_Possiveis,Ac) :-
    Escolha == P,   % encontrou elemento que vai substituir
    Escolha=[Esp,_],
    P_Novo=[Esp,[Pal]],
    append(Ac,[P_Novo],Ac1),
    substituir(Escolha,R,Pal,Novas_Pals_Possiveis,Ac1),!.

substituir(Escolha,[P|R],Pal,Novas_Pals_Possiveis,Ac) :-
    append(Ac,[P],Ac1),
    substituir(Escolha,R,Pal,Novas_Pals_Possiveis,Ac1),!.


%-------------------------------------------------------------------------------------------------------------
% experimenta_pal(Escolha,Pals_Possiveis,Novas_Pals_Possiveis), em que Pals_Possiveis eh uma lista de palavras
% possiveis, e Escolha eh um dos seus elementos segue os seguintes passos: utiliza member para escolher uma 
% palavra de Lst_Pals, unifica com Esp e Novas_Pals_Possiveis eh o resultado de substituir em Pals_Possiveis,
% o elemento Escolha pelo elemento [Esp,[Pal]].

experimenta_pal(Escolha,Pals_Possiveis,Novas_Pals_Possiveis) :-
    Escolha=[Esp,Lst_Pals],
    member(Pal,Lst_Pals),
    Esp=Pal,
    substituir(Escolha,Pals_Possiveis,Pal,Novas_Pals_Possiveis). % vai criar Novas_Pals_Possiveis com a substituicao


%-------------------------------------------------------------------------------------------------------------
% resolve_aux(Pals_Possiveis,Novas_Pals_Possiveis), em que Pals_Possiveis eh uma lista de palavras possiveis,
% significa que Novas_Pals_Possiveis eh o resultado de aplicar 

resolve_aux(Pals_Possiveis,Nova_Pals_Possiveis) :-
    escolhe_menos_alternativas(Pals_Possiveis,Escolha),    % eventualmente da false, unificando entao com o caso terminal
    experimenta_pal(Escolha,Pals_Possiveis,Pals_Possiveis_Intermedio),
    simplifica(Pals_Possiveis_Intermedio,Pals_Possiveis_Final),
    resolve_aux(Pals_Possiveis_Final,Nova_Pals_Possiveis),!.

resolve_aux(Pals_Possiveis_Final,Pals_Possiveis_Final). % caso terminal


%-------------------------------------------------------------------------------------------------------------
% resolve(Puz), em que Puz eh um puzzle, resolve esse puzzle, isto eh, apos a invocacao deste predicado a 
% grelha de Puz tem todas as variaveis substituidas por letras que constituem as palavras da lista de palavras de Puz.
    
resolve(Puz) :-
    inicializa(Puz,Pals_Possiveis),
    resolve_aux(Pals_Possiveis,_).