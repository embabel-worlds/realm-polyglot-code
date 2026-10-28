; Java constructs a method's complexity is counted in, one capture each. Read by the `javaConstructs`
; producer (`emit: captures`): every row names the method it is in (`enclosingId`), so a count per
; method is a GROUP BY. Comments are their own nodes, so commented-out code never counts.
; Keep this file ASCII: tree-sitter loses the end of a query with any other character in it.

; The methods and constructors themselves, for their length.
[(method_declaration) (constructor_declaration) (compact_constructor_declaration)] @method

; Branches: an `else if` is an if of its own.
(if_statement) @if
(switch_expression) @switch
(ternary_expression) @ternary

; Loops.
[(for_statement) (enhanced_for_statement) (while_statement) (do_statement)] @loop

; Exception handling.
[(try_statement) (try_with_resources_statement)] @try
(catch_clause) @catch

; Type tests and casts: `@cast.type` is the type cast to, as written (`List<String>`).
(instanceof_expression) @instanceof
(cast_expression type: (_) @cast.type) @cast
