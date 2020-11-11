#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <ctime>
#include <stdio.h>

__global__ void squareKernel(int* data, int N);

int main(int argc, char** argv)
{
	int* arr;
	int* h_data;
	int* d_data;
	//���������� ��������� + 1
	int n = 1000000;
	//����� ���������
	int sum = 0;
	int sumCPU = 0;

	//������ ��� �������� ������� ���������� �� GPU
	cudaEvent_t g_start, g_stop;
	cudaEventCreate(&g_start);
	cudaEventCreate(&g_stop);
	//clock ��� �������� ������� ���������� �� CPU
	clock_t c_start, c_stop;

	// �������� page-locked ������ �� �����
	// ��� ������� ����� ����� ������������ �������� ��� ��������� ������������� �������� ��� ������ ������� ����� ������ � �����������.
	cudaHostAlloc(&h_data, n * sizeof(int), cudaHostAllocPortable);

	//cudaMemcpy(h_data, arr, n * sizeof(int), cudaMemcpyHostToDevice);

	// �������� ������ �� ����������
	cudaMalloc(&d_data, n * sizeof(int));

	dim3 block(512);
	dim3 grid((n + block.x - 1) / block.x);

	//grid - ���������� ������
	//block - ������ �����
	squareKernel <<<grid, block>>>(d_data, n);

	cudaEventRecord(g_start, 0);

	//�������� ������ � ���������� (d_data) �� ���� (h_data)
	cudaMemcpy(h_data, d_data, n * sizeof(int), cudaMemcpyDeviceToHost);

	cudaEventRecord(g_stop, 0);
	cudaEventSynchronize(g_stop);
	float GPUelapsedTime;
	cudaEventElapsedTime(&GPUelapsedTime, g_start, g_stop);

	for (int j = 0; j < n; j++)
	{
		sum = sum + h_data[j];
	}

	//CPU
	clock_t begin = clock();

	for (int i = 0; i < n; i++)
	{
		sumCPU += i * i;
	}

	clock_t end = clock();
	double time_spent = (double)(end - begin) / CLOCKS_PER_SEC * 1000;

	printf("Time in GPU: %lfms\n", GPUelapsedTime);
	printf("Time in CPU: %lfms\n", time_spent);
	printf("sum GPU for %d = %d\n", n-1, sum);
	printf("sum CPU for %d = %d\n", n-1, sumCPU);

	cudaEventDestroy(g_start);
	cudaEventDestroy(g_stop);
	return 0;
}

__global__ void squareKernel(int* data, int N)
{
	//threadIdx � ����� ���� � �����
	//blockIdx � ����� �����, � ������� ��������� ����
	//blockDim � ������ �����

	//���������� ������ ���� ������ ����
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	if (i < N)
	{
		data[i] = i * i;
	}
}