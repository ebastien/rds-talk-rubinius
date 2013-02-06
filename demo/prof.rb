# Run with `rbx -Xprofile -S ./prof.rb`

100.times do
  a = Array.new(1000) { rand 100 }
  a.sort!
end
