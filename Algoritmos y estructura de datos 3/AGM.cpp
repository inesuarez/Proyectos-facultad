/******************************************************************************

                              Online C++ Compiler.
               Code, Compile, Run and Debug C++ program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/

#include <iostream>
#include <vector>
#include <tuple>
#include <string>
#include <algorithm>
#include <limits>
#include <map>

using namespace std;

int peso(string clave1, string clave2){
    int res = 0;
    for (int i = 0; i < 4; i++){
        int resta = abs(int(clave1[i]) - int(clave2[i]));
        res += min(resta,10-resta);
    }
    return res;
}

string minimo(map<string,int> keys, vector<string> claves){
    string res = claves[0];
    for (int i = 1; i < claves.size(); i++){
        if (keys[res] > keys[claves[i]]) {
            res = claves[i];
        }
    }
    return res;
}

int desbloquear(vector<string> claves){
    string inicial = claves[0];
    map<string,int> keys;
    string ceros = "0000";
    int res = peso(inicial,ceros);
    int infinito = numeric_limits<int>::max();
    for (int i = 0; i < claves.size(); i++){
        if (i != 0){
          int nuevo = peso(claves[i],ceros);
          if (res > nuevo) {
          inicial = claves[i];
          res = nuevo;
          }
        }
        keys[claves[i]]=infinito;
    }
    keys[inicial] = 0;
    while (claves.size() != 0){
        string u = minimo(keys,claves);
        res += keys[u];
        claves.erase(remove(claves.begin(), claves.end(), u),claves.end());
        for (int j = 0; j < claves.size(); j++){
            int w = peso(u,claves[j]);
            if (w < keys[claves[j]]){
                keys[claves[j]] = w;
            }
        }
    } 
    return res;
}

int main() {
    int T;
    cin >> T;
    vector<int> res;
    for (int i = 0; i < T; i++){
        int cant;
        cin >> cant;
        vector<string> claves;
        for (int j = 0; j < cant; j++){
            string clave;
            cin >> clave;
            claves.push_back(clave);
        }
        res.push_back(desbloquear(claves));
    }
    for (int k = 0; k < T; k++){
        cout << res[k] << endl;
    }
    return 0;
}
