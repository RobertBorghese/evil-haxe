<p align="center">
	<a href="https://haxe.org/" title="haxe.org"><img src="extra/images/Readme.png" /></a>
</p>

<p align="center">
	<a href="https://gitter.im/HaxeFoundation/haxe?utm_source=badge&amp;utm_medium=badge&amp;utm_campaign=pr-badge"><img src="https://badges.gitter.im/Join%20Chat.svg" alt="Gitter"></a>
	<a href="https://discord.com/channels/162395145352904705/1129740232502292490"><img src="https://img.shields.io/discord/162395145352904705.svg?logo=discord" alt="Discord"></a>
</p>

#

Evil Haxe is a modified version of the [Haxe](https://github.com/HaxeFoundation/haxe) compiler that allows users to use and write parser mods written entirely in Haxe.

This is achieved by exposing the token stream used internally by the Haxe compiler to the Haxe macro runtime. A "mod" is defined in Haxe by providing callback functions to pre-defined hooks added to the parser.

To help you get started, this project provides some built-in mods as examples. You can check the list of them [here](#built-in-mods), and you can view their source code [here](std/evil/mods)! Also check out this minimal example below:

#### Mod.hx
```haxe
import evil.macro.TokenStream;

// This is called using the new compiler argument:
// --conspire Mod.init()
function init() {
    Evil.addParserMod("loop_mod", {
        onExpr: function(stream: TokenStream): Null<haxe.macro.Expr> {
            return switch(stream.peek().token) {
                case Const(CIdent("loop")): {
                    stream.consume();
                    final expr = stream.nextExpr();
                    macro while(true) $expr;
                }
                case _: {
                    null;
                }
            }
        }
    });
}
```
#### Main.hx
```haxe
// Let the Haxe compiler know this module wants to use Evil Haxe mods.
// We specify to only use the "loop_mod".
#evil(loop_mod)

package;

function main() {
    // New "loop" feature created by "loop_mod".
    var i = 1;
    loop {
        i *= 2;
        if(i > 20) {
            break;
        }
    }
    trace(i);
}
```

&nbsp;
&nbsp;
&nbsp;

# About

The old version of Evil Haxe was an [opinionated edit of the Haxe compiler](https://github.com/SumRndmDde/evil-haxe) I made about a year ago. It's a superset of Haxe that is created to add as many modern and cool features the language can possibly contain without completely breaking compatibility with vanilla Haxe. It was summoned from an alternative universe using a demonic ritual, and it continues to eat away at my soul from the darkest depths of our world.

Long story short, version 1.0 was just a collection of Haxe mods I made for fun. However with version 2.0, I want to try and make the project more accessible to others. To do this, I will:
* Keep all changes modular and allow features to be enabled/disabled like Babel/TypeScript.
* Create a compile-time Haxe API for making parser mods and use it to implement the majority of the mods.
* Enforce a header syntax to enable Evil Haxe in Haxe source files. This'll help mark code intended to be used with Evil Haxe vs normal Haxe to avoid confusion when reading source code.
* Branch from the latest stable release (post v5.0 release). This should prevent annoying maintenence to keep things compatible with the development branch.

Anyway, just setting this repo up to work on whenever I'm bored. Feel free to make requests in the Issues.

&nbsp;
&nbsp;
&nbsp;

# Installation
Please visit [BUILDING](https://github.com/HaxeFoundation/haxe/blob/development/extra/BUILDING.md) to learn how to compile the Haxe compiler. The process is identical for Evil Haxe.

The main branch is an edit of Haxe's development branch, but if you wish to use Evil Haxe for Haxe 4.3, build using the [evil-4.3 branch](https://github.com/RobertBorghese/evil-haxe/tree/evil-4.3).

If building Haxe is too high above your skill level, I'm also committing the Windows 64-bit builds I'm testing into the repo. To install:
1) Download the [latest nightly of Haxe](https://build.haxe.org/builds/haxe/windows64/haxe_latest.zip) OR the [latest version of 4.3](https://haxe.org/download/version/4.3.1/) and install (or use an existing installation).
2) Download the `evil_haxe.zip` from the [main branch (nightly)](evil_haxe.zip) or the [4.3 branch](blob/evil-4.3/evil_haxe.zip).
3) Extract the contents of evil_haxe.zip and paste into the Haxe installation folder (`std/` folder should be merged).
4) Run the `evil_haxe` executable like you would with the Haxe compiler normally.

&nbsp;
&nbsp;
&nbsp;

# Evil Haxe Rules
Every Haxe module that wants to use Evil Haxe mods must use `#evil` at the top of the file. This should be placed above everything, including `package`.

If not provided any arguments, the default mods will be enabled. To configure which mods are the default mods, the new `--default-mods` compiler argument can be used:
```
--default-mods loop,pipe,pow
```
Otherwise, the mods used by the Haxe file can be specified by the `#evil` statement:
```
#evil(loop, pipe)
```

&nbsp;
&nbsp;
&nbsp;

# Creating Mods
To create a parser mod, make a new Haxe module with a static function. Call this function using the new `--conspire` argument in the Evil Haxe compiler. This will run the function at an extremely early point in compilation, before initialization macros are even run!

Within this function, mods can be registered using `Evil.addParserMod`. The first argument is the name. This should be a unique identifier and is used to enable the mod with the `#evil` attribute.
```haxe
// This mod would be enabled with: #evil(my_mod)
function init() {
    var options = { ... };
    Evil.addParserMod("my_mod", options);
}
```
The `options` object should be a structure matching the `evil.macro.Mod` typedef. All of its fields are optional callbacks that will execute at certain points of source code parsing.

For example, `onExpr` will execute whenever the compiler wants to parse an expression. It will first run all the `onExpr` functions provided by the enabled mods. The first to return a non-null `Expr` will have its return used instead of whatever would've been parsed normally. If all the mod functions return `null`, the compiler continues to parse the expression like normal.
```haxe
typedef Mod = {
    ?onExpr: (TokenStream, Bool) -> Null<Expr>,
	?onAfterExpr: (TokenStream, Expr) -> Null<Expr>,
	?onBlockExpr: (TokenStream) -> Void,
	?onAfterBlockExpr: (TokenStream, Expr) -> Null<Expr>,
	?onTypeDeclaration: (TokenStream, evil.macro.TypeDeclCompletionMode) -> Null<TypeDefinition>,
	?onClassField: (TokenStream, Bool) -> Null<Field>,
	?tokenTransmuter: (TokenType) -> Null<TokenType>
}
```

&nbsp;
&nbsp;
&nbsp;

# Built-in Mods
Evil Haxe also contains pre-existing mods. These can be found in the standard library at `std/evil/mods`.

## Pow
This mod adds the `**` (exponentiation) operator from JavaScript/Python. For example, with `A ** B` it returns the value of `A` to the power of `B`. Internally, it converts the expression into `Math.pow(A, B)`.
```haxe
trace(2 ** 3); // 8
```

## Pipe
This mod enables the pipe operator similar to what's seen in many functional languages:
```haxe
2 |> Math.pow(5) |> trace; // 25
```

## Return Assign
This mod adds a shorthand for writing function bodies based on Kotlin. A function declaration can be "assigned" its return expression.
```haxe
function half(num: Float) = num / 2.0;
half(12); // returns 6
```

## Defer
This mod enables the `defer` keyword [based on Go](https://go.dev/tour/flowcontrol/12).
Deferred expressions are moved to the end of their block scope.
```haxe
// Hello world
defer trace("world");
trace("Hello");
```

## Kotlin Keywords
This mod adds the `fun` keyword that acts as an alias for `function`, and it adds the `val` keyword as an alias for `final`. This mod demonstrates the `tokenTransmuter` property for mods.
```haxe
// Valid Haxe with this mod enabled.
fun main() {
    val a = 123;
    trace(a); // 123
}
```
