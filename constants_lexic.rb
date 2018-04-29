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
  		raise msg +" at line #{line}, column #{column}"  
  	end  
end

module TYPE

	DIGIT = "DIGIT"
	LETTER = "LETTER"
	EOF = "EOF"

	def TYPE::is_eof(str)
		return (str.nil? or  str.size == 0  or str == EOF)
	end
end

module TOKENS
	
	NUM = "NUM"
	LITERAL = "LITERAL"
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

