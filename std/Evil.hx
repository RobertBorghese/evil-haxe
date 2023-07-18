package;

#if macro

#if !evilhaxe
#error "Evil Haxe std is being used with normal Haxe."
#end

import evil.macro.*;
import haxe.macro.Expr;

/**
	The main singleton for working with Evil Haxe.
**/
class Evil {
	/**
		Called super early during the compilation process.
	**/
	public static function init() {
		evil.mods.Pipe.init(); // |> operator
		evil.mods.Defer.init(); // defer
	}

	/**
		This is implemented in OCaml.

		ALlows calling certain OCaml functions related to
		Evil Haxe from Haxe code.
	**/
	public static extern function nativeCall(name: String): Dynamic;

	/**
		Make an Evil Haxe parser mod available to be used.
	**/
	public static function addParserMod(name: String, mod: Mod) {
		nativeCall("add_parser_mod")(name, mod);
	}

	/**
		Add a quick parser mod callback for the `OnExpr` hook.
		Applied globally to all Evil Haxe modules.
	**/
	public static function onExpr(callback: (TokenStream, Bool) -> Expr) {
		nativeCall("setup_hook")(HookType.OnExpr, callback);
	}

	/**
		Add a quick parser mod callback for the `OnAfterExpr` hook.
		Applied globally to all Evil Haxe modules.
	**/
	public static function onAfterExpr(callback: (TokenStream, Expr) -> Expr) {
		nativeCall("setup_hook")(HookType.OnAfterExpr, callback);
	}

	/**
		Add a quick parser mod callback for the `OnTypeDeclaration` hook.
		Applied globally to all Evil Haxe modules.
	**/
	public static function onTypeDeclaration(callback: (TokenStream, TypeDeclCompletionMode) -> TypeDefinition) {
		nativeCall("setup_hook")(HookType.OnTypeDeclaration, callback);
	}

	/**
		Add a quick parser mod callback for the `OnClassField` hook.
		Applied globally to all Evil Haxe modules.
	**/
	public static function onClassField(callback: (TokenStream, Bool) -> Field) {
		nativeCall("setup_hook")(HookType.OnClassField, callback);
	}
}

#end
