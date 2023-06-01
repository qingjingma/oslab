#include<usname.h>
#include<stdio.h>
int main(void)
{
    char name[24];
    int r=whoami(name, 24);
    if(r!=-1)
        puts(name);
    return r;
}
