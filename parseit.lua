--[[
    (1)     	program 	  →   	stmt_list
    (2)     	stmt_list 	  →   	{ statement }
    (3)     	statement 	  →   	“cr”
    (4)     	  	|   	“print” ( STRLIT | expr )
    (5)     	  	|   	“input” lvalue
    (6)     	  	|   	“set” lvalue “:” expr
    (7)     	  	|   	“sub” SUBID stmt_list “end”
    (8)     	  	|   	“call” SUBID
    (9)     	  	|   	“if” expr stmt_list { “elseif” expr stmt_list } [ “else” stmt_list ] “end”
    (10)     	  	|   	“while” expr stmt_list “end”
    (11)     	expr 	  →   	comp_expr { ( “&&” | “||” ) comp_expr }
    (12)     	comp_expr 	  →   	“!” comp_expr
    (13)     	  	|   	arith_expr { ( “==” | “!=” | “<” | “<=” | “>” | “>=” ) arith_expr }
    (14)     	arith_expr 	  →   	term { ( “+” | “-” ) term }
    (15)     	term 	  →   	factor { ( “*” | “/” | “%” ) factor }
    (16)     	factor 	  →   	( “+” | “-” ) factor
    (17)     	  	|   	“(” expr “)”
    (18)     	  	|   	NUMLIT
    (19)     	  	|   	( “true” | “false” )
    (20)     	  	|   	lvalue
    (21)     	lvalue 	  →   	VARID [ “[” expr “]” ]

]]

parseit = {}
lexit = require "lexit"

local STMT_LIST   = 1
local CR_STMT     = 2
local PRINT_STMT  = 3
local INPUT_STMT  = 4
local SET_STMT    = 5
local SUB_STMT    = 6
local CALL_STMT   = 7
local IF_STMT     = 8
local WHILE_STMT  = 9
local BIN_OP      = 10
local UN_OP       = 11
local NUMLIT_VAL  = 12
local STRLIT_VAL  = 13
local BOOLLIT_VAL = 14
local VARID_VAL   = 15
local ARRAY_REF   = 16

local iter 
local state 
local retStr
local retCat

local str
local cat


local function advanceLexer()
	retStr, retCat = iter(state, retStr)

	if retStr ~= nil then
		str, cat = retStr, retCat
	else 
		str, cat = "", 0
	end
end	


local function initLexer(raw)
	iter, state, retStr = lexit.lex(raw)
	advanceLexer()
end



function parseit.parse(raw)

	initLexer(raw)

	local good, ast = parse_stmt_list()
	local done = (cat == 0)	--atend

	return good, done, ast

end

local function parse_stmt_list()
	
end



return parseit