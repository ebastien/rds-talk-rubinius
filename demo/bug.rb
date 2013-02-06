# Run with `rbx -Xdebug -S ./bug.rb`

def inc(x)
  y = x + 2
  y
end

puts inc(3)
