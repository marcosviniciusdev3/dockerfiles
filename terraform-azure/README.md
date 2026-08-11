Usage: 
`podman run -it --rm -v azure:/root/.azure -v $(pwd):/terraform:Z tf-az:latest -chdir=/terraform $@`
