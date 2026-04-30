/// <reference path="./index.d.ts" />
import { file, fileURLToPath } from 'bun'

async function loadAndRun(runtimeImport: Promise<unknown>, wasmPath: string, label: string): Promise<void> {
    await runtimeImport;
    const go = new Go();
    try {
        const bytes = await file(wasmPath).arrayBuffer();
        const result = await WebAssembly.instantiate(bytes, go.importObject);
        go.run(result.instance);
        console.log(echo(`Hello from ${label}!`, undefined, null, 42));
    } catch (err) {
        console.error(`${label} WASM file not found. Please build first.`);
        return;
    }
}

Promise.all([
    loadAndRun(import('./wasm_exec_tinygo'), fileURLToPath(import.meta.resolve('./main.tinygo.wasm')), 'TinyGo'),
    loadAndRun(import('./wasm_exec'), fileURLToPath(import.meta.resolve('./main.wasm')), 'Go'),
]).catch((err) => console.error('WASM load failed:', err));
