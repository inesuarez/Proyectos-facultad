#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Materia: Laboratorio de datos - FCEyN - UBA
Autores  : Ines Suarez, Lourdes Montero, Ana Ramirez
Fecha  : 2024-06-04
Actividad: Trabajo Practico 2
"""
#%%##########################################################################
#                                                                           #
#                          Trabajo practico 2                               #
#                                                                           #
#############################################################################

#Imports de bibliotecas necesarias y funciones auxiliares
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import seaborn as sns
from inline_sql import sql,sql_val
from sklearn.model_selection import train_test_split, KFold
from sklearn import tree
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay
from auxiliares import (distintasProfundidades, promedio, imagen, knn, atributos)
#%%====================================================================
# Carga del dataset
#======================================================================
data = pd.read_csv("~/Descargas/emnist_letters_tp.csv", header= None)
data = data.rename(columns={0:"Etiqueta"}) # Modificamos el nombre de la primer columna a Etiqueta
                                           # para mayor comodidad al manipularlo
#%%===========================================================================
# Ejercicio 1 - ANALISIS EXPLORATORIO
#=============================================================================
#a. ¿Cuáles parecen ser atributos relevantes para predecir la letra a la que
#corresponde la imagen? ¿Cuáles no? ¿Creen que se pueden descartar atributos?

#Calculamos la imagen promedio de la letra 'A' y la graficamos. 
a_s = promedio('A', data)[0]
promedioA = a_s.mean(axis=0)
a_s.loc["Promedio"] = promedioA
imagen(2400,a_s,'promedio','A')

#%%-----------       
#b. ¿Hay letras que son parecidas entre sí? Por ejemplo, ¿Qué es más
#fácil de diferenciar: las imágenes correspondientes a la letra E de las
#correspondientes a la L, o la letra E de la M?  

#Calculamos la imagen promedio de las letras 'E', 'M' y 'L' y las graficamos.
e_s = promedio('E', data)[0]
promedioE = promedio('E', data)[1]
l_s = promedio('L', data)[0]
promedioL = promedio('L', data)[1]
m_s = promedio('M', data)[0]
promedioM = promedio('M', data)[1]

imagen(2400,e_s,'promedio','E')
imagen(2400,l_s,'promedio','L')
imagen(2400,m_s,'promedio','M')

#%%
#Ordenamos la imagen promedio de la 'E' descendientemente para quedarnos con los 100 pixeles "mas fuertes",
#los que tienen un valor de color mas grande por lo tanto se distinguen mas.
ordenado = promedioE.sort_values(by="Promedio", ascending = False)
fuertes = ordenado.iloc[:100]

#Agarramos los mismos pixeles para la imagen promedio de la 'L' y de la 'M'.
l_iguales = sql^"""
               SELECT l.Promedio, l.Pixel
               FROM promedioL AS l
               INNER JOIN fuertes AS e
               ON l.Pixel = e.Pixel
               """
m_iguales = sql^"""
               SELECT m.Promedio, m.Pixel
               FROM promedioM AS m
               INNER JOIN fuertes AS e
               ON m.Pixel = e.Pixel
               """
               
#%%
#Hacemos un scatter plot con los pixeles fuertes de la 'E' y los mimos pixeles de la 'L' y la 'M' para
#ver que tan lejos estan las imagenes promedio de la 'L' y la 'M' a los de la 'E'. 
fig, ax = plt.subplots()

plt.rcParams['font.family'] = 'sans-serif'          
ax.scatter(data = fuertes,  
           x='Pixel',
           y='Promedio',
           s=8,                      
           color='rebeccapurple',
           label = 'pixeles fuertes letra E')  

ax.scatter(data = l_iguales,  
           x='Pixel',
           y='Promedio',
           s=8,                      
           color='green',
           label = 'mismos pixeles letra L')  

ax.scatter(data = m_iguales,  
           x='Pixel',
           y='Promedio',
           s=8,                      
           color='gold',
           label = 'mismos pixeles letra M')        

#plt.title('Diferencia de las letras E, M y L en los pixeles mas fuertes de la E')
ax.set_xlabel('Pixel', fontsize='medium')  # Nombre eje X          
ax.set_ylabel('Valor de pixel',
              fontsize='medium')

ax.set_xlim(0,790)
ax.set_ylim(-1,210)

ax.legend(prop={'size':8})

#%%-----------                        
#c. Tomen una de las clases, por ejemplo la letra C, ¿Son todas las imágenes muy similares entre sí?

#Calculamos la imagen promedio de la letra 'C' y la graficamos.
c_s = promedio('C', data)[0]
c_s = c_s.iloc[:2400]
promedioC = c_s.mean(axis=0)
c_s.loc["Promedio"] = promedioC
imagen(2400,c_s,'promedio','C')

#%%
#Hacemos un boxplot para ver la variabilidad entre las distintas imagenes de la letra 'C' en 4 pixeles centrales.
pixeles = c_s[[205,237,480,500]] 
plt.figure(figsize=(14, 8))
meanprops = {
    "marker": "*",      
    "markerfacecolor": "black",
    "markeredgecolor": "black",
    "markersize": 10
}
sns.boxplot(data=pixeles, showmeans=True, palette=['gold','green','rebeccapurple','chocolate'], meanprops=meanprops)
plt.xlabel('Columnas de Píxeles')
plt.ylabel('Valor del Píxel')
plt.title('Variación de varias columnas específicas de píxeles en imágenes de la letra C')
plt.ylim(-15,300)

#%%===========================================================================
# Ejercicio 2 - CLASIFICACION BINARIA 
#=============================================================================
#a. A partir del dataframe original, construir un nuevo dataframe que contenga sólo al subconjunto 
#de imágenes correspondientes a las letras L o A.
asYls = data[(data["Etiqueta"]=='A') | (data["Etiqueta"]=='L')]

#%%----------- 
#b. Sobre este subconjunto de datos, analizar cuántas muestras se tienen y determinar si está 
#balanceado con respecto a las dos clases a predecir (la imagen es de la letra L o de la letra A).
asYls["Etiqueta"].value_counts()

#%%----------- 
#c. Separar los datos en conjuntos de train y test.
X = asYls.drop(columns=["Etiqueta"])
Y = asYls[["Etiqueta"]]

#Separamos un 80% para train y un 20% para test.
X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size = 0.2,random_state = 42) 
                                        
#%%----------- 
#d. Ajustar un modelo de KNN en los datos de train, considerando pocos atributos, por ejemplo 3. 
#Probar con distintos conjuntos de 3 atributos y comparar resultados. Analizar utilizando otras cantidades 
#de atributos. Para comparar los resultados de cada modelo usar el conjunto de test generado en el punto anterior.

#Para el item e vamos a necesitar distintos modelos de knn con distinta cantidad de vecinos y distinta cantidad
#de atributos, eso es lo que calculamos aca porque tambien lo usamos para la resolucion del item d.
#Entrenamos modelos de knn con valores de k desde 1 a 15 y con 3,4,5 y 6 atributos.
tres_atrib = atributos(3,X_test,X_train)
res3 = knn(tres_atrib[0],tres_atrib[1],Y_train,Y_test,15)

cuatro_atrib = atributos(4,X_test,X_train)
res4 = knn(cuatro_atrib[0],cuatro_atrib[1],Y_train,Y_test,15)

cinco_atrib = atributos(5,X_test,X_train)
res5 = knn(cinco_atrib[0], cinco_atrib[1],Y_train,Y_test,15)

seis_atrib = atributos(6,X_test,X_train)
res6 = knn(seis_atrib[0],seis_atrib[1],Y_train,Y_test,15)

#%%
#Para las distintas cantidades de atributos que calculamos antes, agarramos el valor con 6 vecinos
#y comparamos con un grafico de barras.
numeros = [res3[6],res4[6],res5[6],res6[6]]
etiquetas = [3,4,5,6]

plt.figure(figsize=(10, 6))
plt.bar(etiquetas, numeros, width = 0.5, color=['gold','rebeccapurple','green','chocolate'], edgecolor = 'black')

plt.ylim(0, 1)
plt.xlim(2.5,6.5)
plt.xticks(etiquetas[::1])

plt.xlabel('Cant atributos')
plt.ylabel('Accuracy')
plt.title('Accuracy entre modelos de knn con 6 vecinos y distinta cantidad de atributos')

#%%----------- 
#e. Comparar modelos de KNN utilizando distintos atributos y distintos valores de k (vecinos). 
#Para el análisis de los resultados, tener en cuenta las medidas de evaluación (por ejemplo, la exactitud) 
#y la cantidad de atributos.

#Ahora si usamos las listas completas que hicimos antes que dice el la exactitud de cada modelo con vecinos
#desde 1 hasta 15 con distintas cantidades de atributos. Para compararlas hicimos un scatter plot.
plt.figure(figsize=(8, 6))
plt.scatter(range(1,len(res6)+1), res6, color='chocolate', label='6 atributos')
plt.scatter(range(1,len(res5)+1), res5, color='green', label='5 atributos')
plt.scatter(range(1,len(res4)+1), res4, color='rebeccapurple', label='4 atributos')
plt.scatter(range(1,len(res3)+1), res3, color='gold', label='3 atributos')


plt.xlabel('k')
plt.ylabel('accuracy')
plt.ylim(0.6,1)
plt.xticks(range(1,16))
plt.xlim(0.5,15.5)
plt.title('Accuracy entre modelos de knn con distinta cantidad de k y atributos')

plt.legend()  

#%%===========================================================================
# Ejercicio 3 - CLASIFICACION MULTICLASE 
#=============================================================================
#a. Vamos a trabajar con los datos correspondientes a las 5 vocales. Primero filtrar solo los datos 
#correspondientes a esas letras. Luego, separar el conjunto de datos en desarrollo (dev) y validación (held-out).
vocales = data[(data["Etiqueta"]=='A') | (data["Etiqueta"]=='E') | (data["Etiqueta"]=='I') | (data["Etiqueta"]=='O') | (data["Etiqueta"]=='U')]

vocx = vocales.drop(columns=["Etiqueta"])
vocy = vocales[["Etiqueta"]]
vocx_dev, vocx_heldout, vocy_dev, vocy_heldout = train_test_split(vocx, vocy, test_size = 0.2, random_state = 42)
#%%----------- 
#b. Ajustar un modelo de árbol de decisión. Probar con distintas profundidades.
#c. Realizar un experimento para comparar y seleccionar distintos árboles de decisión, con distintos 
#hiperparámetos. Para esto, utilizar validación cruzada con k-folding.

#Los items b. y c. los hacemos juntos entrenando arboles con profundidades de 1 a 20 con criterio de gini
#y entropy haciendo k-folding.
profundidades = range(1,21)
nsplits = 5
kf = KFold(n_splits=nsplits)

accuracy_entropy = distintasProfundidades(kf,'entropy',profundidades,vocx_dev,vocy_dev)
accuracy_gini = distintasProfundidades(kf,'gini',profundidades,vocx_dev,vocy_dev)
#%%-----------     
#Graficamos un scatter plot para comparar la exactitud de los arboles con distintos hiperparametros.
plt.figure(figsize=(8, 6))
plt.scatter(range(1,len(accuracy_entropy)+1), accuracy_entropy, color='blue', label='entropy')
plt.scatter(range(1,len(accuracy_gini)+1), accuracy_gini, color='red', label='gini')

plt.xlabel('profundidad')
plt.ylabel('accuracy')
plt.ylim(0.2,1)
plt.xticks(range(21))
plt.xlim(0.5,21)
plt.title('Accuracy entre diferentes hiperparámetros')
  
plt.legend()  
#%%
#¿Cuál fue el mejor modelo? Documentar cuál configuración de hiperparámetros es la mejor, 
#y qué performance tiene.

#Nos fijamos cual configuracion de hiperparametros tiene mayor exactitud.
max_entropy = max(accuracy_entropy)
max_profundidad_e = np.argmax(accuracy_entropy)
max_gini = max(accuracy_gini)
max_profundidad_g = np.argmax(accuracy_gini)

if max_entropy > max_gini:
    arbolfinal = ('entropy', max_profundidad_e)
else:
    arbolfinal = ('gini', max_profundidad_g)

print(arbolfinal)
#%%----------- 
#d. Entrenar el modelo elegido a partir del inciso previo, ahora en todo el conjunto de desarrollo. 
#Utilizarlo para predecir las clases en el conjunto held-out y reportar la performance.

#Para reportar la performance graficamos una matriz de confusion.
arbol_elegido = tree.DecisionTreeClassifier(max_depth = arbolfinal[1], criterion = arbolfinal[0])
arbol_elegido.fit(vocx_dev, vocy_dev)
y_pred = arbol_elegido.predict(vocx_heldout)
score = arbol_elegido.score(vocx_heldout, vocy_heldout)

ax = plt.subplot()
ax.set_title(f"Criterio: {arbolfinal[0]}, Profundidad: {arbolfinal[1]+1}, score={score}")
conf_matrix_display = ConfusionMatrixDisplay(
        confusion_matrix(vocy_heldout, y_pred), display_labels=["A", "E", "I", "O", "U"]
    )
conf_matrix_display.plot(ax=ax)

plt.rcParams["figure.figsize"] = (10, 6)

