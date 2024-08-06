/******************************************************************************

                              Online C++ Compiler.
               Code, Compile, Run and Debug C++ program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/

#include <iostream>
#include <string>

using namespace std;

bool equiv(string a, string b) {
    int mitad = a.size() / 2;
    if (a==b) return true;
    if (a.size()%2 == 1){
        return false;
    }    
    string a1 = a.substr(0,mitad);
    string a2 = a.substr(mitad);
    string b1 = b.substr(0,mitad);
    string b2 = b.substr(mitad);
    return (equiv(a1,b1) && equiv(a2,b2)) || (equiv(a2,b1) && equiv(a1,b2));
}


int main(){
  string a,b;
  cin >> a;
  cin >> b;
  if (equiv(a,b)){
      cout <<"YES"<< endl;
  }
  else{
      cout <<"NO"<< endl;
  }
}    
