BUILD_DIR = site
SERVER_PORT = 1987
SERVER_ADDR = 127.0.0.1

default: reset

.PHONY: generate build clean start watch

# USE make change record later ...

build:
	janet codes/main.janet -b

generate:
	mdz build $(BUILD_DIR) .

bgs:
	make build && make generate && make start

deploy:
	rsync -azPv --del --exclude '.git' site/* ../gh-pages &&\
	cd ../gh-pages &&\
	git add . &&\
	git commit -a -m "site deployed automatically" &&\
	git push &&\
	cd ../master

clean:
	mdz clean $(BUILD_DIR) && mdz clean $(BUILD_DIR_DEV)

start:
	mdz serve $(SERVER_PORT) 127.0.0.1 $(BUILD_DIR)

watch:		
	mdz watch
