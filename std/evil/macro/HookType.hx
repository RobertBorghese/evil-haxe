package evil.macro;

/**
	The types of parser hooks.
**/
enum HookType {
	OnExpr;
	OnAfterExpr;
	OnBlockExpr;
	OnAfterBlockExpr;
	OnTypeDeclaration;
	OnClassField;
	TokenTransmuter;
}
