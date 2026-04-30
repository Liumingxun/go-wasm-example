GOROOT    := $(shell go env GOROOT)
TINYGOROOT := $(shell tinygo env TINYGOROOT)

OUT_DIR   := runner
WASM_GO   := $(OUT_DIR)/main.wasm
WASM_TINY := $(OUT_DIR)/main.tinygo.wasm
WASM_SRC  := ./wasm

WASM_ENV  := GOOS=js GOARCH=wasm

.PHONY: all build build-go build-tinygo run serve clean

all: build

# Runtime files (auto-copied on demand)
$(OUT_DIR)/wasm_exec.js:
	cp $(GOROOT)/lib/wasm/wasm_exec.js $@

$(OUT_DIR)/wasm_exec_tinygo.js:
	cp $(TINYGOROOT)/targets/wasm_exec.js $@

# WASM Build Targets
build: build-go build-tinygo

build-go: $(WASM_GO)
$(WASM_GO): $(shell find $(WASM_SRC) -name '*.go') $(OUT_DIR)/wasm_exec.js
	$(WASM_ENV) go build -o $@ $(WASM_SRC)

build-tinygo: $(WASM_TINY)
$(WASM_TINY): $(shell find $(WASM_SRC) -name '*.go') $(OUT_DIR)/wasm_exec_tinygo.js
	$(WASM_ENV) tinygo build -o $@ $(WASM_SRC)

# Run with Bun/Node.js
run:
	cd $(OUT_DIR) && bun run index.ts

# Serve for browser testing
serve:
	cd $(OUT_DIR) && deno run -NR jsr:@std/http/file-server

# Clean build artifacts
clean:
	rm -f $(WASM_GO) $(WASM_TINY) $(OUT_DIR)/wasm_exec.js $(OUT_DIR)/wasm_exec_tinygo.js
