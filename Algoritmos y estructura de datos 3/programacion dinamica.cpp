/******************************************************************************

                              Online C++ Compiler.
               Code, Compile, Run and Debug C++ program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/

#include <iostream>
#include <vector>
#include <tuple>

int creciente(std::tuple<int, std::vector<int>, std::vector<int>> info) {
    std::vector<std::tuple<int, int>> lista = {
        std::make_tuple(std::get<1>(info)[0], std::get<2>(info)[0])
    };
    for (int i = 1; i < std::get<0>(info); ++i) {
        int anchura = std::get<2>(info)[i];
        int altura = std::get<1>(info)[i];
        std::vector<std::tuple<int, int>> sumas;
        for (int j = 0; j < i; ++j) {
            if (altura > std::get<0>(lista[j])){
                sumas.push_back(lista[j]);
            }
        }
        if (sumas.size() > 0){
            int maxAncho = std::get<1>(sumas[0]);
            for (int w = 1; w < sumas.size(); ++w) {
                  maxAncho = std::max(maxAncho, std::get<1>(sumas[w]));
            }
            lista.push_back(std::make_tuple(altura, maxAncho + anchura));
        } else {
            lista.push_back(std::make_tuple(altura, anchura));
        }
    } 
    int maximo = std::get<1>(lista[0]);
    for (int x =1; x < lista.size(); ++x) {
            maximo = std::max(maximo, std::get<1>(lista[x]));
        }    
    return maximo;
}

int decreciente(std::tuple<int, std::vector<int>, std::vector<int>> info) {
    std::vector<std::tuple<int, int>> lista = {
        std::make_tuple(std::get<1>(info)[0], std::get<2>(info)[0])
    };
    for (int i = 1; i < std::get<0>(info); ++i) {
        int anchura = std::get<2>(info)[i];
        int altura = std::get<1>(info)[i];
        std::vector<std::tuple<int, int>> sumas;
        for (int j = 0; j < i; ++j) {
            if (altura < std::get<0>(lista[j])){
                sumas.push_back(lista[j]);
            }
        }
        if (sumas.size() > 0){
            int maxAncho = std::get<1>(sumas[0]);
            for (int w = 1; w < sumas.size(); ++w) {
                  maxAncho = std::max(maxAncho, std::get<1>(sumas[w]));
            }
            lista.push_back(std::make_tuple(altura, maxAncho + anchura));
        } else {
            lista.push_back(std::make_tuple(altura, anchura));
        }
    } 
    int maximo = std::get<1>(lista[0]);
    for (int x =1; x < lista.size(); ++x) {
            maximo = std::max(maximo, std::get<1>(lista[x]));
        }    
    return maximo;
}


int main() {
    int T;
    std::cin >> T;

    std::vector<std::tuple<int, std::vector<int>, std::vector<int>>> casos(T);

    for (int i = 0; i < T; ++i) {
        int cantEdificios;
        std::cin >> cantEdificios;

        std::vector<int> altura(cantEdificios);
        std::vector<int> anchura(cantEdificios);

        for (int j = 0; j < cantEdificios; ++j) {
            std::cin >> altura[j];
        }

        for (int j = 0; j < cantEdificios; ++j) {
            std::cin >> anchura[j];
        }
       
        casos[i] = std::make_tuple(cantEdificios, altura, anchura);
    }


    for (int i = 0; i < T; ++i) {
        int increase = creciente(casos[i]);
        int decrease = decreciente(casos[i]);
        if (increase < decrease) {
            std::cout << "Case " << i+1 << ". Decreasing (" << decrease << "). Increasing (" << increase << ")." << std::endl;
        } else {
            std::cout << "Case " << i+1 << ". Increasing (" << increase << "). Decreasing (" << decrease << ")." << std::endl;
        }
    }

    return 0;
}