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
		
		
		while true
			char = IO.read(@file,SIZEBYTES,@offset)
			#print char + "\n"
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

		@file = file
		
		@line_error = 1

		@columns_error = 0

		@error_handling = Error_handle.new

		@states = JSON.parse(File.read(transitions_file), object_class: OpenStruct)
		
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


# begin here
if __FILE__ == $0

	$symbol_table = create_symbol_table

	LA = Lexic_Analyzer.new("code.alg","transitions.json")

	while a = LA.get_next_token and !TYPE::is_eof(a.lexeme)
		
		print "#{a.lexeme}  #{a.token}\n"

	end

	
	$symbol_table.each do |a,b|
		printf "LEXEME: %-20s TOKEN: %s\n", a, b.token
	end

end