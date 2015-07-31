#include <iostream>
#include <cmath>
#include <iomanip>
#include <cstdlib>
using namespace std;
 
void createFilter(double kernel[],int bandwidth)
{
    // set standard deviation
    double sigma = (double)bandwidth/10;
    double r;
    double s = 2.0 * sigma * sigma;
 
    // sum is for normalization
    double sum = 0.0;
 
    // generate kernel
    int lim_inf=0;
    int lim_sup=bandwidth;
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
 
}
 
int main(int argc, char* argv[])
{
    // Read in arguments
    int bandwidth=atof(argv[1]);
    // Initialize kernel grid
    double kernel[bandwidth];
    // Call gaussian filter
    createFilter(kernel,bandwidth);
    // Print results
    for(int i = 0; i < bandwidth ; ++i)
    {
        std::cout << fixed << showpoint << setprecision(4) << kernel[i] << "\n";
    }
    return 0;
}
