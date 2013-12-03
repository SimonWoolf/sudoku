def recurse(counter)
  @objectid = counter.object_id
  puts "before: #{counter}"
  ([0]*counter).each do |c|
    puts "after: #{counter} (c = #{c})\n"
    raise 'error' if @objectid != counter.object_id
    recurse(c)
  end
end

recurse(2)