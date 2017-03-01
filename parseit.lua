--[[

parse grammar

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

lex categories

    lexit.KEY = 1
    lexit.VARID = 2
    lexit.SUBID = 3
    lexit.NUMLIT = 4
    lexit.STRLIT = 5
    lexit.OP = 6
    lexit.PUNCT = 7
    lexit.MAL = 8

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

local function isCompareOp(op)

    local match = false
    local comps = {"==","!=","<=","<",">=",">"}

    for i = 1, #comps do
        if op == comps[i] then
            match = true
        end
    end

    return match

end


function parseit.parse(raw)

    --parse functions - can't be local if below - figure out later



    local function parse_lvalue()
        local good, ast, newast, save
        good = true
         ast = {VARID_VAL, str}
            advanceLexer()

            if str == "[" then
                advanceLexer()
                good, newast = parse_expr()
                if str ~= "]" then
                    return false, nil
                end
                advanceLexer()
                ast[1] = ast
                ast[2] = {ARRAY_REF, newast}
            end

            return good, ast
        
    end

    local function parse_factor()
        
        local good, ast, newast

        if str == "+" or str == "-" then
            ast = {{UN_OP, str}}
            advanceLexer()

            good, newast = parse_factor()
            ast[2]=newast
            return good, ast
        end

        if str == "(" then
            good, ast = parse_expr()
            if str == ")" then
                return good, ast
            else
                return false, nil
            end
        end

        if str == "true" or str == "false" then
            ast = {BOOLLIT_VAL, str}
            advanceLexer()
            return true, ast
        end

        if cat == lexit.NUMLIT then
            ast = {NUMLIT_VAL, str}
            advanceLexer()
            return true, ast
        end

        if cat == lexit.VARID then  --should make an parse_lvalue but this works for now
            good, ast = parse_lvalue()
           
            return good, ast
        end

        return false, nil --until i write code

    end

    local function parse_term()

        local good, ast, newast, save

        good, ast = parse_factor()
        if not good then 
            return false, nil
        end

         while str == "*" or str == "/" or str == "%" do
            
                save = str
                advanceLexer()

                good, newast = parse_factor()
                if not good then 
                    return false, nil
                end

                newast[2] = save
                newast[1], newast[2] = newast[2], newast[1]

            ast[#ast+1] = newast
        end 

        return good, ast

    end

    local function parse_arith_expr()

        local good, ast, newast, save

        good, ast = parse_term()
        if not good then 
            return false, nil
        end

         while str == "+" or str == "-" do
            
                save = str
                advanceLexer()

                good, newast = parse_term()
                if not good then 
                    return false, nil
                end

                newast[2] = save
                newast[1], newast[2] = newast[2], newast[1]

            ast[#ast+1] = newast
        end 

        return good, ast

    end




    local function parse_comp_expr()

        local good, ast, newast --i swapped name halfway through...I need to normalize

        if str == "!" then
            ast = {str}
            advanceLexer()

            good, newast = parse_comp_expr()
            if not good then
                return false, nil
            end

            ast[#ast+1] = newast
            return good, ast

        end

        good, ast = parse_arith_expr()
        if not good then 
            return false, nil
        end

         while isCompareOp(str) do
            
                save = str
                advanceLexer()

                good, newast = parse_arith_expr()
                if not good then 
                    return false, nil
                end

                --the "&&" | "||" needs to go first, maybe make pushfront func to make the swap more clear
                newast[2] = save
                newast[1], newast[2] = newast[2], newast[1]

            ast[#ast+1] = newast
        end 

            return good, ast
    end


    function parse_expr()
        local good, ast, newast, save

        good, ast = parse_comp_expr()
        if not good then
            return false, nil
        end

        while str == "&&" or str == "||" do

                save = str
                advanceLexer()

                good, newast = parse_comp_expr()
                if not good then 
                    return false, nil
                end

                --the "&&" | "||" needs to go first, maybe make pushfront func to make the swap more clear
                newast[2] = save
                newast[1], newast[2] = newast[2], newast[1]

            ast[#ast+1] = newast
        end 


        return good, ast
    end


    local function parse_statement()
        
        local good, ast, save

        if cat == lexit.KEY then

            if str == "cr" then

                advanceLexer()
                return true, {CR_STMT}
            elseif str == "print" then

                advanceLexer()

                if cat == lexit.STRLIT then
                    save = str
                    advanceLexer()
                    return true, {PRINT_STMT, {STRLIT_VAL, save}}
                end

                good, ast = parse_expr()
                return good, {PRINT_STMT, ast}
            end

            --until further develop
          --  advanceLexer()
            return true, nil

        else
            return true, nil
        end
    end

    local function parse_stmt_list()
        
        local good, ast, nextast

        good = true
        ast = {STMT_LIST}
        
        while cat ~= 0 do

            good, nextast = parse_statement()
            
            if not good then
                return false, nil 
            elseif nextast == nil then  --good syntax but bad program?
                return true, nil        --idk needed to get past first tests like input "end"
            end

            --appends new element onto ast table (array)
            ast[#ast+1] = nextast

        end
        

        return good, ast

    end

    


	initLexer(raw)

	local good, ast = parse_stmt_list()
	local done = (cat == 0)	--atend

	return good, done, ast

   

end





return parseit