
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

#define n 10 //����� �������

//���� ����������� ���������� �� ������� ����� �����
__global__ void kernel(int* a, int* b, int* c)
{
	//���������� ������ ����
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	//��������� ��������� �������������� ������ ���� ������
	c[idx] = a[idx] * b[idx];
}

int main(void)
{
	int numBytes = n * sizeof(int);
	int a[n], b[n], c[n];
	int* adev, * bdev, * cdev;

	//�������� ������ �� GPU
	cudaMalloc((void**)&adev, numBytes);
	cudaMalloc((void**)&bdev, numBytes);
	cudaMalloc((void**)&cdev, numBytes);

	//������ �������
	for (int i = 0; i < n; i++)
	{
		a[i] = i;
		b[i] = i * i;
	}

	//����������� ������� ������ �� ������ CPU � ������ GPU
	cudaMemcpy(adev, a, numBytes, cudaMemcpyHostToDevice);
	cudaMemcpy(bdev, b, numBytes, cudaMemcpyHostToDevice);

	//����� ���� � �������� ������������� �������
	kernel <<<n, 1 >>> (adev, bdev, cdev);

	//����������� ���������� � ������ CPU
	cudaMemcpy(c, cdev, numBytes, cudaMemcpyDeviceToHost);

	//����� ����������
	for (int idx = 0; idx < n; idx++)
	{
		printf("%d * %d = %d \n", a[idx], b[idx], c[idx]);
	}

	//���������� ���������� ������ GPU
	cudaFree(adev);
	cudaFree(bdev);
	cudaFree(cdev);

	return 0;
}
