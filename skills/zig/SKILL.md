---
name: zig
description: Use this skill whenever the user is working with Zig (0.16+) — writing, reading, debugging, refactoring, or generating any .zig file, editing build.zig or build.zig.zon, working with allocators, error sets, comptime, std.Io, vtable interfaces, or cross-compilation. Trigger on casual asks like "add a function to my zig project", "make this faster", "fix this zig error", "write a quick zig script", or anything mentioning "zig", "ziglang", or the Zig toolchain. The skill encodes the idioms that distinguish amazing Zig from mediocre Zig — explicit allocators, errdefer-based partial-init cleanup, bulk-capacity APIs over per-element growth, comptime specialization, MultiArrayList for hot data, and the vtable-with-@fieldParentPtr interface pattern. Use it whenever the goal is *good* Zig, not just compiling Zig.
---

# Zig (0.16+)

Zig is a small, blunt language. The runtime does almost nothing for you — that's the point. Every allocation, error, and control-flow path is in the source where you can see it. Good Zig leans into that explicitness rather than papering over it.

This skill targets Zig 0.16+. If `zig version` reports older, stop and say so — the pre-0.16 dialect (managed `ArrayList`, `@cImport`, `GeneralPurposeAllocator`, old reader/writer) is different enough that examples here will mislead.

## The Zig Zen

These aren't fluff — they directly imply every pattern below.

- Communicate intent precisely.
- Edge cases matter.
- Favor reading code over writing it.
- Only one obvious way to do things.
- Runtime crashes are better than bugs.
- Compile errors are better than runtime crashes.
- Allocation may fail; deallocation must succeed.
- Memory is a resource.

## Mental model

- **Allocators are parameters, never globals or struct fields** (unless the struct _is_ an allocator). Storing an allocator inside a domain type couples it to one strategy and breaks composability — the std library does not do this and neither should you.
- **Errors are values.** `!T` returns; `try` propagates; `catch` handles; `errdefer` undoes partial state.
- **`defer` and `errdefer` are the cleanup model.** Pair every acquisition with the cleanup on the _next line_ — don't leave a gap where an early return could leak.
- **No hidden control flow.** If it looks like a function call, it is one.
- **`comptime` is generics, conditionals, and metaprogramming.** Types are values at compile time.
- **`undefined` is unsafe garbage; `?T` is a tagged optional.** Read `undefined` and you get illegal behavior. Unwrap optionals with `if (x) |v|` or `orelse`.

## Program skeleton

```zig
const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;                 // process-lifetime general allocator
    const arena = init.arena.allocator(); // scratch arena, freed at exit
    _ = gpa; _ = arena;
}
```

`init.io`, `init.environ_map`, and `init.minimal.args` are also there. Reach for `init` instead of hand-rolling a `DebugAllocator` — that's what 0.16's "Juicy Main" is for. Hand-roll only in libraries, tests, or non-`main` entry points:

```zig
var dbg: std.heap.DebugAllocator(.{}) = .init;
defer _ = dbg.deinit();   // reports leaks at exit
const gpa = dbg.allocator();
```

## Allocator strategy — by lifetime, not by habit

- **Arena** for many short-lived allocations freed together (parsers, request handlers, per-frame scratch). `O(1)` deinit; don't free items individually.
- **Fixed-buffer** (`std.heap.FixedBufferAllocator`, or stack `[N]u8` + `ArrayList(T).initBuffer(&buf)`) when there's a bounded upper limit. Zero syscalls.
- **DebugAllocator** during development, always — catches leaks, double-free, and use-after-free for free.
- **`std.heap.smp_allocator`** or **`std.heap.c_allocator`** for release.
- **`std.testing.allocator`** in every test that allocates. It fails the test on leak.

## Ownership and `errdefer`

The half-built-state bug class — leaking when init fails partway — is the single largest source of bugs in C. In Zig it's a one-liner per step:

```zig
fn newThing(gpa: Allocator) !*Thing {
    const t = try gpa.create(Thing);
    errdefer gpa.destroy(t);

    t.buf = try gpa.alloc(u8, 1024);
    errdefer gpa.free(t.buf);

    try t.openConnection();   // any failure: both errdefers fire, in reverse
    return t;                 // success: errdefers don't fire, ownership transfers
}
```

For cleanup that always runs, use `defer`:

```zig
const f = try std.fs.cwd().openFile(path, .{});
defer f.close();
```

The discipline: write the cleanup line _immediately_ after the acquisition. Never separate them.

## Errors

Let the compiler infer error sets (`!T`) inside the implementation. Name an explicit set only at API boundaries you want stable.

```zig
pub const ParseError = error{ Empty, Overflow, BadDigit };
pub fn parse(s: []const u8) ParseError!u32 { ... }

fn parseDigit(c: u8) !u8 {  // inferred — picks up errors from callees
    if (c < '0' or c > '9') return error.BadDigit;
    return c - '0';
}
```

`catch unreachable` belongs only where the error is _provably_ impossible (e.g., writing into a fixed-buffer with reserved capacity). Anywhere else, handle it — `unreachable` in a release-safe build is a hard panic.

## The init / deinit shape

Types that own resources expose a consistent pair. The owning struct does _not_ store the allocator; the caller passes it on each method that allocates (this is exactly how `std.ArrayList` works, and for the same reasons):

```zig
pub const Builder = struct {
    items: std.ArrayList(Item),

    pub const empty: Builder = .{ .items = .empty };

    pub fn deinit(self: *Builder, gpa: Allocator) void {
        self.items.deinit(gpa);
        self.* = undefined;   // turns later use into a loud crash in safe modes
    }

    pub fn add(self: *Builder, gpa: Allocator, item: Item) !void {
        try self.items.append(gpa, item);
    }
};

// Caller:
var b: Builder = .empty;
defer b.deinit(gpa);
```

Conventions:

- Decl literal `pub const empty` for zero-state constructors that don't need an allocator.
- `pub fn init(...)` only when allocation happens at construction.
- `deinit` takes the allocator that allocated.
- `self.* = undefined` after cleanup catches use-after-deinit in safe modes.

## Performance idioms

The fastest Zig is rarely the cleverest. It is almost always:

1. **Bulk capacity, not incremental growth.** `try list.ensureTotalCapacity(gpa, n)` once, then `list.appendAssumeCapacity(x)` in the hot loop. Eliminates a branch and a possible realloc per append.
2. **Slices in parameters, not `ArrayList`.** `[]const T` lets callers pass stack arrays, arenas, fixed buffers, or anything else — and reduces monomorphization bloat.
3. **`std.MultiArrayList(T)`** for hot AoS data. Stores fields columnar (SoA) without changing your `T` definition. Big cache win on iteration-heavy workloads.
4. **`comptime` specialization** for tight inner loops. `fn process(comptime mode: Mode, ...)` collapses to straight-line per-mode code with no branch.
5. **`inline for` and `inline else`** for unrolling small known-size loops and tag dispatch.
6. **Stack first, heap second.** A `[N]u8` plus `FixedBufferAllocator` beats a heap allocation every time the bound is known.
7. **Get it correct in `ReleaseSafe` first.** Safety checks are cheap; leave them on until you've measured. Don't ship `ReleaseFast` until the code is sanitizer-clean in `ReleaseSafe`.

## I/O — buffers explicit, flushing required

```zig
var stdout_buffer: [4096]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout: *std.Io.Writer = &stdout_writer.interface;

try stdout.print("hello {s}\n", .{"world"});
try stdout.flush();   // forgetting this is the #1 "why is nothing printed?" bug
```

Files, sockets, and pipes all expose `.writer(&buf).interface` and `.reader(&buf).interface`. `std.Io` is pluggable — the same code can run on threaded or event-driven backends without modification.

For ad-hoc debug prints, `std.debug.print("{any}\n", .{x})` works on any value (stderr, unbuffered). Strip these before shipping.

## Extensibility — vtable interfaces

Zig has no language-level interfaces; the idiom is a struct carrying a context pointer plus a vtable. `std.mem.Allocator` and `std.Io` are canonical examples:

```zig
pub const Hash = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        update: *const fn (*anyopaque, []const u8) void,
        final:  *const fn (*anyopaque, []u8) void,
    };

    pub fn update(self: Hash, bytes: []const u8) void { self.vtable.update(self.ptr, bytes); }
    pub fn final(self: Hash, out: []u8) void          { self.vtable.final(self.ptr, out); }
};

pub const Sha256 = struct {
    state: [8]u32,

    pub fn hash(self: *Sha256) Hash {
        return .{ .ptr = self, .vtable = &.{ .update = &updateImpl, .final = &finalImpl } };
    }
    fn updateImpl(ptr: *anyopaque, bytes: []const u8) void {
        const self: *Sha256 = @ptrCast(@alignCast(ptr));
        _ = self; _ = bytes;
    }
    fn finalImpl(ptr: *anyopaque, out: []u8) void {
        const self: *Sha256 = @ptrCast(@alignCast(ptr));
        _ = self; _ = out;
    }
};
```

When dispatch can be resolved at compile time, pass `comptime Impl: type` instead — zero overhead, full inlining. Reach for vtables only when the choice of implementation must be runtime.

## Tagged unions and exhaustive switching

State machines, ASTs, protocol messages — all want tagged unions:

```zig
pub const Token = union(enum) {
    ident: []const u8,
    number: u64,
    plus,
    minus,
    eof,
};

fn describe(t: Token) []const u8 {
    return switch (t) {
        .ident => |name| name,
        .number => "number",
        .plus, .minus => "operator",
        .eof => "<eof>",
    };
}
```

The compiler enforces exhaustiveness — adding a variant turns every incomplete switch into a compile error. **Avoid `else =>`** in switches over tagged unions; it silently swallows new variants and defeats the safety net.

## Options structs for evolvable APIs

Public APIs that take more than two or three parameters take an options struct with defaults. Adding a field later doesn't break callers:

```zig
pub const ParseOptions = struct {
    max_depth: u32 = 64,
    allow_comments: bool = false,
    duplicate_field_behavior: enum { @"error", first, last } = .@"error",
};

pub fn parse(gpa: Allocator, src: []const u8, opts: ParseOptions) !Document { ... }

// Caller — only override what they care about:
const doc = try parse(gpa, src, .{ .allow_comments = true });
```

## Build system (build.zig)

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target   = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{ .name = "myapp", .root_module = exe_mod });
    b.installArtifact(exe);

    const run = b.addRunArtifact(exe);
    if (b.args) |args| run.addArgs(args);
    b.step("run", "Run the app").dependOn(&run.step);

    const tests = b.addTest(.{ .root_module = exe_mod });
    b.step("test", "Run tests").dependOn(&b.addRunArtifact(tests).step);
}
```

Add deps with `zig fetch --save <url>` — never hand-edit hashes in `build.zig.zon`. Reference them with `b.dependency("name", .{ .target = target, .optimize = optimize })`.

When the build API surprises you, `zig init` in a scratch dir gives the current canonical shape.

## C interop and cross-compilation

`@cImport` is deprecated. Add `translate-c` as a build dependency, translate headers via the build system, and import the result as a normal Zig module. For one-shot mixed compilation, `zig build-exe foo.zig main.c -lc` works. `zig cc` is a drop-in cross-compiling C compiler — `CC="zig cc" ./configure` is a useful trick for autoconf projects.

```
zig build -Dtarget=aarch64-macos
zig build -Dtarget=x86_64-windows-gnu
zig build -Dtarget=x86_64-linux-musl   # static, no glibc dependency
zig build -Dtarget=wasm32-wasi
```

For portable Linux binaries, `-musl` avoids the glibc version-skew trap.

## Workflow

```
zig fmt src/                       # always run before commit
zig test path/to/file.zig          # one-off: tests in a single file
zig build test                     # whole-project tests
zig build --watch -fincremental    # sub-second rebuilds while editing
zig build -Doptimize=ReleaseSafe   # default release; stay here until measured
zig env                            # paths — use --lib-dir to find std source
```

When an API surprises you, read `$(zig env --lib-dir)/std/<area>.zig`. The std lib is readable Zig and is ground truth — faster and more reliable than searching the web.

## Self-review before sending code

- Every acquisition paired with `defer`/`errdefer` on the next line?
- Every fallible step in a multi-step init protected by `errdefer`?
- Every writer flushed before its function returns?
- Tests use `std.testing.allocator`?
- Bulk capacity reserved before hot-loop appends?
- Slices in parameters where possible, not `ArrayList`?
- Allocator passed as a parameter, not stored in the struct?
- Switches over tagged unions exhaustive (no `else =>`)?
- Public APIs with 3+ params take an `Options` struct?
- `zig fmt` clean?
- Compiles in `ReleaseSafe`, not just `Debug`?

## Pitfalls

- Forgetting `try writer.flush()` — output silently lost.
- Storing the allocator in a struct "for convenience" — couples the type to one strategy and breaks composability.
- `catch unreachable` outside genuinely unreachable paths.
- Reading from `undefined` — illegal behavior, not zero.
- Treating `?T` as a C nullable pointer — it's a tagged optional.
- `else =>` in tagged-union switches — silently swallows new variants.
- Hardcoding hashes in `build.zig.zon` — use `zig fetch --save`.
- `inline` on large or recursive functions — compile-time and binary-size disaster.
- Inventing API signatures from memory. If unsure, write a 5-line file and `zig test` it — the error tells you the real shape.
