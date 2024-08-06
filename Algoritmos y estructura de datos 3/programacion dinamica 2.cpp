/******************************************************************************

                              Online C++ Compiler.
               Code, Compile, Run and Debug C++ program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/

#include <iostream>
#include <vector>
#include <tuple>
#include <sstream>
#include <iterator>

int max(std::vector<std::tuple<int,int>> lista){
    int res;
    res = std::get<1>(lista[0]);
    for(int i=0; i<lista.size();i++){
        if (std::get<1>(lista[i]) > res){
            res = std::get<1>(lista[i]);
        }
    }
    return res;
}


int maxbellotas(int cant, int alt, int f, std::vector<std::vector<int>> bellotas){
     std::vector<std::vector<std::tuple<int, int>>> matriz(alt, std::vector<std::tuple<int, int>>(cant, std::make_tuple(0, 0)));
    for(int i = 0; i < bellotas.size(); i ++){
        for(int j = 0; j < bellotas[i].size(); j++){
           std::get<0>(matriz[bellotas[i][j]-1][i]) += 1;
           std::get<1>(matriz[bellotas[i][j]-1][i]) += 1;
        }
    }
    for(int w = 0; w < alt; w++){
        for(int k = 0; k < cant; k++){
            if (w+f < alt) {
                for(int p = 0; p < cant; p++){
                    if (k != p){
                       if ((std::get<0>(matriz[w+f][p]) + std::get<1>(matriz[w][k])) > std::get<1>(matriz[w+f][p])){
                          std::get<1>(matriz[w+f][p]) = std::get<0>(matriz[w+f][p]) + std::get<1>(matriz[w][k]);
                        }
                    }
                   
                }
            }
             if (w != alt-1){
                if ((std::get<0>(matriz[w+1][k]) + std::get<1>(matriz[w][k])) > std::get<1>(matriz[w+1][k])){
                  std::get<1>(matriz[w+1][k]) = std::get<0>(matriz[w+1][k]) + std::get<1>(matriz[w][k]);
                }
            }
        }
    }
   
    return max(matriz[matriz.size()-1]);
}

int sumaAnt(std::vector<int> lista, int indice){
    int suma = 0;
    for(int i=0; i<indice ;i++){
        suma += lista[i];
    }
    return suma;
}

int main(){
    int T;
    std::cin >> T;

    std::vector<int> cantarboles;
    std::vector<int> alturas;
    std::vector<int> fs;
    std::vector<std::vector<int>> bellotas;

    for (int i = 0; i < T; ++i) {
        int cantarbol, altura, f;
        std::cin >> cantarbol >> altura >> f;
        cantarboles.push_back(cantarbol);
        alturas.push_back(altura);
        fs.push_back(f);

        std::vector<int> temp_bellotas;
        for (int j = 0; j < cantarbol; ++j) {
            std:: vector<int> lista;
            int cantbellota;
            std::cin >> cantbellota;
            for (int x = 0; x < cantbellota; ++ x){
                int alturabellota;
                std::cin >> alturabellota;
                lista.push_back(alturabellota);
            }
            bellotas.push_back(lista);
        }
        
    }
   
    int ceroFinal;
    std::cin >>  ceroFinal;
   
    
    for(int k=0; k < T; k++){
        
        std::vector<std::vector<int>> lista;
        for(int m = sumaAnt(cantarboles,k); m < sumaAnt(cantarboles,k) + cantarboles[k]; m++){
            lista.push_back(bellotas[m]);
        }
        std::cout << maxbellotas(cantarboles[k],alturas[k], fs[k], lista) << std::endl;
    }
       
    return 0;
}
