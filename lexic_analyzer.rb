$LOAD_PATH << '.'

require 'set'
require 'constants_lexic'

class Lexic_Analyzer

	# attr_accessor :states, :final_states
	SIZEBYTES = 1

	def get_next_token

		name_lexeme = ""
		actual_state = 0 
		last_state = 0
		has_error = 0
		
		
		while true
			char = IO.read(@file,SIZEBYTES,@offset)

			if char.nil? and name_lexeme.size == 0
				
				actual_state = nil

				last_state = 10	

			else
				if char == "\n"
					@line_error += 1
					@columns_error = 0
				end
				
				type_char = TYPE::get_type(char)

				last_state = actual_state

				actual_state = @states[actual_state][type_char]

				@offset += 1
			end

			if actual_state.nil?

				name_lexeme = name_lexeme.strip
				#print "#{name_lexeme} #{actual_state.nil?} ** #{last_state}\n"
				if @final_states.has_key?(last_state)
					@offset -= 1
					if name_lexeme.size > 0 and $symbol_table.has_key?(name_lexeme) == false and @final_states[last_state] == TOKENS::ID 
						
						$symbol_table[name_lexeme] = Element.new :token => @final_states[last_state], :lexeme => name_lexeme	
					
					end
					if $symbol_table.has_key?(name_lexeme) == true
						return  $symbol_table[name_lexeme]
					else
						return Element.new :token => @final_states[last_state], :lexeme => name_lexeme
					end
				else
					@error_handling.lexic_error(char,"Invalid lexeme",@line_error,@columns_error)
				end	
				
				break
			end

			if char.nil? == false
				name_lexeme += char
			end

			@columns_error += 1

			

		end

	end

	def initialize(file)

		@offset = 0

		@file = file
		
		@line_error = 1

		@columns_error = 0

		@error_handling = Error_handle.new

		@states = []


		#Lexic DFA's final states 
		@final_states = {1 => TOKENS::OPM , 2 => TOKENS::NUM, 4 => TOKENS::NUM,
						 6 => TOKENS::LITERAL , 8 => TOKENS::COMENTARIO,
						 9 => TOKENS::ID, 10 => TOKENS::EOF, 11 => TOKENS::OPR,
						 12 => TOKENS::OPR, 13 => TOKENS::RCB, 14 => TOKENS::OPR,
						 15 => TOKENS::OPM, 16 => TOKENS::AB_P, 17 => TOKENS::FC_P,
						 18 => TOKENS::PT_V, 21 => TOKENS::NUM }


		# state 0 of the DFA				
		hash = { "+" => 1 ,"-" => 1, "\"" => 5, "{" => 7, TYPE::LETTER => 9,
				 "<" => 11, ">" => 14, "=" => 12, "*" => 15, "/" => 15,
				 "(" => 16, ")" => 17, ";" => 18, TYPE::DIGIT => 2, "\t" => 0,
				 "\n" => 0, " " => 0, TYPE::EOF => 10}
		@states.push(hash)

		# state 1 of the DFA
		hash = Hash.new
		hash = { TYPE::DIGIT => 2 }
		@states.push(hash)

		# state 2 of the DFA
		hash = Hash.new
		hash = { TYPE::DIGIT => 2, "." => 3, "E" => 19}
		@states.push(hash)

		# state 3 of the DFA
		hash = Hash.new
		hash = { TYPE::DIGIT => 4}
		@states.push(hash)

		# state 4 of the DFA
		hash = Hash.new
		hash = { TYPE::DIGIT => 4, "E" => 19}
		@states.push(hash)

		# state 5 of the DFA
		hash = Hash.new
		hash = {"\"" => 6}
		hash.default = 5
		@states.push(hash)

		# state 6 of the DFA
		hash = Hash.new
		@states.push(hash)

		# state 7 of the DFA
		hash = Hash.new
		hash = {"}" => 8}
		hash.default = 7
		@states.push(hash)

		# state 8 of the DFA
		hash = Hash.new
		@states.push(hash)
		
		# state 9 of the DFA
		hash = Hash.new
		hash = {TYPE::DIGIT => 9,TYPE::LETTER => 9, "_" => 9 }
		@states.push(hash)
		
		# state 10 of the DFA
		hash = Hash.new
		hash = { }
		@states.push(hash)
		
		# state 11 of the DFA
		hash = Hash.new
		hash = {"-" => 13, "=" => 12, ">" => 12}
		@states.push(hash)
				
		# from state 12 and 13
		for state in 12 .. 13
			hash = Hash.new
			@states.push(hash)
		end

		# state 14 of the DFA
		hash = Hash.new
		hash = { "=" => 12}
		@states.push(hash)

		# from state 15 to 18
		hash = Hash.new
		for state in 15 .. 18
			@states.push(hash)
		end
	
		# state 19 of the DFA
		hash = Hash.new
		hash = { "+" => 20 , "-" => 20}
		@states.push(hash)
	
		# state 20 of the DFA
		hash = Hash.new
		hash = { TYPE::DIGIT => 20}
		@states.push(hash)

		# state 21 of the DFA
		hash = Hash.new
		hash = { TYPE::DIGIT => 21}
		@states.push(hash)
	end

end



def create_symbol_table
	reserved_words = Set.new(["inicio","varinicio", "varfim",
							"escreva", "leia", "se", "entao",
							"senao", "fimse", "fim", "inteiro",
							"literal", "real"])

	symbol_table = Hash.new 

	reserved_words.each do |word|
		symbol_table[word] = Element.new :token => word, :lexeme => word
	end

	return symbol_table
end


# so para mostrar no nome dos tokens
# def create_tokens
# 	table_token = Hash.new
# 	reserved_words = Set.new(["inicio","varinicio", "varfim",
# 							"escreva", "leia", "se", "entao",
# 							"senao", "fimse", "fim", "inteiro",
# 							"literal", "real"])

# 	reserved_words.each do |word|
# 		table_token[word] = word
# 	end


# 	TOKENS.constants.each do |c|
#   		table_token[TOKENS.const_get(c)] = c
# #  		print String(TOKENS.const_get(c)) +  " " + String(c) + "\n"
# 	end
# 	return table_token
# end




# begin here
if __FILE__ == $0

	$symbol_table = create_symbol_table

	LA = Lexic_Analyzer.new("code.alg")

	while a = LA.get_next_token and !TYPE::is_eof(a.lexeme)
		
		print "#{a.lexeme}  #{a.token}\n"

	end
	
	$symbol_table.each do |a,b|
		printf "LEXEME: %-20s TOKEN: %s\n", a, b.token
	end

end