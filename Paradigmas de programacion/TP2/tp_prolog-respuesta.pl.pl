%%%%%%%%%%%%%%%%%%%%%%%%
%% Predicados básicos %%
%%%%%%%%%%%%%%%%%%%%%%%%


%% Ejercicio 1
%% proceso(+P)
proceso(computar).
proceso(escribir(_,_)).
proceso(leer(_)).
proceso(secuencia(P,Q)) :-
        proceso(P),
        proceso(Q).
proceso(paralelo(P,Q)) :-
        proceso(P),
        proceso(Q).

%% Ejercicio 2
%% buffersUsados(+P,-BS)
buffersUsados(computar,[]).
buffersUsados(escribir(B,_),[B]).
buffersUsados(leer(B),[B]).
buffersUsados(secuencia(P,Q),BS) :-
        buffersUsados(P,B1),
        buffersUsados(Q,B2),
        union(B1,B2,BS).

buffersUsados(paralelo(P,Q),BS) :-
        buffersUsados(P,B1),
        buffersUsados(Q,B2),
        union(B1,B2,BS).


/*

Interpretamos que "ordenada" se refiere a ordenada según como aparecieron de izquierda a derecha los buffer en el Proceso que se pasa instanciado al predicado.

si fuera lexicograficamente simplemente seria :

buffersUsados(secuencia(P,Q),BS) :-
        buffersUsados(P,B1),
        buffersUsados(Q,B2),
        union(B1,B2,BS1),
        sort(BS1,BS).
buffersUsados(paralelo(P,Q),BS) :-
        buffersUsados(P,B1),
        buffersUsados(Q,B2),
        union(B1,B2,BS1),
        sort(BS1,BS).

en los dos ultimos casos.
*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Organización de procesos %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Ejercicio 3
%% intercalar(+XS,+YS,?ZS)
intercalar([],[],[]).
intercalar([X|XS],YS,[X|ZS]) :-
        intercalar(XS,YS,ZS).
intercalar(XS, [Y|YS], [Y|ZS]) :-
        intercalar(XS,YS,ZS).

%% Ejercicio 4
%% serializar(+P,?XS)
serializar(computar,[computar]).
serializar(leer(B),[leer(B)]).
serializar(escribir(B,E),[escribir(B,E)]).
serializar(secuencia(P,Q), XS) :-
        serializar(P,X1),
        serializar(Q,X2),
        append(X1,X2,XS).
serializar(paralelo(P,Q), XS) :-
        serializar(P,X1),
        serializar(Q,X2),
        intercalar(X1,X2,XS).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Contenido de los buffers %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Ejercicio 5
%% contenidoBuffer(+B, +ProcesoOLista, ?Contenidos)
contenidoBuffer(B, S, Contenido) :-
        not(proceso(S)),
        procesarEscrituras(B, S, [], Contenido).
contenidoBuffer(B, P, Contenido) :-
        proceso(P),
        serializar(P, S),
        procesarEscrituras(B, S, [], Contenido).

%procesarEscrituras(+B, +PoL, +Actual, -Final).
procesarEscrituras(_, [], Actual, Actual).
procesarEscrituras(B, [escribir(B, E)|PoLS], Actual, Final) :-
        append(Actual, [E], ActualMasUnEscribir),
        procesarEscrituras(B, PoLS, ActualMasUnEscribir, Final).
procesarEscrituras(B, [escribir(B1, _)|PoLS], Actual, Final) :-
        B \= B1,
        procesarEscrituras(B, PoLS, Actual, Final).
procesarEscrituras(B, [computar|PoLS], Actual, Final) :-
        procesarEscrituras(B, PoLS, Actual, Final).
procesarEscrituras(B, [leer(B)|PoLS], Actual, Final) :-
        Actual \= [],
        eliminarPrimero(Actual, ActualMenosUnEscribir),
        procesarEscrituras(B, PoLS, ActualMenosUnEscribir, Final).
procesarEscrituras(B, [leer(B1)|PoLS], Actual, Final) :-
        B \= B1,
        procesarEscrituras(B, PoLS,Actual,Final).

%%eliminarPrimero(?XS, ?YS).
eliminarPrimero([_|XS], XS).


%% Ejercicio 6
%% contenidoLeido(+ProcesoOLista,?Contenidos)
contenidoLeido(P, C) :- proceso(P), serializar(P,S), contenidoLeidoAux(S, [], [], C).
contenidoLeido(S, C) :- not(proceso(S)), contenidoLeidoAux(S, [], [], C).

% contenidoLeidoAux(+ SeriePorProcesar, + ProcesadoHastaAhora, +LeidoHastaAhora, -LeidoFinal).
contenidoLeidoAux([],_,L,L).
contenidoLeidoAux([computar|Serie], ProcesadoAntes, Leido, Final) :-
        append(ProcesadoAntes, [computar], ProcesadoAhora),
        contenidoLeidoAux(Serie, ProcesadoAhora, Leido, Final).
contenidoLeidoAux([escribir(B,E)|Serie], ProcesadoAntes, Leido, Final) :-
        append(ProcesadoAntes, [escribir(B,E)], ProcesadoAhora),
        contenidoLeidoAux(Serie, ProcesadoAhora, Leido, Final).
contenidoLeidoAux([leer(B)|Serie], ProcesadoAntes, LeidoAntes, Final) :-
        contenidoBuffer(B, ProcesadoAntes, [C|_]),
        append(LeidoAntes,[C],LeidoAhora),
        append(ProcesadoAntes, [leer(B)], ProcesadoAhora),
        contenidoLeidoAux(Serie, ProcesadoAhora, LeidoAhora,Final).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Contenido de los buffers %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Ejercicio 7
%% esSeguro(+P)


/*
para que sea seguro nos importa:
1- que no haya subprocesos paralelos que compartan buffers
2- que sean ejecuciones seguras, que no intente leer memoria vacia.

cuando son compartidos los buffers, podria haber una serializacion que de false y otra true para la lectura.
todos los casos que comparten buffers nos los sacamos de encima, es decir, devolvemos false en caso de que pase, con el segundo predicado: "subprocesosNoCompartenBuffers(P)".

Ahora:
De qué forma nos podemos encontrar el leer leyendo memoria vacia? puede ser:
caso secuencia: que aparezca un leer antes que un escribir.
caso paralelo: no nos importa, porque ya esta cubierto por la funcion "subprocesosNoCompartenBuffers" en caso de que sean compartidos, y las serializaciones nos generen
distintos resultados (true o false).
Si no comparten buffers, no pasa nada porque solo importa adentro del subproceso, por ejemplo, entrando en el caso secuencia otra vez.
Al ser distintos buffers, las distintas serializaciones no pueden generar un resultado en el que una variante en su orden pueda dar distinto.
(en este caso es siempre true o siempre false, sin importar el orden de los subprocesos, es decir las serializaciones son siempre legibles o no legibles).
*/

esSeguro(P):-
        algunaSerieNoIntentaLeerBufferVacio(P),
        subprocesosNoCompartenBuffers(P).

algunaSerieNoIntentaLeerBufferVacio(P) :-
        not(not(contenidoLeido(P,_))).

subprocesosNoCompartenBuffers(computar).
subprocesosNoCompartenBuffers(escribir(_,_)).
subprocesosNoCompartenBuffers(leer(_)).
subprocesosNoCompartenBuffers(secuencia(P,Q)):-
        subprocesosNoCompartenBuffers(P),
        subprocesosNoCompartenBuffers(Q).
subprocesosNoCompartenBuffers(paralelo(P,Q)):-
        buffersUsados(P,PS),
        buffersUsados(Q,QS),
        distintosElementos(PS,QS),
        subprocesosNoCompartenBuffers(P),
        subprocesosNoCompartenBuffers(Q).

distintosElementos(XS,YS):-
        not((member(X,XS),member(X,YS))).




%% Ejercicio 8
%% ejecucionSegura(?XS,+BS,+CS).

ejecucionSegura(XS,BS,CS):-
        nonvar(XS),
        noLeeBufferVacio(XS),
        ejecucionCorrecta(XS,BS,CS).
ejecucionSegura(XS,BS,CS):-
        var(XS),
        desde(0,N),
        funcionQueCalculaPosibilidades(BS,CS,N,XS),
        noLeeBufferVacio(XS).
        
%funcionQueCalculaPosibilidades(+ListaBuffers, +ListaEscrituras, -Longitud, -ListaFinal).
funcionQueCalculaPosibilidades(ListaBuffers, ListaEscrituras, 0 , [ ]).
funcionQueCalculaPosibilidades(BS, CS, L, [computar | ListaFinal]) :-
        L1 is L - 1 ,
        L1 >= 0 ,
        funcionQueCalculaPosibilidades(BS, CS, L1, ListaFinal).
funcionQueCalculaPosibilidades(BS, CS, L, [escribir(X,Y) | ListaFinal]) :-
        member(X,BS),
        member(Y,CS),
        L1 is L-1,
        L1 >= 0,
        funcionQueCalculaPosibilidades(BS, CS, L1, ListaFinal).
funcionQueCalculaPosibilidades(BS, CS, L, [leer(X) | ListaFinal]) :-
        member(X,BS),
        L1 is L - 1 ,
        L1 >= 0 ,
        funcionQueCalculaPosibilidades(BS, CS, L1, ListaFinal).

desde(X, X).
desde(X, Y) :- nonvar(Y), X =< Y.
desde(X, Y) :- var(Y), N is X+1, desde(N, Y).

%contenidoLeido se encarga de darnos false si no se puede leer la ejecucion, y true si se puede leer.
%noLeeBufferVacio(+Ejecucion).
noLeeBufferVacio(Ejecucion):-
      contenidoLeido(Ejecucion,_).


%%este predicado se fija que lo que esta escrito en XS, se corresponda con las dos listas BS y CS
%ejecucionCorrecta(+ XS, +BS, +CS).
ejecucionCorrecta([], _, _).
ejecucionCorrecta([computar | LS], BS, CS) :-
        ejecucionCorrecta(XS, BS, CS).
ejecucionCorrecta([leer(B) | LS], BS, CS) :-
        member(B, BS),
        ejecucionCorrecta(XS, BS).
ejecucionCorrecta([escribir(B, C) | LS], BS, CS) :-
        member(B, BS),
        member(C, CS),
        ejecucionCorrecta(LS, BS, CS).









  %% 8.1. Analizar la reversibilidad de XS, justificando adecuadamente por qué el predicado se comporta como lo hace.

  /*
  En nuestro caso el predicado sobre el argumento XS es reversible, y devuelve true y false correctamente.
  Sin embargo , si sólo tuvieramos el caso:

  ejecucionSegura(XS,BS,CS):-
        desde(0,N),
        funcionQueCalculaPosibilidades(BS,CS,N,XS),
        noLeeBufferVacio(XS).

 e intentásemos correr el predicado ejecucionSegura con XS instanciado, el programa se cuelga luego del primer true,
 y si damos un XS que deberia hacerlo false, se cuelga sin devolver nada.

La razón es que el predicado "desde" seguiría incrementando los N y generando posibilidades aun luego de encontrar una combinacion identica a la XS instanciada que pasamos.
Esto es porque prolog sigue haciendo backtracking buscando mas combinaciones que sean iguales a la XS instanciada que pasamos al predicado, es decir
sigue buscando combinaciones que hagan que nuestro predicado sea verdadero.
Como N sigue incrementando por el funcionamiento de "desde" , las soluciones que sigue buscando prolog siempre seran listas distintas o de longitud mas grande que la XS instanciada, por lo tanto 
nunca encontrará una que unifique devuelta.

Y en caso de pasar una instancia XS que haría falso al predicado, de igual manera,
simplemente se sigue buscando una solucion "infinitamente", tanto que nos quedamos sin memoria buscando combinaciones con un N cada vez mas grande.
  */



%%%%%%%%%%%
%% TESTS %%
%%%%%%%%%%%

cantidadTestsBasicos(9).

testBasico(1) :-
        proceso(computar).
testBasico(2) :-
        proceso(secuencia(escribir(1,pepe),escribir(2,pipo))).
testBasico(3) :-
        proceso(paralelo(leer(2),secuencia(escribir(1,agua),leer(1)))).
testBasico(4) :-
        proceso(escribir(4,jose)).
testBasico(5) :-
        proceso(leer(10)).

testBasico(6) :-
        buffersUsados(escribir(1, hola), [1]).
testBasico(7) :-
        buffersUsados(paralelo(leer(2),secuencia(escribir(1,agua),leer(1))), [2, 1]).
testBasico(8) :-
        buffersUsados(secuencia(leer(2),secuencia(leer(3),leer(1))), [2, 3, 1]).
testBasico(9) :-
        buffersUsados((computar), []).



cantidadTestsProcesos(1).

testProcesos(1) :-
        intercalar([1,2,3],[4,5,6], [1,2,3,4,5,6]).
testProcesos(2) :-
        intercalar([1,2,3],[4,5,6], [4,5,6,1,2,3]).
testProcesos(3) :-
        intercalar([],[a,b,c], [a,b,c]).
testProcesos(4) :-
        intercalar([a,b,c],[], [a,b,c]).
testProcesos(5) :-
        intercalar([a,b,c],[c,b,a], [c,b,a,a,b,c]).
testProcesos(6) :-
        intercalar([],[], []).
testProcesos(7) :-
        intercalar([2,2,2],[2,2,2], [2,2,2,2,2,2]).

testProcesos(8) :-
        serializar(secuencia(computar,leer(2)),[computar,leer(2)]).
testProcesos(9) :-
        serializar(paralelo(paralelo(leer(1),leer(2)),secuencia(leer(3),leer(4))),[leer(1),leer(3),leer(2),leer(4)]).
testProcesos(10) :-
        serializar(computar,[]).
testProcesos(11) :-
        serializar(leer(5),[leer(5)]).
testProcesos(12) :-
        serializar(escribir(5, a),[escribir(5, a)]).



cantidadTestsBuffers(5).
testBuffers(1) :-
        contenidoBuffer(1,[escribir(1,pa),escribir(2,ma),escribir(1,hola),
        computar,escribir(1,mundo),leer(1)],[hola, mundo]).
testBuffers(2) :-
        contenidoBuffer(2,[escribir(1,pa),escribir(2,ma),escribir(1,hola),
        computar,escribir(1,mundo),leer(1)],[ma]).
testBuffers(3) :-
        contenidoBuffer(2,paralelo(escribir(2,sol),secuencia(escribir(1,agua),leer(1))),[sol]).
testBuffers(4) :-
        contenidoBuffer(1,paralelo(escribir(2,sol),secuencia(escribir(1,agua),leer(1))),[]).

testBuffers(5) :-
         contenidoBuffer(1,paralelo(leer(1),escribir(1,agua)),[]).


contenidoTestLeido(3).
testLeido(1) :-
        contenidoLeido(paralelo(secuencia(escribir(2,sol),leer(2)),
        secuencia(escribir(1,agua),leer(1))),[sol, agua]).
testLeido(2) :-
        contenidoLeido([escribir(1, agua), escribir(2, sol), leer(1), leer(1)],false).

testLeido(3) :-
        contenidoLeido(paralelo(secuencia(escribir(2,sol),secuencia(leer(2),escribir(2,agua))),
        secuencia(leer(2),computar)),[sol, agua]).


cantidadTestsSeguros(6).
testSeguros(1) :-
        not(esSeguro(secuencia(leer(1),escribir(1,agua)))).

testSeguros(2) :-
        esSeguro(secuencia(escribir(1,agua),leer(1))).

testSeguros(3) :-
        not(esSeguro(paralelo(escribir(1,sol),secuencia(escribir(1,agua),leer(1))))).

testSeguros(4) :-
        esSeguro(paralelo(escribir(2,sol),secuencia(escribir(1,agua),leer(1)))).

testSeguros(5) :-
        esSeguro(computar).

testSeguros(6) :-
        not(esSeguro(leer(1))).


cantTestEsEjecucionSegura(4).
testEjecucion(1) :-
        ejecucionSegura([escribir(1, a), escribir(1, a)] ,[1,2],[a,b]).
testEjecucion(2) :-
         ejecucionSegura([computar] ,[],[]).
testEjecucion(3) :-
         ejecucionSegura([escribir(1, a), escribir(1, a), computar] ,[1],[a]).
testEjecucion(4) :-
         ejecucionSegura([escribir(8,c)] ,[1,2,8],[a,b,c]).



tests(basico) :-
        cantidadTestsBasicos(M),
        forall(between(1,M,N), testBasico(N)).
tests(procesos) :-
        cantidadTestsProcesos(M),
        forall(between(1,M,N), testProcesos(N)).
tests(buffers) :-
        cantidadTestsBuffers(M),
        forall(between(1,M,N), testBuffers(N)).
tests(seguros) :-
        cantidadTestsSeguros(M),
        forall(between(1,M,N), testSeguros(N)).
tests(ejecucion):-
        cantTestEsEjecucionSegura(M),
        forall(between(1,M,N), cantTestEsEjecucionSegura(M)).
tests(leido):-
        contenidoTestLeido(M),
        forall(between(1,M,N), contenidoTestLeido(M)).

tests(todos) :-
        tests(basico),
        tests(procesos),
        tests(buffers),
        tests(seguros),
        tests(ejecucion).

tests :-
        tests(todos).
