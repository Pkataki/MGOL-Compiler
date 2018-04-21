$LOAD_PATH << '.'
require 'json'
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
		
		
		while @found_eof == false
			
			char = IO.read(@file,SIZEBYTES,@offset)
			#print char + "\n"
			if TYPE::is_eof(char) and name_lexeme.size == 0

				char = "EOF"
				
				@found_eof = true
				
				last_state = @states[actual_state]["transitions"][char]
				
				actual_state = @states[last_state]["transitions"] # always retur nil

				name_lexeme = char
			
			else
				
				if char == "\n"
					if @has_endline == false
						@has_endline = true
						@line_error += 1
						@columns_error = 0
					end
				else
					@has_endline = false
				end
				
				type_char = TYPE::get_type(char)

				last_state = actual_state
	
				if @states[actual_state]["transitions"].nil? == false
					
					if @states[actual_state]["transitions"][type_char].nil?
					#	print " ** " + name_lexeme + "\n"
						if @states[actual_state]["self_loop"].nil?
							actual_state = nil
						end 
					
					else
						actual_state = @states[actual_state]["transitions"][type_char]
					end
				
				else
					actual_state = nil
				end

				@offset += 1
			end
	
			if actual_state.nil?

				name_lexeme = name_lexeme.strip
				
				if @states[last_state]["final"] == true
					
					@offset -= 1
					
					if name_lexeme.size > 0 and $symbol_table.has_key?(name_lexeme) == false and @states[last_state]["token"] == TOKENS::ID 
						
						$symbol_table[name_lexeme] = Element.new :token => @states[last_state]["token"], :lexeme => name_lexeme	
					
					end

					if $symbol_table.has_key?(name_lexeme) == true
						return  $symbol_table[name_lexeme]
					else
						return Element.new :token => @states[last_state]["token"], :lexeme => name_lexeme
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

	def initialize(file,transitions_file)

		@offset = 0

		@found_eof = false

		@has_endline = false

		@file = file
		
		@line_error = 1

		@columns_error = 0

		@error_handling = Error_handle.new

		@states = JSON.parse(File.read(transitions_file), object_class: OpenStruct)
		
	end

end



def create_symbol_table(reserved_words_file)

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
		
		print "#{a.lexeme}  #{a.token}\n"
		if TYPE::is_eof(a.lexeme)
			break
		end
	end

	col_labels = [ "|","TOKEN", "|","LEXEME", "|","TYPE", "|" ]
	format = '%s%-15s %s%-15s %s%-15s%s'
	print_table(col_labels,$symbol_table,format)
end