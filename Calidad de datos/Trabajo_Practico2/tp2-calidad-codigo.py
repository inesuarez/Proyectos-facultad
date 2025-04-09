import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

pozos = pd.read_csv('capitulo-iv-pozos.csv')
noConvencionales = pd.read_csv('produccin-de-pozos-de-gas-y-petrleo-no-convencional.csv')
convencionales = pd.read_csv('produccin-de-pozos-de-gas-y-petrleo-2024.csv', low_memory=False)

print(pozos.isnull().sum())
print(noConvencionales.isnull().sum())


print(pozos['idpozo'].nunique())

print(convencionales[['idpozo', 'mes']].duplicated().sum())

print(noConvencionales[['idpozo', 'anio','mes']].duplicated().sum())

duplicados = pozos.duplicated(subset=['geojson'], keep=False)

# Mostrar todas las filas donde hay valores duplicados en la columna
filas_duplicadas = pozos[duplicados]

porcentajes = convencionales['tipo_de_recurso'].value_counts(normalize=True) * 100

convencionales = convencionales[convencionales['tipo_de_recurso'] == 'CONVENCIONAL']

coord_repetidas = noConvencionales.groupby(['coordenadax', 'coordenaday'])['idpozo'].nunique()

coord_repetidas = coord_repetidas[coord_repetidas > 1]

columns_to_check = pozos.columns.difference(['idpozo'])

pozos = pozos.drop_duplicates(subset=columns_to_check, keep='first')


# 2. Verificar rangos de valores numéricos
numeric_cols = ['prod_pet', 'prod_gas', 'prod_agua', 'iny_agua', 'iny_gas', 'iny_co2', 'iny_otro', 'tef', 'vida_util', 'profundidad']
numeric_stats = convencionales[numeric_cols].describe()

print("\
Valores nulos por columna:")
print(convencionales.isnull().sum())

print("\
Estadísticas de columnas numéricas:")
print(numeric_stats)

valores_invalidos_produccion = convencionales[(convencionales['prod_gas'] < 0) | (convencionales['prod_pet'] < 0) | (convencionales['prod_agua'] < 0) | (convencionales['iny_agua'] < 0) | (convencionales['iny_gas'] < 0) | (convencionales['iny_co2'] < 0) | (convencionales['iny_otro'] < 0)]

plt.figure(figsize=(12, 6))
sns.boxplot(data=convencionales[['prod_gas', 'prod_pet']])
plt.title('Distribución de la producción de gas y petróleo')
plt.show()

plt.figure(figsize=(12, 6))
sns.boxplot(data=convencionales[['prod_agua', 'iny_agua']])
plt.title('Distribución de la producción e inyeccion de agua')
plt.show()

plt.figure(figsize=(12, 6))
sns.boxplot(data=convencionales[['iny_gas', 'iny_otro']])
plt.title('Distribución de la inyeccion de gas y otros')
plt.show()

convencionales['fecha_produccion'] = pd.to_datetime(convencionales['fecha_produccion'], errors='coerce')

# Verificar si hay fechas nulas
fechas_nulas = convencionales[convencionales['fecha_produccion'].isnull()]
print(f"Filas con fechas nulas:\n{fechas_nulas}")

# Verificar si las fechas están en orden cronológico (es decir, no hay fechas futuras ni desordenadas)
fechas_desordenadas = convencionales[convencionales['fecha_produccion'] > pd.Timestamp.now()]
print(f"Filas con fechas en el futuro:\n{fechas_desordenadas}")

# Verificar que no haya solapamientos en los períodos de producción
# Supongamos que 'fecha_inicio' y 'fecha_fin' son las fechas de inicio y fin de la producción de cada pozo
convencionales['fecha_inicio'] = pd.to_datetime(convencionales['fecha_inicio'], errors='coerce')
convencionales['fecha_fin'] = pd.to_datetime(convencionales['fecha_fin'], errors='coerce')

# Verificar si hay solapamientos entre los períodos de producción
solapamientos = convencionales[convencionales.duplicated(subset=['ID_pozo', 'fecha_inicio', 'fecha_fin'], keep=False)]
print(f"Solapamientos en los períodos de producción:\n{solapamientos}")

# Gráfico de fechas de producción para detectar visualmente anomalías
plt.figure(figsize=(12, 6))
sns.histplot(convencionales['fecha_produccion'], kde=True, bins=30)
plt.title('Distribución de fechas de producción')
plt.show()