module Tests where

import Test.HUnit
import Solucion

main = runTestTT todosLosTest
todosLosTest = test [testSuite1nombresDeUsuarios, testSuite2amigosDe, testSuite3cantidadDeAmigos, testSuite4usuarioConMasAmigos, testSuite5estaRobertoCarlos, testSuite6publicacionesDe, testSuite7publicacionesQueLeGustanA, testSuite8lesGustanLasMismasPublicaciones, testSuite9tieneUnSeguidorFiel, testSuite10existeSecuenciaDeAmigos] 

-- Casos de Testo
run1 = runTestTT testSuite1nombresDeUsuarios
run2 = runTestTT testSuite2amigosDe
run3 = runTestTT testSuite3cantidadDeAmigos
run4 = runTestTT testSuite4usuarioConMasAmigos
run5 = runTestTT testSuite5estaRobertoCarlos
run6 = runTestTT testSuite6publicacionesDe
run7 = runTestTT testSuite7publicacionesQueLeGustanA
run8 = runTestTT testSuite8lesGustanLasMismasPublicaciones
run9 = runTestTT testSuite9tieneUnSeguidorFiel
run10 = runTestTT testSuite10existeSecuenciaDeAmigos




-- El orden de las listas que dan nuestras implementaciones nos dan en ese orden especifico, pero si otra persona usa otra implementacion podria dar en otro orden y podria saltar un error a pesar de que las implementaciones esten bien hechas y den lo que tienen que dar. Se podria solucionar haciendo una funcion de permutacion y que permita cualquier orden en las listas.
testSuite1nombresDeUsuarios = test [
    "Caso 1: No hay Usuarios" ~: (nombresDeUsuarios red0) ~?= [] ,
    "Caso 2: Hay un Usuario" ~: (nombresDeUsuarios red1) ~?= ["Juan"],
    "Caso 3: Hay mas de un Usuario y hay un nombre repetido" ~: (nombresDeUsuarios redA) ~?= ["Juan","Natalia","Pedro","Mariela"],
    "Caso 4: Hay mas de un Usuario y no hay nombres repetidos" ~: (nombresDeUsuarios red3) ~?= ["Juan","Natalia","Pedro","Jose","Lucas","Isabella","Azul"]   
 ]


testSuite2amigosDe = test [
    "Caso 1: Hay un Usuario" ~: (amigosDe red1 usuario1) ~?= [] ,
    "Caso 2: No tiene Amigos" ~: (amigosDe redB usuario5) ~?= [] ,
    "Caso 3: Tiene un Amigo" ~: (amigosDe redB usuario1) ~?= [(2, "Natalia")],
    "Caso 4: Hay mas de un Amigo y no hay repetidos" ~: (amigosDe redA usuario4) ~?= [(1, "Juan"),(2, "Natalia"),(3, "Pedro")],
    "Caso 5: Hay mas de un Amigo y hay repetidos" ~: (amigosDe red3 usuario9) ~?= [(10,"Lucas"),(11,"Isabella"),(12,"Azul")]
 ]


testSuite3cantidadDeAmigos = test [
    "Caso 1: Hay un Usuario" ~: (cantidadDeAmigos red1 usuario1) ~?= 0 ,
    "Caso 2: No tiene Amigos" ~: (cantidadDeAmigos redB usuario5) ~?= 0 ,
    "Caso 3: Tiene un Amigo" ~: (cantidadDeAmigos redB usuario1) ~?= 1 ,
    "Caso 4: Hay mas de un Amigo" ~: (cantidadDeAmigos redA usuario4) ~?= 3
 ]  

testSuite4usuarioConMasAmigos = test [
    "Caso 1: Hay un Usuario" ~: (usuarioConMasAmigos red1) ~?= (1, "Juan") ,
    "Caso 2: Hay mas de un Usuario" ~: (usuarioConMasAmigos redB) ~?= (2, "Natalia")
 ]


testSuite5estaRobertoCarlos = test [
    "Caso 1: No hay Usuarios" ~: (estaRobertoCarlos red0) ~?= False ,
    "Caso 2: Hay un usuario" ~: (estaRobertoCarlos red1) ~?= False,
    "Caso 3: No hay un usuario con mas de 10 amigos" ~: (estaRobertoCarlos redA) ~?= False,  
    "Caso 4: Hay un usuario con mas de 10 amigos" ~: (estaRobertoCarlos red2) ~?= True
 ]

testSuite6publicacionesDe = test [
    "Caso 1: El usuario no hizo publicaciones" ~: (publicacionesDe redB usuario2) ~?= [],
    "Caso 2: El usuario hizo una publicacion" ~: (publicacionesDe red1 usuario1 ) ~?= [(usuario1, "Vacaciones en Brasil, adjunto foto", [])],
    "Caso 3: El usuario hizo mas de una publicacion y no esta repetida" ~: (publicacionesDe redA usuario4) ~?= [(usuario4, "I am Alice. Not", [usuario1, usuario2]),(usuario4, "I am Bob", [])]  
 ]

testSuite7publicacionesQueLeGustanA = test [
    "Caso 1: Al ususario no le gusta ninguna publicacion" ~: (publicacionesQueLeGustanA redB usuario3) ~?= [],
    "Caso 2: Al usuario le gusta una publicacion" ~: (publicacionesQueLeGustanA red2 usuario2 ) ~?= [(usuario3, "dolor sit amet", [usuario2])],
    "Caso 3: Al usuario le gusta mas de una publicacion y no hay repetidas" ~: (publicacionesQueLeGustanA redA usuario4) ~?=[(usuario1, "Este es mi primer post", [usuario2, usuario4]),(usuario1, "Este es mi segundo post", [usuario4]), (usuario2, "Hello World", [usuario4]), (usuario2, "Good Bye World", [usuario1, usuario4])]  
 ]

testSuite8lesGustanLasMismasPublicaciones = test [
    "Caso 1: No le gusta ninguna a u1 ni a u2" ~: (lesGustanLasMismasPublicaciones redA usuario3 usuario5) ~?= True,
    "Caso 2: No le gusta ninguna a u1" ~: (lesGustanLasMismasPublicaciones redA usuario3 usuario4) ~?= False,
    "Caso 3: No le gusta ninguna a u2" ~: (lesGustanLasMismasPublicaciones redA usuario1 usuario5) ~?= False,  
    "Caso 4: No les gustan las mismas" ~: (lesGustanLasMismasPublicaciones redA usuario1 usuario3) ~?= False,
    "Caso 5: Les gustan las mismas" ~: (lesGustanLasMismasPublicaciones redB usuario2 usuario5) ~?= True,
    "Caso 6: u1 y u2 son el mismo usuario" ~: (lesGustanLasMismasPublicaciones redA usuario1 usuario1) ~?= True
 ]

testSuite9tieneUnSeguidorFiel = test [
    "Caso 1: No tiene publicaciones el Usuario" ~: (tieneUnSeguidorFiel redA usuario5) ~?= False,
    "Caso 2: No tiene seguidor fiel" ~: (tieneUnSeguidorFiel redA usuario3) ~?= False,
    "Caso 3: Tiene seguidor fiel" ~: (tieneUnSeguidorFiel redA usuario2) ~?= True  
 ]
 
testSuite10existeSecuenciaDeAmigos = test [
    "Caso 1: No tiene amigos u1" ~: (existeSecuenciaDeAmigos redA usuario5 usuario1) ~?= False,
    "Caso 2: No tiene amigos u2" ~: (existeSecuenciaDeAmigos redB usuario3 usuario4) ~?= False,
    "Caso 3: No hay cadena de amigos" ~: (existeSecuenciaDeAmigos red3 usuario1 usuario9) ~?= False,  
    "Caso 4: Hay cadena de amigos" ~: (existeSecuenciaDeAmigos redA usuario1 usuario3) ~?= True,
    "Caso 5: u1 y u2 son el mismo usuario y tiene amigos" ~: (existeSecuenciaDeAmigos redA usuario1 usuario1) ~?= False,
    "Caso 6: u1 y u2 son el mismo usuario y no tiene amigos" ~: (existeSecuenciaDeAmigos red1 usuario1 usuario1) ~?= False
 ] 

expectAny actual expected = elem actual expected ~? ("expected any of: " ++ show expected ++ "\n but got: " ++ show actual)

-- Ejemplos

usuario1 = (1, "Juan")
usuario2 = (2, "Natalia")
usuario3 = (3, "Pedro")
usuario4 = (4, "Mariela")
usuario5 = (5, "Natalia")
usuario6 = (6, "Analia")
usuario7 = (7, "Juana")
usuario8 = (8, "Nicolas")
usuario9 = (9, "Jose")
usuario10 = (10, "Lucas")
usuario11 = (11, "Isabella")
usuario12 = (12, "Azul")

relacion1_2 = (usuario1, usuario2)
relacion1_3 = (usuario1, usuario3)
relacion1_4 = (usuario4, usuario1) -- Notar que el orden en el que aparecen los usuarios es indistinto
relacion2_3 = (usuario3, usuario2)
relacion2_4 = (usuario2, usuario4)
relacion3_4 = (usuario4, usuario3)
relacion1_5 = (usuario1, usuario5)
relacion1_6 = (usuario1, usuario6)
relacion1_7 = (usuario1, usuario7)
relacion1_8 = (usuario1, usuario8)
relacion1_9 = (usuario1, usuario9)
relacion1_10 = (usuario1, usuario10)
relacion1_11 = (usuario1, usuario11)
relacion1_12 = (usuario1, usuario12)
relacion9_10 = (usuario9, usuario10)
relacion9_11 = (usuario9, usuario11)
relacion9_12 = (usuario9, usuario12)
relacion12_9 = (usuario12, usuario9)

publicacion1_1 = (usuario1, "Este es mi primer post", [usuario2, usuario4])
publicacion1_2 = (usuario1, "Este es mi segundo post", [usuario4])
publicacion1_3 = (usuario1, "Este es mi tercer post", [usuario2, usuario5])
publicacion1_4 = (usuario1, "Este es mi cuarto post", [])
publicacion1_5 = (usuario1, "Este es como mi quinto post", [usuario5])

publicacion2_1 = (usuario2, "Hello World", [usuario4])
publicacion2_2 = (usuario2, "Good Bye World", [usuario1, usuario4])

publicacion3_1 = (usuario3, "Lorem Ipsum", [])
publicacion3_2 = (usuario3, "dolor sit amet", [usuario2])
publicacion3_3 = (usuario3, "consectetur adipiscing elit", [usuario2, usuario5])

publicacion4_1 = (usuario4, "I am Alice. Not", [usuario1, usuario2])
publicacion4_2 = (usuario4, "I am Bob", [])
publicacion4_3 = (usuario4, "Just kidding, i am Mariela", [usuario1, usuario3])

publicacion1_c = (usuario1, "Vacaciones en Brasil, adjunto foto", [])

usuariosA = [usuario1, usuario2, usuario3, usuario4]
relacionesA = [relacion1_2, relacion1_4, relacion2_3, relacion2_4, relacion3_4]
publicacionesA = [publicacion1_1, publicacion1_2, publicacion2_1, publicacion2_2, publicacion3_1, publicacion3_2, publicacion4_1, publicacion4_2]
redA = (usuariosA, relacionesA, publicacionesA)

usuariosB = [usuario1, usuario2, usuario3, usuario5]
relacionesB = [relacion1_2, relacion2_3]
publicacionesB = [publicacion1_3, publicacion1_4, publicacion1_5, publicacion3_1, publicacion3_2, publicacion3_3]
redB = (usuariosB, relacionesB, publicacionesB)

red0 = ([], [], [])

usuariosC = [usuario1]
relacionesC = []
publicacionesC = [publicacion1_c]
red1 = (usuariosC, relacionesC, publicacionesC)

usuariosD = [usuario1, usuario2, usuario3, usuario4, usuario5, usuario6, usuario7, usuario8, usuario9, usuario10, usuario11, usuario12]
relacionesD = [relacion1_2, relacion1_3, relacion1_4, relacion1_5, relacion1_6, relacion1_7, relacion1_8, relacion1_9, relacion1_10, relacion1_11, relacion1_12]
publicacionesD = [publicacion3_1, publicacion3_2]
red2 = (usuariosD, relacionesD, publicacionesD)


usuariosE = [usuario1, usuario2, usuario3, usuario9, usuario10, usuario11, usuario12]
relacionesE = [relacion9_10, relacion9_11, relacion9_12, relacion12_9, relacion1_8, relacion1_7]
publicacionesE = [publicacion1_1, publicacion3_2]
red3 = (usuariosE, relacionesE, publicacionesE)
















