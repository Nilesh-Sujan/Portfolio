/* INSTRUCTIONS FOR CHANGING INPUTSIZE
 * UNDER GLOBAL DEFINITIONS, CHANGE "inputSize" VARIABLE.
 */

// Includes
#include <stdio.h>
#include <stdlib.h>

// Global definitions for ease of access
int blockThreads_num = 1024; // Initialize variable for number of threads per block
int inputSize = 8;           // Initialize variable for list input size. 8/1024/1025/65535

// Function that runs on GPU to reduce the array
__global__ void reduce(int *input, int *output, int deviceinputSize)
{
    extern __shared__ int sdata[]; // Dynamically allocated shared memory

    unsigned int tid = threadIdx.x;                               // Define threadID
    unsigned int i = blockIdx.x * (blockDim.x * 2) + threadIdx.x; // Index in the grid

    if (i < deviceinputSize)
    { // Check if there is more elements in the dataset than threads
        // perform first level of reduction,
        // reading from global memory, writing to shared memory
        // OPTIMIZATION: Deals with idle threads
        sdata[tid] = input[i] + input[i + blockDim.x]; // Each thread loads one element from global to shared memory

        __syncthreads(); // Synchronizes to protect from read-after-write memory race conditions within the block. Waits for code to reach this point.

        // Performs the reduction in shared memory.
        // OPTIMIZATION: reversed loop and threadID-based indexing to use sequential addressing rather than interleaved addressing
        for (unsigned int s = 1; s < blockDim.x; s *= 2)
        {
            if (tid % (2 * s) == 0)
            {
                sdata[tid] += sdata[tid + s];
            }

            __syncthreads(); // Synchronizes to protect from read-after-write memory race conditions within the block. Waits for code to reach this point.
        }

        // Writes result for this block to global memory
        if (tid == 0)
            output[blockIdx.x] = sdata[0];
    }
}

// Helper function that runs on CPU to fills in the array with all the numbers up to inputarraylength.
void fill_array(int *a, int n)
{
    for (int i = 0; i < n; i++) // For loop through the array size
        a[i] = i;               // Fill in each array index with the index of the loop
}

// Helper function that calculates the appropriate output size for the output array based on input size
int initOutputArray(int inputSize, int outputSize)
{
    outputSize = inputSize / (blockThreads_num / 2); // Divide input size by the amount of thread block going to be used
    if (inputSize % (blockThreads_num / 2))
    {                 // Check if the inputsize is divisible by the specificed number of threads in a block.
        outputSize++; // Increment the output size
    }
    return outputSize; // Return output size
}

// Helper function that calculates the sum of the reduced array
int calculateSum(int *hostOutput, int outputSize)
{
    for (int i = 1; i < outputSize; i++)
    {                                   // Loop through the output array
        hostOutput[0] += hostOutput[i]; // Perform the calculation while appending it to the first element.
    }

    return hostOutput[0]; // Return the first element
}

// Main function, entry point of program.
int main()
{
    // Definitions
    int *a;             // Define input host array
    int *a_out;         // Define output host array
    int *b;             // Define input device array
    int *b_out;         // Define output device array
    int outputSize = 0; // Define output size of output array

    outputSize = initOutputArray(inputSize, outputSize); // Inititalize output array

    a = (int *)malloc(inputSize * sizeof(int));      // Allocate memory to host input array
    a_out = (int *)malloc(outputSize * sizeof(int)); // Allocate memory to host output array

    if (a == NULL || a_out == NULL)
    {
        printf("Failed to allocate memory to host array!\n");
        exit(EXIT_FAILURE);
    }

    fill_array(a, inputSize); // Fill in the array with the appropriate numbers

    dim3 blockSize(blockThreads_num, 1, 1); // Create blocksize based on threadnum
    dim3 gridSize(outputSize, 1, 1);        // Create gridsize based on outputSize

    cudaError_t error = cudaSuccess; // Error code to check return values for CUDA calls

    error = cudaMalloc((void **)&b, inputSize * sizeof(int)); // Allocate memory to device input array

    if (error != cudaSuccess) // Error checking
    {
        fprintf(stderr, "Failed to allocate memory to input device array. (Error Code: %s)\n", cudaGetErrorString(error)); // Print error message if error
        exit(EXIT_FAILURE);                                                                                                // Exit program
    }

    error = cudaMalloc((void **)&b_out, outputSize * sizeof(int)); // Allocate memory to device output array

    if (error != cudaSuccess) // Error checking
    {
        fprintf(stderr, "Failed to allocate memory to output device array. (Error Code: %s)\n", cudaGetErrorString(error)); // Print error message if error
        exit(EXIT_FAILURE);                                                                                                 // Exit program
    }

    error = cudaMemcpy(b, a, inputSize * sizeof(int), cudaMemcpyHostToDevice); // Copy data between the host and the device.

    if (error != cudaSuccess) // Error checking
    {
        fprintf(stderr, "Failed to copy data from host to device (Error Code: %s)\n", cudaGetErrorString(error)); // Print error message if error
        exit(EXIT_FAILURE);                                                                                       // Exit program
    }

    reduce<<<gridSize, blockSize, blockThreads_num * sizeof(double)>>>(b, b_out, inputSize); // Kernel for the reduce function containing gridsize, block size and amount of dynamically allocated shared memory

    error = cudaGetLastError(); // Returns the last error from a runtime call.

    if (error != cudaSuccess) // Error checking
    {
        fprintf(stderr, "Failed to launch kernel (Error Code: %s)\n", cudaGetErrorString(error)); // Print error message if error
        exit(EXIT_FAILURE);                                                                       // Exit program
    }

    error = cudaMemcpy(a_out, b_out, outputSize * sizeof(int), cudaMemcpyDeviceToHost); // Copy data between the device and the host.

    if (error != cudaSuccess) // Error checking
    {
        fprintf(stderr, "Failed to copy data from device to host (Error Code: %s)\n", cudaGetErrorString(error)); // Print error message if error
        exit(EXIT_FAILURE);                                                                                       // Exit program
    }

    int sum = calculateSum(a_out, outputSize); // Accumulate the sum from the host output

    printf("Sum of list: %d\n", sum); // Print out the final sum

    error = cudaFree(b); // Free device input memory

    if (error != cudaSuccess) // Error checking
    {
        fprintf(stderr, "Failed to free device input memory (error code %s)!\n", cudaGetErrorString(error)); // Print error message if error
        exit(EXIT_FAILURE);                                                                                  // Exit program
    }

    error = cudaFree(b_out); // Free device output memory

    if (error != cudaSuccess) // Error checking
    {
        fprintf(stderr, "Failed to free device output memory (error code %s)!\n", cudaGetErrorString(error)); // Print error message if error
        exit(EXIT_FAILURE);                                                                                   // Exit program
    }

    free(a);     // Free host input array memory
    free(a_out); // Free host output array memory

    error = cudaDeviceReset(); // Reset the device and exit

    if (error != cudaSuccess) // Error checking
    {
        fprintf(stderr, "Failed to deinitialize the device! error=%s\n", cudaGetErrorString(error)); // Print error message if error
        exit(EXIT_FAILURE);                                                                          // Exit program
    }

    cudaDeviceSynchronize(); // Ensures that the GPU finishes before exiting as kernel execution is asynchronous.
}