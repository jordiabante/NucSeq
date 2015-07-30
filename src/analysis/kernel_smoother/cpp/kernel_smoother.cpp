#include <iostream>
#include <cmath>
#include <iomanip>
#include <cstdlib>
using namespace std;
 
void createFilter(double kernel[],int bandwidth,int counts)
{
    // set standard deviation to 1.0
    double sigma = 1.0;
    double r;
    double s = 2.0 * sigma * sigma;
 
    // sum is for normalization
    double sum = 0.0;
 
    // generate kernel
    int lim_inf=0; //-((float)bandwidth)/2;
    int lim_sup=bandwidth;//((float)bandwidth)/2;
    int x=0;
    for (int i = lim_inf; i <= lim_sup; i++)
    {
        x=i-bandwidth/2;  
        kernel[i] = (exp(-(x*x)/s))/(M_PI * s);
        sum += kernel[i];
    }
 
    // normalize the Kernel
    for(int i =lim_inf; i <= lim_sup ; i++){
        kernel[i] /= sum;
    }
    // Scale by the number of reads
    for(int i =lim_inf; i <= lim_sup ; i++){
        kernel[i] *= counts;
    }
 
}
 
int main(int argc, char* argv[])
{
    // Read in arguments
    char* chr=argv[1];
    int position=atoi(argv[2]);
    int counts=atof(argv[3]);
    int bandwidth=atof(argv[4]);
    // Set output
    char* out_chr[bandwidth];
    int out_pos[bandwidth];
    for(int i = 0;i <=bandwidth;i++){
        out_chr[i]=chr;
        out_pos[i]=i+position-bandwidth/2;
    }
    // Initialize kernel grid
    double kernel[bandwidth];
    // Call gaussian filter
    createFilter(kernel,bandwidth,counts);
    // Print results
    for(int i = 0; i < bandwidth ; ++i)
    {
        cout << out_chr[i] << "\t" << out_pos[i] << "\t" << kernel[i];
        cout << endl;
    }
    return 0;
}
