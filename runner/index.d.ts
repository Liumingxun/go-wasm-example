
declare class Go {
    importObject: import('bun').WebAssembly.Imports & { env: Record<string, any> };
    run(instance: import('bun').WebAssembly.Instance): void;
};
declare function echo(...args: any[]): any[];
