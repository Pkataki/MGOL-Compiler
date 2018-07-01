$LOAD_PATH << '.'
require 'json'
require 'auxiliary_compiler'

class Lexic_Analyzer

	SIZEBYTES = 1

	@line_error = 1

	@columns_error = 0

	def get_line_error()
		return @line_error - @repeated_breakline
	end

	def get_column_error()
		return @columns_error
	end

	def build_token(last_state, name_lexeme)
		name_lexeme = name_lexeme.strip
		

		if TYPE::is_eof(name_lexeme)
			return Element.new :token => "EOF", :lexeme => "EOF"	
		end
		
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
			@error_handling.lexic_error("Invalid lexeme",@line_error - @repeated_breakline,@columns_error)
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
		
		while @found_eof == false
			
			#reading one byte at a time
			char = IO.read(@file,SIZEBYTES,@offset) 
			
			# offset on file
			@offset += 1 

			if TYPE::is_eof(char) 

				@found_eof = true
				#checking literal and comentary error	
				if @states[current_state]["final"].nil?
					
					error_state = @states[current_state]["transitions"].values.first
				
					type_error = @states[error_state]["token"] == TOKENS::LITERAL ? "Literal": "Comentary"

					#raising exception  
					@error_handling.lexic_error("Invalid " + type_error, @first_appearence_line - @repeated_breakline,@first_appearence_column)
			
				end
				
				return build_token(last_state,name_lexeme)
				
			else

				#updating lines and columns if occur some error
				if char == "\n"
					@line_error += 1
					@columns_error = 1
				end

				last_state = current_state
				
				# checking transitions of the actual state
				if not @states[current_state]["transitions"].nil?
					
					if @states[current_state]["transitions"][char].nil?
					
						# checking if a state is a self loop
						if @states[current_state]["self_loop"].nil?
							#print "entered here!! #{@states[last_state]["final"].nil}\n"
							
							#invalid lexeme
							if char != nil and current_state == 0
								last_state = 1
								name_lexeme = "*"
							end
							

							#build lexeme because is a final state			
							update_breaklines(char) 
							return build_token(last_state,name_lexeme)
									
						end

					# going to next state in the DFA
					else
						@first_appearence_line = @line_error
						@first_appearence_column = @columns_error
						current_state = @states[current_state]["transitions"][char]
					end

				else
					# build lexeme because is a final state
					update_breaklines(char)
					return build_token(last_state,name_lexeme)
				end
				
			end

			# appending the new character read in the lexeme name
			name_lexeme += char
		
			# updating columns
			@columns_error += 1
			
		end

		#building EOF lexeme
		return build_token(last_state,name_lexeme)
	end

	def generate_states()
		
		#change the DIGIT for all digits and LETTER for all letters

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

	private :build_token, :update_breaklines, :generate_states
	#public :line_error, :columns_error
end


class Syntactic_Analyser
	

	def semantic(grammar_rule)
		
		a = Element.new :token => " ", :lexeme => " ", :type => " " 

		case grammar_rule

		when 5
			
			@output_string += "\n\n\n"

		when 6
			
			ptv = @stack_symbols[-1]
			id = @stack_symbols[-3]
			tipo = @stack_symbols[-2]

			id.type = tipo.type

			$symbol_table[id.lexeme] = id

			t = tipo.type
			if t == "real"
				t = "double"
			end

			for i in (1 .. @count_space)
				@output_string += "\t"
			end

			@output_string += "#{t} #{id.lexeme};\n"

			a = id


		when 7

			tipo = @stack_symbols.last()
			
			tipo.type = $symbol_table["int"].type
	
			a = tipo

		when 8 

			tipo = @stack_symbols.last()
			
			tipo.type = $symbol_table["real"].type

			a = tipo
		
		when 9 

			tipo = @stack_symbols.last()
			
			tipo.type = $symbol_table["lit"].type

			a = tipo	

		when 11
			
			ptv = @stack_symbols[-1]

			id = @stack_symbols[-2]

			
			for i in (1 .. @count_space)
				@output_string += "\t"
			end
			

			if id.type == "lit"
				@output_string += "scanf(\"%s\",#{id.lexeme});\n"
			
			elsif id.type == "real"
			 	@output_string += "scanf(\"%lf\",&#{id.lexeme});\n"
			
			elsif id.type == "int"
				@output_string += "scanf(\"%d\",&#{id.lexeme});\n"
				
			else
				@error_handling.semantic_error("The variable was not declared",@LA.get_line_error,@LA.get_column_error)
			end


		when 12
			
			ptv = @stack_symbols[-1]	
			arg = @stack_symbols[-2]
			
			for i in (1 .. @count_space)
				@output_string += "\t"
			end

			if arg.type == "lit"
				@output_string += "printf(\"%s\",#{arg.lexeme});\n"
			
			elsif arg.type == "int"
				@output_string += "printf(\"%d\",#{arg.lexeme});\n"

			elsif arg.type == "real"
				@output_string += "printf(\"%lf\",#{arg.lexeme});\n"
			else
				@output_string += "printf(#{arg.lexeme});\n"
			end

		when 13
			
			lit = @stack_symbols.last()
			a = lit

		when 14
			
			num = @stack_symbols.last()
			a = num

		when 15

			id = @stack_symbols.last()

			if id.type != ""
				a = id
			else
				@error_handling.semantic_error("The variable was not declared",@LA.get_line_error,@LA.get_column_error)
			end

		when 17

			ptv = @stack_symbols[-1]
			ld = @stack_symbols[-2]
			rcb = @stack_symbols[-3]
			id = @stack_symbols[-4]

			if id.type != ""
				
				if ld.type == id.type
					
					for i in (1 .. @count_space)
						@output_string += "\t"
					end
			
					@output_string += "#{id.lexeme} = #{ld.lexeme};\n"
				else
					@error_handling.semantic_error("Diferent types in atribution",@LA.get_line_error,@LA.get_column_error)
				end
			else
				@error_handling.semantic_error("The variable was not declared",@LA.get_line_error,@LA.get_column_error)
			end

		when 18
			
			oprd1 = @stack_symbols[-3]
			opm = 	@stack_symbols[-2]
			oprd2 = @stack_symbols[-1]

			if oprd2.type != "lit" and oprd1.type != "lit"
				
				a.lexeme = "T#{@type_t.size()}"

				if oprd2.type == "real" or oprd1.type == "real"
					a.type = "real"
				else
					a.type = "int"
				end

				for i in (1 .. @count_space)
					@output_string += "\t"
				end
			
				@output_string += "T#{@type_t.size()} = #{oprd1.lexeme} #{opm.lexeme} #{oprd2.lexeme};\n"
				
				@type_t.push(a.type)

			else
				@error_handling.semantic_error("Operands with incompatible types",@LA.get_line_error,@LA.get_column_error)
			end
	
		
		when 19

			oprd = @stack_symbols.last()
			a = oprd


		when 20

			id = @stack_symbols.last()

			if id.type != ""
				a = id
			else
				@error_handling.semantic_error("The variable was not declared",@LA.get_line_error,@LA.get_column_error)
			end
	

		when 21	
			
			num = @stack_symbols.last()
			a = num
			if a.lexeme.include?(".") or a.lexeme.include?("E") 
				a.type = "real"
			else
				a.type = "int"
			end

		when 23
			
			@count_space -= 1
			for i in (1 .. @count_space)
				@output_string += "\t"
			end

			@output_string += "}\n"
			

		when 24
			
			ptv = @stack_symbols[-1]
			exp_r = @stack_symbols[-3]
			
			for i in (1 .. @count_space)
				@output_string += "\t"
			end

			@output_string += "if( #{exp_r.lexeme} ){\n"
			
			@count_space += 1

		when 25

			oprd1 = @stack_symbols[-3]
			opr   = @stack_symbols[-2]
			oprd2 = @stack_symbols[-1]

			if oprd1.type == oprd2.type

				a.lexeme = "T#{@type_t.size()}"
				a.type = oprd2.type
				
				
				for i in (1 .. @count_space)
					@output_string += "\t"
				end
			
				@output_string += "T#{@type_t.size()} = #{oprd1.lexeme} #{opr.lexeme} #{oprd2.lexeme};\n"
				
				@type_t.push(a.type)
			else
				@error_handling.semantic_error("Operands with incompatible types",@LA.get_line_error,@LA.get_column_error)
			end

		end
		
		return a

	end

	def run()

		@stack = [0]
		@stack_symbols = ["-"]
		
		#getting token from lexic analyzer
		a = @LA.get_next_token()
		
		while true 
			
			#getting the top of stack
			s = @stack.last()

			#going to the current state on ACTION table
			state = @table_actions[s][a.token]
			
			#shift state
			if state[0] == "S"
				
				#getting state number
				t = state[1..-1]
				
				@stack.push(Integer(t))
				
				if $symbol_table[a.lexeme].nil? == false
					@stack_symbols.push($symbol_table[a.lexeme])
				else
					@stack_symbols.push(a)
				end
				a = @LA.get_next_token()
			
			#reduce state
			elsif state[0] == "R"

				t = state[1..-1]
				
				p = semantic(Integer(t))

				#removing |B| from stacks
				@stack.pop((@grammar[Integer(t)]["size"]))
				@stack_symbols.pop((@grammar[Integer(t)]["size"]))
				
				
				aa = @grammar[Integer(t)]["left"]; 
					
				t = @stack.last()
				
				next_state = @table_transitions[Integer(t)][aa]


			
				@stack.push(next_state)
				@stack_symbols.push(p)

				#printing grammar rule
				print "#{@grammar[Integer(state[1..-1])]["left"]} ->  #{@grammar[Integer(state[1..-1])]["right"]}\n"

			#error state
			elsif state[0] == "E"

				t = state[1..-1]

				#getting the error, look at auxiliary_compiler file
				@error_handling.syntactic_error(state,@LA.get_line_error,@LA.get_column_error)
				
				break;
			
			#accepted state
			elsif state[0] == "A"
				
				@output_string += "}\n"
				
				s = ""
				s += "#include<stdio.h>\n"
				s += "#include<stdlib.h>\n"
				s += "typedef char lit[256];\n"
				s += "void main(void){\n"
				s += "\t/*----Variaveis temporarias----*/\n"
				
				for i in (0 .. @type_t.size()-1)
					tt = @type_t[i] == "real" ? "double" : "int"
					s += "\t#{tt} T#{i};\n"
				end
				
				s += "\t/*------------------------------*/\n"

				@output_string = s + @output_string

				@output_file.write(@output_string)

				@output_file.close()

				print "The code is syntactically correct\n"
				break
			
			end

		end
	end


	def initialize(actions_file,transitions_file, grammar_file, lexic)

	
		@type_t = []

		@count_space = 1

		@output_string = ""

		@output_file = File.new("Prog.c","w")


		@error_handling = Error_handle.new

		@LA = lexic

		@grammar = JSON.parse(File.read(grammar_file))
		
		@table_actions = JSON.parse(File.read(actions_file))

		@table_transitions = JSON.parse(File.read(transitions_file))

	end
end



def create_symbol_table(reserved_words_file)

	#creating symbol table
	reserved_words = JSON.parse(File.read(reserved_words_file))
		
	symbol_table = Hash.new 

	reserved_words.each do |word|
		symbol_table[word] = Element.new :token => word, :lexeme => word
	end

	symbol_table["int"].type = "int"
	symbol_table["real"].type = "real"
	symbol_table["lit"].type = "lit"

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

	name_file = ARGV[0]
	$symbol_table = create_symbol_table("reserved_words.json")
	
	LA = Lexic_Analyzer.new(name_file,"transitions.json")

	SA = Syntactic_Analyser.new("syntactic_table_actions.json", "syntactic_table_transitions.json", "grammar.json", LA)

	SA.run()


	col_labels = [ "|","TOKEN", "|","LEXEME", "|","TYPE", "|" ]
	format = '%s%-15s %s%-15s %s%-15s%s'
	print_table(col_labels,$symbol_table,format)

end