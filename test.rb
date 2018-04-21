col_labels = { date: "Date", from: "From", subject: "Subject" }

arr = [{date: "2014-12-01", from: "Ferdous", subject: "Homework this week"},
       {date: "2014-12-01", from: "Dajana", subject: "Keep on coding! :)"},
       {date: "2014-12-02", from: "Ariane", subject: "Re: Homework this week"}]

@columns = col_labels.each_with_object({}) { |(col,label),h|
h[col] = { label: label,
             width: [arr.map { |g| g[col].size }.max, label.size].max } }
  # => {:date=>    {:label=>"Date",    :width=>10},
  #     :from=>    {:label=>"From",    :width=>7},
  #     :subject=> {:label=>"Subject", :width=>22}}
print arr
def write_header
  puts "| #{ @columns.map { |_,g| g[:label].ljust(g[:width]) }.join(' | ') } |"
end

def write_divider
  puts "+-#{ @columns.map { |_,g| "-"*g[:width] }.join("-+-") }-+"
end

def write_line(h)
  str = h.keys.map { |k| h[k].ljust(@columns[k][:width]) }.join(" | ")
  puts "| #{str} |"
end

write_divider
write_header
write_divider
arr.each { |h| write_line(h) }
write_divider