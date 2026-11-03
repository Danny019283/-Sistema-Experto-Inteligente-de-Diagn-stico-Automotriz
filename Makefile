CC      ?= gcc
BIN     := sistema_experto
SRC     := $(wildcard frontend/*.c) $(wildcard integracion/*.c) integracion/vendor/cJSON.c
OBJ     := $(SRC:.c=.o)
FUENTE  := $(shell fc-list 2>/dev/null | cut -d: -f1 | grep -m1 'DejaVuSans\.ttf$$')
CFLAGS  := -std=gnu11 -O2 -Wall -Wextra -Ifrontend -Ifrontend/vendor -Iintegracion \
           -Iintegracion/vendor -DFUENTE_TTF='"$(FUENTE)"' $(shell pkg-config --cflags sdl2 2>/dev/null)
LDLIBS  := $(shell pkg-config --libs sdl2 2>/dev/null) -lm

.PHONY: build run test clean deps

build: deps $(BIN)

$(BIN): $(OBJ)
	$(CC) -o $@ $^ $(LDLIBS)

# cJSON es código de terceros: sin warnings propios.
integracion/vendor/cJSON.o: CFLAGS += -w

run: build
	./$(BIN)

test:
	@command -v swipl >/dev/null || { echo "Falta swipl (SWI-Prolog)."; exit 1; }
	swipl -q -g run_tests -t halt pruebas/pruebas_prolog.pl

clean:
	rm -f $(BIN) $(OBJ)

deps:
	@command -v gcc >/dev/null || { echo "Falta gcc."; exit 1; }
	@command -v swipl >/dev/null || { echo "Falta swipl (SWI-Prolog): sudo dnf install pl | sudo apt install swi-prolog"; exit 1; }
	@pkg-config --exists sdl2 || { echo "Falta SDL2 (headers): sudo dnf install SDL2-devel | sudo apt install libsdl2-dev"; exit 1; }
	@[ -n "$(FUENTE)" ] || { echo "Falta la fuente DejaVu Sans: sudo dnf install dejavu-sans-fonts | sudo apt install fonts-dejavu-core"; exit 1; }
