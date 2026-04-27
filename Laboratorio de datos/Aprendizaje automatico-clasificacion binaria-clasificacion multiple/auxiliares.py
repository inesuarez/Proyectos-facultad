#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Materia: Laboratorio de datos - FCEyN - UBA
Autores  : Ines Suarez, Lourdes Montero, Ana Ramirez
Fecha  : 2024-06-04
Actividad: Trabajo Practico 2 - Funciones auxiliares
"""
#%%Imports
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.neighbors import KNeighborsClassifier
from sklearn import metrics
import random
from sklearn import tree

#%%
def flip_rotate(image):
    """
    Función que recibe un array de numpy representando una
    imagen de 28x28. Espeja el array y lo rota en 90°.
    """
    W = 28
    H = 28
    image = image.reshape(W, H)
    image = np.fliplr(image)
    image = np.rot90(image)
    return image

#%%
#Funcion que recibe una fila (n) de un dataFrame (df) que representa una imagen, que tipo de imagen es (tipo)
#y que letra representa (letra) y la grafica.
def imagen(n,df,tipo,letra): 
  row = df.iloc[n]
  im = np.array(row).astype(np.float32)
  plt.imshow(flip_rotate(im))
  if tipo == 'promedio':
      plt.title('Promedio letra ' + letra)
  else:
      plt.title('Letra ' + letra)
  plt.axis('off')
  plt.show()

#%%
#Funcion que recibe una letra (n) y un dataFrame (df) de imagenes de letras y devuelve un dataFrame con 
#todas las filas que represetan esa letra y sin la columna "Etiqueta", y otro dataFrame que te dice
#cual es el valor de pixel promedio entre todas las imagenes de la misma letra (n) para todos los pixeles.
def promedio(n, df):
    n_s = df[(df["Etiqueta"]==n)]
    n_s = n_s.drop(columns = ["Etiqueta"])
    promedioN = n_s.mean(axis=0)
    n_s.loc["Promedio"] = promedioN
    promedioN = pd.DataFrame(promedioN)
    promedioN = promedioN.rename(columns={0: "Promedio"})
    numeracion = range(1,len(promedioN)+1)
    promedioN["Pixel"] = numeracion
    return n_s, promedioN

#%%
#Funcion que recibe un numero (cant) y dos dataFrames (X_test, X_train) y devuelve dos subDataFrame de 
#los originales que recibe pero solo con cant atributos aleatorios.
def atributos(cant,X_test, X_train):
    random.seed(451)
    lista = random.sample(range(200,700),cant)
    test = X_test[lista]
    train = X_train[lista]
    return test,train  

#%%
#Funcion que recibe 4 dataFrames, X_train, X_test, Y_train e Y_test, y un valor k y entrena un modelo de knn
#con cantidad de vecinos desde 1 hasta k y devuelve una lista con el valor de exactitud del modelo para cada k.
def knn(X_test,X_train,Y_train,Y_test,k):
    res = []
    for i in range(1,k+1):
      model = KNeighborsClassifier(i) 
      model.fit(X_train, Y_train) 
      Y_pred = model.predict(X_test) 
      acc = metrics.accuracy_score(Y_test, Y_pred)
      res.append(acc)
    return res

#%%
#Funcion que recibe un k-fold (kf), un criterio, un numero (profundidades), y dos dataFrames (x_dev,y_dev)
#y entrena un arbol de decision haciendo k-folding con kf y x_dev e y_dev con el criterio dado para 
#cada profundidad desde 1 hasta profundidades, guardando la exactitud de cada uno en una matriz donde
#las filas son los k-foldings y las columnas las distintas profundidades. Finalmente devuelve un vector
#con el promedio de todos los k-fold para cada profundidad.
def distintasProfundidades(kf,criterio,profundidades,x_dev,y_dev):
    accuracy = []
    for i,(train_index, test_index) in enumerate(kf.split(x_dev)):
        kf_X_train, kf_X_test = x_dev.iloc[train_index], x_dev.iloc[test_index]
        kf_y_train, kf_y_test = y_dev.iloc[train_index], y_dev.iloc[test_index]  
        accuracy_list = []
        for pmax in profundidades:    
           arbol = tree.DecisionTreeClassifier(max_depth = pmax, criterion= criterio)
           arbol.fit(kf_X_train, kf_y_train)  
           pred = arbol.predict(kf_X_test)    
           acc = metrics.accuracy_score(kf_y_test.values, pred)
           accuracy_list.append(acc)    
        accuracy.append(accuracy_list)    
    accuracy_np = np.array(accuracy)
    return np.mean(accuracy_np, axis=0)

