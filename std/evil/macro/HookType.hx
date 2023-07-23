package evil.macro;

/**
	The types of parser hooks.
**/
enum HookType {
	OnExpr;
	OnAfterExpr;
	OnFunctionExpr;
	OnBlockExpr;
	OnAfterBlockExpr;
	OnType;
	OnAfterType;
	OnTypeDeclaration;
	OnClassField;
	TokenTransmuter;
}
