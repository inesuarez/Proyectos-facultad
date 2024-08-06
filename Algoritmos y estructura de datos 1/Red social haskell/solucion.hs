module Solucion where

-- Nombre de Grupo: Academic avengers
-- Integrante 1: Ines Suarez, ine.suarez22@gmail.com, 890/22
-- Integrante 2: Joaquin Novoa, nojoaco2003@gmail.com, 1043/22
-- Integrante 3: Lucio Tag, luciotag2011@gmail.com, 876/22
-- Integrante 4: Solana Navarro, solanan3@gmail.com, 906/22


type Usuario = (Integer, String) -- (id, nombre)
type Relacion = (Usuario, Usuario) -- usuarios que se relacionan
type Publicacion = (Usuario, String, [Usuario]) -- (usuario que publica, texto publicacion, likes)
type RedSocial = ([Usuario], [Relacion], [Publicacion])


-- Funciones basicas

usuarios :: RedSocial -> [Usuario]
usuarios (us, _, _) = us

relaciones :: RedSocial -> [Relacion]
relaciones (_, rs, _) = rs

publicaciones :: RedSocial -> [Publicacion]
publicaciones (_, _, ps) = ps

idDeUsuario :: Usuario -> Integer
idDeUsuario (id, _) = id

nombreDeUsuario :: Usuario -> String
nombreDeUsuario (_, nombre) = nombre

usuarioDePublicacion :: Publicacion -> Usuario
usuarioDePublicacion (u, _, _) = u

likesDePublicacion :: Publicacion -> [Usuario]
likesDePublicacion (_, _, us) = us

-- Funciones auxiliares generales
-- Decidimos generar las funciones pertenece, eliminarRepetidos y mismosElementos de una forma general, asi lo podiamos utilizar cuando las necesitabamos.

pertenece :: (Eq t) => t -> [t] -> Bool
pertenece t [] = False
pertenece t (h:hs) | t == h = True
                   | otherwise = pertenece t hs

eliminarRepetidos :: (Eq t) => [t] -> [t]
eliminarRepetidos [] = []
eliminarRepetidos (h:hs) | pertenece h hs == False = h : eliminarRepetidos hs
                         | otherwise = eliminarRepetidos hs

mismosElementos :: (Eq t) => [t] -> [t] -> Bool
mismosElementos [] [] = True
mismosElementos [] (x:xs) = False
mismosElementos (h:hs) [] = False
mismosElementos (h:hs) (x:xs) | pertenece h (x:xs) = True
                              | otherwise = mismosElementos hs (x:xs)


-- EJERCICIO 1     
-- nombresDeUsuarios nos da una lista de nombres de los usuarios de la red social dada sin repetirlos.              
proyectarNombres :: [Usuario] -> [String] --Le damos una lista de usuarios y nos devuelve una lista con solo los nombres.
proyectarNombres [] = []
proyectarNombres (u:us) = nombreDeUsuario u : proyectarNombres us 


nombresDeUsuarios :: RedSocial -> [String] 
nombresDeUsuarios red = eliminarRepetidos (proyectarNombres (usuarios(red)))


-- EJERCICIO 2
-- amigosDe te da los amigos del usuario de la lista de relaciones de la red social dada sin repetirlos.
relacion1 :: Relacion-> Usuario --Te da el primer usuario de una relacion.
relacion1 (us1,_) = us1

relacion2 :: Relacion-> Usuario --Te da el segundo usuario de una relacion.
relacion2 (_, us2) = us2

estaIncluido :: Usuario-> Relacion -> Int --Te da 1 o 2 segun la ubicacion del usuario en la relacion y 0 si no pertenece a la relacion.
estaIncluido u r | u == relacion1(r)= 1
                 | u == relacion2(r)= 2
                 | otherwise= 0

amigos :: Usuario-> [Relacion]->[Usuario] --Te da la lista de amigos del usuario dado.
amigos u [] = []
amigos u (r:rs) | estaIncluido u r == 1 = relacion2(r) : amigos u rs
                | estaIncluido u r == 2 = relacion1(r) : amigos u rs
                | otherwise = amigos u rs

amigosDe :: RedSocial -> Usuario -> [Usuario]
amigosDe red u = eliminarRepetidos (amigos u (relaciones red))


-- EJERCICIO 3
-- cantidadDeAmigos te da la longitud de la lista de los amigos del usuario en la red social dada.

longdeLista :: [Usuario] -> Integer --Te da la longitud de una lista de usuarios. 
longdeLista [] = 0
longdeLista (u:us) = 1 + longdeLista us

cantidadDeAmigos :: RedSocial -> Usuario -> Integer
cantidadDeAmigos red u = longdeLista (amigosDe red u)

--Ejercicio 4
-- usuarioConMasAmigos te da al usuario con el mayor número de amigos entre todos los usuarios de la red social dada.

mayorNumero ::  RedSocial-> [Usuario]-> Usuario --Te da el usuario con el mayor numero de amigos.
mayorNumero red (u1:[]) = u1
mayorNumero red (u1:u2:us)|cantidadDeAmigos red u1 > cantidadDeAmigos red u2 = mayorNumero red  (u1:us)
                          |otherwise = mayorNumero red (u2:us)

                       
usuarioConMasAmigos :: RedSocial -> Usuario
usuarioConMasAmigos red = mayorNumero red (usuarios(red))                  

--Ejercicio 5
--estaRobertoCarlos se fija si hay algun usuario con mas de 10 amigos en los usuarios de la red social dada.

mayorA10 :: RedSocial-> [Usuario]-> Bool --Te dice si hay algun usuario con mas de 10 amigos en una lista dad.
mayorA10 red [] = False
mayorA10 red (u:us) |cantidadDeAmigos red u > 10 = True
                    |otherwise = mayorA10 red us

estaRobertoCarlos :: RedSocial -> Bool 
estaRobertoCarlos red = mayorA10 red (usuarios(red))

--Ejercicio 6
-- publicacionesDe te da la lista de publicaciones de un usuario en una red social dada sin repetidas.

textoPublicado :: Publicacion -> String --Te da el texto de una publicacion.
textoPublicado (_,txt,_) = txt
                               
publicacionesUsuario :: [Publicacion]-> Usuario -> [Publicacion] --Te da una lista de las publicaciones de un usuario.
publicacionesUsuario [] u = []
publicacionesUsuario (p:ps) u | usuarioDePublicacion p == u = p : publicacionesUsuario ps u    
                              | otherwise = publicacionesUsuario ps u                

publicacionesDe :: RedSocial -> Usuario -> [Publicacion]
publicacionesDe red u = publicacionesUsuario (eliminarRepetidos(publicaciones(red))) u

--Ejercicio 7
-- publicacionesQueLeGustanA te da la lista de publicaciones que le gustan a un usuario en un red social dada sin repetirlas.

listaDePublicaciones :: Usuario -> [Publicacion]-> [Publicacion] --Te da una lista de las publicaciones que le gustan a un usuario.
listaDePublicaciones u [] = []
listaDePublicaciones u (p:ps) | pertenece u (likesDePublicacion p) == True = p : listaDePublicaciones u ps
                              | otherwise = listaDePublicaciones u ps
                           
                             
publicacionesQueLeGustanA :: RedSocial -> Usuario -> [Publicacion]
publicacionesQueLeGustanA red u = eliminarRepetidos(listaDePublicaciones u (publicaciones(red)))

--Ejercicio 8
-- lesGustanLasMismasPublicaciones compara si las listas de publicaciones que les gustan a u1 y u2 son iguales y si lo son, la función devuelve True. Si las listas de publicaciones son diferentes, devuelve False.

lesGustanLasMismasPublicaciones :: RedSocial -> Usuario -> Usuario -> Bool
lesGustanLasMismasPublicaciones red u1 u2 = mismosElementos (publicacionesQueLeGustanA red u1) (publicacionesQueLeGustanA red u2)

--Ejercicio 9
-- tieneUnSeguidorFiel se fija si existe al menos un usuario que le gusten todas las publicaciones del usuario dado en la red social dada, si existe, devuelve True, si no existe, devuelve False.

leGustaA :: Publicacion -> Usuario-> Bool --Te da True si a un usuario le gusta una publicacion dada, sino te da False.
leGustaA pub u = pertenece u (likesDePublicacion pub)

leGustanTodas :: [Publicacion] -> Usuario -> Bool --Te da True si a un usuario le gustan todas las publicaciones de una lista de publicaciones, sino te da False.
leGustanTodas [] u = True
leGustanTodas (p:ps) u | leGustaA p u == True = leGustanTodas ps u
                       | otherwise = False


existeLeGustanTodas :: [Publicacion] -> [Usuario] -> Bool --Te da true si existe algun usuario al cual le gusten todas las publicaciones de cierto usuario dado, sino te da False.
existeLeGustanTodas (p:ps) [] = False
existeLeGustanTodas [] (u:us) = False
existeLeGustanTodas (p:ps) (u:us) | leGustanTodas (p:ps) u == True = True  
                                  | otherwise = existeLeGustanTodas (p:ps) us              


tieneUnSeguidorFiel :: RedSocial -> Usuario -> Bool
tieneUnSeguidorFiel red u = existeLeGustanTodas (publicacionesDe red u) (usuarios(red))


--Ejercicio 10
-- existeSecuenciaDeAmigos te da True si existe una forma de armar una lista que arranque con el primer usuario dado, termine con el segundo y cada usuario se relacione con el de al lado, sino te da False.
cadenaDeAmigos :: RedSocial -> Usuario -> [Usuario] -> [Usuario] -> Bool 
cadenaDeAmigos red u2 [] (x:xs) = False
cadenaDeAmigos red u2 (u:us) (x:xs) | pertenece u (x:xs) == True = cadenaDeAmigos red u2 us (x:xs)
                                    | u == u2 = True
                                    | otherwise = cadenaDeAmigos red u2 (amigosDe red u ++ us) ((x:xs) ++ [u]) --Te da True si se puede armar una secuencia de amigos tal que cada usuario sea amigo del de al lado y la lista arranque con el primer usuario y termine con el segundo.

existeSecuenciaDeAmigos :: RedSocial -> Usuario -> Usuario -> Bool
existeSecuenciaDeAmigos red u1 u2 = cadenaDeAmigos red u2 (amigosDe red u1) [u1]
