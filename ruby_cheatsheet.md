# Ruby Cheatsheet (Class-Based)

## Class Basics

```ruby
require 'securerandom'

class Animal
  # Constants
  KINGDOM = "Animalia"

  # attr_accessor = getter + setter
  # attr_reader  = getter only
  # attr_writer  = setter only
  attr_accessor :name, :age
  attr_reader :id

  def initialize(name, age)
    @id   = SecureRandom.uuid  # cryptographically random, globally unique
    @name = name               # instance variable
    @age  = age
  end

  # Instance method
  def speak
    "..."
  end

  # Private methods (can't be called from outside)
  private

  def secret
    "hidden"
  end

  # Protected methods (callable from same class or subclasses, not outside)
  protected

  def internal_compare(other)
    @age <=> other.age
  end
end

dog = Animal.new("Rex", 3)
dog.name          # => "Rex"
dog.name = "Max"  # setter
dog.id            # => "550e8400-e29b-41d4-a716-446655440000"
dog.id = "x"      # NoMethodError — attr_reader only
```

---

## Inheritance

```ruby
class Dog < Animal
  def initialize(name, age, breed)
    super(name, age)   # calls parent initialize
    @breed = breed
  end

  def speak
    "Woof!"
  end

  # Call parent method explicitly
  def description
    "#{super} I am a #{@breed}."
  end
end

dog = Dog.new("Rex", 3, "Husky")
dog.is_a?(Dog)     # => true
dog.is_a?(Animal)  # => true
dog.class          # => Dog
dog.superclass     # NoMethodError — call on class: Dog.superclass => Animal
```

---

## Modules (Mixins)

```ruby
module Swimmable
  def swim
    "#{@name} is swimming"
  end
end

module Runnable
  def run
    "#{@name} is running"
  end
end

class Duck < Animal
  include Swimmable  # mixin — adds instance methods
  include Runnable
  extend Swimmable   # extend — adds as class methods instead
end

duck = Duck.new("Donald", 2)
duck.swim   # => "Donald is swimming"
duck.run    # => "Donald is running"
```

---

## Comparable & Enumerable (Common Modules to Include)

```ruby
class Box
  include Comparable

  attr_accessor :volume

  def initialize(volume)
    @volume = volume
  end

  # Required by Comparable — unlocks <, >, <=, >=, between?, clamp
  def <=>(other)
    @volume <=> other.volume
  end
end

boxes = [Box.new(10), Box.new(3), Box.new(7)]
boxes.min.volume   # => 3
boxes.max.volume   # => 10
boxes.sort.map(&:volume)  # => [3, 7, 10]
```

---

## Strings

```ruby
s = "hello world"

s.upcase           # => "HELLO WORLD"
s.downcase         # => "hello world"
s.capitalize       # => "Hello world"
s.reverse          # => "dlrow olleh"
s.length           # => 11
s.include?("world") # => true
s.start_with?("he") # => true
s.end_with?("ld")   # => true
s.split(" ")        # => ["hello", "world"]
s.strip             # removes leading/trailing whitespace
s.chomp             # removes trailing newline
s.gsub("l", "r")    # => "herro worrd"  (replace all)
s.sub("l", "r")     # => "herlo world"  (replace first)
s[0..4]             # => "hello"  (slice)
s.chars             # => ["h", "e", "l", "l", "o", ...]
s.count("l")        # => 3

# String interpolation
name = "Rex"
"Hello, #{name}!"   # => "Hello, Rex!"

# Multiline
text = <<~HEREDOC
  line one
  line two
HEREDOC
```

---

## Arrays

```ruby
arr = [3, 1, 4, 1, 5, 9, 2, 6]

# Access
arr[0]        # => 3
arr[-1]       # => 6
arr[1..3]     # => [1, 4, 1]
arr.first     # => 3
arr.last      # => 6
arr.first(2)  # => [3, 1]

# Modify
arr.push(7)        # add to end
arr << 8           # same as push
arr.pop            # remove from end
arr.unshift(0)     # add to front
arr.shift          # remove from front
arr.insert(2, 99)  # insert at index

# Info
arr.length    # or .size or .count
arr.empty?
arr.include?(5)
arr.flatten   # flattens nested arrays
arr.compact   # removes nils
arr.uniq      # removes duplicates
arr.sort
arr.sort_by { |x| -x }   # sort descending
arr.reverse
arr.min / arr.max
arr.sum
arr.sample    # random element
arr.shuffle

# Iteration
arr.each { |x| puts x }
arr.map  { |x| x * 2 }        # transform, returns new array
arr.select { |x| x > 3 }      # filter (keep matching)
arr.reject { |x| x > 3 }      # filter (remove matching)
arr.find   { |x| x > 3 }      # first match
arr.reduce(0) { |sum, x| sum + x }  # fold/accumulate
arr.any?   { |x| x > 8 }      # => true if any match
arr.all?   { |x| x > 0 }      # => true if all match
arr.none?  { |x| x > 10 }     # => true if none match
arr.count  { |x| x > 3 }      # count matching
arr.flat_map { |x| [x, x*2] } # map + flatten
arr.each_with_index { |x, i| puts "#{i}: #{x}" }
arr.each_with_object([]) { |x, acc| acc << x * 2 }
arr.zip([1,2,3])               # => [[3,1],[1,2],[4,3],...]

# Group / chunk
arr.group_by { |x| x.even? }  # => {false=>[3,1,...], true=>[4,...]}
arr.tally                      # => {3=>1, 1=>2, 4=>1, ...} count occurrences
arr.take(3)                    # first 3 elements
arr.drop(3)                    # all after first 3
arr.take_while { |x| x < 5 }
arr.each_slice(2).to_a         # => [[3,1],[4,1],[5,9],...]
arr.each_cons(3).to_a          # sliding window of size 3
```

---

## Hashes

```ruby
h = { name: "Rex", age: 3, breed: "Husky" }

# Default value hash — missing keys return the default instead of nil
counter = Hash.new(0)
counter[:x] += 1    # => 1 (no KeyError, starts from 0)
counter[:y]         # => 0 (default, key not added)

# Conditional initialization of a specific key
h[:visits] ||= 0    # sets to 0 only if nil/false — use over Hash.new when
h[:visits] += 1     # you need a default for one key, not all keys

# Array as a composite hash key
cache = {}
cache[["HTT736", "East"]] = entry   # any object can be a key
cache.key?(["HTT736", "East"])      # => true

# Access
h[:name]            # => "Rex"
h.fetch(:name)      # => "Rex" (raises KeyError if missing)
h.fetch(:x, "N/A")  # => "N/A" (default)
h.dig(:name)        # safe nested access: h.dig(:a, :b, :c)

# Modify
h[:color] = "gray"        # add/update
h.delete(:color)          # removes key, returns the deleted value (or nil)
removed = h.delete(:name) # => "Rex"

# Info
h.keys              # => [:name, :age, :breed]
h.values            # => ["Rex", 3, "Husky"]
h.key?(:name)       # => true  (preferred over has_key?)
h.value?("Rex")     # => true  (preferred over has_value?)
h.length            # => 3
h.empty?

# Iteration
h.each { |k, v| puts "#{k}: #{v}" }
h.map  { |k, v| [k, v.to_s] }.to_h
h.select { |k, v| v.is_a?(String) }
h.reject { |k, v| v.is_a?(String) }
h.any?   { |k, v| v == 3 }
h.all?   { |k, v| !v.nil? }
h.min_by { |k, v| v }          # => [:age, 3]  (key-value pair with min value)
h.max_by { |k, v| v.to_s }    # by stringified value
h.sort_by { |k, v| k.to_s }
h.count  { |k, v| v.is_a?(String) }
h.sum    { |k, v| v.is_a?(Integer) ? v : 0 }

# Merge
h.merge({ weight: 30 })       # returns new hash
h.merge!({ weight: 30 })      # mutates in place
h1.merge(h2) { |k, v1, v2| v1 + v2 }  # resolve conflicts

# Transform
h.transform_values { |v| v.to_s }
h.transform_keys   { |k| k.to_s }
h.to_a             # => [[:name, "Rex"], [:age, 3], ...]
Hash[arr]          # array of pairs => hash
```

---

## Symbols

```ruby
:hello            # immutable, memory-efficient string-like identifier
:hello.to_s       # => "hello"
"hello".to_sym    # => :hello
:hello == :hello  # => true (same object in memory)
```

---

## Ranges

```ruby
(1..5).to_a       # => [1, 2, 3, 4, 5]  (inclusive)
(1...5).to_a      # => [1, 2, 3, 4]     (exclusive end)
(1..5).include?(3)  # => true
(1..5).each { |i| puts i }
(1..5).map { |i| i * 2 }
(1..5).select { |i| i.odd? }
(1..5).sum        # => 15
(1..5).min        # => 1
(1..5).max        # => 5
('a'..'e').to_a   # => ["a", "b", "c", "d", "e"]
```

---

## Conditionals

```ruby
# if / elsif / else
if x > 10
  "big"
elsif x > 5
  "medium"
else
  "small"
end

# Inline / ternary
result = x > 5 ? "big" : "small"
puts "positive" if x > 0
puts "negative" unless x > 0

# case / when
case x
when 1..5   then "low"
when 6..10  then "medium"
when String then "it's a string"
else             "other"
end

# Safe navigation (avoid NoMethodError on nil)
user&.name        # returns nil instead of raising if user is nil

# Nil coalescing pattern
value = potentially_nil || "default"
```

---

## Loops & Iteration

```ruby
# times
5.times { |i| puts i }

# upto / downto
1.upto(5)   { |i| puts i }
5.downto(1) { |i| puts i }

# loop (infinite, use break to exit)
loop do
  break if condition
end

# while / until
while x < 10
  x += 1
end

until x >= 10
  x += 1
end

# for (rare in Ruby — prefer each)
for i in 1..5
  puts i
end
```

---

## Blocks, Procs, Lambdas

```ruby
# Block (anonymous chunk of code passed to a method)
[1,2,3].each { |x| puts x }
[1,2,3].each do |x|
  puts x
end

# Yield — lets a method accept a block
def greet
  puts "Before"
  yield("Rex") if block_given?
  puts "After"
end
greet { |name| puts "Hello, #{name}!" }

# Proc (reusable block)
double = Proc.new { |x| x * 2 }
double.call(5)   # => 10

# Lambda (like Proc but strict about argument count)
square = lambda { |x| x ** 2 }
square = ->(x) { x ** 2 }   # shorthand
square.call(4)   # => 16

# Method reference shorthand
[1,2,3].map(&method(:puts))   # passes method as block
["a","b"].map(&:upcase)        # symbol to proc shorthand => ["A", "B"]
```

---

## Exception Handling

```ruby
begin
  result = 10 / 0
rescue ZeroDivisionError => e
  puts "Error: #{e.message}"
rescue TypeError, ArgumentError => e
  puts "Type or Arg error: #{e.message}"
ensure
  puts "Always runs"
end

# Retry
attempts = 0
begin
  attempts += 1
  raise "fail" if attempts < 3
rescue
  retry if attempts < 3
end

# raise custom
class MyError < StandardError
  def initialize(msg = "my default message")
    super
  end
end

raise MyError
raise MyError, "custom message"
```

---

## Common Patterns

```ruby
# Guard clause (early return)
def process(user)
  return "no user" if user.nil?
  return "inactive" unless user.active?
  "processing #{user.name}"
end

# Memoization
def expensive_result
  @result ||= compute_something
end

# Method chaining
[1,2,3,4,5]
  .select(&:odd?)
  .map { |x| x * 3 }
  .sum

# Struct (lightweight data class)
Point = Struct.new(:x, :y) do
  def distance_to_origin
    Math.sqrt(x**2 + y**2)
  end
end
p = Point.new(3, 4)
p.x   # => 3
p.distance_to_origin  # => 5.0

# OpenStruct (dynamic attributes — slower, use sparingly)
require 'ostruct'
person = OpenStruct.new(name: "Rex", age: 3)
person.name   # => "Rex"
person.color = "gray"  # add attributes dynamically

# Freeze (make object immutable)
str = "hello".freeze
str << " world"  # => RuntimeError

# dup vs clone
arr.dup    # shallow copy, unfrozen
arr.clone  # shallow copy, preserves frozen state
```

---

## Useful Conversions

```ruby
"42".to_i       # => 42
"3.14".to_f     # => 3.14
42.to_s         # => "42"
42.to_f         # => 42.0
3.14.to_i       # => 3  (truncates)
nil.to_a        # => []
nil.to_s        # => ""
nil.to_i        # => 0
[[:a,1]].to_h   # => {a: 1}
```

---

## Type Checking

```ruby
x.class           # => Integer
x.is_a?(Integer)  # => true
x.kind_of?(Numeric) # => true (includes superclasses)
x.instance_of?(Integer) # => true (exact class only)
x.respond_to?(:upcase)  # => true if method exists
x.nil?
x.frozen?
Integer === 42    # => true (case equality)
```

---

## Helpful Numeric Methods

```ruby
42.even?         # => true
43.odd?          # => true
-5.abs           # => 5
3.14.round       # => 3
3.14.ceil        # => 4
3.14.floor       # => 3
10.gcd(4)        # => 2
2 ** 10          # => 1024
Math.sqrt(16)    # => 4.0
Math::PI         # => 3.14159...
rand(10)         # random 0..9
rand(1.0)        # random float 0..1
```

---

## Enumerable Chaining (Power Combos)

```ruby
# Common pipeline
data = [
  { name: "Alice", age: 30, score: 88 },
  { name: "Bob",   age: 25, score: 72 },
  { name: "Carol", age: 35, score: 95 },
]

data
  .select { |p| p[:age] >= 28 }
  .sort_by { |p| p[:score] }
  .map { |p| p[:name] }
# => ["Alice", "Carol"]

# group_by + transform
data.group_by { |p| p[:age] >= 30 ? :senior : :junior }
# => { senior: [...], junior: [...] }

# flat_map (map + flatten one level)
[[1,2],[3,4]].flat_map { |a| a.map { |x| x * 2 } }
# => [2, 4, 6, 8]

# each_with_object (build a result while iterating)
data.each_with_object({}) { |p, h| h[p[:name]] = p[:score] }
# => {"Alice"=>88, "Bob"=>72, "Carol"=>95}

# reduce to build a hash
data.reduce({}) { |h, p| h.merge(p[:name] => p[:score]) }
# => {"Alice"=>88, "Bob"=>72, "Carol"=>95}

# chunk_while (group consecutive elements)
[1,2,3,7,8,12].chunk_while { |a, b| b - a == 1 }.to_a
# => [[1, 2, 3], [7, 8], [12]]

# min_by / max_by
data.min_by { |p| p[:score] }[:name]  # => "Bob"
data.max_by { |p| p[:score] }[:name]  # => "Carol"

# sum with block
data.sum { |p| p[:score] }  # => 255
```

---

## String Formatting

```ruby
# printf-style
"Hello, %s! You are %d years old." % ["Rex", 3]
"Pi is approx %.2f" % 3.14159    # => "Pi is approx 3.14"

# rjust / ljust / center (padding)
"42".rjust(5)         # => "   42"
"42".ljust(5, "-")    # => "42---"
"hi".center(10, "*")  # => "****hi****"

# Useful string checks
"".empty?             # => true
" ".strip.empty?      # => true
"123".match?(/^\d+$/) # => true  (regex match)
"hello" =~ /ell/      # => 1     (index of match, or nil)

# scan (find all matches)
"one 1 two 2 three 3".scan(/\d+/)  # => ["1", "2", "3"]

# split with limit
"a,b,c,d".split(",", 2)  # => ["a", "b,c,d"]
```

---

## File I/O

```ruby
# Read entire file
content = File.read("file.txt")
lines   = File.readlines("file.txt")        # array of lines
lines   = File.readlines("file.txt", chomp: true)  # strip newlines

# Write
File.write("file.txt", "hello world")       # overwrites
File.open("file.txt", "a") { |f| f.puts "append this" }

# Check existence
File.exist?("file.txt")
File.directory?("path/")
File.basename("/path/to/file.txt")  # => "file.txt"
File.extname("file.txt")            # => ".txt"
File.dirname("/path/to/file.txt")   # => "/path/to"

# Path joining (cross-platform)
File.join("path", "to", "file.txt")  # => "path/to/file.txt"
```

---

## Frozen String Literal & Performance Tips

```ruby
# Add at top of file — makes all string literals frozen (faster, less memory)
# frozen_string_literal: true

# Use symbols for hash keys when keys are fixed/known
{ name: "Rex" }     # good — symbols as keys
{ "name" => "Rex" } # fine for dynamic keys

# Prefer map over each when you want a transformed array
result = arr.map { |x| x * 2 }   # returns new array
# vs
result = []
arr.each { |x| result << x * 2 } # avoid this pattern

# Use tap for debugging in a chain (returns self)
[1,2,3]
  .map { |x| x * 2 }
  .tap { |a| p a }    # prints [2,4,6] without breaking the chain
  .select(&:odd?)
```

---

## Comparable Operators

```ruby
1 <=> 2   # => -1  (less than)
2 <=> 2   # =>  0  (equal)
3 <=> 2   # =>  1  (greater than)
# Used internally by sort, min, max
```

---

## Miscellaneous Useful Methods

```ruby
# pp (pretty print — great for debugging)
pp({ name: "Rex", scores: [1,2,3] })

# Object inspection
42.inspect          # => "42"
[1,2].inspect       # => "[1, 2]"
nil.inspect         # => "nil"

# Conditional assignment
x ||= "default"     # assign only if x is nil or false
x &&= x.upcase      # assign only if x is truthy

# Multiple assignment / destructuring
a, b, c = [1, 2, 3]
first, *rest = [1, 2, 3, 4]   # rest => [2, 3, 4]
*init, last  = [1, 2, 3, 4]   # init => [1, 2, 3]

# Swap
a, b = b, a

# Array multiplication / union / intersection
[1,2] * 3              # => [1, 2, 1, 2, 1, 2]
[1,2,3] | [2,3,4]      # => [1, 2, 3, 4]  (union)
[1,2,3] & [2,3,4]      # => [2, 3]         (intersection)
[1,2,3,2] - [2]        # => [1, 3]          (difference)

# Spaceship in sort
arr.sort { |a, b| a <=> b }         # ascending
arr.sort { |a, b| b <=> a }         # descending

# Object equality
1 == 1.0    # => true   (value equality)
1.eql?(1.0) # => false  (type + value)
1.equal?(1) # => true   (same object identity)

# Freeze check
"hello".frozen?   # => false
:hello.frozen?    # => true  (symbols always frozen)
```
