#include <stdio.h>
#include <iostream>

using namespace std;

class fragment {
    int position;
    int score;
    public:
        fragment (int,int);
        int area () 
        {
            return (position*score);
        }
};

fragment::fragment (int b, int c) {
    position = b;
    score = c;
}

int main () {
    string line;

    fragment x (3,4);
    cout << "area: " << x.area() << endl;
    ifstream myfile ("example.txt");
    if (myfile.is_open())
    {
        myfile << "This is a line.\n";
        myfile << "This is another line.\n";
        myfile.close();
    }
    else cout << "Unable to open file";
    return 0;
}
