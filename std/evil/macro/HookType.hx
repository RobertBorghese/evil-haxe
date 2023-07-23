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
	OnTypeDeclaration;
	OnClassField;
	TokenTransmuter;
}
