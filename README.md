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
  `LargestFunctions`; and how the code holds together, after shinar's code realm: `WhoUses`,
  `PartDependencies`, `MutualDependencies`, `Hotspots`, `UnusedTypes`, `Impact`.
- **Java metrics:** `JavaMethodMetrics` (per method: lines, ifs, loops, switches, ternaries, try,
  catch, instanceof, casts), `JavaConstructDensity` (each construct per 100 lines), `JavaCastTargets`
  (the types cast to, most first) and `JavaCasts` (every cast, with its method and line). They count
  what `queries/java-metrics.scm` captures, through the `source-tree` kind's `emit: captures`; add a
  pattern there to count something else. Commented-out code is never counted: a comment is a node
  of its own. `examples/java-metrics/Metrics.java` is a file whose counts are known by hand — in
  `branchy`, 3 ifs, 4 loops, 1 switch, 1 try, 1 catch, 2 instanceof and 2 casts (to `Integer` and
  `Number`); the field `value`, 1 cast to `Object`; `plain`, nothing, though its string and comments
  hold an `if` and a cast.
- **Search and ask, by meaning:** mark a project as an `IndexedProject` and the `code-declarations`
  documents source (`sources.yml`) keeps each of its types, functions and methods as a document
  (`code://<project>!<path>#<kind>:<owner.name>`, tagged `code`, no entity pass). A document is named by
  what the declaration is and its text carries no line numbers, so each 15-minute run embeds only the
  declarations whose text changed: a new commit or code that moves re-embeds nothing else, a deleted
  or renamed declaration is pruned. `realm_sync_documents` runs it at once. `SearchCode` and `SearchAndCallers` find
  code by what it does; `Declarations` (or `Declaration`) reads the live rows by id. The Atlas
  and Explorer apps' **Ask** finds the code by name, live (`MatchDeclarations`: the question's words against every declaration's
  name, so it answers before anything is embedded), and by meaning (`SearchCode`), merged by declaration; reads the best with
  `Declarations`; then `AnswerFromCode` hands the model their code, callers and callees, numbered, and the answer explains how the code
  works, citing each one. `IndexState` says how much of a project is indexed. Every citation is a declaration: click it to focus it in
  the Atlas (`AskContext`: its code, callers and callees) or on the Explorer's map. These views read only the declarations a
  question reaches (the files the found ones are in, the code that mentions their names, the declarations their code names), so a
  10,000-declaration project is never read whole to answer one question; asking a new project records it and starts the code index.
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
