package aed;

class Funciones {
    int cuadrado(int x) {
        int res = x*x;
        return res;
    }

    double distancia(double x, double y) {
        double res = Math.sqrt(x*x + y*y);
        return res;
    }

    boolean esPar(int n) {
        boolean res = false;
        if (n%2 == 0){
            res = true;
        }
        return res;
    }

    boolean esBisiesto(int n) {
        return n%4 == 0 && n%100 != 0 || n%400 == 0;
    }

    int factorialIterativo(int n) {
        int res = 1;
        for (int i=1;i<=n;i=i+1){
        res = res*i;
     }    
        return res;
    }

    int factorialRecursivo(int n) {
        int res;
        if (n==0){
            res = 1;
        }
        else {
            res = n*factorialRecursivo(n-1);
        }
        return res;
    }

    boolean esPrimo(int n) {
        boolean res = true;
        if (n==0){
            res = false;
        }
        else if (n==1){
            res = false;
        }
        else for (int i=2;i<n;i=i+1){
         if (n%i == 0){
          res = false;
        }}
        return res;
    }

    int sumatoria(int[] numeros) {
        int res = 0;
        for (int i=0;i < numeros.length;i++){
        res += numeros[i];
        }
        return res;
    }

    int busqueda(int[] numeros, int buscado) {
        int res = 0;
        for (int i = 0; i < numeros.length; i++){
            if (buscado==numeros[i]){
                res = i;
            }}
        return res;
    }

    boolean tienePrimo(int[] numeros) {
        boolean res = false;
        for (int i = 0; i < numeros.length; i++){
            if (esPrimo(numeros[i])){
                res = true;
            }}
        return res;
    }

    boolean todosPares(int[] numeros) {
        boolean res = true;
        for (int i = 0; i < numeros.length; i++){
            if (esPar(numeros[i])==false){
                res = false;
            }}
        return res;
    }

    boolean esPrefijo(String s1, String s2) {
        boolean res = true;
        if (s1.length()> s2.length()){
            res = false;
        }
        else for (int i = 0; i < s1.length(); i++){
            if (s1.charAt(i) != s2.charAt(i)){
                res = false;
            }}
        return res;
    }

    boolean esSufijo(String s1, String s2) {
        boolean res = false;
        String a = "";
        String b = "";
        if (s1.length()> s2.length()){
            res = false;
        }
        for (int i = s1.length()-1;i>=0; i --){
            a+=s1.charAt(i);
        }
        for (int i = s2.length()-1;i>=0; i --){
            b+=s2.charAt(i);
        }
        if (esPrefijo(a,b)){
            res = true;
        }
        return res;
    }
}
