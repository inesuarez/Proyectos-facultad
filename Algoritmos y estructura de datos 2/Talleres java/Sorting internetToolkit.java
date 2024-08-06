package aed;
import aed.Heap;

public class InternetToolkit {
    public InternetToolkit() {
    }

    public Fragment[] tcpReorder(Fragment[] fragments) {       
        for (int i = 1; i<fragments.length ;i++){
            Fragment elem = fragments[i];
            int j = i - 1;
            while (j>=0 && fragments[j].compareTo(elem)==1){
                fragments[j+1] = fragments[j];
                j-=1;
            }
            fragments[j+1]=elem;
       }
        return fragments;
    }

    public Router[] kTopRouters(Router[] routers, int k, int umbral) {
        Heap r = new Heap();
        r.repr=routers;
        r.tamaño=routers.length;
        r.heapify(routers.length-1);
        Router[] listo = new Router[k];
        Router x= new Router(0, 0);
        for(int i=0;i<k;i++){
            x=r.desencolar();
            if(x.getTrafico()>=umbral){
                listo[i]=x;
            }
            
        }
        return listo;
    }

    public IPv4Address[] sortIPv4(String[] ipv4) {
        IPv4Address[] res = new IPv4Address[ipv4.length];
        for (int i = 0; i<ipv4.length ;i++){
            IPv4Address x = new  IPv4Address(ipv4[i]);
            res[i]= x;
        }
        for(int o=3;o>-1;o--){
            for (int r = 1; r<ipv4.length ;r++){
                IPv4Address elem = res[r];
                int j = r - 1;
                while (j>=0 && res[j].getOctet(o) > elem.getOctet(o)){
                    res[j+1] = res[j];
                    j-=1;
                }
                res[j+1]=elem;
            }
        }    
        return res;
    }

}
