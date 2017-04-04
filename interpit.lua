-- interpit.lua  INCOMPLETE
-- VERSION 2
-- Glenn G. Chappell
-- 27 Mar 2017
-- Modified in class 27 Mar 2017
--
-- For CS F331 / CSCE A331 Spring 2017
-- Interpret AST from parseit.parse
-- For Assignment 6, Exercise B



--TODO--

--allow variables to hold bool values - wrong, all bools are 0 or 1
--needs more testing and some refactoring
--reread semantics because there's probably more
--looks like i did booleans wrong


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
    local isLvalue

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
            value = state.a[ast[2][2]][evalIntExpr(ast[3])]
        end

        return value
    end

    function isLvalue(ast)
        
        if ast[1] == NUMLIT_VAL or ast[1] == VARID_VAL
            or ast[1] == ARRAY_REF then
            return true
        end

        if type(ast[1])=="table" then
            if ast[1][1] == UN_OP then
                if ast[1][2] == "+" or
                    ast[1][2] == "-" then
                    return true
                end
            end

            if ast[1][1] == BIN_OP then
                if ast[1][2] == "+" or
                    ast[1][2] == "-" or
                    ast[1][2] == "*" or
                    ast[1][2] == "/" or
                    ast[1][2] == "%" then
                    return true
                end
            end
        end
        return false

    end

    function evalIntExpr(ast)
     

        local value=nil

        local i = 1

        if ast[1]==NUMLIT_VAL or ast[1] == VARID_VAL or ast[1] == ARRAY_REF then --num_lit, var_val, or array_ref
            value = getLvalue(ast)
        else --arithmetic expression
            --count up through binary operators
            while ast[i][1] == BIN_OP do
             i=i+1
            end
 
            i=i-1   --this is kind of confusing, puts i back to last bin_op

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

        local value=nil
        local boolValue = nil

        local i = 1

        if ast[1]==BOOLLIT_VAL then
            if ast[2] == "false" then
                boolValue = false
            else
                boolValue = true
            end
        elseif isLvalue(ast) then
            if evalIntExpr(ast) == 0 then
                return false
            else
                return true
            end
        else --conditional expression
            --count up through binary operators
            while ast[i][1] == BIN_OP do
             i=i+1
            end
 
            i=i-1   --this is kind of confusing, puts i back to last bin_op

            --j counts up conditional statements as i counts down bin_ops
            for j = i+1, #ast do
               
                local tempValue
            
                if ast[j][1] == UN_OP then

                    
                    if ast[j][2] == "!" then

                        j=j+1   --increment cond counter to get cond for un_op

                       boolValue = not evalBoolExpr(ast[j])
                    end

                end

                --this all needs cleaned up...
                if i > 0 then
                    if ast[j][1] == BOOLLIT_VAL then
                        if boolValue == nil then
                            boolValue = evalBoolExpr(ast[j])
                        elseif ast[i][2] == "&&" then
                            i=i-1
                            boolValue = boolValue and evalBoolExpr(ast[j])
                        elseif ast[i][2] == "||" then
                            i=i-1
                            boolValue = boolValue or evalBoolExpr(ast[j])
                        end
                    elseif isLvalue(ast[j]) then
                        if value == nil then
                            value = evalIntExpr(ast[j])
                        else
                            tempValue = evalIntExpr(ast[j])
                            if ast[i][2] == "==" then
                                boolValue = value == tempValue                    
                            elseif ast[i][2] == ">=" then
                                boolValue = value >= tempValue
                            elseif ast[i][2] == "<=" then
                                boolValue = value <= tempValue
                            elseif ast[i][2] == ">" then
                                boolValue = value > tempValue
                            elseif ast[i][2] == "<" then
                                boolValue = value < tempValue
                            elseif ast[i][2] == "!=" then
                                boolValue = value ~= tempValue
                            end
                            value = tempValue
                            i=i-1   --decrement bin_op counter
                        end
                    end
                end
            end
        end


        return boolValue
    end

    function interp_stmt(ast)
        local name, body, str

        if ast[1] == CR_STMT then
            outcall("\n")
        elseif ast[1] == PRINT_STMT then
            if ast[2][1] == STRLIT_VAL then
                str = ast[2][2]
                outcall(str:sub(2,str:len()-1))
            elseif isLvalue(ast[2]) then 
                outcall(numToStr(evalIntExpr(ast[2])))
            elseif evalBoolExpr(ast[2]) then
                outcall("true")
            else
                outcall("false")
            end
        elseif ast[1] == INPUT_STMT then
            if ast[2][1] == VARID_VAL then
                name = ast[2][2]
                body = incall()
                state.v[name] = strToNum(body)  --variables must hold integer
            elseif ast[2][1] == ARRAY_REF then
                name = ast[2][2][2]
                body = incall()
                 --add new table for array
                if(state.a[name] == nil) then
                    state.a[name]={}
                end
                state.a[name][evalIntExpr(ast[2][3])] = strToNum(body)
            else
                print("Input Statement Error: input into what?")
            end
        elseif ast[1] == SET_STMT then
            if ast[2][1] == VARID_VAL then
                name = ast[2][2]
                if isLvalue(ast[3]) then
                    body = evalIntExpr(ast[3])
                else
                    body = boolToInt( evalBoolExpr(ast[3]))
                end
                
                state.v[name] = body
            elseif ast[2][1] == ARRAY_REF then
                name = ast[2][2][2]
                body = ast[3]
                --add new table for array
                if(state.a[name] == nil) then
                    state.a[name]={}
                end

                if isLvalue(ast[3]) then
                    body = evalIntExpr(ast[3])
                else
                    body = boolToInt( evalBoolExpr(ast[3]))
                end
                state.a[name][evalIntExpr(ast[2][3])] = body 
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

            local passed = false
            local counter = 2

            --if and elseif
            for i=2, #ast-1, 2 do
                if evalBoolExpr(ast[i]) then
                    interp_stmt_list(ast[i+1])
                    passed = true
                end
                counter = i
            end

            --else
            if not passed and type(ast[counter+2]) == "table" then --could also say and ast[counter+2] ~= nil
                interp_stmt_list(ast[counter+2])    --if there was no else then last ast doesn't exist
            end

        elseif ast[1] == WHILE_STMT then
            while evalBoolExpr(ast[2])  do
                interp_stmt_list(ast[3])
            end
        
        else
        end
    end

    -- Body of function interp
    interp_stmt_list(ast)

    return state
end


-- ***** Module Export *****


return interpit

