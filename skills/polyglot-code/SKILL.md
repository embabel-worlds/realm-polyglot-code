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
| Who calls or reads X (a method, or a property, field or attribute)? | `WhoCalls(project, name)`; `access` says which |
| Will pushing this file be refused (literals joined with +, an inline qualified name, a direct file write, a bean or listener to list)? | `PushChecks(project, path)` |
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
uses). Every language is read the same way, Java included. Install realm-code-model with this
realm: it declares those parents.

Java is also said a second time with its names resolved, outside those parents so nothing is
counted twice: `DECLARES_TYPE` (JavaCodeType: a type by binary name, with what it extends and
implements) and `DECLARES_MEMBER` (JavaCodeMember: parameter and return types in full). Use them
only when a question needs a resolved name.

## Being honest about calls and uses

A call, and every type use, is matched by NAME: `resolution: 'name'`. Two types with one
name share their uses; `Hotspots` says so with `sameName`, and `WhereDefined` shows how many declare
a name. "`OrderService.save` calls something
named `get` on `this.http`" is true; "it calls `HttpClient.get`" is a guess. Say which. For a
Java call resolved exactly, use the Java realms.

## Routes

`Routes` matches route styles held as reference data (`RouteStyle`): an annotation pattern
(`@getmapping`, `[httpget`, `#[get(`, `.get(` on a Python decorator) or a router call (`router.get`,
`router.GET`, `Route::get`, Django's `url`/`path`). A route a framework declares some other way is
missing until a style is added — say so rather than concluding the endpoint does not exist.
`role: prefix` rows are the paths a class's routes sit under; join them by file when composing a
full path.

## Before and after an edit

Two views for a coding agent, in any language. Each replaces something otherwise learnt from a
refused push or a wasted build.

| When | Ask | What comes back |
|---|---|---|
| About to add a type, a method or many lines to a file | `RulesHeadroom(project, path)` | Types in the file's package against the cap, the file's length, each method near the limit; `headroom` and `verdict` (ok, near, over) |
| After changing a type | `TestsFor(project, type)` | The test files that import it or are named for it, why each was chosen and, for a Maven layout, the tags it runs under and the `command` that runs it |

- `RulesHeadroom`: pass the project's own caps (`typeCap`, `fileCap`, `methodCap`; defaults 50, 600,
  60). Lengths are source lines from first to last, comments and blank lines included, so a linter
  that counts statements or lines of code reads lower. `near` or `over` on the package means the new
  type belongs elsewhere or nested.
- `TestsFor`: run `command` as given. Pass `tagIsProfile: true` for a build that runs tagged tests
  only under a profile named for the tag; such a test run without it runs nothing and says nothing.
  `command` is empty where the build is not Maven: the file is still the right one to run.
- Neither finds a test that reaches a type only through another type, and neither knows a rule
  other than size.

