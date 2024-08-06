package aed;

import java.util.*;

public class ABB<T extends Comparable<T>> implements Conjunto<T> {
    private class Nodo {
        T valor;
        Nodo izquierdo;
        Nodo derecho;
        Nodo padre; 

        Nodo(T valor) {
            this.valor = valor; 
        }
    }

    private Nodo raiz;
    private int tamaño;

    public ABB() {
        raiz = null;
        tamaño = 0;
    }

    public int cardinal() {
        return tamaño;
    }

    public T minimo(){
        if (raiz == null) {
            return null;
        } else {
            Nodo nodoActual = raiz; 
            while (nodoActual.izquierdo != null) {
                nodoActual = nodoActual.izquierdo;
            }
            return nodoActual.valor;
        }
    }

    public T maximo(){
        if  (raiz == null) {
            return null;
        } else {
            Nodo nodoActual = raiz;
            while (nodoActual.derecho != null) {
                nodoActual = nodoActual.derecho;
            }
            return nodoActual.valor;
        }
    }

    public void insertar(T elem){
        raiz = insertarRecursivo(raiz, elem, null);

    }
    private Nodo insertarRecursivo(Nodo nodo, T elem, Nodo Padre) {
        if (nodo == null) {
            tamaño++;
            return new Nodo(elem);
        }

        int comparacion = elem.compareTo(nodo.valor);

        if (comparacion < 0) {
            nodo.izquierdo = insertarRecursivo(nodo.izquierdo, elem, nodo);
        } else if (comparacion > 0) {
            nodo.derecho = insertarRecursivo(nodo.derecho, elem, nodo);
        }

        return nodo;
    }
    public boolean pertenece(T elem){
        return buscar(raiz, elem) != null;
    }
    private Nodo buscar(Nodo nodo, T elem) {
        if (nodo == null) {
            return null; 
        }

        int comparacion = elem.compareTo(nodo.valor);

        if (comparacion < 0) {
            return buscar(nodo.izquierdo, elem);
        } else if (comparacion > 0) {
            return buscar(nodo.derecho, elem);
        } else {
            return nodo;
        }
    }

    public void eliminar(T elem) {
        raiz = eliminarRecursivo(raiz, elem);
        tamaño--;
    }
    
    private Nodo eliminarRecursivo(Nodo nodo, T elem) {
        if (nodo == null) {
            return null; 
        }
    
        int comparacion = elem.compareTo(nodo.valor);
    
        if (comparacion < 0) {
            nodo.izquierdo = eliminarRecursivo(nodo.izquierdo, elem);
        } else if (comparacion > 0) {
            nodo.derecho = eliminarRecursivo(nodo.derecho, elem);
        } else {
    
            if (nodo.izquierdo == null) {
                return nodo.derecho;
            } else if (nodo.derecho == null) {
                return nodo.izquierdo;
            }
    
            Nodo sucesor = encontrarMinimo(nodo.derecho);
            nodo.valor = sucesor.valor;
            nodo.derecho = eliminarRecursivo(nodo.derecho, sucesor.valor);
        }
    
        return nodo;
    }
    
    private Nodo encontrarMinimo(Nodo nodo) {
        if (nodo.izquierdo != null) {
            return encontrarMinimo(nodo.izquierdo);
        }
        return nodo;
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        toStringRecursivo(raiz, sb);
        if (sb.length() > 1) {
            
            sb.deleteCharAt(sb.length() - 1);
        }
        sb.append("}");
        return sb.toString();
    }
    
    private void toStringRecursivo(Nodo nodo, StringBuilder sb) {
        if (nodo != null) {
            
            toStringRecursivo(nodo.izquierdo, sb);
            
            sb.append(nodo.valor);
            
            sb.append(",");
            
            toStringRecursivo(nodo.derecho, sb);
        }
    }

    private class ABB_Iterador implements Iterador<T> {
        private Nodo actual;
        private Stack<Nodo> pila; 

        public ABB_Iterador() {
            actual = raiz; 
            pila = new Stack<>();
            inicializadorPila(actual);
        }
        private void inicializadorPila(Nodo nodo) {
            while (nodo != null) {
                pila.push(nodo);
                nodo = nodo.izquierdo; 
            }
        }

        public boolean haySiguiente() {            
            return !pila.isEmpty();
        }
    
        public T siguiente() {
            if (!haySiguiente()) {
                return null;
            }
            Nodo nodo = pila.pop();
            actual = nodo.derecho; 
            inicializadorPila(actual);
            return nodo.valor;
        }
    }

    public Iterador<T> iterador() {
        return new ABB_Iterador();
    }

}