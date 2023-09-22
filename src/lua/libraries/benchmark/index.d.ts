type BenchmarkData = {Total: number, Longest: number, Shortest: number, Average: number};

interface BenchmarkObject {
    SetFunction(self: BenchmarkObject, timesToRun: number, func: (timesRan: number) => (void)): BenchmarkData;
    Start(self: BenchmarkObject): void;
    Stop(self: BenchmarkObject): void;
    GetCurrentTime(self: BenchmarkObject): number | undefined;
    Destroy(self: BenchmarkObject): void;
}

export namespace Benchmark {
    export function CreateBenchmark(): BenchmarkObject
}