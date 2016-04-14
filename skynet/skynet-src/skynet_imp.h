#ifndef SKYNET_IMP_H
#define SKYNET_IMP_H

struct skynet_config {
	int thread; //线程
	int harbor; //节点
	const char * daemon; //守护进程，后台程序
	const char * module_path;
	const char * bootstrap;
	const char * logger;
	const char * logservice;
};

#define THREAD_WORKER 0
#define THREAD_MAIN 1
#define THREAD_SOCKET 2
#define THREAD_TIMER 3
#define THREAD_MONITOR 4 //monitor监视器

void skynet_start(struct skynet_config * config);

#endif
