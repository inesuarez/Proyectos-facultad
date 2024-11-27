module Proceso (Procesador, AT(Nil,Tern), RoseTree(Rose), Trie(TrieNodo), foldAT, foldRose, foldTrie, procVacio, procId, procCola, procHijosRose, procHijosAT, procRaizTrie, procSubTries, unoxuno, sufijos, inorder, preorder, postorder, preorderRose, hojasRose, ramasRose, caminos, palabras, ifProc,(++!), (.!)) where

import Test.HUnit


--Definiciones de tipos

type Procesador a b = a -> [b]


-- Árboles ternarios
data AT a = Nil | Tern a (AT a) (AT a) (AT a) deriving Eq
--E.g., at = Tern 1 (Tern 2 Nil Nil Nil) (Tern 3 Nil Nil Nil) (Tern 4 Nil Nil Nil)
--Es es árbol ternario con 1 en la raíz, y con sus tres hijos 2, 3 y 4.

-- RoseTrees
data RoseTree a = Rose a [RoseTree a] deriving Eq
--E.g., rt = Rose 1 [Rose 2 [], Rose 3 [], Rose 4 [], Rose 5 []] 
--es el RoseTree con 1 en la raíz y 4 hijos (2, 3, 4 y 5)

-- Tries
data Trie a = TrieNodo (Maybe a) [(Char, Trie a)] deriving Eq
-- E.g., t = TrieNodo (Just True) [('a', TrieNodo (Just True) []), ('b', TrieNodo Nothing [('a', TrieNodo (Just True) [('d', TrieNodo Nothing [])])]), ('c', TrieNodo (Just True) [])]
-- es el Trie Bool de que tiene True en la raíz, tres hijos (a, b, y c), y, a su vez, b tiene como hijo a d.
 

-- Definiciones de Show

instance Show a => Show (RoseTree a) where
    show = showRoseTree 0
      where
        showRoseTree :: Show a => Int -> RoseTree a -> String
        showRoseTree indent (Rose value children) =
            replicate indent ' ' ++ show value ++ "\n" ++
            concatMap (showRoseTree (indent + 2)) children

instance Show a => Show (AT a) where
    show = showAT 0
      where
        showAT :: Show a => Int -> AT a -> String
        showAT _ Nil = replicate 2 ' ' ++ "Nil"
        showAT indent (Tern value left middle right) =
            replicate indent ' ' ++ show value ++ "\n" ++
            showSubtree (indent + 2) left ++
            showSubtree (indent + 2) middle ++
            showSubtree (indent + 2) right
        
        showSubtree :: Show a => Int -> AT a -> String
        showSubtree indent subtree =
            case subtree of
                Nil -> replicate indent ' ' ++ "Nil\n"
                _   -> showAT indent subtree

instance Show a => Show (Trie a) where
    show = showTrie ""
      where 
        showTrie :: Show a => String -> Trie a -> String
        showTrie indent (TrieNodo maybeValue children) =
            let valueLine = case maybeValue of
                                Nothing -> indent ++ "<vacío>\n"
                                Just v  -> indent ++ "Valor: " ++ show v ++ "\n"
                childrenLines = concatMap (\(c, t) -> showTrie (indent ++ "  " ++ [c] ++ ": ") t) children
            in valueLine ++ childrenLines



--Ejercicio 1
procVacio :: Procesador a b
procVacio = const []

procId :: Procesador a a
procId x = [x]

procCola :: Procesador [a] a
procCola [] = []
procCola (x:xs) = xs

procHijosRose :: Procesador (RoseTree a) (RoseTree a)
procHijosRose (Rose x hijos) = hijos


--consideramos que Nil tambien son hijos, por lo que un arbol de la forma (Tern r Nil Nil Nil), con procHijosAT  , devuelve [Nil,Nil,Nil] por ejemplo.
procHijosAT :: Procesador (AT a) (AT a)
procHijosAT Nil = []
procHijosAT (Tern x h1 h2 h3) = [h1,h2,h3]


procRaizTrie :: Procesador (Trie a) (Maybe a)
procRaizTrie (TrieNodo x _ ) = [x] 

procSubTries :: Procesador (Trie a) (Char, Trie a)
procSubTries (TrieNodo x hijos)  = hijos 

--Ejercicio 2

foldAT :: b -> (a -> b -> b -> b -> b) -> AT a -> b
foldAT fNil fTern Nil = fNil 
foldAT fNil fTern (Tern x h1 h2 h3) = fTern x (rec h1) (rec h2) (rec h3)
  where rec = foldAT fNil fTern 

foldRose :: (a -> [b] -> b) -> RoseTree a -> b
foldRose fRose (Rose x hijos) = fRose x (map rec hijos)
  where rec = foldRose fRose

foldTrie :: ((Maybe a) -> [(Char, b)] -> b) -> Trie a -> b
foldTrie fTrie (TrieNodo x hijos) = fTrie x (map (segundo rec) hijos) 
   where rec = foldTrie fTrie

segundo :: (b -> c) -> (a, b) -> (a, c)
segundo f (a,b) = (a, f b)

--Ejercicio 3
unoxuno :: Procesador [a] [a]
unoxuno = foldr (\x rec -> [x]:rec) []

sufijos :: Procesador [a] [a]
sufijos = foldr (\x rec -> [[x] ++ head rec] ++ rec) [[]]


--Ejercicio 4
preorder :: Procesador (AT a) a
preorder = foldAT [] (\x rech1 rech2 rech3 -> [x] ++ rech1 ++ rech2 ++ rech3)  

at = Tern 16 (Tern 1 (Tern 9 Nil Nil Nil) (Tern 7 Nil Nil Nil) (Tern 2 Nil Nil Nil)) (Tern 14 (Tern 0 Nil Nil Nil) (Tern 3 Nil Nil Nil) (Tern 6 Nil Nil Nil)) (Tern 10 (Tern 8 Nil Nil Nil) (Tern 5 Nil Nil Nil) (Tern 4 Nil Nil Nil))

inorder :: Procesador (AT a) a
inorder = foldAT [] (\x rech1 rech2 rech3 ->  rech1 ++ rech2 ++ [x] ++ rech3)

postorder :: Procesador (AT a) a
postorder = foldAT [] (\x rech1 rech2 rech3 ->  rech1 ++ rech2 ++ rech3 ++ [x])

--Ejercicio 5

preorderRose :: Procesador (RoseTree a) a
preorderRose = foldRose (\x rec -> [x] ++ concat rec)

hojasRose :: Procesador (RoseTree a) a
hojasRose = foldRose (\x rec -> if (null rec) then [x] else concat rec)

ramasRose :: Procesador (RoseTree a) [a]
ramasRose = foldRose (\x rec -> if (null rec) then [[x]] else map (x:) (concat rec) )


--Ejercicio 6

caminos :: Procesador (Trie a) String
caminos = foldTrie (\x rec -> "" : concat (map (\(ch,rec2)-> map (ch:) rec2) rec))

--recordar que el primer rec es de tipo [(Char, [String])] , mientras que rec2 seria de tipo [String] o sea , de tipo "b", que es el tipo de lo que quiero obtener.
--el primer map "desarma" la estructura de tuplas de rec para armar los caminos, luego el concat sobre ese resultado (que es de tipo [[String]])
--es lo que me "desarma" la lista de listas de strings, para 
--finalmente obtener algo de tipo "b" en este caso, [String]

--Ejercicio 7

palabras :: Procesador (Trie a) String
palabras = foldTrie (\x rec -> case x of 
                                  Just _ -> "" : concat (map (\(ch,rec2)-> map (ch:) rec2) rec)
                                  Nothing -> concat (map (\(ch,rec2)-> map (ch:) rec2) rec)
                    )


--Ejercicio 8
-- 8.a)

esNil t = case t of
             Nil -> True
             _ -> False

ifProc :: (a->Bool) -> Procesador a b -> Procesador a b -> Procesador a b
ifProc cond p1 p2 = (\x -> if cond x then p1 x else p2 x)

-- 8.b)
(++!) :: Procesador a b -> Procesador a b -> Procesador a b
(++!) p1 p2 = (\x -> p1 x ++ p2 x)

-- 8.c)
(.!) :: Procesador b c -> Procesador a b -> Procesador a c
(.!) p1 p2 = (\x -> concat (map p1 (p2 x)))

--Ejercicio 9
-- Se recomienda poner la demostración en un documento aparte, por claridad y prolijidad, y, preferentemente, en algún formato de Markup o Latex, de forma de que su lectura no sea complicada.


{-Tests-}

main :: IO Counts
main = do runTestTT allTests


allTests = test [ 

  "ejercicio1" ~: testsEj1,
  "ejercicio2" ~: testsEj2,
  "ejercicio3" ~: testsEj3,
  "ejercicio4" ~: testsEj4,
  "ejercicio5" ~: testsEj5,
  "ejercicio6" ~: testsEj6,
  "ejercicio7" ~: testsEj7,
  "ejercicio8a" ~: testsEj8a,
  "ejercicio8b" ~: testsEj8b,
  "ejercicio8c" ~: testsEj8c
  ]

testsEj1 = test [
    "test00Ej1" ~: "procVacio []" ~: ([]::[Int]) ~=? ((procVacio [])::[Int]), 
    "test01Ej1" ~: "procVacio [1,2,3]" ~: ([]::[Int]) ~=? ((procVacio [1,2,3])::[Int]), 
    "test02Ej1" ~: "procVacio (atUnNodo 0)" ~: ([]::[Int]) ~=? ((procVacio (atUnNodo 0))::[Int]),
    "test03Ej1" ~: "procId []" ~: ([[]]::[[Int]]) ~=? ((procId [])::[[Int]]), 
    "test04Ej1" ~: "procId [1,2,3]" ~: [[1,2,3]] ~=? procId [1,2,3], 
    "test05Ej1" ~: "procId (atUnNodo 0)" ~: [(atUnNodo 0)] ~=? procId (atUnNodo 0),
    "test06Ej1" ~: "procCola []" ~: ([]::[Int]) ~=? ((procCola [])::[Int]),
    "test07Ej1" ~: "procCola [1,2,3]" ~: [2,3] ~=? procCola [1,2,3], 
    "test08Ej1" ~: "procCola [(atUnNodo 0), Nil]" ~: [Nil] ~=? procCola [(atUnNodo 0), Nil], 
    "test09Ej1" ~: "procHijosRose Rose 0 []" ~: [] ~=? procHijosRose (Rose 0 []), 
    "test10Ej1" ~: "procHijosRose Rose 0 [Rose 1 []]" ~: [Rose 1 []] ~=? procHijosRose (Rose 0 [Rose 1 []]),
    "test11Ej1" ~: "procHijosRose Rose 0 [Rose 1 [], Rose 2 [], Rose 3 []]" ~: [Rose 1 [], Rose 2 [], Rose 3 []] ~=? procHijosRose (Rose 0 [Rose 1 [], Rose 2 [], Rose 3 []]), 
    "test12Ej1" ~: "procHijosAT Nil" ~: ([]::[AT Int]) ~=? ((procHijosAT Nil)::[AT Int]), 
    "test13Ej1" ~: "procHijosAT (atUnNodo 0)" ~: [Nil, Nil, Nil] ~=? procHijosAT (atUnNodo 0), 
    "test14Ej1" ~: "procHijosAT (Tern 0 (atUnNodo 1) Nil Nil)" ~: [(Tern 1 Nil Nil Nil),  Nil,  Nil] ~=? procHijosAT (Tern 0 (atUnNodo 1) Nil Nil), 
    "test15Ej1" ~: "procHijosAT (Tern 0 (atUnNodo 1) (atUnNodo 2) (atUnNodo 3))" ~: [atUnNodo 1, atUnNodo 2, atUnNodo 3] ~=? procHijosAT (Tern 0 (atUnNodo 1) (atUnNodo 2) (atUnNodo 3)), 
    "test16Ej1" ~: "procRaizTrie (TrieNodo Nothing [])" ~: ([Nothing]::[Maybe Bool]) ~=? ((procRaizTrie (TrieNodo Nothing []))::[Maybe Bool]), 
    "test17Ej1" ~: "procRaizTrie trieUnNodoT" ~: [Just True] ~=? procRaizTrie trieUnNodoT, 
    "test18Ej1" ~: "procRaizTrie (TrieNodo (Just True) [('a',trieUnNodoT)])" ~: [Just True] ~=? procRaizTrie (TrieNodo (Just True) [('a',trieUnNodoT)]), 
    "test19Ej1" ~: "procSubTries (TrieNodo Nothing [])" ~: ([]::[(Char, Trie (Maybe Bool))]) ~=? ((procSubTries (TrieNodo Nothing []))::[(Char, Trie (Maybe Bool))]), 
    "test20Ej1" ~: "procSubTries (TrieNodo Nothing [('a',trieUnNodoT)])" ~: [('a',trieUnNodoT)] ~=? procSubTries (TrieNodo Nothing [('a',trieUnNodoT)]), 
    "test21Ej1" ~: "procSubTries (TrieNodo Nothing [('a',trieUnNodoT), ('b',trieUnNodoT), ('c',trieUnNodoT)])" ~: [('a',trieUnNodoT), ('b',trieUnNodoT), ('c',trieUnNodoT)] ~=? procSubTries (TrieNodo Nothing [('a',trieUnNodoT), ('b',trieUnNodoT), ('c',trieUnNodoT)])
  ] where atUnNodo n = Tern n Nil Nil Nil
          trieUnNodoT = TrieNodo (Just True) []

testsEj2 = test [
    "test00Ej2" ~: "foldAT 0 (\\r recizq recmed recder -> 1 + recizq + recmed + recder) Nil" ~: 0 ~=? foldAT 0 (\r recizq recmed recder -> 1 + recizq + recmed + recder) Nil, 
    "test01Ej2" ~: "foldAT 0 (\\r recizq recmed recder -> 1 + recizq + recmed + recder) (atUnNodo 1)" ~: 1 ~=? foldAT 0 (\r recizq recmed recder -> 1 + recizq + recmed + recder) (atUnNodo 1), 
    "test02Ej2" ~: "foldAT 0 (\\r recizq recmed recder -> 1 + recizq + recmed + recder) (Tern 1 (atUnNodo 2) (atUnNodo 3) (atUnNodo 4))" ~: 4 ~=? foldAT 0 (\r recizq recmed recder -> 1 + recizq + recmed + recder) (Tern 1 (atUnNodo 2) (atUnNodo 3) (atUnNodo 4)),
    "test03Ej2" ~: "foldRose (\\r rechijos -> 1 + sum rechijos) (Rose 0 [])" ~: 1 ~=? foldRose (\r rechijos -> 1 + sum rechijos) (Rose 0 []), 
    "test04Ej2" ~: "foldRose (\\r rechijos -> 1 + sum rechijos) (Rose 0 [Rose 1 [], Rose 2 [], Rose 3 []])" ~: 4 ~=? foldRose (\r rechijos -> 1 + sum rechijos) (Rose 0 [Rose 1 [], Rose 2 [], Rose 3 []]), 
    "test05Ej2" ~: "foldRose (\\r rechijos -> 1 + sum rechijos) (Rose 0 [Rose 1 [], Rose 2 [], Rose 3 [Rose 4 []]])" ~: 5 ~=? foldRose (\r rechijos -> 1 + sum rechijos) (Rose 0 [Rose 1 [], Rose 2 [], Rose 3 [Rose 4 []]]), 
    "test06Ej2" ~: "foldTrie (\\r rechijos -> 1 + sum (map snd rechijos)) (TrieNodo Nothing [])" ~: 1 ~=? foldTrie (\r rechijos -> 1 + sum (map snd rechijos)) (TrieNodo Nothing []), 
    "test07Ej2" ~: "foldTrie (\\r rechijos -> 1 + sum (map snd rechijos)) (TrieNodo Nothing [('a',trieUnNodoT), ('b',trieUnNodoT)])" ~: 3 ~=? foldTrie (\r rechijos -> 1 + sum (map snd rechijos)) (TrieNodo Nothing [('a',trieUnNodoT), ('b',trieUnNodoT)]), 
    "test08Ej2" ~: "foldTrie (\\r rechijos -> 1 + sum (map snd rechijos)) (TrieNodo Nothing [('a',trieUnNodoT), ('b', TrieNodo (Just True) [('c',trieUnNodoT)])])" ~: 4 ~=? foldTrie (\r rechijos -> 1 + sum (map snd rechijos)) (TrieNodo Nothing [('a',trieUnNodoT), ('b', TrieNodo (Just True) [('c',trieUnNodoT)])])
  ] where atUnNodo n = Tern n Nil Nil Nil
          trieUnNodoT = TrieNodo (Just True) []

testsEj3 = test [
    "test00Ej3" ~: "unoxuno []" ~: ([]::[[Int]]) ~=? ((unoxuno [])::[[Int]]), 
    "test01Ej3" ~: "unoxuno [1]" ~: [[1]] ~=? unoxuno [1], 
    "test02Ej3" ~: "unoxuno [1,2,3]" ~: [[1],[2],[3]] ~=? unoxuno [1,2,3], 
    "test03Ej3" ~: "sufijos []" ~: ([[]]::[[Int]]) ~=? ((sufijos [])::[[Int]]), 
    "test04Ej3" ~: "sufijos [1]" ~: [[1], []] ~=? sufijos [1], 
    "test05Ej3" ~: "sufijos [1,2,3]" ~: [[1,2,3], [2,3], [3], []] ~=? sufijos [1,2,3]
  ]

testsEj4 = test [
    "test00Ej4" ~: "preorder Nil" ~: ([]::[Int]) ~=? ((preorder Nil)::[Int]), 
    "test01Ej4" ~: "preorder (atUnNodo 0)" ~: [0] ~=? preorder ((atUnNodo 0)), 
    "test02Ej4" ~: "preorder (atCuatroNodos 0 1 2 3)" ~: [0,1,2,3] ~=? preorder (atCuatroNodos 0 1 2 3), 
    "test03Ej4" ~: "preorder at" ~: [16,1,9,7,2,14,0,3,6,10,8,5,4] ~=? preorder at, 
    "test04Ej4" ~: "postorder Nil" ~: ([]::[Int]) ~=? ((postorder Nil)::[Int]), 
    "test05Ej4" ~: "postorder (atUnNodo 0)" ~: [0] ~=? postorder (Tern 0 Nil Nil Nil), 
    "test06Ej4" ~: "postorder (atCuatroNodos 0 1 2 3)" ~: [1,2,3,0] ~=? postorder (atCuatroNodos 0 1 2 3), 
    "test07Ej4" ~: "preorder at" ~: [9,7,2,1,0,3,6,14,8,5,4,10,16] ~=? postorder at, 
    "test08Ej4" ~: "inorder Nil" ~: ([]::[Int]) ~=? ((inorder Nil)::[Int]), 
    "test09Ej4" ~: "inorder (Tern 0 Nil Nil Nil)" ~: [0] ~=? inorder (Tern 0 Nil Nil Nil), 
    "test10Ej4" ~: "inorder (Tern 0 (Tern 1 Nil Nil Nil) (Tern 2 Nil Nil Nil) (Tern 3 Nil Nil Nil))" ~: [1,2,0,3] ~=? inorder (Tern 0 (Tern 1 Nil Nil Nil) (Tern 2 Nil Nil Nil) (Tern 3 Nil Nil Nil)), 
    "test11Ej4" ~: "preorder at" ~: [9,7,1,2,0,3,14,6,16,8,5,10,4] ~=? inorder at
  ] where atUnNodo n = Tern n Nil Nil Nil
          atCuatroNodos n1 n2 n3 n4 = Tern n1 (atUnNodo n2) (atUnNodo n3) (atUnNodo n4)
          at = Tern 16 (atCuatroNodos 1 9 7 2) (atCuatroNodos 14 0 3 6) (atCuatroNodos 10 8 5 4)

testsEj5 = test [
    "test00Ej5" ~: "preorderRose roseUnNodo" ~: [0] ~=? preorderRose roseUnNodo, 
    "test01Ej5" ~: "preorderRose roseCuatroNodos" ~: [0,1,2,3] ~=? preorderRose roseCuatroNodos, 
    "test02Ej5" ~: "preorderRose roseOchoNodos" ~: [0,1,2,5,6,3,4,7] ~=? preorderRose roseOchoNodos, 
    "test03Ej5" ~: "hojasRose roseUnNodo" ~: [0] ~=? hojasRose roseUnNodo, 
    "test04Ej5" ~: "hojasRose roseCuatroNodos" ~: [1,2,3] ~=? hojasRose roseCuatroNodos, 
    "test05Ej5" ~: "hojasRose roseOchoNodos" ~: [1,5,6,3,7] ~=? hojasRose roseOchoNodos, 
    "test06Ej5" ~: "ramasRose roseUnNodo" ~: [[0]] ~=? ramasRose roseUnNodo, 
    "test07Ej5" ~: "ramasRose roseCuatroNodos" ~: [[0,1],[0,2],[0,3]] ~=? ramasRose roseCuatroNodos, 
    "test08Ej5" ~: "ramasRose roseOchoNodos" ~: [[0,1],[0,2,5],[0,2,6],[0,3],[0,4,7]] ~=? ramasRose roseOchoNodos
  ] where roseUnNodo = Rose 0 []
          roseCuatroNodos = Rose 0 [Rose 1 [], Rose 2 [], Rose 3 []]
          roseOchoNodos = Rose 0 [Rose 1 [], Rose 2 [Rose 5 [], Rose 6 []], Rose 3 [], Rose 4 [Rose 7 []]]

testsEj6 = test [
    "test00Ej6" ~: "caminos (TrieNodo Nothing [])" ~: [""] ~=? caminos (TrieNodo Nothing []), 
    "test01Ej6" ~: "caminos (TrieNodo Nothing [('a', TrieNodo (Just True) []), ('b', TrieNodo Nothing [])])" ~: ["", "a", "b"] ~=? caminos (TrieNodo Nothing [('a', TrieNodo (Just True) []),('b', TrieNodo Nothing [])]), 
    "test02Ej6" ~: "caminos t" ~: ["", "a", "b", "ba", "bad", "c"] ~=? caminos t
  ] where t = TrieNodo Nothing [
                ('a', TrieNodo (Just True) []),
                ('b', TrieNodo Nothing [
                  ('a', TrieNodo (Just True) [
                    ('d', TrieNodo Nothing [])
                  ])
                ]),
                ('c', TrieNodo (Just True) [])
              ]

testsEj7 = test [
    "test00Ej7" ~: "palabras (TrieNodo Nothing [])" ~: ([]::[[Char]]) ~=? ((palabras (TrieNodo Nothing []))::[[Char]]), 
    "test01Ej7" ~: "palabras (TrieNodo Nothing [('a', TrieNodo (Just True) []), ('b', TrieNodo Nothing [])])" ~: ["a"] ~=? palabras (TrieNodo Nothing [('a', TrieNodo (Just True) []),('b', TrieNodo Nothing [])]), 
    "test02Ej7" ~: "palabras t" ~: ["a", "ba", "c"] ~=? palabras t
  ] where t = TrieNodo Nothing [
                ('a', TrieNodo (Just True) []),
                ('b', TrieNodo Nothing [
                  ('a', TrieNodo (Just True) [
                    ('d', TrieNodo Nothing [])
                  ])
                ]),
                ('c', TrieNodo (Just True) [])
              ]

testsEj8a = test [
    "test00Ej8a" ~: "ifProc (all (>0)) (map (+1)) (map (+(-1))) []" ~: ([]::[Int]) ~=? ((ifProc (all (>0)) (map (+1)) (map (+(-1))) [])::[Int]),
    "test01Ej8a" ~: "ifProc (all (>0)) (map (+1)) (map (+(-1))) [1,2,3]" ~: [2,3,4] ~=? ifProc (all (>0)) (map (+1)) (map (+(-1))) [1,2,3], 
    "test02Ej8a" ~: "ifProc (all (>0)) (map (+1)) (map (+(-1))) [-1,2,3]" ~: [-2,1,2] ~=? ifProc (all (>0)) (map (+1)) (map (+(-1))) [-1,2,3],
    "test03Ej8A" ~: "ifProc nodosPositivosAT postorder preorder (Tern 1 (atUnNodo 2) (atUnNodo 3) (atUnNodo 4))" ~: [2,3,4,1] ~=? ifProc nodosPositivosAT postorder preorder (Tern 1 (atUnNodo 2) (atUnNodo 3) (atUnNodo 4)), 
    "test04Ej8A" ~: "ifProc nodosPositivosAT postorder preorder (Tern 0 (atUnNodo 2) (atUnNodo 3) (atUnNodo 4))" ~: [0,2,3,4] ~=? ifProc nodosPositivosAT postorder preorder (Tern 0 (atUnNodo 2) (atUnNodo 3) (atUnNodo 4))
    -- Se podría agregar casos de test sobre las otras estructuras basadas en árboles.
  ] where nodosPositivosAT = foldAT True (\r recizq recmed recder -> (r > 0) && recizq && recmed && recder)
          atUnNodo n = Tern n Nil Nil Nil
testsEj8b = test [
    "test00Ej8b" ~: "(++!) (map (+1)) (map (+(-1))) []" ~: ([]::[Int]) ~=? (((++!) (map (+1)) (map (+(-1))) [])::[Int]), 
    "test01Ej8b" ~: "(++!) (map (+1)) (map (+(-1))) [1,2,3]" ~: [2,3,4,0,1,2] ~=? (++!) (map (+1)) (map (+(-1))) [1,2,3], 
    "test02Ej8b" ~: "(++!) postorder preorder (Tern 1 (atUnNodo 2) (atUnNodo 3) (atUnNodo 4))" ~: [2,3,4,1,1,2,3,4] ~=? (++!) postorder preorder (Tern 1 (atUnNodo 2) (atUnNodo 3) (atUnNodo 4))
  ] where atUnNodo n = Tern n Nil Nil Nil
testsEj8c = test [
    "test00Ej8c" ~: "(.!) (\\z->[0..z]) (map (+1)) []" ~: ([]::[Int]) ~=? (((.!) (\z->[0..z]) (map (+1)) [])::[Int]), 
    "test01Ej8c" ~: "(.!) (\\z->[0..z]) (map (+1)) [1,3]" ~: [0,1,2,0,1,2,3,4] ~=? (.!) (\z->[0..z]) (map (+1)) [1,3], 
    "test02Ej8c" ~: "(.!) (\\z -> if (z > 0) then 'a' else 'b' ) preorder (Tern (-1) (atUnNodo 2) (atUnNodo 3) (atUnNodo 4))" ~: "baaa" ~=? (.!) (\z -> if (z > 0) then "a" else "b" ) preorder (Tern (-1) (atUnNodo 2) (atUnNodo 3) (atUnNodo 4))
  ] where atUnNodo n = Tern n Nil Nil Nil
