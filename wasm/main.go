//go:build js && wasm

package main

import (
	"syscall/js"
)

func main() {
	echo := js.FuncOf(func(this js.Value, args []js.Value) any {
		out := make([]any, len(args))
		for i, arg := range args {
			out[i] = arg
		}
		return out
	})
	// https://pkg.go.dev/syscall/js@go1.26.0#Value.Set
	// https://pkg.go.dev/syscall/js@go1.26.0#ValueOf
	js.Global().Set("echo", echo)

	// Keep the Go runtime alive so JS callbacks remain callable.
	select {}
}
