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

A key is `https://github.com/owner/repo` (optionally `@tag`, `@branch` or `@commit`) or a folder in
the owner's workspace (`shop`).

## Writing your own query

Name a parent to read every language, a child to read one:

```cypher
MATCH (p:CodeProject {key: $project})-[:DECLARES]->(d:SourceDeclaration)   // every language
MATCH (p:CodeProject {key: $project})-[:DECLARES]->(d:GoDeclaration)       // Go alone
```

Relationships from `CodeProject`: `HAS_SOURCE` (Source), `DECLARES` (SourceDeclaration),
`IMPORTS` (SourceImport), `CALLS` (CallSite), `DECLARES_TYPE` (JavaCodeType).

## Being honest about calls

Outside Java a call is matched by NAME: `resolution: 'name'`. "`OrderService.save` calls something
named `get` on `this.http`" is true; "it calls `HttpClient.get`" is a guess. Say which. Java's
members are resolved by binary name through the file's imports; its call graph is in the Java realms.

## Routes

`Routes` matches route styles held as reference data (`RouteStyle`): an annotation pattern
(`@getmapping`, `[httpget`, `#[get(`, `.get(` on a Python decorator) or a router call (`router.get`,
`router.GET`, `Route::get`, Django's `url`/`path`). A route a framework declares some other way is
missing until a style is added — say so rather than concluding the endpoint does not exist.
`role: prefix` rows are the paths a class's routes sit under; join them by file when composing a
full path.
