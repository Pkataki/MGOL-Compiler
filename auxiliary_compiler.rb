class Element
	attr_accessor :token, :lexeme, :type

	def initialize args
    	args.each do |k,v|
      		instance_variable_set("@#{k}", v) unless v.nil?
    	end
  	end

	def ==(other)
		self.class === other and
		other.token == @token and
		other.lexema == @lexeme and
		other.type == @type
	 end
end

class Error_handle
	def lexic_error(msg, line, column)  
  		raise "LEXIC ERROR: "+ msg +" at line #{line}, column #{column}"  
  	end

  	def syntactic_error(id, line, column) 
  		syntactic_errors = 
		{
			"E1" 	=> "The \"inicio\" was not found",
			"E2"	=> "There is no \"fim\"",
			"E3"	=> "Without \"varinicio\"",
			"E4"	=> "Without id, leia, escreva, se or fim",
			"E5"	=> "Without \"varfim\" or \"id\"",
			"E6"	=> "Without \"id\"",
			"E7"	=> "Without literal, num or id ",
			"E8" 	=> "Without rcb",
			"E9"	=> "Without fimse, leia, escreva, id or se",
			"E10"	=> "Condition without the parenthesis",
			"E11"	=> "Without semicolon",
			"E12"	=> "Without int, real or literal",
			"E13"	=> "Without id or num",
			"E14"	=> "Without arithmetic operator",
			"E15"	=> "Codition without relational operator",
			"E16"	=> "\"se\"'s block without \"entao\"",
		} 
  		raise "SYNTACTIC ERROR: "+ syntactic_errors[id] +" at line #{line}, column #{column}"  
  	end  
end

module TYPE

	DIGIT = "DIGIT"
	LETTER = "LETTER"
	EOF = "EOF"

	def TYPE::is_eof(str)
		return (str.nil? or  str.size == 0  or str == EOF)
	end

	def TYPE::is_whitespace(str)
		return (str == "\n" or str == " " or str == "\t")
	end
end

module TOKENS
	
	NUM = "NUM"
	LITERAL = "lit"
	ID = "ID"
	COMENTARIO = "COMENTARIO"
	EOF = "EOF"
	OPR = "OPR"
	RCB = "RCB"
	OPM = "OPM"
	AB_P = "AB_P"
	FC_P = "FC_P"
	PT_V  = "PT_V"
	ERROR = "ERROR"
	
end

