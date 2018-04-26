$LOAD_PATH << '.'
require 'json'
require 'constants_lexic'

class Lexic_Analyzer

	SIZEBYTES = 1

	def build_lexeme(last_state, name_lexeme)

		name_lexeme = name_lexeme.strip
		
		#last_state is a final state
		if @states[last_state]["final"] == true 
			
			@offset -= 1


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

	end

	def update_breaklines(char)
		
		if char == "\n"
			@repeated_breakline += 1;
		end
	end

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
				
					type_error = @states[error_state]["token"] == TOKENS::LITERAL ? "Literal": "Comentary"

					#raising exception  
					@error_handling.lexic_error(char,"Invalid " + type_error, @first_appearence_line - @repeated_breakline,@first_appearence_column)
			
				end

				char = "EOF"
				
				@found_eof = true
				
				last_state = @states[0]["transitions"][char]
				
				#always return nil
				current_state = @states[last_state]["transitions"] 


				name_lexeme = char

				return build_lexeme(last_state,name_lexeme)
				

			else

				#updating lines and columns if occur some error
				if char == "\n"
					@line_error += 1
					@columns_error = 0
				end

				last_state = current_state

				# offset on file
				@offset += 1 

				# checking transitions of the actual state
				if not @states[current_state]["transitions"].nil?
	
					if @states[current_state]["transitions"][char].nil?
						
						# checking if a state is a self loop
						if @states[current_state]["self_loop"].nil?

							update_breaklines(char) 
							return build_lexeme(last_state,name_lexeme)
				
						end

					# going to next state in the DFA
					else
						@first_appearence_line = @line_error
						@first_appearence_column = @columns_error
						current_state = @states[current_state]["transitions"][char] 
					end

				else

					update_breaklines(char)
					return build_lexeme(last_state,name_lexeme)
					
				end

				
			end

			# appending the new character read in the lexeme name
			name_lexeme += char
		
			# updating columns
			@columns_error += 1
			
		end


	end

	def generate_states()
		
		letters = ("A".."Z").to_a + ("a" .. 'z').to_a

		numbers = ("0" .. "9").to_a
		
		@states.each do |hash|

			if hash["transitions"].nil? == false and hash["transitions"].has_key?("LETTER")
				state = hash["transitions"]["LETTER"]
				for c in letters
					if not hash["transitions"].has_key?(c)
						hash["transitions"][c] = state
					end
				end
				hash["transitions"].delete("LETTER")
			end
			
			if hash["transitions"].nil? == false and hash["transitions"].has_key?("DIGIT")
				state = hash["transitions"]["DIGIT"]
				for c in numbers
					if not hash["transitions"].has_key?(c)
						hash["transitions"][c] = state
					end
				end
				hash["transitions"].delete("DIGIT")
			end
	
		end

	end

	def initialize(file,transitions_file)

		@repeated_breakline = 0

		@offset = 0

		@found_eof = false

		@first_appearence_line = 0

		@first_appearence_column = 0

		@file = file
		
		@line_error = 1

		@columns_error = 1

		@error_handling = Error_handle.new

		@states = JSON.parse(File.read(transitions_file))
		
		generate_states()

	end

	private :build_lexeme, :update_breaklines, :generate_states

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