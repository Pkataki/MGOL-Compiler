$LOAD_PATH << '.'
require 'json'
require 'set'
require 'constants_lexic'

class Lexic_Analyzer

	SIZEBYTES = 1

	def get_next_token

		name_lexeme = "" 
		current_state = 0 
		last_state = 0
		has_error = 0
		
		while @found_eof == false
			
			#reading one byte at a time
			char = IO.read(@file,SIZEBYTES,@offset) 
	
			if TYPE::is_eof(char) 

				#checking literal and comentary error	
				if @states[current_state]["final"].nil? 
					
					error_state = @states[current_state]["transitions"].values.first
				
					type_error = @states[error_state]["token"] == TOKENS::LITERAL ? "literal": "comentary"

					#raising exception  
					@error_handling.lexic_error(char,"Invalid " + type_error, @first_apperance_line - @repeated_breakline,@first_apperance_column)
			
				end

				char = "EOF"
				
				@found_eof = true
				
				last_state = @states[0]["transitions"][char]
				
				#always return nil
				current_state = @states[last_state]["transitions"] 

				name_lexeme = char
			
			else

				#updating lines and columns if occur some error
				if char == "\n"
					@line_error += 1
					@columns_error = 0
				end

				# getting type, can be "EOF", "LETTER", "DIGIT"
				type_char = TYPE::get_type(char) 

				last_state = current_state

				# checking transitions of the actual state
				if not @states[current_state]["transitions"].nil?
	
					if @states[current_state]["transitions"][type_char].nil?
						
						# checking if a state is a self loop
						if @states[current_state]["self_loop"].nil? 
							current_state = nil
						end

					# going to next state in the DFA
					else
						@first_apperance_line = @line_error
						@first_apperance_column = @columns_error
						current_state = @states[current_state]["transitions"][type_char] 
					end
				
				else
					current_state = nil
				end

				# offset on file
				@offset += 1 
			end

			#don't have transition
			if current_state.nil?

				name_lexeme = name_lexeme.strip
				
				#last_state is a final state
				if @states[last_state]["final"] == true 
					
					@offset -= 1


					if char == "\n"
						@repeated_breakline += 1
					end
					
					#checking if the lexeme read has the token "ID"
					if not TYPE::is_eof(name_lexeme)  and not $symbol_table.has_key?(name_lexeme)  and @states[last_state]["token"] == TOKENS::ID 
						
						$symbol_table[name_lexeme] = Element.new :token => @states[last_state]["token"], :lexeme => name_lexeme	
					
					end

					# returning the element if it's in the symbol table
					if $symbol_table.has_key?(name_lexeme) == true
						return  $symbol_table[name_lexeme]
					
					#return the element that is not in the symbol table
					else
						return Element.new :token => @states[last_state]["token"], :lexeme => name_lexeme
					end

				# an invalid lexeme appeared
				else
					@error_handling.lexic_error(char,"Invalid lexeme",@line_error - @repeated_breakline,@columns_error)
				end	
				
				break
			end

			# appending the new character read in the lexeme name
			name_lexeme += char
		
			# updating columns
			@columns_error += 1
			
		end

	end

	def initialize(file,transitions_file)

		@repeated_breakline = 0

		@offset = 0

		@found_eof = false

		@first_apperance_line = 0

		@first_apperance_column = 0

		@file = file
		
		@line_error = 1

		@columns_error = 0

		@error_handling = Error_handle.new

		@states = JSON.parse(File.read(transitions_file))
		
	end

end



def create_symbol_table(reserved_words_file)

	#creating symbol table
	reserved_words = JSON.parse(File.read(reserved_words_file))
		
	symbol_table = Hash.new 

	reserved_words.each do |word|
		symbol_table[word] = Element.new :token => word, :lexeme => word
	end

	return symbol_table
end

def print_table(col_labels, table, format)
	
	board = ["+", "-"*15, "+", "-"*15,"+", "-"*15, "+"]
	puts format % board
	puts format % col_labels
	puts format % board
	table.each do |key, value|
	  puts format % ["|",value.lexeme, "|" ,value.token,"|" ,value.type, "|"]
	end
	puts format % board
end


# begin here
if __FILE__ == $0

	$symbol_table = create_symbol_table("reserved_words.json")

	LA = Lexic_Analyzer.new("code.alg","transitions.json")

	while a = LA.get_next_token
		
		print "#{a.lexeme}  #{a.token}\n\n"
		if TYPE::is_eof(a.lexeme)
			break
		end
	end

	col_labels = [ "|","TOKEN", "|","LEXEME", "|","TYPE", "|" ]
	format = '%s%-15s %s%-15s %s%-15s%s'
	print_table(col_labels,$symbol_table,format)
end