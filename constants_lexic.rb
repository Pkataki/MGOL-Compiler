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
	def lexic_error(lexeme, msg, line, column)  
  		raise msg +" #{lexeme} at line #{line}, column #{column}"  
  	end  
end

module TYPE

	DIGIT = "DIGIT"
	LETTER = "LETTER"
	EOF = "EOF"

	def TYPE::is_eof(str)
		return !(str.size != 0)
	end

	def TYPE::get_type(str)
		if str == nil
			return EOF
		end
		if str.match(/[A-Za-z]/) then 
			return LETTER 
		elsif str.match(/[0-9]/)
			return DIGIT 
		else
			return str
		end
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

