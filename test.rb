$LOAD_PATH << '.'
require 'json'

# module StateRepresenter
#   include Representable::JSON

#   property :id
#   property :final
#   property :token
#   property :transitions
#   property :self_loop
# end

# class State
#   attr_accessor :id,:final,:token,:transitions,:self_loop
# end


f = File.read("transitions.json")

states = JSON.parse(f, object_class: OpenStruct)

print states[0]["self_loop"].nil?

