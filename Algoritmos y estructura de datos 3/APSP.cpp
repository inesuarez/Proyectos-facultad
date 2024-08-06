/******************************************************************************

                              Online C++ Compiler.
               Code, Compile, Run and Debug C++ program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/

#include <iostream>
#include <vector>
#include <algorithm>
#include <climits>
#include <numeric>
#include <limits>

using namespace std;


vector<vector<int>> ordenar(vector<vector<int>> torres, vector<int> orden){
    int n = torres.size();
    vector<vector<int>> res(n,vector<int>(n,0));
    for(int i = 0; i < orden.size(); i++){
        for(int j = 0; j < orden.size(); j++){
           res[i][j] = torres[orden[i]][orden[j]];
        }    
    }
    return res;
}

long long sumMatriz(vector<vector<int>> matriz, int k){
    long long res = 0;
    for(int i = 0; i <= k; i++){
       for(int j = 0; j <= k; j++){
           res += matriz[i][j];
       }
    }
    return res;
}

long long dantzig(vector<vector<int>> torres){
    vector<vector<int>> modificada = torres;
    long long res = 0;
    for(int k = 0; k < torres.size()-1; k++){
        res += sumMatriz(modificada,k);
        for(int i = 0; i <= k; i++){
            int res1 = numeric_limits<int>::max();
            int res2 = numeric_limits<int>::max();
            for(int j = 0; j <= k; j++){
                res1 = min(res1,modificada[i][j]+modificada[j][k+1]);
                res2 = min(res2,modificada[k+1][j]+modificada[j][i]);
            }
            modificada[i][k+1] = res1;
            modificada[k+1][i] = res2;
        }
        for(int i = 0; i <= k; i++){
            for(int j = 0; j <= k; j++){
                modificada[i][j] = min(modificada[i][j],modificada[i][k+1]+modificada[k+1][j]);
            }
        }
    }
    res += sumMatriz(modificada, torres.size()-1);
    return res;
}

int main(){
    int T;
    cin >> T;
    vector<long long> res;
   
    for(int i = 0; i < T; i++){
        int cantTorres;
        cin >> cantTorres;
        vector<vector<int>> torres;
        for(int j = 0; j < cantTorres; j++){
            vector<int> torre;
            for(int k = 0; k < cantTorres; k++){
                int num;
                cin >> num;
                torre.push_back(num);
            }
            torres.push_back(torre);
        }
        vector<int> orden;
        for(int p = 0; p < cantTorres; p++){
            int ord;
            cin >> ord;
            orden.push_back(ord);
        }
        reverse(orden.begin(),orden.end());
        vector<vector<int>> ordenada = ordenar(torres,orden);
        res.push_back(dantzig(ordenada));
    }
   
    for(int m = 0; m < res.size(); m++){
        cout << res[m] << endl;
    }
    return 0;
}