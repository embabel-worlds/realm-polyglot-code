; What a Kotlin push is refused for that no size rule says, one capture each. Read by the
; `kotlinPushChecks` producer (`emit: captures`); views/agent.yml PushChecks reads the rows.
; Keep this file ASCII: tree-sitter loses the end of a query with any other character in it.

; String literals joined with +. Each literal operand of a +, with the + it is in. A chain of +
; nests to the left, so every link of one chain starts where the chain does: the view counts the
; literals per chain start, and two or more is a paragraph built by hand.
(additive_expression (string_literal) @concat.literal) @concat

; A fully qualified name written inline: a dotted path of lowercase segments ending in a capitalised
; name, under a prefix a project imports instead (here com.embabel., java. and kotlin.). Imports and
; the package line are other nodes, so they are never captured.
((navigation_expression) @qualified (#match? @qualified "^(com[.]embabel|java|kotlin)([.][a-z][A-Za-z0-9_]*)+[.][A-Z]"))
((user_type) @qualified (#match? @qualified "^(com[.]embabel|java|kotlin)([.][a-z][A-Za-z0-9_]*)+[.][A-Z]"))
