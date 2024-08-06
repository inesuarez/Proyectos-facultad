package aed;

public class Heap {
    public int tamaño;
    public Router[] repr;

    /*
    INV REP:
    tamaño >= 0 (representa  la cantidad de elementos en el heap).
    repr es la reprecentacion de un heap en una lista,
    el primer elemento de cada arreglo representa la prioridad (o valor) del elemento y 
    el segundo elemento representa el idPartido (ya que los elementos en un heap pueden tener atributos adicionales),
    asi cuando los "ordeno" como heap no pierdo la informacion de cual es su id.
     */

    public void crearHeap(int tamañoHeap) {
        tamaño = 0;
        repr = new Router[tamañoHeap];
    } 

    public Heap heap1(Router[] lista){
        Heap heap = new Heap();
        heap.crearHeap(lista.length);
        for(int i=0;i<lista.length;i++){
            heap.encolar(lista[i]);
        }
        return heap;
    }

    private int padre(int pos) { return (pos-1)/2; }

    private int izq(int pos) { return 2*pos + 1; }

    private int der(int pos) { return 2*pos + 2; }

    private boolean esHoja(int pos) { return pos >= (tamaño / 2); }

    private int maxHijo(int posPadre) {
        if (der(posPadre) >= tamaño) return izq(posPadre);
        else if (repr[der(posPadre)].getTrafico() > repr[izq(posPadre)].getTrafico()) return der(posPadre);
        else return izq(posPadre);
    }

    public void bajar(int pos)
    {
        while (!esHoja(pos) && repr[maxHijo(pos)].getTrafico() >= repr[pos].getTrafico()) {
            Router tmp = repr[pos];
            repr[pos] = repr[maxHijo(pos)];
            pos = maxHijo(pos);
            repr[pos] = tmp;
        }
    }


    public void encolar(Router elto)
    {
        if (tamaño == 0) {
            repr[0] = elto;
        }
        else {
            repr[tamaño] = elto;
            int curr = tamaño;
            while (repr[curr].getTrafico() > repr[padre(curr)].getTrafico()) {
                bajar(padre(curr));
                curr = padre(curr);
            }
        }
        tamaño++;
    }



    public void heapify(int pos) {
        if(tamaño==0 || pos<0) return;
        bajar(pos);
        heapify(pos-1);
    }
    
        
    public Router desencolar()
    {   
        Router a = new Router(0,0);
        if (tamaño == 0) return a;
        Router max = repr[0];
        repr[0] = repr[--tamaño];
        heapify(0);
        return max;
    }
}

