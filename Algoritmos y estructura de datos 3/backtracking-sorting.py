# -*- coding: utf-8 -*-
"""
Created on Tue Apr  2 18:11:50 2024

@author: User W10
"""
T = int(input())    
jugadores = [0,0,0,0,0,0,0,0,0,0]*T

for i in range(T*10):
    data = input().split()
    jugadores[i] = (data[0], int(data[1]), int(data[2]))
    
def maximo(l):
  res = l[0]
  maximo = l[0][1]
  minimo = l[0][2]
  for i in range(1,len(l)):
    if l[i][1] > maximo:
      res = l[i]
      maximo = l[i][1]
      minimo = l[i][2]
    elif l[i][1] == maximo:
      if l[i][2] < minimo:
        res = l[i]
        minimo = l[i][2]
  return res

orden = []

def ordenada(l):
  max = maximo(l)
  orden.append(max)
  l.remove(max)
  l1 = l.copy()
  if len(l1) > 0:
    return ordenada(l1)
  else:
    res = orden.copy()
    orden[:] = []
    return res
  


lista = []
matriz = []
for j in range(T):
    caso = []
    for p in range(j*10,(j+1)*10,1):
      caso.append(lista[p]) 
    matriz.append(caso)
for k in range(len(matriz)):
   matriz[k].sort()
   final = []
   final.extend(ordenada(matriz[k]))
   at = "("+",".join(final[0][0], final[1][0], final[2][0], final[3][0], final[4][0])+")"
   defen = "("+",".join(final[5][0], final[6][0], final[7][0], final[8][0], final[9][0])+")"
   print(f"Case {k+1}: \n {at} \n {defen}")
    


