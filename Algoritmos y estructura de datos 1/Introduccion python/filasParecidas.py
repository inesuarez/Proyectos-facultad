from typing import List

def filaAnteriorMasN(m:List[List[int]], i,n:int) -> bool:
  if i<1 or i>=len(m):
    return false
  for j in range(len(m[0])):
    if m[i][j]!=m[i-1][j]+n:
      return False
  return True

    
def filasParecidas(m:List[List[int]]) -> bool:
  if len(m) == 1:
    return True
  else:
    n = m[1][0] - m[0][0]
    for i in range(1,len(m)):
      if filaAnteriorMasN(m,i,n) != True:
        return False
    return True   

if __name__ == '__main__':
  filas = int(input())
  columnas = int(input())
 
  matriz = []
 
  for i in range(filas):         
    fila = input()
    if len(fila.split()) != columnas:
      print("Fila " + str(i) + " no contiene la cantidad adecuada de columnas")
    matriz.append([int(j) for j in fila.split()])
  
  print(filasParecidas(matriz))