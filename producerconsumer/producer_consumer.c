#include<stdio.h>
#include<pthread.h>
#define MAXB 10//缓冲区大小
#define MAXP 16//生产者的最终值
#define MAXC 25//消费者的最终值
pthread_mutex_t the_mutex;
pthread_cond_t condc, condp;

int buffer = 2;//生产者和消费者所使用的缓存

void *producer(void *ptr)//生产数据
{
	int i;

	for (i = 1; i <= MAXP; i++)
	{
		pthread_mutex_lock(&the_mutex);//互斥使用缓存区
		while (buffer == MAXB)
		{
			printf("producer:wait...  ");
			pthread_cond_wait(&condp, &the_mutex);
		}
		buffer = buffer + 1;//将数据放入缓存区
		printf("produce,left %d\n", buffer);
		pthread_cond_broadcast(&condc);//唤醒消费者
		pthread_mutex_unlock(&the_mutex);//释放缓冲区
	}
	pthread_exit(0);
}

void *consumer(void *ptr)//消费数据
{
	int i;

	for (i = 1; i <= MAXC; i++)
	{
		pthread_mutex_lock(&the_mutex);//互斥使用缓存区
		while (buffer == 0)
		{
			printf("consumer:wait...  ");
			pthread_cond_wait(&condc, &the_mutex);
		}

		buffer = buffer-1;//从缓存区中取出数据
		printf("consume,left: %d\n", buffer);
		pthread_cond_broadcast(&condp);
		pthread_mutex_unlock(&the_mutex);//释放缓存区
	}
	pthread_exit(0);
}

int main(int argc,char **argv)
{
	pthread_t pro1,pro2,pro3, con1,con2;
	pthread_mutex_init(&the_mutex, 0);
	pthread_cond_init(&condc, 0);
	pthread_cond_init(&condp, 0);
	pthread_create(&con1, 0, consumer, 0);
	pthread_create(&con2, 0, consumer, 0);
	pthread_create(&pro1, 0, producer, 0);
	pthread_create(&pro2, 0, producer, 0);
	pthread_create(&pro3, 0, producer, 0);
	pthread_join(pro3, 0);
	pthread_join(pro2, 0);
	pthread_join(pro1, 0);
	pthread_join(con2, 0);
	pthread_join(con1, 0);
	pthread_cond_destroy(&condc);
	pthread_cond_destroy(&condp);
	pthread_mutex_destroy(&the_mutex); 
	printf("completed");
}
