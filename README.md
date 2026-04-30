# WASM Example: Go to WebAssembly

A minimal example project demonstrating Go-to-WebAssembly compilation with dual build methods using standard Go and TinyGo compilers.

## Quick Start

### Prerequisites
- **Go 1.26.1+** (for standard build)
- **TinyGo 0.41** (optional, for TinyGo build)
- **Bun** (optional, for JavaScript/TypeScript runtime)
- **Deno** (optional, for browser server)

### Build & Run

```bash
# Build with standard Go
make build-go

# Or build with TinyGo
make build-tinygo

# Run with Bun
make run

# Or serve for browser
make serve
# Open http://localhost:8000 in your browser
```

## How It Works

### Go Side (wasm/main.go)

**Key Points:**
- `//go:build js && wasm` - Compiler directive for WebAssembly target
- `js.FuncOf()` - Creates a callable function for JavaScript
- `js.Global().Set()` - Exports function to JavaScript global scope
- `select {}` - Infinite loop to keep Go runtime active

### JavaScript Side (runner/)

**Bun** (index.ts):

Two runtimes (`wasm_exec_tinygo` and `wasm_exec`) are loaded in parallel via `Promise.all`. Each gets its own `Go` instance, so they never interfere with each other's global state. Missing WASM files are handled gracefully without crashing the other runtime.

**Browser** (index.html):
```html
<script src="wasm_exec_tinygo.js"></script>
<script>
    const go = new Go();
    WebAssembly.instantiateStreaming(fetch('./main.wasm'), go.importObject)
        .then(result => go.run(result.instance));
</script>
```

## Development

### Building Locally

```bash
# Standard Go build (recommended)
GOOS=js GOARCH=wasm go build -o ./runner/main.wasm ./wasm

# TinyGo build
GOOS=js GOARCH=wasm tinygo build -o ./runner/main.wasm ./wasm
```

### Testing

1. **Browser Testing:**
   ```bash
   make serve
   # Open http://localhost:8000 in browser
   # Check browser console for output
   ```

2. **Node.js Testing:**
   ```bash
   make build-go
   make run
   ```

### Debugging

- **Browser**: Check DevTools Console for errors and output
- **Node.js**: Standard console output will show results

### Adding More Functions

1. Create function in `wasm/main.go`:
   ```go
   add := js.FuncOf(func(this js.Value, args []js.Value) any {
       return args[0].Int() + args[1].Int()
   })
   js.Global().Set("add", add)
   ```

2. Call from JavaScript:
   ```javascript
   console.log(add(5, 3));  // Output: 8
   ```

## References

- [WebAssembly MDN Guide](https://developer.mozilla.org/en-US/docs/WebAssembly)
- [Go WebAssembly Documentation](https://go.dev/wiki/WebAssembly)
- [TinyGo WASM Support](https://tinygo.org/docs/guides/webassembly/)
- [JavaScript/Go Interop](https://pkg.go.dev/syscall/js)
- [WebAssembly Directives](https://pkg.go.dev/cmd/compile#hdr-WebAssembly_Directives)
- [Go Build Constraints](https://pkg.go.dev/cmd/go#hdr-Build_constraints)
