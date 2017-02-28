#!/usr/bin/env lua
-- parseit_test.lua
-- Glenn G. Chappell
-- 25 Feb 2017
--
-- For CS F331 / CSCE A331 Spring 2017
-- Test Program for Module parseit
-- Used in Assignment 4, Exercise A

parseit = require "parseit"  -- Import parseit module


-- *********************************************
-- * YOU MAY WISH TO CHANGE THE FOLLOWING LINE *
-- *********************************************

EXIT_ON_FIRST_FAILURE = true
-- If EXIT_ON_FIRST_FAILURE is true, then this program exits after the
-- first failing test. If it is false, then this program executes all
-- tests, reporting success/failure for each.


-- *********************************************************************
-- Testing Package
-- *********************************************************************


tester = {}
tester.countTests = 0
tester.countPasses = 0

function tester.test(self, success, testName)
    self.countTests = self.countTests+1
    io.write("    Test: " .. testName .. " - ")
    if success then
        self.countPasses = self.countPasses+1
        io.write("passed")
    else
        io.write("********** FAILED **********")
    end
    io.write("\n")
end

function tester.allPassed(self)
    return self.countPasses == self.countTests
end


-- *********************************************************************
-- Utility Functions
-- *********************************************************************


function fail_exit()
    if EXIT_ON_FIRST_FAILURE then
        io.write("**************************************************\n")
        io.write("* This test program is configured to exit after  *\n")
        io.write("* the first failing test. To make it execute all *\n")
        io.write("* tests, reporting success/failure for each, set *\n")
        io.write("* variable                                       *\n")
        io.write("*                                                *\n")
        io.write("*   EXIT_ON_FIRST_FAILURE                        *\n")
        io.write("*                                                *\n")
        io.write("* to false, near the start of the test program.  *\n")
        io.write("**************************************************\n")

        -- Wait for user
        io.write("\nPress ENTER to quit ")
        io.read("*l")

        -- Terminate program
        os.exit(1)
    end
end


-- printTable
-- Given a table, prints it in (roughly) Lua literal notation. If
-- parameter is not a table, prints <not a table>.
function printTable(t)
    -- out
    -- Print parameter, surrounded by double quotes if it is a string,
    -- or simply an indication of its type, if it is not number, string,
    -- or boolean.
    local function out(p)
        if type(p) == "number" then
            io.write(p)
        elseif type(p) == "string" then
            io.write('"'..p..'"')
        elseif type(p) == "boolean" then
            if p then
                io.write("true")
            else
                io.write("false")
            end
        else
            io.write('<'..type(p)..'>')
        end
    end

    if type(t) ~= "table" then
        io.write("<not a table>")
    end

    io.write("{ ")
    local first = true  -- First iteration of loop?
    for k, v in pairs(t) do
        if first then
            first = false
        else
            io.write(", ")
        end
        io.write("[")
        out(k)
        io.write("]=")
        out(v)
    end
    io.write(" }")
end


-- printArray
-- Given a table, prints it in (roughly) Lua literal notation for an
-- array. If parameter is not a table, prints <not a table>.
function printArray(t)
    -- out
    -- Print parameter, surrounded by double quotes if it is a string.
    local function out(p)
        if type(p) == "string" then io.write('"') end
        io.write(p)
        if type(p) == "string" then io.write('"') end
    end

    if type(t) ~= "table" then
        io.write("<not a table>")
    end

    io.write("{ ")
    local first = true  -- First iteration of loop?
    for k, v in ipairs(t) do
        if first then
            first = false
        else
            io.write(", ")
        end
        out(v)
    end
    io.write(" }")
end


-- tableEq
-- Compare equality of two tables.
-- Uses "==" on table values. Returns false if either of t1 or t2 is not
-- a table.
function tableEq(t1, t2)
    -- Both params are tables?
    local type1, type2 = type(t1), type(t2)
    if type1 ~= "table" or type2 ~= "table" then
        return false
    end

    -- Get number of keys in t1 & check values in t1, t2 are equal
    local t1numkeys = 0
    for k, v in pairs(t1) do
        t1numkeys = t1numkeys + 1
        if t2[k] ~= v then
            return false
        end
    end

    -- Check number of keys in t1, t2 same
    local t2numkeys = 0
    for k, v in pairs(t2) do
        t2numkeys = t2numkeys + 1
    end
    return t1numkeys == t2numkeys
end


-- *********************************************************************
-- Definitions for This Test Program
-- *********************************************************************


-- Symbolic Constants for AST
-- Names differ from those in assignment, to avoid interference.
local STMTxLIST   = 1
local CRxSTMT     = 2
local PRINTxSTMT  = 3
local INPUTxSTMT  = 4
local SETxSTMT    = 5
local SUBxSTMT    = 6
local CALLxSTMT   = 7
local IFxSTMT     = 8
local WHILExSTMT  = 9
local BINxOP      = 10
local UNxOP       = 11
local NUMLITxVAL  = 12
local STRLITxVAL  = 13
local BOOLLITxVAL = 14
local VARIDxVAL   = 15
local ARRAYxREF   = 16


-- String forms of symbolic constants

symbolNames = {
  [1]="STMT_LIST",
  [2]="CR_STMT",
  [3]="PRINT_STMT",
  [4]="INPUT_STMT",
  [5]="SET_STMT",
  [6]="SUB_STMT",
  [7]="CALL_STMT",
  [8]="IF_STMT",
  [9]="WHILE_STMT",
  [10]="BIN_OP",
  [11]="UN_OP",
  [12]="NUMLIT_VAL",
  [13]="STRLIT_VAL",
  [14]="BOOLLIT_VAL",
  [15]="VARID_VAL",
  [16]="ARRAY_REF"
}


-- writeAST_parseit
-- Write an AST, in (roughly) Lua form, with numbers replaced by the
-- symbolic constants used in parseit.
-- A table is assumed to represent an array.
-- See the Assignment 4 description for the AST Specification.
function writeAST_parseit(x)
    if type(x) == "number" then
        local name = symbolNames[x]
        if name == nil then
            io.write("<ERROR: Unknown constant: "..x..">")
        else
            io.write(name)
        end
    elseif type(x) == "string" then
        io.write('"'..x..'"')
    elseif type(x) == "boolean" then
        if x then
            io.write("true")
        else
            io.write("false")
        end
    elseif type(x) == "table" then
        local first = true
        io.write("{")
        for k = 1, #x do  -- ipairs is problematic
            if not first then
                io.write(", ")
            end
            writeAST_parseit(x[k])
            first = false
        end
        io.write("}")
    elseif type(x) == "nil" then
        io.write("nil")
    else
        io.write("<ERROR: "..type(x)..">")
    end
end


-- astEq
-- Checks equality of two ASTs, represented as in the Assignment 4
-- description. Returns true if equal, false otherwise.
function astEq(ast1, ast2)
    if type(ast1) ~= type(ast2) then
        return false
    end

    if type(ast1) ~= "table" then
        return ast1 == ast2
    end

    if #ast1 ~= #ast2 then
        return false
    end

    for k = 1, #ast1 do  -- ipairs is problematic
        if not astEq(ast1[k], ast2[k]) then
            return false
        end
    end
    return true
end


-- bool2Str
-- Given boolean, return string representing it: "true" or "false".
function bool2Str(b)
    if b then
        return "true"
    else
        return "false"
    end
end


-- checkParse
-- Given tester object, input string ("program"), expected output values
-- from parser (good, AST), and string giving the name of the test. Do
-- test & print result. If test fails and EXIT_ON_FIRST_FAILURE is true,
-- then print detailed results and exit program.
function checkParse(t, prog,
                    expectedGood, expectedDone, expectedAST,
                    testName)
    local actualGood, actualDone, actualAST = parseit.parse(prog)
    local sameGood = (expectedGood == actualGood)
    local sameDone = (expectedDone == actualDone)
    local sameAST = true
    if sameGood and expectedGood and sameDone and expectedDone then
        sameAST = astEq(expectedAST, actualAST)
    end
    local success = sameGood and sameDone and sameAST
    t:test(success, testName)

    if success or not EXIT_ON_FIRST_FAILURE then
        return
    end

    io.write("\n")
    io.write("Input for the last test above:\n")
    io.write('"'..prog..'"\n')
    io.write("\n")
    io.write("Expected parser 'good' return value: ")
    io.write(bool2Str(expectedGood).."\n")
    io.write("Actual parser 'good' return value: ")
    io.write(bool2Str(actualGood).."\n")
    io.write("Expected parser 'done' return value: ")
    io.write(bool2Str(expectedDone).."\n")
    io.write("Actual parser 'done' return value: ")
    io.write(bool2Str(actualDone).."\n")
    if not sameAST then
        io.write("\n")
        io.write("Expected AST:\n")
        writeAST_parseit(expectedAST)
        io.write("\n")
        io.write("\n")
        io.write("Returned AST:\n")
        writeAST_parseit(actualAST)
        io.write("\n")
    end
    io.write("\n")
    fail_exit()
end


-- *********************************************************************
-- Test Suite Functions
-- *********************************************************************


function test_simple(t)
    io.write("Test Suite: simple cases\n")

    checkParse(t, "", true, true, {STMTxLIST},
      "Empty program")
    checkParse(t, "end", true, false, nil,
      "Bad program: Keyword only #1")
    checkParse(t, "elseif", true, false, nil,
      "Bad program: Keyword only #2")
    checkParse(t, "else", true, false, nil,
      "Bad program: Keyword only #3")
    checkParse(t, "%abc", true, false, nil,
      "Bad program: VariableIdentifier only")
    checkParse(t, "123", true, false, nil,
      "Bad program: NumericLiteral only")
    checkParse(t, "'xyz'", true, false, nil,
      "Bad program: StringLiteral only #1")
    checkParse(t, '"xyz"', true, false, nil,
      "Bad program: StringLiteral only #2")
    checkParse(t, "<=", true, false, nil,
      "Bad program: Operator only")
    checkParse(t, "{", true, false, nil,
      "Bad program: Punctuation only")
    checkParse(t, "\a", true, false, nil,
      "Bad program: Malformed only #1")
    checkParse(t, "'", true, false, nil,
      "bad program: malformed only #2")
    checkParse(t, "abc", true, false, nil,
      "bad program: malformed only #2")
end


function test_cr_stmt(t)
    io.write("Test Suite: cr statements\n")

    checkParse(t, "cr", true, true,
      {STMTxLIST,{CRxSTMT}},
      "Cr statement: one")
    checkParse(t, "cr cr cr cr cr cr", true, true,
      {STMTxLIST,{CRxSTMT},{CRxSTMT},{CRxSTMT},{CRxSTMT},{CRxSTMT},
        {CRxSTMT}},
      "Cr statement: multiple")
    checkParse(t, "cr 1", true, false, nil,
      "Bad cr statement")
    checkParse(t, "cr end", true, false, nil,
      "Bad cr statement: followed by end")
    checkParse(t, "print \"x\" cr", true, true,
        {STMTxLIST,{PRINTxSTMT,{STRLITxVAL,"\"x\""}},{CRxSTMT}},
      "Print + cr")
end


function test_print_stmt(t)
    io.write("Test Suite: print statements\n")

    checkParse(t, "print 'abc'", true, true,
      {STMTxLIST,{PRINTxSTMT,{STRLITxVAL,"'abc'"}}},
      "Print statement: StringLiteral")
    checkParse(t, "print %x", true, true,
      {STMTxLIST,{PRINTxSTMT,{VARIDxVAL,"%x"}}},
      "Print statement: variable")
    checkParse(t, "print %a+%x[%b*(%c==%d-%f)]%%g<=%h", true, true,
      {STMTxLIST,{PRINTxSTMT,{{BINxOP,"<="},{{BINxOP,"+"},{VARIDxVAL,"%a"},
        {{BINxOP,"%"},{ARRAYxREF,{VARIDxVAL,"%x"},{{BINxOP,"*"},
        {VARIDxVAL,"%b"},{{BINxOP,"=="},{VARIDxVAL,"%c"},{{BINxOP,"-"},
        {VARIDxVAL,"%d"},{VARIDxVAL,"%f"}}}}},{VARIDxVAL,"%g"}}},{VARIDxVAL,"%h"}}}},
      "Print statement: expression")
    checkParse(t, "print", false, true, nil,
      "Bad print statement: empty")
    checkParse(t, "print end", false, false, nil,
      "Bad print statement: keyword")
    checkParse(t, "print 1 end", true, false, nil,
      "Bad print statement: followed by end")
end


function test_input_stmt(t)
    io.write("Test Suite: input statements\n")

    checkParse(t, "input %x", true, true,
      {STMTxLIST,{INPUTxSTMT,{VARIDxVAL,"%x"}}},
      "Input statement: simple")
    checkParse(t, "input %x[1]", true, true,
      {STMTxLIST,{INPUTxSTMT,{ARRAYxREF,{VARIDxVAL,"%x"},
        {NUMLITxVAL,"1"}}}},
      "Input statement: array ref")
    checkParse(t, "input %x[(%a==%b[%c[%d]])+%e[3e7%5]]", true, true,
      {STMTxLIST,{INPUTxSTMT,{ARRAYxREF,{VARIDxVAL,"%x"},{{BINxOP,"+"},
        {{BINxOP,"=="},{VARIDxVAL,"%a"},{ARRAYxREF,{VARIDxVAL,"%b"},{ARRAYxREF,
        {VARIDxVAL,"%c"},{VARIDxVAL,"%d"}}}},{ARRAYxREF,{VARIDxVAL,"%e"},
        {{BINxOP,"%"},{NUMLITxVAL,"3e7"},{NUMLITxVAL,"5"}}}}}}},
      "Input statement, complex array ref")
    checkParse(t, "input", false, true, nil,
      "Bad input statement: no lvalue")
    checkParse(t, "input %a %b", true, false, nil,
      "Bad input statement: two lvalues")
    checkParse(t, "input end", false, false, nil,
      "Bad input statement: keyword")
    checkParse(t, "input (%x)", false, false, nil,
      "Bad input statement: var in parens")
    checkParse(t, "input (%x[1])", false, false, nil,
      "Bad input statement: array ref in parens")
end


function test_set_stmt(t)
    io.write("Test Suite: set statements\n")

    checkParse(t, "set %abc: 123", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%abc"},{NUMLITxVAL,"123"}}},
      "Set statement: NumericLiteral")
    checkParse(t, "set %abc: %xyz", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL, "%abc"},{VARIDxVAL,"%xyz"}}},
      "Set statement: variableIdentifier #1")
    checkParse(t, "set %abc: %true", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL, "%abc"},{VARIDxVAL,"%true"}}},
      "Set statement: variableIdentifier #2")
    checkParse(t, "set %abc: %false", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL, "%abc"},{VARIDxVAL,"%false"}}},
      "Set statement: variableIdentifier #3")
    checkParse(t, "set %abc[1]: %xyz", true, true,
      {STMTxLIST,{SETxSTMT,{ARRAYxREF,{VARIDxVAL,"%abc"},{NUMLITxVAL,"1"}},
        {VARIDxVAL,"%xyz"}}},
      "Set statement: array ref = ...")
    checkParse(t, "set %abc: true", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL, "%abc"},{BOOLLITxVAL,"true"}}},
      "Set statement: boolean literal Keyword: true")
    checkParse(t, "set %abc: false", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL, "%abc"},{BOOLLITxVAL,"false"}}},
      "Set statement: boolean literal Keyword: false")
    checkParse(t, "%abc: 123", true, false, nil,
      "Bad set statement: missing 'set'")
    checkParse(t, "set: 123", false, false, nil,
      "Bad set statement: missing LHS")
    checkParse(t, "set 123: 123", false, false, nil,
      "Bad set statement: LHS is NumericLiteral")
    checkParse(t, "set end: 123", false, false, nil,
      "Bad set statement: LHS is Keyword")
    checkParse(t, "set %abc 123", false, false, nil,
      "Bad set statement: missing assignment op")
    checkParse(t, "set %abc == 123", false, false, nil,
      "Bad set statement: assignment op replaced by equality")
    checkParse(t, "set %abc :", false, true, nil,
      "Bad set statement: RHS is empty")
    checkParse(t, "set %abc: end", false, false, nil,
      "Bad set statement: RHS is Keyword")
    checkParse(t, "set %abc: 1 2", true, false, nil,
      "Bad set statement: RHS is two NumericLiterals")
    checkParse(t, "set %abc: 1 end", true, false, nil,
      "Bad set statement: followed by end")
end


function test_expr_simple(t)
    io.write("Test Suite: simple expressions\n")

    checkParse(t, "set %x: 1&&2", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"&&"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: &&")
    checkParse(t, "set %x: 1||2", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"||"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: ||")
    checkParse(t, "set %x: 1 + 2", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: binary + (numbers with space)")
    checkParse(t, "set %x: 1+2", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: binary + (numbers without space)")
    checkParse(t, "set %x: %a+2", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},
        {VARIDxVAL,"%a"},{NUMLITxVAL,"2"}}}},
      "Simple expression: binary + (var+number)")
    checkParse(t, "set %x: 1+%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},
        {NUMLITxVAL,"1"},{VARIDxVAL,"%b"}}}},
      "Simple expression: binary + (number+var)")
    checkParse(t, "set %x: %a+%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}},
      "Simple expression: binary + (vars)")
    checkParse(t, "set %x: 1+", false, true, nil,
      "Bad expression: end with +")
    checkParse(t, "set %x: 1 - 2", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"-"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: binary - (numbers with space)")
    checkParse(t, "set %x: 1-2", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"-"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: binary - (numbers without space)")
    checkParse(t, "set %x: 1-", false, true, nil,
      "Bad expression: end with -")
    checkParse(t, "set %x: 1*2", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"*"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: * (numbers)")
    checkParse(t, "set %x: %a*2", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"*"},
        {VARIDxVAL,"%a"},{NUMLITxVAL,"2"}}}},
      "Simple expression: * (var*number)")
    checkParse(t, "set %x: 1*%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"*"},
        {NUMLITxVAL,"1"},{VARIDxVAL,"%b"}}}},
      "Simple expression: * (number*var)")
    checkParse(t, "set %x: %a*%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"*"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}},
      "Simple expression: * (vars)")
    checkParse(t, "set %x: 1*", false, true, nil,
      "Bad expression: end with *")
    checkParse(t, "set %x: 1/2", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"/"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: /")
    checkParse(t, "set %x: 1/", false, true, nil,
      "Bad expression: end with /")
    checkParse(t, "set %x: 1%2", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"%"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: % #1")
    checkParse(t, "set %x: 1%true", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"%"},
        {NUMLITxVAL,"1"},{BOOLLITxVAL,"true"}}}},
      "Simple expression: % #2")
    checkParse(t, "set %x: 1%false", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"%"},
        {NUMLITxVAL,"1"},{BOOLLITxVAL,"false"}}}},
      "Simple expression: % #3")
    checkParse(t, "set %x: 1%", false, true, nil,
      "Bad expression: end with %")
    checkParse(t, "set %x: 1==2", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"=="},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: == (numbers)")
    checkParse(t, "set %x: %a==2", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"=="},
        {VARIDxVAL,"%a"},{NUMLITxVAL,"2"}}}},
      "Simple expression: == (var==number)")
    checkParse(t, "set %x: 1==%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"=="},
        {NUMLITxVAL,"1"},{VARIDxVAL,"%b"}}}},
      "Simple expression: == (number==var)")
    checkParse(t, "set %x: %a==%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"=="},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}},
      "Simple expression: == (vars)")
    checkParse(t, "set %x: 1==", false, true, nil,
      "Bad expression: end with ==")
    checkParse(t, "set %x: 1!=2", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"!="},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: !=")
    checkParse(t, "set %x: 1!=", false, true, nil,
      "Bad expression: end with !=")
    checkParse(t, "set %x: 1<2", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"<"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: <")
    checkParse(t, "set %x: 1<", false, true, nil,
      "Bad expression: end with <")
    checkParse(t, "set %x: 1<=2", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"<="},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: <=")
    checkParse(t, "set %x: 1<=", false, true, nil,
      "Bad expression: end with <=")
    checkParse(t, "set %x: 1>2", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,">"},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: >")
    checkParse(t, "set %x: 1>", false, true, nil,
      "Bad expression: end with >")
    checkParse(t, "set %x: 1>=2", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,">="},
        {NUMLITxVAL,"1"},{NUMLITxVAL,"2"}}}},
      "Simple expression: >=")
    checkParse(t, "set %x: +%a", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"+"},{VARIDxVAL,"%a"}}}},
      "Simple expression: unary +")
    checkParse(t, "set %x: -%a", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"-"},{VARIDxVAL,"%a"}}}},
      "Simple expression: unary -")
    checkParse(t, "set %x: 1>=", false, true, nil,
      "Bad expression: end with >=")
    checkParse(t, "set %x: (1)", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{NUMLITxVAL,"1"}}},
      "Simple expression: parens (number)")
    checkParse(t, "set %x: (%a)", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{VARIDxVAL,"%a"}}},
      "Simple expression: parens (var)")
    checkParse(t, "set %x: %a[1]", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{ARRAYxREF,{VARIDxVAL,"%a"},
        {NUMLITxVAL,"1"}}}},
      "Simple expression: array ref")
    checkParse(t, "set %x: (1", false, true, nil,
      "Bad expression: no closing paren")
    checkParse(t, "set %x: ()", false, false, nil,
      "Bad expression: empty parens")
    checkParse(t, "set %x: %a[1", false, true, nil,
      "Bad expression: no closing bracket")
    checkParse(t, "set %x: %a 1]", true, false, nil,
      "Bad expression: no opening bracket")
    checkParse(t, "set %x: %a[]", false, false, nil,
      "Bad expression: empty brackets")
    checkParse(t, "set %x: (%x)", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{VARIDxVAL,"%x"}}},
      "Simple expression: var in parens on RHS")
    checkParse(t, "set (%x): %x", false, false, nil,
      "Bad expression: var in parens on LHS")
    checkParse(t, "set %x[1]: (%x[1])", true, true,
      {STMTxLIST,{SETxSTMT,{ARRAYxREF,{VARIDxVAL,"%x"},{NUMLITxVAL,"1"}},
        {ARRAYxREF,{VARIDxVAL,"%x"},{NUMLITxVAL,"1"}}}},
      "Simple expression: array ref in parens on RHS")
    checkParse(t, "set (%x[1]): %x[1]", false, false, nil,
      "Bad expression: array ref in parens on LHS")
end


function test_expr_prec_assoc(t)
    io.write("Test Suite: expressions - precedence & associativity\n")

    checkParse(t, "set %x: 1&&2&&3&&4&&5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"&&"},{{BINxOP,"&&"},
        {{BINxOP, "&&"},{{BINxOP,"&&"},{NUMLITxVAL,"1"},{NUMLITxVAL,"2"}},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},{NUMLITxVAL,"5"}}}},
      "Operator && is left-associative")
    checkParse(t, "set %x: 1||2||3||4||5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"||"},{{BINxOP,"||"},
        {{BINxOP, "||"},{{BINxOP,"||"},{NUMLITxVAL,"1"},{NUMLITxVAL,"2"}},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},{NUMLITxVAL,"5"}}}},
      "Operator || is left-associative")
    checkParse(t, "set %x: 1+2+3+4+5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},{{BINxOP,"+"},
        {{BINxOP, "+"},{{BINxOP,"+"},{NUMLITxVAL,"1"},{NUMLITxVAL,"2"}},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},{NUMLITxVAL,"5"}}}},
      "Binary operator + is left-associative")
    checkParse(t, "set %x: 1-2-3-4-5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"-"},{{BINxOP,"-"},
        {{BINxOP, "-"},{{BINxOP,"-"},{NUMLITxVAL,"1"},{NUMLITxVAL,"2"}},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},{NUMLITxVAL,"5"}}}},
      "Binary operator - is left-associative")
    checkParse(t, "set %x: 1*2*3*4*5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"*"},{{BINxOP,"*"},
        {{BINxOP, "*"},{{BINxOP,"*"},{NUMLITxVAL,"1"},{NUMLITxVAL,"2"}},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},{NUMLITxVAL,"5"}}}},
      "Operator * is left-associative")
    checkParse(t, "set %x: 1/2/3/4/5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"/"},{{BINxOP,"/"},
        {{BINxOP, "/"},{{BINxOP,"/"},{NUMLITxVAL,"1"},{NUMLITxVAL,"2"}},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},{NUMLITxVAL,"5"}}}},
      "Operator / is left-associative")
    checkParse(t, "set %x: 1%2%3%4%5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"%"},{{BINxOP,"%"},
        {{BINxOP, "%"},{{BINxOP,"%"},{NUMLITxVAL,"1"},{NUMLITxVAL,"2"}},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},{NUMLITxVAL,"5"}}}},
      "Operator % is left-associative")
    checkParse(t, "set %x: 1==2==3==4==5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"=="},{{BINxOP,"=="},
        {{BINxOP, "=="},{{BINxOP,"=="},{NUMLITxVAL,"1"},
        {NUMLITxVAL,"2"}},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},
        {NUMLITxVAL,"5"}}}},
      "Operator == is left-associative")
    checkParse(t, "set %x: 1!=2!=3!=4!=5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"!="},{{BINxOP,"!="},
        {{BINxOP, "!="},{{BINxOP,"!="},{NUMLITxVAL,"1"},
        {NUMLITxVAL,"2"}},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},
        {NUMLITxVAL,"5"}}}},
      "Operator != is left-associative")
    checkParse(t, "set %x: 1<2<3<4<5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"<"},{{BINxOP,"<"},
        {{BINxOP, "<"},{{BINxOP,"<"},{NUMLITxVAL,"1"},{NUMLITxVAL,"2"}},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},{NUMLITxVAL,"5"}}}},
      "Operator < is left-associative")
    checkParse(t, "set %x: 1<=2<=3<=4<=5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"<="},{{BINxOP,"<="},
        {{BINxOP, "<="},{{BINxOP,"<="},{NUMLITxVAL,"1"},
        {NUMLITxVAL,"2"}},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},
        {NUMLITxVAL,"5"}}}},
      "Operator <= is left-associative")
    checkParse(t, "set %x: 1>2>3>4>5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,">"},{{BINxOP,">"},
        {{BINxOP, ">"},{{BINxOP,">"},{NUMLITxVAL,"1"},{NUMLITxVAL,"2"}},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},{NUMLITxVAL,"5"}}}},
      "Operator > is left-associative")
    checkParse(t, "set %x: 1>=2>=3>=4>=5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,">="},{{BINxOP,">="},
        {{BINxOP, ">="},{{BINxOP,">="},{NUMLITxVAL,"1"},
        {NUMLITxVAL,"2"}},{NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}},
        {NUMLITxVAL,"5"}}}},
      "Operator >= is left-associative")

    checkParse(t, "set %x: !!!!%a", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"!"},{{UNxOP,"!"},
        {{UNxOP,"!"},{{UNxOP,"!"},{VARIDxVAL,"%a"}}}}}}},
      "Operator ! is right-associative")
    checkParse(t, "set %x: ++++%a", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"+"},{{UNxOP,"+"},
        {{UNxOP,"+"},{{UNxOP,"+"},{VARIDxVAL,"%a"}}}}}}},
      "Unary operator + is right-associative")
    checkParse(t, "set %x: ----%a", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"-"},{{UNxOP,"-"},
        {{UNxOP,"-"},{{UNxOP,"-"},{VARIDxVAL,"%a"}}}}}}},
      "Unary operator - is right-associative")

    checkParse(t, "set %x: %a&&%b||%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"||"},{{BINxOP,"&&"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: &&, ||")
    checkParse(t, "set %x: %a&&%b==%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"&&"},{VARIDxVAL,"%a"},
        {{BINxOP,"=="},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: &&, ==")
    checkParse(t, "set %x: %a&&%b!=%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"&&"},{VARIDxVAL,"%a"},
        {{BINxOP,"!="},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: &&, !=")
    checkParse(t, "set %x: %a&&%b<%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"&&"},{VARIDxVAL,"%a"},
        {{BINxOP,"<"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: &&, <")
    checkParse(t, "set %x: %a&&%b<=%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"&&"},{VARIDxVAL,"%a"},
        {{BINxOP,"<="},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: &&, <=")
    checkParse(t, "set %x: %a&&%b>%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"&&"},{VARIDxVAL,"%a"},
        {{BINxOP,">"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: &&, >")
    checkParse(t, "set %x: %a&&%b>=%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"&&"},{VARIDxVAL,"%a"},
        {{BINxOP,">="},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: &&, >=")
    checkParse(t, "set %x: %a&&%b+%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"&&"},{VARIDxVAL,"%a"},
        {{BINxOP,"+"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: &&, binary +")
    checkParse(t, "set %x: %a&&%b-%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"&&"},{VARIDxVAL,"%a"},
        {{BINxOP,"-"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: &&, binary -")
    checkParse(t, "set %x: %a&&%b*%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"&&"},{VARIDxVAL,"%a"},
        {{BINxOP,"*"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: &&, *")
    checkParse(t, "set %x: %a&&%b/%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"&&"},{VARIDxVAL,"%a"},
        {{BINxOP,"/"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: &&, /")
    checkParse(t, "set %x: %a&&%b%%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"&&"},{VARIDxVAL,"%a"},
        {{BINxOP,"%"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: &&, %")

    checkParse(t, "set %x: %a||%b&&%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"&&"},{{BINxOP,"||"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: ||, &&")
    checkParse(t, "set %x: %a||%b==%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"||"},{VARIDxVAL,"%a"},
        {{BINxOP,"=="},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: ||, ==")
    checkParse(t, "set %x: %a||%b!=%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"||"},{VARIDxVAL,"%a"},
        {{BINxOP,"!="},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: ||, !=")
    checkParse(t, "set %x: %a||%b<%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"||"},{VARIDxVAL,"%a"},
        {{BINxOP,"<"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: ||, <")
    checkParse(t, "set %x: %a||%b<=%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"||"},{VARIDxVAL,"%a"},
        {{BINxOP,"<="},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: ||, <=")
    checkParse(t, "set %x: %a||%b>%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"||"},{VARIDxVAL,"%a"},
        {{BINxOP,">"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: ||, >")
    checkParse(t, "set %x: %a||%b>=%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"||"},{VARIDxVAL,"%a"},
        {{BINxOP,">="},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: ||, >=")
    checkParse(t, "set %x: %a||%b+%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"||"},{VARIDxVAL,"%a"},
        {{BINxOP,"+"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: ||, binary +")
    checkParse(t, "set %x: %a||%b-%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"||"},{VARIDxVAL,"%a"},
        {{BINxOP,"-"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: ||, binary -")
    checkParse(t, "set %x: %a||%b*%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"||"},{VARIDxVAL,"%a"},
        {{BINxOP,"*"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: ||, *")
    checkParse(t, "set %x: %a||%b/%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"||"},{VARIDxVAL,"%a"},
        {{BINxOP,"/"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: ||, /")
    checkParse(t, "set %x: %a||%b%%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"||"},{VARIDxVAL,"%a"},
        {{BINxOP,"%"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: ||, %")

    checkParse(t, "set %x: %a==%b>%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,">"},{{BINxOP,"=="},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: ==, >")
    checkParse(t, "set %x: %a==%b+%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"=="},{VARIDxVAL,"%a"},
        {{BINxOP,"+"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: ==, binary +")
    checkParse(t, "set %x: %a==%b-%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"=="},{VARIDxVAL,"%a"},
        {{BINxOP,"-"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: ==, binary -")
    checkParse(t, "set %x: %a==%b*%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"=="},{VARIDxVAL,"%a"},
        {{BINxOP,"*"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: ==, *")
    checkParse(t, "set %x: %a==%b/%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"=="},{VARIDxVAL,"%a"},
        {{BINxOP,"/"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: ==, /")
    checkParse(t, "set %x: %a==%b%%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"=="},{VARIDxVAL,"%a"},
        {{BINxOP,"%"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: ==, %")

    checkParse(t, "set %x: %a>%b==%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"=="},{{BINxOP,">"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: >, ==")
    checkParse(t, "set %x: %a>%b+%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,">"},{VARIDxVAL,"%a"},
        {{BINxOP,"+"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: >, binary +")
    checkParse(t, "set %x: %a>%b-%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,">"},{VARIDxVAL,"%a"},
        {{BINxOP,"-"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: >, binary -")
    checkParse(t, "set %x: %a>%b*%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,">"},{VARIDxVAL,"%a"},
        {{BINxOP,"*"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: >, *")
    checkParse(t, "set %x: %a>%b/%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,">"},{VARIDxVAL,"%a"},
        {{BINxOP,"/"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: >, /")
    checkParse(t, "set %x: %a>%b%%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,">"},{VARIDxVAL,"%a"},
        {{BINxOP,"%"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: >, %")

    checkParse(t, "set %x: %a+%b==%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"=="},{{BINxOP,"+"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: binary +, ==")
    checkParse(t, "set %x: %a+%b>%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,">"},{{BINxOP,"+"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: binary +, >")
    checkParse(t, "set %x: %a+%b-%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"-"},{{BINxOP,"+"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: binary +, binary -")
    checkParse(t, "set %x: %a+%b*%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},{VARIDxVAL,"%a"},
        {{BINxOP,"*"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: binary +, *")
    checkParse(t, "set %x: %a+%b/%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},{VARIDxVAL,"%a"},
        {{BINxOP,"/"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: binary +, /")
    checkParse(t, "set %x: %a+%b%%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},{VARIDxVAL,"%a"},
        {{BINxOP,"%"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: binary +, %")

    checkParse(t, "set %x: %a-%b==%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"=="},{{BINxOP,"-"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: binary -, ==")
    checkParse(t, "set %x: %a-%b>%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,">"},{{BINxOP,"-"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: binary -, >")
    checkParse(t, "set %x: %a-%b+%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},{{BINxOP,"-"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: binary -, binary +")
    checkParse(t, "set %x: %a-%b*%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"-"},{VARIDxVAL,"%a"},
        {{BINxOP,"*"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: binary -, *")
    checkParse(t, "set %x: %a-%b/%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"-"},{VARIDxVAL,"%a"},
        {{BINxOP,"/"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: binary -, /")
    checkParse(t, "set %x: %a-%b%%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"-"},{VARIDxVAL,"%a"},
        {{BINxOP,"%"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence check: binary -, %")

    checkParse(t, "set %x: %a*%b==%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"=="},{{BINxOP,"*"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: *, ==")
    checkParse(t, "set %x: %a*%b>%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,">"},{{BINxOP,"*"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: *, >")
    checkParse(t, "set %x: %a*%b+%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},{{BINxOP,"*"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: *, binary +")
    checkParse(t, "set %x: %a*%b-%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"-"},{{BINxOP,"*"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: *, binary -")
    checkParse(t, "set %x: %a*%b/%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"/"},{{BINxOP,"*"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: *, /")
    checkParse(t, "set %x: %a*%b%%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"%"},{{BINxOP,"*"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: *, %")

    checkParse(t, "set %x: %a/%b==%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"=="},{{BINxOP,"/"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: /, ==")
    checkParse(t, "set %x: %a/%b>%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,">"},{{BINxOP,"/"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: /, >")
    checkParse(t, "set %x: %a/%b+%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},{{BINxOP,"/"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: /, binary +")
    checkParse(t, "set %x: %a/%b-%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"-"},{{BINxOP,"/"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: /, binary -")
    checkParse(t, "set %x: %a/%b*%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"*"},{{BINxOP,"/"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: /, *")
    checkParse(t, "set %x: %a/%b%%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"%"},{{BINxOP,"/"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: /, %")

    checkParse(t, "set %x: %a%%b==%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"=="},{{BINxOP,"%"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: %, ==")
    checkParse(t, "set %x: %a%%b>%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,">"},{{BINxOP,"%"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: %, >")
    checkParse(t, "set %x: %a%%b+%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},{{BINxOP,"%"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: %, binary +")
    checkParse(t, "set %x: %a%%b-%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"-"},{{BINxOP,"%"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: %, binary -")
    checkParse(t, "set %x: %a%%b*%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"*"},{{BINxOP,"%"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: %, *")
    checkParse(t, "set %x: %a%%b/%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"/"},{{BINxOP,"%"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: %, /")

    checkParse(t, "set %x: !%a&&%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"&&"},{{UNxOP,"!"},
        {VARIDxVAL,"%a"}},{VARIDxVAL,"%b"}}}},
      "Precedence check: !, &&")
    checkParse(t, "set %x: !%a||%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"||"},{{UNxOP,"!"},
        {VARIDxVAL,"%a"}},{VARIDxVAL,"%b"}}}},
      "Precedence check: !, ||")
    checkParse(t, "set %x: !%a==%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"!"},{{BINxOP,"=="},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}}},
      "Precedence check: !, ==")
    checkParse(t, "set %x: !%a!=%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"!"},{{BINxOP,"!="},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}}},
      "Precedence check: !, !=")
    checkParse(t, "set %x: !%a<%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"!"},{{BINxOP,"<"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}}},
      "Precedence check: !, <")
    checkParse(t, "set %x: !%a<=%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"!"},{{BINxOP,"<="},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}}},
      "Precedence check: !, <=")
    checkParse(t, "set %x: !%a>%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"!"},{{BINxOP,">"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}}},
      "Precedence check: !, >")
    checkParse(t, "set %x: !%a>=%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"!"},{{BINxOP,">="},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}}},
      "Precedence check: !, >=")
    checkParse(t, "set %x: !%a+%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"!"},{{BINxOP,"+"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}}},
      "Precedence check: !, binary +")
    checkParse(t, "set %x: !%a-%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"!"},{{BINxOP,"-"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}}},
      "Precedence check: !, binary -")
    checkParse(t, "set %x: !%a*%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"!"},{{BINxOP,"*"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}}},
      "Precedence check: !, *")
    checkParse(t, "set %x: !%a/%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"!"},{{BINxOP,"/"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}}},
      "Precedence check: !, /")
    checkParse(t, "set %x: !%a%%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"!"},{{BINxOP,"%"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}}},
      "Precedence check: !, %")
    checkParse(t, "set %x: %a!=+%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"!="},{VARIDxVAL,"%a"},
        {{UNxOP,"+"},{VARIDxVAL,"%b"}}}}},
      "Precedence check: !=, unary +")
    checkParse(t, "set %x: -%a<%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"<"},{{UNxOP,"-"},
        {VARIDxVAL,"%a"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: unary -, <")
    checkParse(t, "set %x: %a++%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},{VARIDxVAL,"%a"},
        {{UNxOP,"+"},{VARIDxVAL,"%b"}}}}},
      "Precedence check: binary +, unary +")
    checkParse(t, "set %x: %a+-%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},{VARIDxVAL,"%a"},
        {{UNxOP,"-"},{VARIDxVAL,"%b"}}}}},
      "Precedence check: binary +, unary -")
    checkParse(t, "set %x: +%a+%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},{{UNxOP,"+"},
        {VARIDxVAL,"%a"}},{VARIDxVAL,"%b"}}}},
      "Precedence check: unary +, binary +, *")
    checkParse(t, "set %x: -%a+%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},{{UNxOP,"-"},
        {VARIDxVAL,"%a"}},{VARIDxVAL,"%b"}}}},
      "Precedence check: unary -, binary +")
    checkParse(t, "set %x: %a-+%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"-"},{VARIDxVAL,"%a"},
        {{UNxOP,"+"},{VARIDxVAL,"%b"}}}}},
      "Precedence check: binary -, unary +")
    checkParse(t, "set %x: %a--%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"-"},{VARIDxVAL,"%a"},
        {{UNxOP,"-"},{VARIDxVAL,"%b"}}}}},
      "Precedence check: binary -, unary -")
    checkParse(t, "set %x: +%a-%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"-"},{{UNxOP,"+"},
        {VARIDxVAL,"%a"}},{VARIDxVAL,"%b"}}}},
      "Precedence check: unary +, binary -, *")
    checkParse(t, "set %x: -%a-%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"-"},{{UNxOP,"-"},
        {VARIDxVAL,"%a"}},{VARIDxVAL,"%b"}}}},
      "Precedence check: unary -, binary -")
    checkParse(t, "set %x: %a*-%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"*"},{VARIDxVAL,"%a"},
        {{UNxOP,"-"},{VARIDxVAL,"%b"}}}}},
      "Precedence check: *, unary -")
    checkParse(t, "set %x: +%a*%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"*"},{{UNxOP,"+"},
        {VARIDxVAL,"%a"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: unary +, *")
    checkParse(t, "set %x: %a/+%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"/"},{VARIDxVAL,"%a"},
        {{UNxOP,"+"},{VARIDxVAL,"%b"}}}}},
      "Precedence check: /, unary +")
    checkParse(t, "set %x: -%a/%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"/"},{{UNxOP,"-"},
        {VARIDxVAL,"%a"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: unary -, /")
    checkParse(t, "set %x: %a%-%b", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"%"},{VARIDxVAL,"%a"},
        {{UNxOP,"-"},{VARIDxVAL,"%b"}}}}},
      "Precedence check: %, unary -")
    checkParse(t, "set %x: +%a%%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"%"},{{UNxOP,"+"},
        {VARIDxVAL,"%a"}},{VARIDxVAL,"%c"}}}},
      "Precedence check: unary +, %")

    checkParse(t, "set %x: 1&&(2&&3&&4)&&5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"&&"},{{BINxOP,"&&"},
        {NUMLITxVAL,"1"},{{BINxOP,"&&"},{{BINxOP,"&&"},{NUMLITxVAL,"2"},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},{NUMLITxVAL,"5"}}}},
      "Associativity override: &&")
    checkParse(t, "set %x: 1||(2||3||4)||5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"||"},{{BINxOP,"||"},
        {NUMLITxVAL,"1"},{{BINxOP,"||"},{{BINxOP,"||"},{NUMLITxVAL,"2"},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},{NUMLITxVAL,"5"}}}},
      "Associativity override: ||")
    checkParse(t, "set %x: 1==(2==3==4)==5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"=="},{{BINxOP,"=="},
        {NUMLITxVAL,"1"},{{BINxOP,"=="},{{BINxOP,"=="},{NUMLITxVAL,"2"},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},{NUMLITxVAL,"5"}}}},
      "Associativity override: ==")
    checkParse(t, "set %x: 1!=(2!=3!=4)!=5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"!="},{{BINxOP,"!="},
        {NUMLITxVAL,"1"},{{BINxOP,"!="},{{BINxOP,"!="},{NUMLITxVAL,"2"},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},{NUMLITxVAL,"5"}}}},
      "Associativity override: !=")
    checkParse(t, "set %x: 1<(2<3<4)<5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"<"},{{BINxOP,"<"},
        {NUMLITxVAL,"1"},{{BINxOP,"<"},{{BINxOP,"<"},{NUMLITxVAL,"2"},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},{NUMLITxVAL,"5"}}}},
      "Associativity override: <")
    checkParse(t, "set %x: 1<=(2<=3<=4)<=5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"<="},{{BINxOP,"<="},
        {NUMLITxVAL,"1"},{{BINxOP,"<="},{{BINxOP,"<="},{NUMLITxVAL,"2"},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},{NUMLITxVAL,"5"}}}},
      "Associativity override: <=")
    checkParse(t, "set %x: 1>(2>3>4)>5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,">"},{{BINxOP,">"},
        {NUMLITxVAL,"1"},{{BINxOP,">"},{{BINxOP,">"},{NUMLITxVAL,"2"},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},{NUMLITxVAL,"5"}}}},
      "Associativity override: >")
    checkParse(t, "set %x: 1>=(2>=3>=4)>=5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,">="},{{BINxOP,">="},
        {NUMLITxVAL,"1"},{{BINxOP,">="},{{BINxOP,">="},{NUMLITxVAL,"2"},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},{NUMLITxVAL,"5"}}}},
      "Associativity override: >=")
    checkParse(t, "set %x: 1+(2+3+4)+5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},{{BINxOP,"+"},
        {NUMLITxVAL,"1"},{{BINxOP,"+"},{{BINxOP,"+"},{NUMLITxVAL,"2"},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},{NUMLITxVAL,"5"}}}},
      "Associativity override: binary +")
    checkParse(t, "set %x: 1-(2-3-4)-5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"-"},{{BINxOP,"-"},
        {NUMLITxVAL,"1"},{{BINxOP,"-"},{{BINxOP,"-"},{NUMLITxVAL,"2"},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},{NUMLITxVAL,"5"}}}},
      "Associativity override: binary -")
    checkParse(t, "set %x: 1*(2*3*4)*5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"*"},{{BINxOP,"*"},
        {NUMLITxVAL,"1"},{{BINxOP,"*"},{{BINxOP,"*"},{NUMLITxVAL,"2"},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},{NUMLITxVAL,"5"}}}},
      "Associativity override: *")
    checkParse(t, "set %x: 1/(2/3/4)/5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"/"},{{BINxOP,"/"},
        {NUMLITxVAL,"1"},{{BINxOP,"/"},{{BINxOP,"/"},{NUMLITxVAL,"2"},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},{NUMLITxVAL,"5"}}}},
      "Associativity override: /")
    checkParse(t, "set %x: 1%(2%3%4)%5", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"%"},{{BINxOP,"%"},
        {NUMLITxVAL,"1"},{{BINxOP,"%"},{{BINxOP,"%"},{NUMLITxVAL,"2"},
        {NUMLITxVAL,"3"}},{NUMLITxVAL,"4"}}},{NUMLITxVAL,"5"}}}},
      "Associativity override: %")

    checkParse(t, "set %x: (%a==%b)+%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},{{BINxOP,"=="},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence override: ==, binary +")
    checkParse(t, "set %x: (%a!=%b)-%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"-"},{{BINxOP,"!="},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence override: !=, binary -")
    checkParse(t, "set %x: (%a<%b)*%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"*"},{{BINxOP,"<"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence override: <, *")
    checkParse(t, "set %x: (%a<=%b)/%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"/"},{{BINxOP,"<="},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence override: <=, /")
    checkParse(t, "set %x: (%a>%b)%%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"%"},{{BINxOP,">"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence override: >, %")
    checkParse(t, "set %x: %a+(%b>=%c)", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"+"},{VARIDxVAL,"%a"},
        {{BINxOP,">="},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence override: binary +, >=")
    checkParse(t, "set %x: (%a-%b)*%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"*"},{{BINxOP,"-"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence override: binary -, *")
    checkParse(t, "set %x: (%a+%b)%%c", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"%"},{{BINxOP,"+"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}}},
      "Precedence override: binary +, %")
    checkParse(t, "set %x: %a*(%b==%c)", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"*"},{VARIDxVAL,"%a"},
        {{BINxOP,"=="},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence override: *, ==")
    checkParse(t, "set %x: %a/(%b!=%c)", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"/"},{VARIDxVAL,"%a"},
        {{BINxOP,"!="},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence override: /, !=")
    checkParse(t, "set %x: %a%(%b<%c)", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"%"},{VARIDxVAL,"%a"},
        {{BINxOP,"<"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}}}}},
      "Precedence override: %, <")

    checkParse(t, "set %x: +(%a<=%b)", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"+"},{{BINxOP,"<="},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}}},
      "Precedence override: unary +, <=")
    checkParse(t, "set %x: -(%a>%b)", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"-"},{{BINxOP,">"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}}},
      "Precedence override: unary -, >")
    checkParse(t, "set %x: +(%a+%b)", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"+"},{{BINxOP,"+"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}}},
      "Precedence override: unary +, binary +")
    checkParse(t, "set %x: -(%a-%b)", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"-"},{{BINxOP,"-"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}}},
      "Precedence override: unary -, binary -")
    checkParse(t, "set %x: +(%a*%b)", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"+"},{{BINxOP,"*"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}}},
      "Precedence override: unary +, *")
    checkParse(t, "set %x: -(%a/%b)", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"-"},{{BINxOP,"/"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}}},
      "Precedence override: unary -, /")
    checkParse(t, "set %x: +(%a%%b)", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{UNxOP,"+"},{{BINxOP,"%"},
        {VARIDxVAL,"%a"},{VARIDxVAL,"%b"}}}}},
      "Precedence override: unary +, %")
end


function test_expr_complex(t)
    io.write("Test Suite: complex expressions\n")

    checkParse(t, "set %x: ((((((((((((((((((((((((((((((((((((((((%a)))"
      ..")))))))))))))))))))))))))))))))))))))", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{VARIDxVAL,"%a"}}},
      "Complex expression: many parens")
    checkParse(t, "set %x: (((((((((((((((((((((((((((((((((((((((%a))))"
      .."))))))))))))))))))))))))))))))))))))", true, false, nil,
      "Bad complex expression: many parens, mismatch #1")
    checkParse(t, "set %x: ((((((((((((((((((((((((((((((((((((((((%a)))"
      .."))))))))))))))))))))))))))))))))))))", false, true, nil,
      "Bad complex expression: many parens, mismatch #2")
    checkParse(t, "set %x: %a==%b+%c[%x-%y[2]]*+%d!=%e-%f/-%g<%h+%i%+%j", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"<"},{{BINxOP,"!="},
        {{BINxOP,"=="},{VARIDxVAL,"%a"},{{BINxOP,"+"},{VARIDxVAL,"%b"},
        {{BINxOP,"*"},{ARRAYxREF,{VARIDxVAL,"%c"},{{BINxOP,"-"},
        {VARIDxVAL,"%x"},{ARRAYxREF,{VARIDxVAL,"%y"},{NUMLITxVAL,"2"}}}},
        {{UNxOP,"+"},{VARIDxVAL,"%d"}}}}},{{BINxOP,"-"},{VARIDxVAL,"%e"},
        {{BINxOP,"/"},{VARIDxVAL,"%f"},{{UNxOP,"-"},{VARIDxVAL,"%g"}}}}},
        {{BINxOP,"+"},{VARIDxVAL,"%h"},{{BINxOP,"%"},{VARIDxVAL,"%i"},
        {{UNxOP,"+"},{VARIDxVAL,"%j"}}}}}}},
      "Complex expression: misc #1")
    checkParse(t, "set %x: %a==%b+(%c*+(%d!=%e[%z]-%f/-%g)<%h+%i)%+%j", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,"=="},{VARIDxVAL,"%a"},
      {{BINxOP,"+"},{VARIDxVAL,"%b"},{{BINxOP,"%"},{{BINxOP,"<"},
      {{BINxOP,"*"},{VARIDxVAL,"%c"},{{UNxOP,"+"},{{BINxOP,"!="},
      {VARIDxVAL,"%d"},{{BINxOP,"-"},{ARRAYxREF,{VARIDxVAL,"%e"},{VARIDxVAL,"%z"}},
      {{BINxOP,"/"},{VARIDxVAL,"%f"},{{UNxOP,"-"},{VARIDxVAL,"%g"}}}}}}},
      {{BINxOP,"+"},{VARIDxVAL,"%h"},{VARIDxVAL,"%i"}}},{{UNxOP,"+"},
      {VARIDxVAL,"%j"}}}}}}},
      "Complex expression: misc #2")
    checkParse(t, "set %x: %a[%x[%y[%z]]%4]++%b*%c<=%d--%e/%f>%g+-%h%%i>=%j", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,">="},{{BINxOP,">"},
        {{BINxOP,"<="},{{BINxOP,"+"},{ARRAYxREF,{VARIDxVAL,"%a"},
        {{BINxOP,"%"},{ARRAYxREF,{VARIDxVAL,"%x"},{ARRAYxREF,{VARIDxVAL,"%y"},
        {VARIDxVAL,"%z"}}},{NUMLITxVAL,"4"}}},{{BINxOP,"*"},{{UNxOP,"+"},
        {VARIDxVAL,"%b"}},{VARIDxVAL,"%c"}}},{{BINxOP,"-"},{VARIDxVAL,"%d"},
        {{BINxOP,"/"},{{UNxOP,"-"},{VARIDxVAL,"%e"}},{VARIDxVAL,"%f"}}}},
        {{BINxOP,"+"},{VARIDxVAL,"%g"},{{BINxOP,"%"},{{UNxOP,"-"},
        {VARIDxVAL,"%h"}},{VARIDxVAL,"%i"}}}},{VARIDxVAL,"%j"}}}},
      "Complex expression: misc #3")
    checkParse(t, "set %x: %a++(%b*%c<=%d)--%e/(%f>%g+-%h%%i)>=%j[-%z]", true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{{BINxOP,">="},
        {{BINxOP,"-"},{{BINxOP,"+"},{VARIDxVAL,"%a"},{{UNxOP,"+"},
        {{BINxOP,"<="},{{BINxOP,"*"},{VARIDxVAL,"%b"},{VARIDxVAL,"%c"}},
        {VARIDxVAL,"%d"}}}},{{BINxOP,"/"},{{UNxOP,"-"},
        {VARIDxVAL,"%e"}},{{BINxOP,">"},{VARIDxVAL,"%f"},{{BINxOP,"+"},
        {VARIDxVAL,"%g"},{{BINxOP,"%"},{{UNxOP,"-"},{VARIDxVAL,"%h"}},
        {VARIDxVAL,"%i"}}}}}},{ARRAYxREF,{VARIDxVAL,"%j"},{{UNxOP,"-"},
        {VARIDxVAL,"%z"}}}}}},
      "Complex expression: misc #4")
    checkParse(t, "set %x: %a==%b+%c*+%d!=%e-/-%g<%h+%i%+%j",
      false, false, nil,
      "Bad complex expression: misc #1")
    checkParse(t, "set %x: %a==%b+(%c*+(%d!=%e-%f/-%g)<%h+%i)%+",
      false, true, nil,
      "Bad complex expression: misc #2")
    checkParse(t, "set %x: %a++%b*%c<=%d--%e %x/%f>%g+-%h%%i>=%j",
      false, false, nil,
      "Bad complex expression: misc #3")
    checkParse(t, "set %x: %a++%b*%c<=%d)--%e/(%f>%g+-%h%%i)>=%j",
      true, false, nil,
      "Bad complex expression: misc #4")

    checkParse(t, "set %x: ((%a[(%b[%c[(%d[((%e[%f]))])]])]))", true, true,
        {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%x"},{ARRAYxREF,
          {VARIDxVAL,"%a"},{ARRAYxREF,{VARIDxVAL,"%b"},{ARRAYxREF,
          {VARIDxVAL,"%c"},{ARRAYxREF,{VARIDxVAL,"%d"},{ARRAYxREF,
          {VARIDxVAL,"%e"},{VARIDxVAL,"%f"}}}}}}}},
      "Complex expression: many parens/brackets")
    checkParse(t, "set %x: ((%a[(%b[%c[(%d[((%e[%f]))]])])]))", false, false, nil,
      "Bad complex expression: mismatched parens/brackets")
end


function test_sub_stmt(t)
    io.write("Test Suite: sub statements\n")

    checkParse(t, "sub &s end", true, true,
      {STMTxLIST,{SUBxSTMT,"&s",{STMTxLIST}}},
      "Sub statement: empty body")
    checkParse(t, "sub end", false, false, nil,
      "Bad sub statement: missing name")
    checkParse(t, "sub %s end", false, false, nil,
      "Bad sub statement: VariableIdentifier for name")
    checkParse(t, "sub &s end end", true, false, nil,
      "Bad sub statement: extra end")
    checkParse(t, "sub &s &s end", false, false, nil,
      "Bad sub statement: extra name")
    checkParse(t, "sub (&s) end", false, false, nil,
      "Bad sub statement: name in parentheses")
    checkParse(t, "sub &s cr end", true, true,
      {STMTxLIST,{SUBxSTMT,"&s",{STMTxLIST,{CRxSTMT}}}},
      "Sub statement: 1-statement body #1")
    checkParse(t, "sub &s print 'x' end", true, true,
      {STMTxLIST,{SUBxSTMT,"&s",{STMTxLIST,{PRINTxSTMT,
        {STRLITxVAL,"'x'"}}}}},
      "Sub statement: 1-statment body #2")
    checkParse(t, "sub &s input %x print %x end", true, true,
      {STMTxLIST,{SUBxSTMT,"&s",{STMTxLIST,{INPUTxSTMT,
        {VARIDxVAL,"%x"}},{PRINTxSTMT,{VARIDxVAL,"%x"}}}}},
      "Sub statement: 2-statment body")
    checkParse(t, "sub &sss cr cr cr cr cr cr cr end", true, true,
      {STMTxLIST,{SUBxSTMT,"&sss",{STMTxLIST,{CRxSTMT},{CRxSTMT},
        {CRxSTMT},{CRxSTMT},{CRxSTMT},{CRxSTMT},{CRxSTMT}}}},
      "Sub statement: longer body")
    checkParse(t, "sub &s sub &t sub &u cr end end sub &v cr end end",
      true, true,
      {STMTxLIST,{SUBxSTMT,"&s",{STMTxLIST,{SUBxSTMT,"&t",{STMTxLIST,
        {SUBxSTMT,"&u",{STMTxLIST,{CRxSTMT}}}}},{SUBxSTMT,"&v",
        {STMTxLIST,{CRxSTMT}}}}}},
      "Sub statement: nested sub statements")
end


function test_call_stmt(t)
    io.write("Test Suite: call statements\n")

    checkParse(t, "call &s", true, true,
      {STMTxLIST,{CALLxSTMT,"&s"}},
      "Call statement #1")
    checkParse(t, "call &sssssssssssssssssssssssssssssssss", true, true,
      {STMTxLIST,{CALLxSTMT,"&sssssssssssssssssssssssssssssssss"}},
      "Call statement #2")
    checkParse(t, "call &sss call &ttt", true, true,
      {STMTxLIST,{CALLxSTMT,"&sss"},{CALLxSTMT,"&ttt"}},
      "Two call statements")
    checkParse(t, "call %sss", false, false, nil,
      "Bad call statement: VariableIdentifier for name")
    checkParse(t, "call call %sss", false, false, nil,
      "Bad call statement: extra call")
    checkParse(t, "call %sss %sss", false, false, nil,
      "Bad call statement: extra name")
end


function test_if_stmt(t)
    io.write("Test Suite: if statements\n")

    checkParse(t, "if %a cr end", true, true,
      {STMTxLIST,{IFxSTMT,{VARIDxVAL,"%a"},{STMTxLIST,{CRxSTMT}}}},
      "If statement: simple")
    checkParse(t, "if %a end", true, true,
      {STMTxLIST,{IFxSTMT,{VARIDxVAL,"%a"},{STMTxLIST}}},
      "If statement: empty statement list")
    checkParse(t, "if %a cr else cr cr end", true, true,
      {STMTxLIST,{IFxSTMT,{VARIDxVAL,"%a"},{STMTxLIST,{CRxSTMT}},{STMTxLIST,
        {CRxSTMT},{CRxSTMT}}}},
      "If statement: else")
    checkParse(t, "if %a cr elseif %b cr cr else cr cr cr end", true, true,
      {STMTxLIST,{IFxSTMT,{VARIDxVAL,"%a"},{STMTxLIST,{CRxSTMT}},
        {VARIDxVAL,"%b"},{STMTxLIST,{CRxSTMT},{CRxSTMT}},{STMTxLIST,
        {CRxSTMT},{CRxSTMT},{CRxSTMT}}}},
      "If statement: elseif, else")
    checkParse(t, "if %a cr elseif %b cr cr elseif %c cr cr cr elseif %d "
      .."cr cr cr cr elseif %e cr cr cr cr cr else cr cr cr cr cr cr "
      .."end", true, true,
      {STMTxLIST,{IFxSTMT,{VARIDxVAL,"%a"},{STMTxLIST,{CRxSTMT}},
        {VARIDxVAL,"%b"},{STMTxLIST,{CRxSTMT},{CRxSTMT}},{VARIDxVAL,"%c"},
        {STMTxLIST,{CRxSTMT},{CRxSTMT},{CRxSTMT}},{VARIDxVAL,"%d"},
        {STMTxLIST,{CRxSTMT},{CRxSTMT},{CRxSTMT},{CRxSTMT}},
        {VARIDxVAL,"%e"},{STMTxLIST,{CRxSTMT},{CRxSTMT},{CRxSTMT},{CRxSTMT},
        {CRxSTMT}},{STMTxLIST,{CRxSTMT},{CRxSTMT},{CRxSTMT},{CRxSTMT},
        {CRxSTMT},{CRxSTMT}}}},
      "If statement: multiple elseif, else")
    checkParse(t, "if %a cr elseif %b cr cr elseif %c cr cr cr elseif %d "
      .."cr cr cr cr elseif %e cr cr cr cr cr end", true, true,
      {STMTxLIST,{IFxSTMT,{VARIDxVAL,"%a"},{STMTxLIST,{CRxSTMT}},
        {VARIDxVAL,"%b"},{STMTxLIST,{CRxSTMT},{CRxSTMT}},{VARIDxVAL,"%c"},
        {STMTxLIST,{CRxSTMT},{CRxSTMT},{CRxSTMT}},{VARIDxVAL,"%d"},
        {STMTxLIST,{CRxSTMT},{CRxSTMT},{CRxSTMT},{CRxSTMT}},
        {VARIDxVAL,"%e"},{STMTxLIST,{CRxSTMT},{CRxSTMT},{CRxSTMT},{CRxSTMT},
        {CRxSTMT}}}},
      "If statement: multiple elseif, no else")
    checkParse(t, "if %a elseif %b elseif %c elseif %d elseif %e else end",
      true, true,
      {STMTxLIST,{IFxSTMT,{VARIDxVAL,"%a"},{STMTxLIST},{VARIDxVAL,"%b"},
        {STMTxLIST},{VARIDxVAL,"%c"},{STMTxLIST},{VARIDxVAL,"%d"},{STMTxLIST},
        {VARIDxVAL,"%e"},{STMTxLIST},{STMTxLIST}}},
      "If statement: multiple elseif, else, empty statement lists")
    checkParse(t, "if %a if %b cr else cr end elseif %c if %d cr "
      .."else cr end else if %e cr else cr end end", true, true,
      {STMTxLIST,{IFxSTMT,{VARIDxVAL,"%a"},{STMTxLIST,{IFxSTMT,{VARIDxVAL,"%b"},
        {STMTxLIST,{CRxSTMT}},{STMTxLIST,{CRxSTMT}}}},{VARIDxVAL,"%c"},
        {STMTxLIST,{IFxSTMT,{VARIDxVAL,"%d"},{STMTxLIST,{CRxSTMT}},
        {STMTxLIST,{CRxSTMT}}}},{STMTxLIST,{IFxSTMT,{VARIDxVAL,"%e"},
        {STMTxLIST,{CRxSTMT}},{STMTxLIST,{CRxSTMT}}}}}},
      "If statement: nested #1")
    checkParse(t, "if %a if %b if %c if %d if %e if %f if %g cr end end end "
      .."end end end end", true, true,
      {STMTxLIST,{IFxSTMT,{VARIDxVAL,"%a"},{STMTxLIST,{IFxSTMT,{VARIDxVAL,"%b"},
        {STMTxLIST,{IFxSTMT,{VARIDxVAL,"%c"},{STMTxLIST,{IFxSTMT,
        {VARIDxVAL,"%d"},{STMTxLIST,{IFxSTMT,{VARIDxVAL,"%e"},{STMTxLIST,
        {IFxSTMT,{VARIDxVAL,"%f"},{STMTxLIST,{IFxSTMT,{VARIDxVAL,"%g"},
        {STMTxLIST,{CRxSTMT}}}}}}}}}}}}}}}},
      "If statement: nested #2")

    checkParse(t, "if cr end", false, false, nil,
      "Bad if statement: no expr")
    checkParse(t, "if %a cr", false, true, nil,
      "Bad if statement: no end")
    checkParse(t, "if %a %b cr end", false, false, nil,
      "Bad if statement: 2 expressions")
    checkParse(t, "if %a cr else cr elseif %b cr", false, false, nil,
      "Bad if statement: else before elseif")
    checkParse(t, "if %a cr end end", true, false, nil,
      "Bad if statement: followed by end")
end


function test_while_stmt(t)
    io.write("Test Suite: while statements\n")

    checkParse(t, "while %a cr end", true, true,
      {STMTxLIST,{WHILExSTMT,{VARIDxVAL,"%a"},{STMTxLIST,{CRxSTMT}}}},
      "While statement: simple")
    checkParse(t, "while %a cr cr cr cr cr cr cr cr cr cr end", true, true,
      {STMTxLIST,{WHILExSTMT,{VARIDxVAL,"%a"},{STMTxLIST,{CRxSTMT},
        {CRxSTMT},{CRxSTMT},{CRxSTMT},{CRxSTMT},{CRxSTMT},{CRxSTMT},
        {CRxSTMT},{CRxSTMT},{CRxSTMT}}}},
      "While statement: longer statement list")
    checkParse(t, "while %a end", true, true,
      {STMTxLIST,{WHILExSTMT,{VARIDxVAL,"%a"},{STMTxLIST}}},
      "While statement: empty statement list")
    checkParse(t, "while %a while %b while %c while %d while %e while %f "
      .."while %g cr end end end end end end end", true, true,
      {STMTxLIST,{WHILExSTMT,{VARIDxVAL,"%a"},{STMTxLIST,{WHILExSTMT,
        {VARIDxVAL,"%b"},{STMTxLIST,{WHILExSTMT,{VARIDxVAL,"%c"},{STMTxLIST,
        {WHILExSTMT,{VARIDxVAL,"%d"},{STMTxLIST,{WHILExSTMT,{VARIDxVAL,"%e"},
        {STMTxLIST,{WHILExSTMT,{VARIDxVAL,"%f"},{STMTxLIST,{WHILExSTMT,
        {VARIDxVAL,"%g"},{STMTxLIST,{CRxSTMT}}}}}}}}}}}}}}}},
      "While statement: nested")
    checkParse(t, "while %a if %b while %c end elseif %d while %e if %f end "
      .."end elseif %g while %h end else while %i end end end", true, true,
      {STMTxLIST,{WHILExSTMT,{VARIDxVAL,"%a"},{STMTxLIST,{IFxSTMT,
        {VARIDxVAL,"%b"},{STMTxLIST,{WHILExSTMT,{VARIDxVAL,"%c"},{STMTxLIST}}},
        {VARIDxVAL,"%d"},{STMTxLIST,{WHILExSTMT,{VARIDxVAL,"%e"},{STMTxLIST,
        {IFxSTMT,{VARIDxVAL,"%f"},{STMTxLIST}}}}},{VARIDxVAL,"%g"},{STMTxLIST,
        {WHILExSTMT,{VARIDxVAL,"%h"},{STMTxLIST}}},{STMTxLIST,{WHILExSTMT,
        {VARIDxVAL,"%i"},{STMTxLIST}}}}}}},
      "While statement: nested while & if")

    checkParse(t, "while cr end", false, false, nil,
      "Bad while statement: no expr")
    checkParse(t, "while %a cr", false, true, nil,
      "Bad while statement: no end")
    checkParse(t, "while %a cr else cr end ", false, false, nil,
      "Bad while statement: has else")
    checkParse(t, "while %a cr end end", true, false, nil,
      "Bad while statement: followed by end")
end


function test_prog(t)
    io.write("Test Suite: complete programs\n")

    -- Example #1 from Assignment 4 description
    checkParse(t,
      [[#
        # Kanchil Example #1
        # By GGC 2017-02-22
        set %k: 3
        print %k cr
      ]], true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%k"},{NUMLITxVAL,"3"}},{PRINTxSTMT,
        {VARIDxVAL,"%k"}},{CRxSTMT}},
      "Program: Example #1 from Assignment 4 description")

    -- Example #2 from Assignment 4 description
    checkParse(t,
      [[#
        # Kanchil Example: Printing Fibonacci Numbers
        # Glenn G. Chappell
        # 13 Feb 2017


        # Subroutine &fibo
        # Given %k, set %fibk to F(%k),
        # where F(n) = nth Fibonacci no.
        sub &fibo
            set %a: 0  # Consecutive Fibos
            set %b: 1
            set %i: 0  # Loop counter
            while %i < %k
                set %c: %a+%b  # Advance
                set %a: %b
                set %b: %c
                set %i: %i+1   # ++counter
            end
            set %fibk: %a  # Result
        end


        # Get number of Fibos to output
        print "How many Fibos to print: "
        input %n
        cr cr

        # Print requested number of Fibos
        set %j: 0  # Loop counter
        while %j < %n
            set %k: %j
            call &fibo
            print %j
            print "  "
            print %fibk cr
        end
      ]], true, true,
      {STMTxLIST, {SUBxSTMT, "&fibo", {STMTxLIST, {SETxSTMT,
        {VARIDxVAL, "%a"}, {NUMLITxVAL, "0"}}, {SETxSTMT,
        {VARIDxVAL, "%b"}, {NUMLITxVAL, "1"}}, {SETxSTMT,
        {VARIDxVAL, "%i"}, {NUMLITxVAL, "0"}}, {WHILExSTMT,
        {{BINxOP, "<"}, {VARIDxVAL, "%i"}, {VARIDxVAL, "%k"}},
        {STMTxLIST, {SETxSTMT, {VARIDxVAL, "%c"}, {{BINxOP, "+"},
        {VARIDxVAL, "%a"}, {VARIDxVAL, "%b"}}}, {SETxSTMT,
        {VARIDxVAL, "%a"}, {VARIDxVAL, "%b"}}, {SETxSTMT,
        {VARIDxVAL, "%b"}, {VARIDxVAL, "%c"}}, {SETxSTMT,
        {VARIDxVAL, "%i"}, {{BINxOP, "+"}, {VARIDxVAL, "%i"},
        {NUMLITxVAL, "1"}}}}}, {SETxSTMT, {VARIDxVAL, "%fibk"},
        {VARIDxVAL, "%a"}}}}, {PRINTxSTMT,
        {STRLITxVAL, '"How many Fibos to print: "'}}, {INPUTxSTMT,
        {VARIDxVAL, "%n"}}, {CRxSTMT}, {CRxSTMT}, {SETxSTMT,
        {VARIDxVAL, "%j"}, {NUMLITxVAL, "0"}}, {WHILExSTMT,
        {{BINxOP, "<"}, {VARIDxVAL, "%j"}, {VARIDxVAL, "%n"}},
        {STMTxLIST, {SETxSTMT, {VARIDxVAL, "%k"}, {VARIDxVAL, "%j"}},
        {CALLxSTMT, "&fibo"}, {PRINTxSTMT, {VARIDxVAL, "%j"}},
        {PRINTxSTMT, {STRLITxVAL, '"  "'}}, {PRINTxSTMT,
        {VARIDxVAL, "%fibk"}}, {CRxSTMT}}}},
      "Program: Example #2 from Assignment 4 description")

    -- Input number, print its square
    checkParse(t,
      [[#
        print 'Type a number: '
        input %n
        cr cr
        print 'You typed: '
        print %a cr
        print 'Its square is: '
        print %a*%a cr
        cr
      ]], true, true,
      {STMTxLIST,{PRINTxSTMT,{STRLITxVAL,"'Type a number: '"}},
        {INPUTxSTMT,{VARIDxVAL,"%n"}},{CRxSTMT},{CRxSTMT},{PRINTxSTMT,
        {STRLITxVAL,"'You typed: '"}},{PRINTxSTMT,{VARIDxVAL,"%a"}},
        {CRxSTMT},{PRINTxSTMT,{STRLITxVAL,"'Its square is: '"}},
        {PRINTxSTMT,{{BINxOP,"*"},{VARIDxVAL,"%a"},{VARIDxVAL,"%a"}}},{CRxSTMT},
        {CRxSTMT}},
      "Program: Input number, print its square")

    -- Input numbers, stop at sentinel, print even/odd
    checkParse(t,
      [[#
        set %continue: 1
        while %continue
            print 'Type a number (0 to end): '
            input %n
            cr cr
            if %n == 0
                set %continue: 0
            else
                print 'The number '
                print %n
                print ' is '
                if %n % 2 == 0
                    print 'even'
                else
                    print 'odd'
                end
                cr cr
            end
        end
        print 'Bye!' cr
        cr
      ]], true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%continue"},{NUMLITxVAL,"1"}},
        {WHILExSTMT,{VARIDxVAL,"%continue"},{STMTxLIST,{PRINTxSTMT,
        {STRLITxVAL,"'Type a number (0 to end): '"}},{INPUTxSTMT,
        {VARIDxVAL,"%n"}},{CRxSTMT},{CRxSTMT},{IFxSTMT,{{BINxOP,"=="},
        {VARIDxVAL,"%n"},{NUMLITxVAL,"0"}},{STMTxLIST,{SETxSTMT,
        {VARIDxVAL,"%continue"},{NUMLITxVAL,"0"}}},{STMTxLIST,{PRINTxSTMT,
        {STRLITxVAL,"'The number '"}},{PRINTxSTMT,{VARIDxVAL,"%n"}},
        {PRINTxSTMT,{STRLITxVAL,"' is '"}},{IFxSTMT,{{BINxOP,"=="},
        {{BINxOP,"%"},{VARIDxVAL,"%n"},{NUMLITxVAL,"2"}},{NUMLITxVAL,"0"}},
        {STMTxLIST,{PRINTxSTMT,{STRLITxVAL,"'even'"}}},{STMTxLIST,
        {PRINTxSTMT,{STRLITxVAL,"'odd'"}}}},{CRxSTMT},{CRxSTMT}}}}},
        {PRINTxSTMT,{STRLITxVAL,"'Bye!'"}},{CRxSTMT},{CRxSTMT}},
      "Program: Input numbers, stop at sentinel, print even/odd")

    -- Input 10 numbers, print them in reverse order
    checkParse(t,
      [[#
        set %howMany: 10  # How many numbers to input
        print 'I will ask you for '
        print %howMany
        print ' values (numbers).' cr
        print 'Then I will print them in reverse order.' cr
        cr
        set %i: 1
        while %i <= %howMany  # Input loop
            print 'Type value #'
            print %i
            print ': '
            input %v[%i]
            cr cr
            set %i: %i+1
        end
        print '----------------------------------------' cr
        cr
        print 'Here are the values, in reverse order:' cr
        set %i: %howMany
        while %i > 0  # Output loop
            print 'Value #'
            print %i
            print ': '
            print %v[%i]
            cr
            set %i: %i-1
        end
        cr
      ]], true, true,
      {STMTxLIST,{SETxSTMT,{VARIDxVAL,"%howMany"},{NUMLITxVAL,"10"}},
        {PRINTxSTMT,{STRLITxVAL,"'I will ask you for '"}},{PRINTxSTMT,
        {VARIDxVAL,"%howMany"}},{PRINTxSTMT,
        {STRLITxVAL,"' values (numbers).'"}},{CRxSTMT},{PRINTxSTMT,
        {STRLITxVAL,"'Then I will print them in reverse order.'"}},
        {CRxSTMT},{CRxSTMT},{SETxSTMT,{VARIDxVAL,"%i"},{NUMLITxVAL,"1"}},
        {WHILExSTMT,{{BINxOP,"<="},{VARIDxVAL,"%i"},{VARIDxVAL,"%howMany"}},
        {STMTxLIST,{PRINTxSTMT,{STRLITxVAL,"'Type value #'"}},
        {PRINTxSTMT,{VARIDxVAL,"%i"}},{PRINTxSTMT,{STRLITxVAL,"': '"}},
        {INPUTxSTMT,{ARRAYxREF,{VARIDxVAL,"%v"},{VARIDxVAL,"%i"}}},{CRxSTMT},
        {CRxSTMT},{SETxSTMT,{VARIDxVAL,"%i"},{{BINxOP,"+"},{VARIDxVAL,"%i"},
        {NUMLITxVAL,"1"}}}}},{PRINTxSTMT,
        {STRLITxVAL,"'----------------------------------------'"}},
        {CRxSTMT},{CRxSTMT},{PRINTxSTMT,
        {STRLITxVAL,"'Here are the values, in reverse order:'"}},
        {CRxSTMT},{SETxSTMT,{VARIDxVAL,"%i"},{VARIDxVAL,"%howMany"}},
        {WHILExSTMT,{{BINxOP,">"},{VARIDxVAL,"%i"},{NUMLITxVAL,"0"}},
        {STMTxLIST,{PRINTxSTMT,{STRLITxVAL,"'Value #'"}},{PRINTxSTMT,
        {VARIDxVAL,"%i"}},{PRINTxSTMT,{STRLITxVAL,"': '"}},{PRINTxSTMT,
        {ARRAYxREF,{VARIDxVAL,"%v"},{VARIDxVAL,"%i"}}},{CRxSTMT},{SETxSTMT,
        {VARIDxVAL,"%i"},{{BINxOP,"-"},{VARIDxVAL,"%i"},{NUMLITxVAL,"1"}}}}},
        {CRxSTMT}},
      "Program: Input 10 numbers, print them in reverse order")

    -- Long program
    howmany = 50
    progpiece = "print 42\n"
    prog = progpiece:rep(howmany)
    ast = {STMTxLIST}
    astpiece = {PRINTxSTMT,{NUMLITxVAL,"42"}}
    for i = 1, howmany do
        table.insert(ast, astpiece)
    end
    checkParse(t, prog, true, true,
      ast,
      "Program: Long program")

    -- Very long program
    howmany = 10000
    progpiece = "input %x print %x cr\n"
    prog = progpiece:rep(howmany)
    ast = {STMTxLIST}
    astpiece1 = {INPUTxSTMT,{VARIDxVAL,"%x"}}
    astpiece2 = {PRINTxSTMT,{VARIDxVAL,"%x"}}
    astpiece3 = {CRxSTMT}
    for i = 1, howmany do
        table.insert(ast, astpiece1)
        table.insert(ast, astpiece2)
        table.insert(ast, astpiece3)
    end
    checkParse(t, prog, true, true,
      ast,
      "Program: Very long program")
end


function test_parseit(t)
    io.write("TEST SUITES FOR MODULE parseit\n")
    test_simple(t)
    test_cr_stmt(t)
    test_print_stmt(t)
    test_input_stmt(t)
    test_set_stmt(t)
    test_expr_simple(t)
    test_expr_prec_assoc(t)
    test_expr_complex(t)
    test_sub_stmt(t)
    test_call_stmt(t)
    test_if_stmt(t)
    test_while_stmt(t)
    test_prog(t)
end


-- *********************************************************************
-- Main Program
-- *********************************************************************


test_parseit(tester)
io.write("\n")
if tester:allPassed() then
    io.write("All tests successful\n")
else
    io.write("Tests ********** UNSUCCESSFUL **********\n")
    io.write("\n")
    io.write("**************************************************\n")
    io.write("* This test program is configured to execute all *\n")
    io.write("* tests, reporting success/failure for each. To  *\n")
    io.write("* make it exit after the first failing test, set *\n")
    io.write("* variable                                       *\n")
    io.write("*                                                *\n")
    io.write("*   EXIT_ON_FIRST_FAILURE                        *\n")
    io.write("*                                                *\n")
    io.write("* to true, near the start of the test program.   *\n")
    io.write("**************************************************\n")
end

-- Wait for user
io.write("\nPress ENTER to quit ")
io.read("*l")

