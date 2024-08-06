/******************************************************************************

                              Online C++ Compiler.
               Code, Compile, Run and Debug C++ program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/

#include <iostream>
#include <vector>
#include <tuple>
#include <algorithm>
#include <map>
#include <limits>
#include <sstream>
#include <string>

using namespace std;

int cantAp(vector<tuple<int,int>> lista, int elem){
    int res = 0;
    for(int i = 0; i < lista.size(); i++){
        if (get<0>(lista[i]) == elem) {
            res += 1;
        }
    }
    return res;
}

vector<tuple<int,int>> repetidos(vector<tuple<int,int>> ascensores, int final){
    vector<tuple<int,int>> res;
    for(int k = 0; k < ascensores.size(); k++){
        if ((cantAp(ascensores,get<0>(ascensores[k])) > 1) || (get<0>(ascensores[k]) == 0) || (get<0>(ascensores[k]) == final)) {
            res.push_back(ascensores[k]);
        }
    }
    return res;
}

vector<tuple<int,int>> vecinos(vector<tuple<int,int>> vertices, tuple<int,int> vertice){
    vector<tuple<int,int>> res;
    for(int i = 0; i < vertices.size(); i++){
        if (vertices[i] != vertice){
            if ((get<1>(vertices[i]) == get<1>(vertice)) || (get<0>(vertices[i])==get<0>(vertice))){
                res.push_back(vertices[i]);
            }
        }
    }
    return res;
}

vector<int> tienecero(vector<tuple<int,int>> vertices){
    vector<int> res;
    for(int i = 0; i < vertices.size(); i++){
        if(get<0>(vertices[i]) == 0){
            res.push_back(get<1>(vertices[i]));
        }
    }
    return res;
}

bool pertenece(vector<int> lista, int elem){
    for(int i = 0; i < lista.size(); i++){
        if(lista[i]==elem){
            return true;
        }
    }
    return false;
}

tuple<int,int> minimo(map<tuple<int,int>,int> dist, vector<tuple<int,int>> vertices){
    tuple<int,int> res = vertices[0];
    for (int i = 1; i < vertices.size(); i++){
        if (dist[res] > dist[vertices[i]]) {
            res = vertices[i];
        }
    }
    return res;
}

int peso(tuple<int,int> ver1, tuple<int,int> ver2, vector<int> tiempo){
    if(get<0>(ver1)==get<0>(ver2)){
        return 60;
    }
    else return abs(get<0>(ver1)-get<0>(ver2))*tiempo[get<1>(ver2)-1];
}

int dijkstra(vector<tuple<int,int>> vertices, vector<int> tiempo, int final){
    vector<tuple<int,int>> s;
    tuple<int,int> inicio = make_tuple(0,0);
    s.push_back(inicio);
    map<tuple<int,int>,int> dist;
    dist[inicio] = 0;
    int infinito = numeric_limits<int>::max();
    vector<int> cero = tienecero(vertices);
    int i = 0;
    while(i < vertices.size()){
        if (get<0>(vertices[i]) != 0){
            if (pertenece(cero,get<1>(vertices[i]))){
                dist[vertices[i]] = peso(inicio,vertices[i],tiempo);
            }
            else {
                dist[vertices[i]] = infinito;
            }
            i += 1;
        }
        else{
            vertices.erase(remove(vertices.begin(), vertices.end(), vertices[i]),vertices.end());
        }
    }
    while (vertices.size() != 0) {
       tuple<int,int> u = minimo(dist,vertices);
       s.push_back(u);
       vertices.erase(remove(vertices.begin(), vertices.end(), u),vertices.end());
       vector<tuple<int,int>> vecinosu = vecinos(vertices, u);
       for(tuple<int,int> vertice : vecinosu){
           int l = dist[u] + peso(vertice,u,tiempo);
           if(dist[vertice] > l){
               dist[vertice] = l;
           }
       }
    }
    int res = infinito;
    for(tuple<int,int> vertice : s){
        if(get<0>(vertice) == final){
          if(dist[vertice] < res){
            res = dist[vertice];  
          }
        }
    }
    return res;
}

int main(){ 
    int cantasc, final;
    vector<int> respuestas;
    string line;
    while(getline(cin, line)){
        if(line.empty()){
            break;
        }
        stringstream ss(line);
        ss >> cantasc >> final;
        vector<int> tiempo(cantasc);
        getline(cin, line);
        stringstream ss2(line);
        for(int i = 0; i < cantasc; i++){
           ss2 >> tiempo[i];
        }
        
        vector<tuple<int,int>> ascensores;
        
        for(int j = 0; j < cantasc; j++){
            getline(cin, line);
            stringstream ss3(line);
            int numero;
            while (ss3 >> numero) {
              ascensores.push_back(make_tuple(numero,j+1));
            }
        }
        vector<tuple<int,int>> vertices = repetidos(ascensores, final);
        int res = dijkstra(vertices, tiempo, final);
        respuestas.push_back(res);
    }
    for(int valor : respuestas){
        if(valor > 2000000000 || valor < -2000000000){
            cout << "IMPOSSIBLE" << endl;
        }
        else{
            cout << valor << endl;
        }
    }
    
    return 0;
}