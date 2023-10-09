package evil.mods;

#if (macro || display)

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import evil.macro.TokenStream;

/**
	Stores `modify` fields to be used to modify types
	using `@:build` macros later.
**/
var modifyFields: Map<String, Array<Field>> = [];

/**
	Initializes the Modify mod.
**/
function init() {
	Evil.addParserMod("modify", {
		onTypeDeclaration: onTypeDeclaration
	});
}

/**
	Called at the "type definition" hook when parsing.

	Parses the top-level `modify` statement.
**/
function onTypeDeclaration(stream: TokenStream, mode: evil.macro.TypeDeclCompletionMode): Null<TypeDefinition> {
	final tokenData = stream.peek();

	switch(tokenData.token) {
		case Const(CIdent("modify")): {}
		case _: return null;
	}

	stream.consume();

	final path = [];

	while(true) {
		switch(stream.peek().token) {
			case Const(CIdent(name)): {
				path.push(name);
			}
			case _: throw "Expected identifier";
		}

		stream.consume();

		switch(stream.peek().token) {
			case Dot: {
				stream.consume();
			}
			case BrOpen: {
				stream.consume();
				break;
			}
			case _: {
				throw "Expected . or {";
			}
		}
	}

	final fieldData = stream.parseClassFields(tokenData.pos);
	final pathString = path.join(".");

	if(!modifyFields.exists(pathString)) {
		modifyFields.set(pathString, fieldData.fields);
		Compiler.addGlobalMetadata(pathString, '@:build(evil.mods.Modify.applyMods("$pathString"))');
	} else {
		final existingFields = modifyFields.get(pathString);
		for(f in fieldData.fields) {
			existingFields.push(f);
		}
	}

	return null;
}

/**
	Passed to `@:build` macros for modified types.
	Simply adds the parsed fields to the existing fields for the type.
**/
function applyMods(id: String) {
	final existingFields = Context.getBuildFields();
	final fields = modifyFields.get(id);
	return existingFields.concat(fields);
}

#end
