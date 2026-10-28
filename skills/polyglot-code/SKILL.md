---
name: polyglot-code
description: Answer questions about a codebase in any of fourteen languages — what it is written in, its HTTP endpoints, where a name is defined, who calls it, what it imports, what its frontend and backend share — by querying the polyglot-code realm's views and labels.
---

# Reading a codebase in any language

Pin the project by its key and use the views first; they already span every language.

| Question | View |
|---|---|
| What is this written in? | `ProjectLanguages(project)` |
| What endpoints does it serve (or call)? | `Routes(project)` |
| Where is X defined? | `WhereDefined(project, name)` |
| Who calls X? | `WhoCalls(project, name)` |
| What do the backend and frontend share? | `SharedNames(project)` |
| What does it depend on, really? | `ExternalDependencies(project)` |
| How well documented is it? | `DocCoverage(project)` |
| Where is the complexity? | `LargestFunctions(project)` |
| Who uses type X? | `WhoUses(project, name)` |
| What does this repository look like? | `PartDependencies(project)` |
| Which parts depend on each other? | `MutualDependencies(project)` |
| What does the most code lean on? | `Hotspots(project)` |
| What might be unused? | `UnusedTypes(project)` |
| What would changing X touch? | `Impact(project, name)` |

For "what would you fix first?", ask `Hotspots`, `MutualDependencies` and `UnusedTypes`, rank what
they find, and cite every claim with its file and line. Call the unused types candidates to check,
never dead code.

A key is `https://github.com/owner/repo` (optionally `@tag`, `@branch` or `@commit`) or a folder in
the owner's workspace (`shop`).

## Writing your own query

Name a parent to read every language, a child to read one:

```cypher
MATCH (p:CodeProject {key: $project})-[:DECLARES]->(d:SourceDeclaration)   // every language
MATCH (p:CodeProject {key: $project})-[:DECLARES]->(d:GoDeclaration)       // Go alone
```

Relationships from `CodeProject`: `HAS_SOURCE` (Source), `DECLARES` (SourceDeclaration),
`IMPORTS` (SourceImport), `CALLS` (CallSite), `REFERENCES` (SourceReference: a type name a file
uses), `DECLARES_TYPE` (JavaCodeType). Install realm-code-model with this realm: it declares those
parents.

## Being honest about calls and uses

Outside Java a call, and every type use, is matched by NAME: `resolution: 'name'`. Two types with one
name share their uses; `Hotspots` says so with `sameName`, and `WhereDefined` shows how many declare
a name. "`OrderService.save` calls something
named `get` on `this.http`" is true; "it calls `HttpClient.get`" is a guess. Say which. Java's
members are resolved by binary name through the file's imports; its call graph is in the Java realms.

## Routes

`Routes` matches route styles held as reference data (`RouteStyle`): an annotation pattern
(`@getmapping`, `[httpget`, `#[get(`, `.get(` on a Python decorator) or a router call (`router.get`,
`router.GET`, `Route::get`, Django's `url`/`path`). A route a framework declares some other way is
missing until a style is added — say so rather than concluding the endpoint does not exist.
`role: prefix` rows are the paths a class's routes sit under; join them by file when composing a
full path.
