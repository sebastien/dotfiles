CUDA_PATH=$(echo /usr/local/cuda-* | head -n1)
if [ -d "$CUDA_PATH" ]; then
	export PATH=$CUDA_PATH/bin:$PATH
	export LD_LIBRARY_PATH=$CUDA_PATH/lib64:$LD_LIBRARY_PATH
fi
