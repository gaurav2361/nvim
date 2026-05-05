; extends

; apply sql syntax highlighting string literal argument of sqlx::query()
(macro_invocation                             ; match a macro invocation
  macro: (scoped_identifier                   ; the macro has to be identified with a scoped identifer, of the form module::identifier
    path: (identifier) @_macro_path           ; label the macro's module name / path node for later reference
    name: (identifier) @_macro_name)          ; label the macro's identifier node for later reference
  (token_tree                                 ; the macro should have a token tree argument, because it's a macro
    .                                         ; the dot operator anchors to the first sibling, which targets the first macro argument
    [                                         ; match a case where the token tree's first child is either a string or a raw string literal
    (string_literal
      ((string_content) @injection.content))  ; in either case declare the content (the part inside the quotes) is the injection content
    (raw_string_literal
      ((string_content) @injection.content))
    ])
  (#eq? @_macro_path "sqlx")                   ; match only if the macro's module name is "sqlx"
  (#match? @_macro_name "query(_as|_scalar|)") ; match only if the identifier is one of sqlx's query macro names
  (#set! injection.language "sql")            ; set the injection language to "sql"
  (#set! injection.priority 110))             ; give the injection a high priority to win against other injections
