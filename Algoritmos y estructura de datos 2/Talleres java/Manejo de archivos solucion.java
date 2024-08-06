package aed;

import java.util.Scanner;
import java.io.PrintStream;

class Archivos {
    float[] leerVector(Scanner entrada, int largo) {
        float[] res = new float[largo];
        for (int i=0; i < largo; i++){
            res[i] = entrada.nextFloat();
        }
        return res;
    }

    float[][] leerMatriz(Scanner entrada, int filas, int columnas) {
        float[][] res = new float[filas][columnas];
        for (int i=0; i < filas; i++){
        res[i] = leerVector(entrada, columnas);
        }
        return res;
    }

    void imprimirPiramide(PrintStream salida, int alto) {
        int largo = alto*2 - 1;
        int primerAst = largo/2+1;
        int cantAst = 1;
        int astHechos = 0;
        for (int i=1; i<= alto; i++) {
            cantAst = i*2-1;
            astHechos = 0;
            for(int j=1; j<= largo; j++) {
                if(j<primerAst) salida.write(' ');
                else if (j>=primerAst && cantAst > astHechos) {
                    salida.write('*');
                    astHechos += 1;

                }
                else salida.write(' ');
            }
            if (i<alto) salida.write('\n');
            primerAst -= 1;
        }
        salida.close();
    }
}

            
        

        
    

