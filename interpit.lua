-- interpit.lua  INCOMPLETE
-- VERSION 2
-- Glenn G. Chappell
-- 27 Mar 2017
-- Modified in class 27 Mar 2017
--
-- For CS F331 / CSCE A331 Spring 2017
-- Interpret AST from parseit.parse
-- For Assignment 6, Exercise B


-- *********************************************************************
-- * To run a Kanchil program, use kanchil.lua (which uses this file). *
-- *********************************************************************


local interpit = {}  -- Our module


-- ***** Variables *****


-- Symbolic Constants for AST

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


-- ***** Utility Functions *****


-- numToInt
-- Given a number, return the number rounded toward zero.
local function numToInt(n)
    if n >= 0 then
        return math.floor(n)
    else
        return math.ceil(n)
    end
end


-- strToNum
-- Given a string, attempt to interpret it as an integer. If this
-- succeeds, return the integer. Otherwise, return 0.
local function strToNum(s)
    -- Try to do string -> number conversion; make protected call
    -- (pcall), so we can handle errors.
    local success, value = pcall(function() return 0+s end)

    -- Return integer value, or 0 on error.
    if success then
        return numToInt(value)
    else
        return 0
    end
end


-- numToStr
-- Given a number, return its string form.
local function numToStr(n)
    return ""..n
end


-- boolToInt
-- Given a boolean, return 1 if it is true, 0 if it is false.
local function boolToInt(b)
    if b then
        return 1
    else
        return 0
    end
end

-- ***** Primary Function for Client Code *****


-- interp
-- Interpreter, given AST returned by parseit.parse.
-- Parameters:
--   ast     - AST constructed by parseit.parse
--   state   - Table holding values of Zebu integer variables
--             Value of simple variable xyz is in state.s["xyz"]
--             Value of array item xyz[42] is in state.a["xyz"][42]
--   incall  - Function to call for line input
--             incall() inputs line, returns string with no newline
--   outcall - Function to call for string output
--             outcall(str) outputs str with no added newline
--             To print a newline, do outcall("\n")
-- Return Value:
--   state updated with changed variable values
function interpit.interp(ast, state, incall, outcall)
    -- Each local interpretation function is given the AST for the
    -- portion of the code it is interpreting. The function-wide
    -- versions of state, incall, and outcall may be used. The
    -- function-wide version of state may be modified as appropriate.

    local interp_stmt_list
    local interp_stmt
    local evalIntExpr
    local evalBoolExpr
    local getLvalue

    function interp_stmt_list(ast)  -- Already declared local
        for i = 2, #ast do
            interp_stmt(ast[i])
        end
    end

    function getLvalue(ast)
        local value

        if ast[1] == NUMLIT_VAL then 
            value = strToNum(ast[2])
        elseif ast[1] == VARID_VAL then
            value = state.v[ast[2]]
        elseif ast[1] == ARRAY_REF then
            value = state.a[ast[2]][evalIntExpr(ast[3])]
        end

        return value
    end

    function evalIntExpr(ast)
     

        local value=nil

        local i = 1
        --count up through binary operators
        if #ast > 2 then    --needs to be at least 3 to have binary operation
            while ast[i][1] == BIN_OP do
             i=i+1
            end
        end

        i=i-1   --this is kind of confusing

        if ast[1]==NUMLIT_VAL or ast[1] == VARID_VAL or ast[1] == ARRAY_REF then --num_lit, var_val, or array_ref
            value = getLvalue(ast)
        else

            --j counts up lvalues as i counts down bin_ops
            for j = i+1, #ast do
               
                local tempValue
            
                if ast[j][1] == UN_OP then

                    local  sign = 1
                        
                    if ast[j][2] == "-" then
                        sign = sign*-1
                    end

                    j=j+1   --increment lvalue counter to get lvalue for un_op

                    tempValue = sign * getLvalue(ast[j])
                else 
                    tempValue = getLvalue(ast[j])
                end

                if value == nil then
                    value = tempValue
                elseif i > 0 then 
                    if ast[i][2] == '*' then
                        value = value * tempValue
                    elseif ast[i][2] == '/' then
                        value = value / tempValue
                    elseif ast[i][2] == '%' then
                        value = value % tempValue    
                    elseif ast[i][2] == '+' then 
                        value = value + tempValue  
                    elseif ast[i][2] == '-' then
                        value = value - tempValue    
                    end
                    i=i-1   --decrement bin_op counter
                end

            end
        end


        return value
    end

    function evalBoolExpr(ast)
        
    end

    function interp_stmt(ast)
        local name, body, str

        if ast[1] == CR_STMT then
            outcall("\n")
        elseif ast[1] == PRINT_STMT then
            if ast[2][1] == STRLIT_VAL then
                str = ast[2][2]
                outcall(str:sub(2,str:len()-1))
            else
                outcall(numToStr(evalIntExpr(ast[2])))
            end
        elseif ast[1] == INPUT_STMT then
            if ast[2][1] == VARID_VAL then
                name = ast[2][2]
                body = incall()
                state.v[name] = strToNum(body)  --variables must hold integer
            elseif ast[2][1] == ARRAY_REF then
                print("No support for arrays yet")
            else
                print("input into what?")
            end
        elseif ast[1] == SET_STMT then
            if ast[2][1] == VARID_VAL then
                name = ast[2][2]
                body = ast[3]
                state.v[name] = evalIntExpr(body)
            elseif ast[2][1] == ARRAY_REF then
                name = ast[2][2][2]
                body = ast[3]
                 print ( numToStr( evalIntExpr(ast[3])))
                 print ( numToStr( evalIntExpr(ast[2][3])))
                 print (ast[2][2][2])
                state.a[name][evalIntExpr(ast[2][3])] = evalIntExpr(body) --this doesn't work...need to add as key/value pair??
            end
        elseif ast[1] == SUB_STMT then
            name = ast[2]
            body = ast[3]
            state.s[name] = body
        elseif ast[1] == CALL_STMT then
            name = ast[2]
            body = state.s[name]
            if body == nil then
                body = { STMT_LIST }  -- Default AST
            end
            interp_stmt_list(body)
        elseif ast[1] == IF_STMT then
            print("If stmt; DUNNO WHAT TO DO!!!")
        elseif ast[1] == WHILE_STMT then
            print("While stmt; DUNNO WHAT TO DO!!!")
        else
        end
    end

    -- Body of function interp
    interp_stmt_list(ast)
    return state
end


-- ***** Module Export *****


return interpit

