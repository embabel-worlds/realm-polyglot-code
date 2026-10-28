# realm-polyglot-code

Any codebase, in fourteen languages, as one graph — read live from the repository or your mounted
workspace when a question reaches it. Nothing is ingested.

**Install [realm-code-model](https://github.com/embabel-worlds/realm-code-model) with it.** This realm's types extend parents declared there (`Source`, `SourceDeclaration`, `SourceImport`, `CallSite`, `CodeType`). Without it the realm still loads, but its types lose those parents, so a query that names a parent finds none of its rows.

- **Languages:** TypeScript/TSX, JavaScript/JSX, Python, Go, Rust, C, C++, C#, Ruby, PHP, Kotlin,
  Scala, Swift and Java, all read with tree-sitter; Java's names are resolved by binary name.
- **One model:** every language's rows are children of the same standard-model parents (`Source`,
  `SourceDeclaration`, `SourceImport`, `CallSite`), so a query spans a Python backend and its
  TypeScript frontend, or a Java service and its Kotlin client.
- **Views:** `ProjectLanguages`, `Routes` (every HTTP endpoint, in any of a dozen frameworks),
  `WhereDefined`, `WhoCalls`, `SharedNames`, `ExternalDependencies`, `DocCoverage`,
  `LargestFunctions`.
- **Java metrics:** `JavaMethodMetrics` (per method: lines, ifs, loops, switches, ternaries, try,
  catch, instanceof, casts), `JavaConstructDensity` (each construct per 100 lines), `JavaCastTargets`
  (the types cast to, most first) and `JavaCasts` (every cast, with its method and line). They count
  what `queries/java-metrics.scm` captures, through the `source-tree` kind's `emit: captures`; add a
  pattern there to count something else. Commented-out code is never counted: a comment is a node
  of its own. `examples/java-metrics/Metrics.java` is a file whose counts are known by hand — in
  `branchy`, 3 ifs, 4 loops, 1 switch, 1 try, 1 catch, 2 instanceof and 2 casts (to `Integer` and
  `Number`); the field `value`, 1 cast to `Object`; `plain`, nothing, though its string and comments
  hold an `if` and a cast.
- **Route styles are data:** `reference/route-styles.yml` says how each framework declares a route.
  Add a row to teach it another.

Try it on the RealWorld apps — the same API in nine languages:

```
Routes(project: 'https://github.com/gothinkster/golang-gin-realworld-example-app')
Routes(project: 'https://github.com/realworld-apps/aspnetcore-realworld-example-app')
Routes(project: 'https://github.com/TatriX/realworld-rust-rocket')
```

or on a full-stack repository, where the languages meet:

```
SharedNames(project: 'https://github.com/fastapi/full-stack-fastapi-template')
```

`tools/generate.py` writes the per-language types and producers; edit it, not them.

Calls outside Java are matched by name and say so (`resolution: name`). Requires the appliance's
`source-tree` producer kind. Apache-2.0.
