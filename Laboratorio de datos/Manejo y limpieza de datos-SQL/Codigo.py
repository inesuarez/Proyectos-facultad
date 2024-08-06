#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Materia: Laboratorio de datos - FCEyN - UBA
Autores  : Ines Suarez, Lourdes Montero, Ana Ramirez
Fecha  : 2024-05-12
Actividad: Trabajo Practico 1
"""

#%%##########################################################################
#                                                                           #
#                          Trabajo practico 1                               #
#                                                                           #
#############################################################################
#Imports y carga de datasets

import pandas as pd
import csv
from inline_sql import sql, sql_val
import numpy as np
import matplotlib.pyplot as plt # Para graficar series multiples
from   matplotlib import ticker   # Para agregar separador de miles
import seaborn as sns

#%%
#%%====================================================================
# Importamos los datasets que vamos a utilizar en este programa
#======================================================================
carpeta = "~/Descargas/"

#Datos de las sedes 
listaSedes = pd.read_csv(carpeta+"lista-sedes.csv")
listaSedesDatos = pd.read_csv(carpeta+"lista-sedes-datos.csv", on_bad_lines='skip')

#Secciones de las sedes
listaSecciones= pd.read_csv(carpeta+"lista-secciones.csv")

#Flujos
#La giramos para facilitar el manejo de los datos de la tabla
flujo = pd.read_csv(carpeta+"flujos.csv").T.reset_index()

#Paises
pais = pd.read_csv(carpeta+"paises.csv")



#%%===================================================================
# Limpieza de datos
#=====================================================================

#Armamos nuestros datasets con la informacion necesaria para resolver los ejercicios en base a nuestro modelo relacional.
#Le ponemos a las columnas los nombres que nos parecen mas comodos para trabajar.
sedes = listaSedesDatos[['sede_id', 'sede_desc_castellano', 'pais_iso_3']]
sedes = sedes.rename(columns={"sede_desc_castellano": "descripcion", "pais_iso_3": "codigoPais"})

secciones = listaSecciones[['sede_id', 'sede_desc_castellano']]
secciones = secciones.rename(columns={"sede_desc_castellano": "descripcion"})

#Algunas columnas tenian un espacio antes, se lo sacamos para poder modificarlas.
pais.columns=['nombre', 'name', 'nom', 'iso2', 'iso3', 'phone_code']
pais2 = sql ^ """
               SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(lower(nombre),'á','a'),'é','e'),'í','i'),'ú','u'),'ó','o') AS nombre,iso3 AS codigo
               FROM pais
               """    
#La region geografica la tenemos en el dataset de las sedes,
#por lo tanto, los paises sin sedes en un principio los vamos a perder de esta tabla,
#tratamos de salvar la mayor cantidad posible.

paises = sql ^ """
               SELECT DISTINCT nombre, codigo, region_geografica
               FROM pais2
               INNER JOIN listaSedesDatos
               ON pais_iso_3 = codigo
               """    

#En este dataframe miramos solo las columnas con los registros desde el 2018 hasta el 2022
#y sacamos los paies que tenian nan en todos los registros, ademas agregamos el iso3 y sacamos el nombre
#de los paises en base a nuestro modelo relacional.
#Aca tambien se pierden paises porque hay problemas de calidad de datos
#ya que estan escritos de distinta manera en los datasets.

flujos1 = flujo[['index',38,39,40,41,42]]
flujos1 = flujos1.rename(columns={"index": "nombrePais",38: "año2018", 39: "año2019", 40: "año2020", 41: "año2021", 42: "año2022"})[1:]
flujos1 = flujos1.dropna(thresh=2)

flujos2 = sql ^ """
               SELECT REPLACE(nombrePais,'_',' ') AS nombrePais, año2018, año2019, año2020, año2021, año2022
               FROM flujos1
               """  
               
flujos3 = sql ^ """
               SELECT codigo, año2018, año2019, año2020, año2021, año2022
               FROM paises
               INNER JOIN flujos2
               ON nombre = nombrePais
               """    
#Lo giramos para que el codigo del pais junto con el año sean la clave que define el monto.

flujos = sql ^"""
              SELECT codigo,'2018' AS año,  año2018 AS monto
              FROM flujos3
            UNION
              SELECT codigo, '2019' AS año, año2019 AS monto
              FROM flujos3
            UNION
              SELECT codigo, '2020' AS año, año2020 AS monto
              FROM flujos3
            UNION
              SELECT codigo, '2021' AS año, año2021 AS monto
              FROM flujos3
            UNION
              SELECT codigo, '2022' AS año, año2022 AS monto
              FROM flujos3
              """

#Por ultimo la tabla redes la tenemos que armar sacando la informacion de la columna redes sociales del
#dataset listaSedesDatos, tenemos que separar los distintos links que hay en cada celda y luego
#acomodarlos de manera que cada pais tenga su codigo junto a cada una de sus redes sociales.

colRedes = listaSedesDatos[["sede_id", "redes_sociales"]]
colRedes = colRedes["redes_sociales"].str.split(" // ", expand = True)
colRedes["sede_id"] = listaSedesDatos["sede_id"]

redes1 = sql ^"""
              SELECT sede_id, "0" AS url
              FROM colRedes
        UNION
              SELECT sede_id, "1" AS url
              FROM colRedes
        UNION
              SELECT sede_id, "2" AS url
              FROM colRedes
        UNION
              SELECT sede_id, "3" AS url
              FROM colRedes
        UNION
              SELECT sede_id, "4" AS url
              FROM colRedes
        UNION
              SELECT sede_id, "5" AS url
              FROM colRedes
              """

redes1 = redes1.dropna()
redes2 = sql ^"""
              SELECT *,
              FROM redes1
              WHERE url LIKE '%com%'
               """
redesSociales = sql^"""
            SELECT *,
                   CASE
                     WHEN Lower(url) LIKE '%facebook%' THEN 'Facebook'
                     WHEN Lower(url) LIKE '%twitter%' THEN 'Twitter'
                     WHEN Lower(url) LIKE '%youtube%' THEN 'Youtube'
                     WHEN Lower(url) LIKE '%instagram%' THEN 'Instagram'
                     WHEN Lower(url) LIKE '%linkedin%' THEN 'Linkedin'
                     WHEN Lower(url) LIKE '%flickr%' THEN 'Flickr'
                   END AS tipoDeRed
            FROM   redes2
            """
redesSociales = redesSociales.dropna()
#%%===========================================================================
# Ejercicio H - CONSULTAS DE SQL
#=============================================================================
#i.) Para cada país informar cantidad de sedes, cantidad de secciones en
#promedio que poseen sus sedes y el flujo monetario neto de Inversión
#Extranjera Directa (IED) del país en el año 2022. El orden del reporte debe
#respetar la cantidad de sedes (de manera descendente). En caso de empate,
#ordenar alfabéticamente por nombre de país.

#Calculamos la cantidad de sedes por pais
cantSedes = sql ^ """
                 SELECT nombre, COUNT(*) AS sedesPorPais, codigo
                 FROM sedes
                 INNER JOIN paises
                 ON codigoPais = codigo
                 GROUP BY nombre, codigo
                 """
           
#Ahora calculamos la cantidad de secciones por sede, tuvimos que agregar las sedes que no tienen secciones
#y ponerles un 0 en cantidad de secciones.
sedesysecciones = sql ^  """
                 SELECT s.sede_id, codigoPais, COUNT(*) AS seccionesPorSede
                 FROM secciones AS l
                 INNER JOIN sedes AS s
                 ON l.sede_id = s.sede_id
                 GROUP BY s.sede_id, codigoPais
                 """
cantSecciones = sql^ """
                 SELECT s.sede_id, s.codigoPais,
                     CASE WHEN l.seccionesPorSede is null
                     THEN 0
                     ELSE l.seccionesPorSede
                     END AS seccionesPorSede,
                 FROM sedesysecciones AS l
                 RIGHT OUTER JOIN sedes AS s
                 ON l.sede_id = s.sede_id
                 """
#Calculamos el promedio de secciones por sede por cada pais.
promedio = sql ^ """
                SELECT codigoPais, nombre AS Pais, sedesPorPais AS Sedes, AVG(seccionesPorSede) AS seccionesPromedio
                FROM cantSecciones
                INNER JOIN cantSedes
                ON codigoPais = codigo
                GROUP BY codigoPais, nombre, sedesPorPais
                """          
               
#Repuesta final del ejercicio i.) uniendo toda la informacion anteriormente conseguida con el flujo en 2022.            
res1 = sql ^ """
       SELECT DISTINCT Pais, Sedes, seccionesPromedio, monto AS IED2022MU$S
       FROM promedio AS p
       INNER JOIN flujos AS f
       ON codigoPais = codigo
       WHERE año = 2022
       ORDER BY Sedes DESC, Pais ASC
       """    
#%%-----------       
#ii.) Reportar agrupando por región geográfica: a) la cantidad de países en que
#Argentina tiene al menos una sede y b) el promedio del IED del año 2022 de
#esos países (promedio sobre países donde Argentina tiene sedes). Ordenar
#de manera descendente por este último campo.              
                 
#Como la tabla paises la armamos haciendo un join con sedes para poder tener la region geografica
#todos los paises en la tabla paises ya tienen al menos 1 sede, por lo tanto contamos cuantos hay
#por region geografica.

paisesPorRegion =  sql ^ """
       SELECT DISTINCT region_geografica, COUNT(*) AS paisesConSedesArgentinas
       FROM paises
       GROUP BY region_geografica
       """                    
       
#Hacemos un join con la tabla de flujos para agregarle la region geografica y despues poder agruparlos
#en base a eso, ademas, ya nos quedamos con los registros del año 2022 que son los que nos interesan.

flujoyregion =   sql ^ """
       SELECT DISTINCT p.region_geografica, f.año, f.codigo, f.monto
       FROM paises AS p
       INNER JOIN flujos AS f
       ON p.codigo = f.codigo
       WHERE f.año = 2022
       """            
       
#Respuesta final del ejercicio ii.) uniendo todas las tablas y calculando el promedio                      
res2 =  sql ^ """
       SELECT DISTINCT f.region_geografica, p.paisesConSedesArgentinas, AVG(f.monto) AS PromedioIED2022MU$S_PaisesConSedesArgentinas
       FROM flujoyregion AS f
       INNER JOIN paisesPorRegion AS p
       ON p.region_geografica = f.region_geografica
       GROUP BY f.region_geografica, p.paisesConSedesArgentinas
       ORDER BY PromedioIED2022MU$S_PaisesConSedesArgentinas DESC
       """
#%%-----------                        
#iii.) Para saber cuál es la vía de comunicación de las sedes en cada país, nos
#hacemos la siguiente pregunta: ¿Cuán variado es, en cada el país, el tipo de
#redes sociales que utilizan las sedes? Se espera como respuesta que para
#cada país se informe la cantidad de tipos de redes distintas utilizadas.

#Primero agregamos a redesSociales el pais de cada sede.
redesycodigo =sql ^ """
                      SELECT DISTINCT s.codigoPais, r.tipoDeRed, r.url, r.sede_id
                      FROM redesSociales AS r
                      INNER JOIN sedes AS s
                      ON r.sede_id = s.sede_id
                      """  
                     
#Aca agregamos los nombres de los paises y ya agrupamos todo en funcion a cada pais y que redes tiene.
redesypaises = sql ^ """
                      SELECT DISTINCT p.nombre, r.tipoDeRed
                      FROM redesycodigo AS r
                      INNER JOIN paises AS p
                      ON p.codigo = r.codigoPais
                      GROUP BY p.nombre, r.tipoDeRed
                      """  
#Respuesta final del ejercicio iii) contando la cantidad de redes por pais, lo ordenamos descendientemente
#por cantidad para mayor prolijidad.
                   
res3 = sql ^ """
              SELECT DISTINCT nombre AS Pais, COUNT(*) AS cantDeRedes
              FROM redesypaises
              GROUP BY nombre
              ORDER BY cantDeRedes DESC
              """  
#%%-----------
#iv) Confeccionar un reporte con la información de redes sociales, donde se
#indique para cada caso: el país, la sede, el tipo de red social y url utilizada.
#Ordenar de manera ascendente por nombre de país, sede, tipo de red y
#finalmente por url.

#Reutilizamos la tabla de redesycodigo y le agregamos el nombre del pais
res4 = sql ^ """
                      SELECT DISTINCT p.nombre AS Pais, r.sede_id AS Sede, r.tipoDeRed AS RedSocial, r.url
                      FROM redesycodigo AS r
                      INNER JOIN paises AS p
                      ON p.codigo = r.codigoPais
                      ORDER BY Pais, Sede, RedSocial, url ASC
                      """  
#%%===========================================================================
# Ejercicio I - UTILIZAMOS HERRAMIENTAS DE VISUALIZACION 
#=============================================================================
#GRAFICO 1
#Mostrar, utilizando herramientas de visualización, la siguiente información:
#i.) Cantidad de sedes por región geográfica. Mostrarlos ordenados de manera
#decreciente por dicha cantidad.

sedes_por_region = sql ^ """
                 SELECT region_geografica, nombre, COUNT(*) AS sedesPorPais
                 FROM sedes
                 INNER JOIN paises
                 ON codigoPais = codigo
                 GROUP BY nombre, region_geografica
                 """
grafico1 = sql ^ """ 
           SELECT region_geografica, SUM(sedesPorPais) AS sedesPorRegion
           FROM sedes_por_region
           GROUP BY region_geografica
           ORDER BY sedesPorRegion DESC 
"""
                 
fig, ax = plt.subplots()


plt.rcParams['font.family'] = 'sans-serif'  

width = 1

ax.bar(data=grafico1, x='region_geografica',
       height='sedesPorRegion',
       color=['maroon', 'firebrick', 'indianred', 'red', 'orangered', 'tomato', 'coral', 'darksalmon', 'lightsalmon'],
       align = 'center',
       edgecolor='black')

       
ax.set_title('CANTIDAD DE SEDES POR REGION GEOGRAFICA', fontsize = 18)
ax.set_xlabel('Región Geográfica', fontsize=14)                      
ax.set_ylabel('Cantidad de sedes', fontsize=14)    
ax.set_xlim(-0.5, len(grafico1['region_geografica']) -0.5)
ax.set_ylim(0, 45)

ax.tick_params(axis='x', labelrotation= 90)
plt.xticks(fontsize=14)

bins = np.arange(1,10, width)  
bin_edges = [max(0, i-1) for i in bins]
center = (bins[:-1] + bins[1:])/2


ax.spines['bottom'].set_visible(True)
ax.spines['bottom'].set_color('black')

fig.set_size_inches(10, 10)  # Ancho y alto personalizado de la figura
# Ajusta los márgenes del gráfico para evitar superposiciones
plt.subplots_adjust(left=0.1, right=1, top=0.9, bottom=0.3)
ax.set_yticks(range(0,46,5))
#%%
#GRAFICO 2
#ii.)Boxplot, por cada región geográfica, del valor correspondiente al promedio
#del IED (para calcular el promedio tomar los valores anuales
#correspondientes al período 2018-2022) de los países donde Argentina tiene
#una delegación. Mostrar todos los boxplots en una misma figura, ordenados
#por la mediana de cada región.

grafico2= sql ^ """
SELECT DISTINCT p.codigo, AVG (monto) AS promedio_pais, p.region_geografica
FROM flujos AS f
INNER JOIN paises as p
ON f. codigo = p.codigo
GROUP BY p.codigo, p.region_geografica
"""

#Graficamos el boxplot ordenando en forma descendiente por la mediana de cada region, pusimos los
#mismos colores en los paises que en el grafico anterior asi se identifican mas facil.

ax = sns.boxplot(y='promedio_pais', x ='region_geografica', data=grafico2,
            order= ['AMÉRICA  DEL  NORTE','OCEANÍA','ASIA','EUROPA  OCCIDENTAL',
            'EUROPA  CENTRAL  Y  ORIENTAL','AMÉRICA  DEL  SUR', 'ÁFRICA  SUBSAHARIANA',
            'ÁFRICA  DEL  NORTE  Y  CERCANO  ORIENTE','AMÉRICA  CENTRAL  Y  CARIBE'],
            palette =
            {'AMÉRICA  DEL  NORTE': 'darksalmon', 'OCEANÍA': 'lightsalmon',
             'ASIA': 'maroon',
             'EUROPA  OCCIDENTAL': 'firebrick', 'EUROPA  CENTRAL  Y  ORIENTAL': 'orangered',
            'AMÉRICA  DEL  SUR': 'red', 'AMÉRICA  CENTRAL  Y  CARIBE': 'indianred', 'ÁFRICA  DEL  NORTE  Y  CERCANO  ORIENTE':'coral',
            'ÁFRICA  SUBSAHARIANA': 'tomato'}, flierprops=dict(marker='o', markersize=8, markerfacecolor = 'none', markeredgecolor = 'black'))

sns.set(rc={"figure.figsize": (18.7, 8.27)})
#Añadimos título y etiquetas de los ejes, giramos los nombres de las regiones para que queden legibles.
ax.set_title(
    "Promedio IED en periodo 2018-2022 por region geografica", fontsize="20", fontweight="bold")

plt.ylabel('PROMEDIOS (millones de U$S)', fontsize='20', fontweight="bold")
plt.xlabel('REGION GEOGRAFICA', fontsize='20', fontweight="bold")
plt.xticks (rotation= 90)
ax.set_ylim(-30000, 60000)

#%%# 
#GRAFICO 3
#iii.) Relación entre el IED de cada país (año 2022 y para todos los países que se
#tiene información) y la cantidad de sedes en el exterior que tiene Argentina
#en esos países.


#Usamos la respuesta del ejercicio H.i) que tenia la informacion de cantidad de sedes por pais
#junto con su IED en el año 2022 y lo graficamos con un scatter plot.
fig, ax = plt.subplots()

plt.rcParams['font.family'] = 'sans-serif'    
 
#Pusimos la cantidad de sedes en el ejex y el IED de 2022 en el eje y, cada punto representa un pais con
#la cantidad de sedes que tiene Argentina en el.
               
ax.scatter(data = res1, x='Sedes', y='IED2022MU$S', s=20,color='maroon')      

ax.set_title('Relacion entre el IED (2022) y la cantidad de sedes en cada pais',fontsize='20', fontweight="bold") # Titulo del gráfico
ax.set_xlabel('CANTIDAD DE SEDES POR PAIS', fontsize='19', fontweight="bold")            
ax.set_ylabel('IED 2022 (millones de U$S)', fontsize='20', fontweight="bold")  
ax.set_xticks(range(0,12,1))                  
ax.set_yticks(range(-10000,90000,10000))
ax.set_ylim(-10000,90000)  
ax.set_xlim(0,12)

