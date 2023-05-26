#include <errno.h>
#define __LIBRARY__
#include <unistd.h>
#include <stdio.h>

_syscall1(int, iam, const char*, name); //_syscall1 是一个宏，在 include/unistd.h 中定义。

int main(int argc,char *argv[])
{
	if (argc>23) {
	errno = EINVAL;
	return -1;
	}
	else 
	iam(argv[1]);
	return 0;
}

/*argc 是argument count的缩写表示传入main函数中的参数个数，包括这个程序本身

argv 是 argument vector的缩写表示传入main函数中的参数列表，其中argv[0]表示这个程序的名字*/

