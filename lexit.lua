-- lexit.lua
-- Sam Erie
-- CSCE331
-- Chappell
-- lexer for assignment 3
-- first module of Kanchil interpreter
-- passes all lexit_test.lua tests
-- 2/18/17

lexit = {}		--module to export

-- *** exports *** ---

	lexit.KEY = 1
	lexit.VARID = 2
	lexit.SUBID = 3
	lexit.NUMLIT = 4
	lexit.STRLIT = 5
	lexit.OP = 6
	lexit.PUNCT = 7
	lexit.MAL = 8

	lexit.catnames = 
	{	
		"Keyword",
		"VariableIdentifier",
		"SubroutineIdentifier",
		"NumericLiteral",
		"StringLiteral",
		"Operator",
		"Punctuation",
		"Malformed"
	}

	local binaryOnly = false	--tells lexer to ignore unary operators (force them to be binary)

	function lexit.preferOp()
		binaryOnly = true
	end
---------------------------------------

-- *** parse functions *** ---

	local function empty(c)
		return ( c:len() ~= 1 )
	end

	local function legal(c)
		if empty(c) then
			return false
		end

		return ( c >= " " and c <= "~" ) 
	end

	local function digit(c)
		if empty(c) then
			return false
		end

		return ( c >= "0" and c <= "9" )
	end

	local function letter(c)
		if empty(c) then
			return false
		end

		return ( (c >= "a" and c <= "z") or (c >= "A" and c <= "Z") )
	end

	local function whiteSpace(c)
		if empty(c) then
			return false
		end

		return ( c == " " or c == "\t" or c == "\n" or c == "\r" or c == "\f" )
	end
----------------------------------------

--- *** main function *** ---

	function lexit.lex(raw)
		
		--state machine variables--

		local pos	--position in raw program
		local state	--state of machine
		local str 	--return string
		local char 	--current character
		local cat 	--return category
		local userType = false	--flag for variables or subroutines
		local delim		--string begin quote ' or " to match end

		--state handler table index --state handler below
		local DONE = 0
		local START = 1
		local WORD = 2	
		local NUMBER = 3
		local OPERATOR = 4
		local STRING = 5

		--tables to match operators and keys
		local ops = { "||","!","==","!=","<","<=",">",">=","*","/","[","]",":", "%", "+", "-" }	
		local key = {"call","cr","else","elseif","end","false","if","input","print","set","sub","true","while"}

		--state machine functions--

		local function matchOp(ch, idx)
			for i=1, #ops do
				if ops[i]:len() >- idx then
					if ops[i]:sub(idx,idx) == ch then
						return true
					end
				end
			end

			return false  
		end

		local function isOp(s)
			for i=1, #ops do
				if s == ops[i] then
					return true
				end
			end

			return false
		end

		local function isKey(s)
			for i = 1, #key do
				if s == key[i] then
					return true
				end
			end

			return false
		end

		local function hasExp(c)

			for i = 1, c:len() do
				e = c:sub(i,i)
				if e == "e" or e == "E" then
					return true
				end
			end 

			return false

		end

		local function getChar()
			return raw:sub(pos,pos)
		end

		local function lookAhead(n)
			return raw:sub(pos+n, pos+n)
		end

		local function skipChar()
			pos = pos + 1
		end

		local function addChar()
			str = str .. getChar()
			skipChar()
		end

		local function skipWhite()
			if not (pos > raw:len()) then

				while whiteSpace(getChar()) do
					skipChar()
				end
				char = getChar()
				if char == "#" then
					while char ~= "\n" and char ~= "\f" and not empty(char) do 	--skip comments until newline or eof
						skipChar()
						char = getChar()
					end
					skipChar()
					skipWhite()	--incase of whitespace or more comments on the line after comment line
				end
			end
		end


		--state handler functions--

		local function handle_DONE()
			--not supposed to actually get here
			io.write("Program Error")
			assert(0)
		end

		local function handle_START()
			-- start parse
			if not legal(char) then
				addChar()
				cat = lexit.MAL
				state = DONE
			elseif char == "%" and not binaryOnly then 
				addChar()
				userType = true
				cat = lexit.VARID
				state = WORD
			elseif char == "&" then
				addChar()
				userType = true
				cat = lexit.SUBID
				state = WORD
			elseif letter(char) then
				addChar()
				state = WORD
			elseif digit(char) or char == "+" or char == "-" then	
				addChar()
				state = NUMBER	
			elseif char == '"' or char == "'" then
				addChar()
				delim = char
				state = STRING
			elseif matchOp(char, 1) then
				addChar()
				state = OPERATOR
			else
				addChar()
				cat = lexit.PUNCT
				state = DONE
			end
		end

		local function handle_WORD()
					
			if not userType then
				cat = lexit.MAL --malformed if not keyword
			end

			if letter(char) then --for keyword
				addChar()
			elseif userType and (letter(char) or (digit(char) and str:len() ~= 1) or char == "_") then	--for user types
				addChar()
			else 

				if isKey(str) then 
					cat = lexit.KEY
				end

				state = DONE
				if str == "%" then
					cat = lexit.OP
				end
				if str == "&" then
					if char == "&" then
						addChar()
						cat = lexit.OP
					else
						cat = lexit.PUNCT
					end
				end
				
				userType = false	--reset flag when usertype done
			end	
		end

		local function handle_NUMBER()
			cat = lexit.NUMLIT

			if (str == "+" or str == "-") and ( binaryOnly or not digit(char)) then
				cat = lexit.OP
				state = DONE		
			elseif digit(char) then
				addChar()
			elseif (char == "e" or char == "E") and str ~= "+" and str ~= "-" and not hasExp(str) then	--this got pretty heavy, I probably should have just made handle_EXP
				if digit(lookAhead(1)) or ( lookAhead(1) == "+" and digit(lookAhead(2)) ) then
					--then it is a proper exponent and START can handle it 
					addChar() --adds e or E
					state = START
				else
					state = DONE 	--this is case with numlit followed by malform - incorrect exponent
				end
			else 
				state = DONE
			end

		end

		local function handle_OPERATOR()
			cat = lexit.OP
			if matchOp(char, 2) then
				if isOp(str .. char) then
					addChar()
				end
			end

			if not isOp(str) then	
				cat = lexit.PUNCT
			end

			state = DONE
		end

		local function handle_STRING()
			cat = lexit.STRLIT

			addChar()

			if char == delim then
				state = DONE
			end

			if pos > raw:len() and state ~= DONE then	--eof
				cat = lexit.MAL
				state = DONE
			end
		end

		--state handler table--

		local handler = 
		{
			[DONE] = handle_DONE,
			[START] = handle_START,
			[WORD] = handle_WORD,
			[NUMBER] = handle_NUMBER,
			[OPERATOR] = handle_OPERATOR,
			[STRING] = handle_STRING

		}


	--- *** main iterator function *** ---

		local function iter(d1, d2)

			if pos > raw:len() then
				binaryOnly = false	--reset flag every iteration
				return nil, nil
			end

			str = ""
			state = START
			while state ~= DONE do
				char = getChar()
				handler[state] ()		
			end
			
	
			skipWhite()
			binaryOnly = false	--reset flag every iteration
			return str, cat
		end

		--begin iteration of lexeme
		pos = 1
		skipWhite()
	
		return iter, nil, nil
	end
------------------------------------

return lexit 	--export module