#include<stdio.h>
#include<usname.h>
int main(int argc, char *argv[])
{
    int r;
    if(argc!=2)
    {
        puts("Argument Error!");
        r=-1;
    }
    else
    {
        r=iam(argv[1]);
        if(r!=-1)   r=0;
    }
    return r;
}
