# realm-polyglot-code

Any codebase, in fourteen languages, as one graph — read live from the repository or your mounted
workspace when a question reaches it. Nothing is ingested.

- **Languages:** TypeScript/TSX, JavaScript/JSX, Python, Go, Rust, C, C++, C#, Ruby, PHP, Kotlin,
  Scala, Swift (tree-sitter), and Java (a type-resolving parser).
- **One model:** every language's rows are children of the same standard-model parents (`Source`,
  `SourceDeclaration`, `SourceImport`, `CallSite`), so a query spans a Python backend and its
  TypeScript frontend, or a Java service and its Kotlin client.
- **Views:** `ProjectLanguages`, `Routes` (every HTTP endpoint, in any of a dozen frameworks),
  `WhereDefined`, `WhoCalls`, `SharedNames`, `ExternalDependencies`, `DocCoverage`,
  `LargestFunctions`.
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
`source-tree` and `source` producer kinds. Apache-2.0.
