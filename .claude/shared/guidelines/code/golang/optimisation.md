# Optimization

## Stack vs Heap: Pointer and Value Passing Semantics in Go

1. **Pass structs as pointers, only if the pointer does not escape.** Write code that avoids escape — don't return them
   from constructors, don't store them in heap-allocated containers, don't send them through interfaces or channels.
   Verify with `-gcflags='-m'`
2. **Use an escaping pointer only** when the object must outlive its stack frame, allocated once per runtime (config,
   singleton, server instance)
3. **Use value for primitives and trivially small types** — where pointer indirection adds more complexity than the copy
   costs
4. **Never** use a short-lived escaping pointer for performance — always slower than a value copy at any size

## Benchmarks

Use `Benchmark<Name>(b *testing.B)` for performance-sensitive code. Document results in comments above the benchmark
function for future reference. Benchmarks are only useful for comparing results before and after changes. Raw benchmark
values are usually pointless.
