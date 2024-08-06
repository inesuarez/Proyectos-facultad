package aed;

import java.util.*;

public class ListaEnlazada<T> implements Secuencia<T> {
    private Nodo primero;
    private Nodo ultimo;

    private class Nodo {
        Nodo ant;
        T valor;
        Nodo sig;

        Nodo(T v){valor = v; ant = null; sig = null;}
        
    }

    public ListaEnlazada() {
        primero = null;
        ultimo = null;
    }

    public int longitud() {
        int largo = 0;
        Nodo actual = primero;
        while(actual != null){
            actual = actual.sig;
            largo ++;
        }
        return largo;
    }

    public void agregarAdelante(T elem) {
        Nodo nuevo = new Nodo(elem);
        nuevo.sig = primero;
        primero = nuevo;
    }

    public void agregarAtras(T elem) {
        Nodo nuevo = new Nodo(elem);
        if (primero == null) {
          primero = nuevo;
        } 
        else {
          Nodo actual = primero;
          while(actual.sig != null) {
            actual = actual.sig;
          }
          actual.sig = nuevo;
          nuevo.ant = actual;
          ultimo = nuevo;
        }
    }

    public T obtener(int i) {
        Nodo actual = primero;

        for (int j = 0; j < i; j++) {
          actual = actual.sig;
        }
        return actual.valor;
    }

    public void eliminar(int i) {
        Nodo actual = primero;
        Nodo prev = primero;
        for (int j = 0; j < i; j++) {
        prev = actual;
        actual = actual.sig;
        }
        if (i == 0) {
        primero = actual.sig;
        } 
        else {
        prev.sig = actual.sig;
        };
    }

    public void modificarPosicion(int indice, T elem) {
        Nodo actual = primero;

        for (int j = 0; j < indice; j++) {
          actual = actual.sig;
        }

        actual.valor = elem;
    }

    public ListaEnlazada<T> copiar() {
        ListaEnlazada<T> lista = new ListaEnlazada<>();
        Nodo actual = primero;
        while (actual != null) {
            lista.agregarAtras(actual.valor);
            actual = actual.sig;
        }
        return lista;
    }

    public ListaEnlazada(ListaEnlazada<T> lista) {
        Nodo actual = lista.primero;
        while (actual != null) {
            this.agregarAtras(actual.valor);
            actual = actual.sig;
        }
        }
    
    
    @Override
    public String toString() {
        String res = "[";
        Nodo actual = primero;
        while (actual != null) {
            if (actual.sig == null) {
                res = res + actual.valor + "]";
            }
            else {
                res = res + actual.valor + ", ";      
        }
            actual = actual.sig;
        }
        return res;
    }

    private class ListaIterador implements Iterador<T> {
    	private Nodo dedo;
        private boolean finalice;

        public boolean haySiguiente() {
            if (dedo == null) {
                return false;
            }
            else {        
             return dedo != null;
        }}	
        
        public boolean hayAnterior() {
            if ((dedo == primero) || (dedo == null & finalice == false)) {
                return false;
            }
            else {
                return true;
            }
        }

        public T siguiente() {
            T valor = dedo.valor;
            dedo = dedo.sig;
            if (dedo == null) {
                finalice = true;
            }
	        return valor;
        }
        
        public T anterior() {
            if (finalice == true) {
                return ultimo.valor;
            }
            else {
              T valor = dedo.ant.valor;
              dedo = dedo.ant;
              return valor;
            }
	        
        }

    }
    public Iterador<T> iterador(){
        ListaIterador iterador = new  ListaIterador();
        iterador.dedo = primero;
        iterador.finalice = false;
        return iterador;
    }
}
