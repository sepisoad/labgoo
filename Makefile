BUILD_DIR = site
SERVER_PORT = 1987
SERVER_ADDR = 127.0.0.1

default: reset

.PHONY: generate build clean start watch

# USE make change record later ...

build:
	janet codes/main.janet -b

rebuild:
	janet codes/main.janet -r

build-last:
	janet codes/main.janet -l

generate:
	mdz build $(BUILD_DIR) .

clean:
	mdz clean $(BUILD_DIR) && mdz clean $(BUILD_DIR_DEV)

start:
	mdz serve $(SERVER_PORT) 127.0.0.1 $(BUILD_DIR)

watch:		
	mdz watch