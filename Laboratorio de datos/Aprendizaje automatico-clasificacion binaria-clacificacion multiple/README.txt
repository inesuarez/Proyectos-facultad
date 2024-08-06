Para correr el código, crear un enviroment en conda con spyder y python instalados (conda create --name myenv python=3.8.18 spyder=5.4.3).Luego descargarse la carpeta y extraerla.Luego, correr pip install -r requirements.txt para descargar las bibliotecas necesarias. Abrir el proyecto con spyder asegurándose de estar en el directorio de los archivos de Python. Descargar el archivo "emnist_letters_tp.csv" y agregarlo a la carpeta
Correr el código del archivo codigo.py. Se recomienda no correr el archivo entero, sino ir ejecutando los bloques armados para cada ejercicio con Shift+Enter.

Bibliotecas utilizadas: 
-sklearn: sklearn.model_selection (funciones train_test_split)
	  sklearn.neighbors (función KNeighborsClassifier)
	  sklearn.metrics (funciones confusion_matrix, ConfusionMatrixDisplay)
          sklearn.tree (función DecisionTreeClassifier)
-numpy
-pandas
-matplotlib.pyplot
-sns

