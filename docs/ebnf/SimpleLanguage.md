# EBNF grammar for SimpleLanguage

The following diagrams have been generated from file [**`SimpleLanguage.ebnf`**](SimpleLanguage.ebnf) using [Railroad Diagram Generator](https://www.bottlecaps.de/rr/ui).

| *Rule* | *Diagram* |
| :----- | :-------- |
| **simplelanguage** | <img src="diagram/simplelanguage.png" /> |
| <br/>**function** | <img src="diagram/function.png" /> |
| **block** | <img src="diagram/block.png" /> |
| **statement** | <img src="diagram/statement.png" /> |
| **while_statment** | <img src="diagram/while_statement.png" /> |
| **if_statement** | <img src="diagram/if_statement.png" /> |
| **condition** | <img src="diagram/condition.png" /> |
| **return_statement** | <img src="diagram/return_statement.png" /> |
| <br/>**expression** |  <img src="diagram/expression.png" /> |
| <br/>**logic_term** |  <img src="diagram/logic_term.png" /> |
| **logic_factor**<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/> | <img src="diagram/logic_factor.png" /> |
| <br/><br/><br/>**arithmetic** | <img src="diagram/arithmetic.png" /> |
| <br/><br/><br/>**term** | <img src="diagram/term.png" /> |
| **factor**<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/> | <img src="diagram/factor.png" /> |
| **LETTER** | <img src="diagram/LETTER.png" /> |
| **DIGIT** |  <img src="diagram/DIGIT.png" /> |
| <br/><br/><br/>**IDENTIFIER** | <img src="diagram/IDENTIFIER.png" /> |
| **STRING_LITERAL** | <img src="diagram/STRING_LITERAL.png" /> |
| **NUMERIC_LITERAL** | <img src="diagram/NUMERIC_LITERAL.png" /><span style="font-size:80%;">generated by <a name="Railroad-Diagram-Generator" title="https://www.bottlecaps.de/rr/ui" href="https://www.bottlecaps.de/rr/ui" target="_blank">Railroad Diagram Generator <img border="0" src="diagram/rr-1.59.1797.png" height="16" width="16"></a></span> |

<p>&nbsp;</p>

<p>
SL built-in functions are:
</p>

| *Signature* | *Example* |
| :---------- | :-------- |
| <a href="../../language/src/main/java/com/oracle/truffle/sl/builtins/SLDefineFunctionBuiltin.java" title="SLDefineFunctionBuiltin.java"><code>defineFunction(String code)</code></a> | <a href="../../language/tests/DefineFunction.sl" title="DefineFunction.sl"><code>defineFunction("function f(a, b) { return a + b; }");</code></a>
| <a href="../../language/src/main/java/com/oracle/truffle/sl/builtins/SLEvalBuiltin.java" title="SLEvalBuiltin.java"><code>eval(String id, String code): Object</code></a> | <a href="../../language/tests/Eval.sl" title="Eval.sl"><code>eval("sl", "function foo() { return 14 + 2; }");</code></a> |
| <a href="../../language/src/main/java/com/oracle/truffle/sl/builtins/SLGetSizeBuiltin.java" title="SLGetSizeBuiltin.java"><code>getSize(Object o): long</code></a> | &nbsp; |
| <a href="../../language/src/main/java/com/oracle/truffle/sl/builtins/SLHasSizeBuiltin.java" title="SLHasSizeBuiltin.java"><code>hasSize(Object o): boolean</code></a> | &nbsp; |
| <a href="../../language/src/main/java/com/oracle/truffle/sl/builtins/SLImportBuiltin.java" title="SLImportBuiltin.java"><code>import</code></a> | <a href="../../language/src/test/java/com/oracle/truffle/sl/test/PassItselfBackViaContextTest.java#L94"><i>(see example in PassItselfBackViaContextText)</i></a> |
| <a href="../../language/src/main/java/com/oracle/truffle/sl/builtins/SLIsExecutableBuiltin.java" title="SLIsExecutableBuiltin.java"><code>isExecutable(Object o): boolean</code></a> | &nbsp; |
| <a href="../../language/src/main/java/com/oracle/truffle/sl/builtins/SLIsNullBuiltin.java" title="SLIsNullBuiltin.java"><code>isNull(Object o): boolean</code></a> | &nbsp; |
| <a href="../../language/src/main/java/com/oracle/truffle/sl/builtins/SLNanoTimeBuiltin.java"><code>nanoTime(): long</code></a> | <a href="../../language/tests/Builtins.sl" title="Builtins.sl"><code>nanoTime()</code></a> |
| <a href="../../language/src/main/java/com/oracle/truffle/sl/builtins/SLNewObjectBuiltin.java" title="SLNewObjectBuiltin.java"><code>new(): Object</code></a> | <a href="../../language/tests/Object.sl" title="Object.sl"><code>obj1 = new();</code><br/><code>obj1.x = 42;</code><br/><code>println(obj1.x);</code></a> |
| <a href="../../language/src/main/java/com/oracle/truffle/sl/builtins/SLPrintlnBuiltin.java" title="SLPrintlnBuiltin.java"><code>println(long value)</code><br/><code>println(boolean value)</code><br/><code>println(String value)</code><br/><code>println(Object value)</code></a> | <a href="../../language/tests/Builtins.sl" title="Builtins.sl"><code>println("Hello World!")</code></a> |
| <a href="../../language/src/main/java/com/oracle/truffle/sl/builtins/SLReadlnBuiltin.java" title="SLReadlnBuiltin.java"><code>readln(): String</code></a> | &nbsp; |
| <a href="../../language/src/main/java/com/oracle/truffle/sl/builtins/SLStackTraceBuiltin.java" title="SLStackTraceBuiltin.java"><code>stacktrace(): String</code></a> | &nbsp; |
| <a href="../../language/src/main/java/com/oracle/truffle/sl/builtins/SLWrapPrimitiveBuiltin.java" title="SLWrapPrimitiveBuiltin.java"><code>wrapPrimitive</code></a> | &nbsp; |

***

