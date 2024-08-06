from typing import List
from typing import Tuple

def sinRepetidos(l:List[Tuple[str,str]])->List[Tuple[str,str]]:
  sinRep : List[Tuple[str,str]]=[]
  for i in range(len(l)):
    if (l[i] not in sinRep):
      sinRep.append(l[i])
  return sinRep

def vuelosValidos(ruta,vuelos:List[Tuple[str,str]]) -> bool:
  if len(sinRepetidos(ruta)) == len(ruta):
   for i in range(len(ruta)):
    if ruta[i] not in vuelos:
      return False
   return True
  else:
    return False 

def caminoDeVuelos(ruta:List[Tuple[str,str]]) -> bool:
  for i in range(1,len(ruta)):
    if ruta[i][0] != ruta[i-1][1]:
      return False
  return True
  
def laRuta(vuelos: List[Tuple[str,str]], origen,destino: str) -> List[Tuple[str,str]]:
  ruta:List[Tuple[str,str]] = []
  if vuelos == []:
    return []
  for i in range(len(vuelos)):
    if vuelos[i][0] == origen and vuelos[i][1] == destino:
      return [vuelos[i]]
    if vuelos[i][0] == origen and vuelos[i][1] != destino:
      ruta.append(vuelos[i])
      for j in range(len(vuelos)):
        for h in range(len(vuelos)):
          if vuelos[h][0] == ruta[-1][1] and ruta[-1][1]!=destino:
           ruta.append(vuelos[h])
      if ruta[-1][1]!=destino:
            return []
      else:
        return ruta
    
def hayRuta(vuelos: List[Tuple[str,str]],origen,destino: str) -> bool:
  ruta:List[Tuple[str,str]] = laRuta(vuelos,origen,destino)
  if vuelosValidos(ruta,vuelos) == True and len(ruta) >= 1 and caminoDeVuelos(ruta) == True:
    return True
  else:
    return False
  
def sePuedeLlegar(origen,destino: str, vuelos: List[Tuple[str,str]]) -> int:
  if hayRuta(vuelos,origen,destino) == True:
    return len(laRuta(vuelos,origen,destino))
  else:
    return -1

if __name__ == '__main__':
  origen = input()
  destino = input()
  vuelos = input()
  
  print(sePuedeLlegar(origen, destino, [tuple(vuelo.split(',')) for vuelo in vuelos.split()]))


