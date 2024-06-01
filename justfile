imageName:= 'ghcr.io/kingwill101/fvm'

build tag='latest':
    docker build --no-cache -t {{imageName}}:{{tag}} .

push tag='latest': build
    docker push {{imageName}}:{{tag}}
