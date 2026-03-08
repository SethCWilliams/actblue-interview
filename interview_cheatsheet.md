# Ruby Interview Cheatsheet

## OOP Skeleton

```ruby
require 'securerandom'

# use p for debugging, puts for output, and pp for pretty print

class Vehicle
  attr_reader :id, :make, :model   # getter only — can't be set from outside
  attr_accessor :speed             # getter + setter

  def initialize(make, model)
    @id    = SecureRandom.uuid
    @make  = make
    @model = model
    @speed = 0
    process_data                   # call private setup if needed
  end

  def summary
    "#{@make} #{@model} going #{@speed}mph"
  end

  private

  def process_data
    # internal setup — not callable from outside
  end
end

car = Vehicle.new("Toyota", "Camry")
car.make      # => "Toyota"
car.speed     # => 0
car.speed = 60
car.id        # => "550e8400-..."
car.id = "x"  # NoMethodError
```

---

## Parsing a Line of Text

```ruby
# Input: "1000.589 HTT736 B1E entry"
parts = line.split(" ")
timestamp     = parts[0].to_f       # => 1000.589
license_plate = parts[1]            # => "HTT736"
booth_raw     = parts[2]            # => "B1E"
booth_id      = booth_raw[0..-2]    # => "B1"  (all except last char)
direction     = booth_raw[-1]       # => "E"   (last char)
booth_type    = parts[3]            # => "entry"
```

---

## Reading a File

```ruby
lines = File.readlines("data.txt", chomp: true)  # array of strings, no \n
entries = lines.map { |line| LogEntry.new(line) } # parse each line into objects
```

---

## Hash Patterns (Most Common Interview Patterns)

```ruby
# Counter hash — missing keys default to 0
counts = Hash.new(0)
counts[:apples] += 1   # no KeyError, starts from 0
counts[:apples] += 1
counts[:apples]        # => 2

# Conditional init for a specific key (not all keys)
visits = {}
visits["HTT736"] ||= 0
visits["HTT736"] += 1

# Array as a composite key — track combos
open = {}
open[["HTT736", "East"]] = entry   # keyed by plate + direction pair
open.key?(["HTT736", "East"])      # => true
open.delete(["HTT736", "East"])    # removes and returns the value

# Top N / find max
max_val = counts.values.max
winners = counts.select { |k, v| v == max_val }.keys  # all keys tied for max

# Invert a hash
{ a: 1, b: 2 }.invert   # => { 1 => :a, 2 => :b }
```

---

## Array Patterns

```ruby
arr = [3, 1, 4, 1, 5, 9, 2, 6]

# Core iteration
arr.map    { |x| x * 2 }          # transform — returns new array
arr.select { |x| x > 3 }          # keep matching
arr.reject { |x| x > 3 }          # remove matching
arr.find   { |x| x > 3 }          # first match
arr.reduce(0) { |sum, x| sum + x } # accumulate (also: arr.sum)

# Min / max
arr.min                            # => 1
arr.max                            # => 9
arr.min_by { |x| x.to_s }         # min by custom criteria
arr.max_by { |x| -x }             # max by custom criteria (descending trick)

# Sorting
arr.sort                           # ascending
arr.sort_by { |x| -x }            # descending
arr.sort_by { |x| [x.category, x.name] }  # multi-key sort

# Grouping
arr.group_by { |x| x.even? }      # => { true => [...], false => [...] }
arr.tally                          # => { 3=>1, 1=>2, 4=>1, ... } count occurrences
arr.uniq                           # remove duplicates
arr.flatten                        # flatten nested arrays

# Append
arr << 7                           # add to end (same as push)

# Symbol shorthand
arr.map(&:to_s)                    # same as arr.map { |x| x.to_s }
arr.select(&:odd?)
keys.map(&:first)                  # pull first element from each key (array keys)

# Checks
arr.any?  { |x| x > 8 }
arr.all?  { |x| x > 0 }
arr.none? { |x| x > 10 }
arr.include?(5)
arr.empty?
arr.count { |x| x > 3 }
```

---

## String Patterns

```ruby
s = "hello world"

s.split(" ")          # => ["hello", "world"]
s.split(",", 2)       # => split with limit: ["a", "b,c,d"]
s.chars               # => ["h", "e", "l", ...]
s[0..4]               # => "hello"
s[-1]                 # => "d"  (last char)
s[0..-2]              # => "hello worl"  (all but last)
s.include?("world")   # => true
s.start_with?("he")   # => true
s.strip               # remove whitespace
s.upcase / s.downcase
s.reverse
s.count("l")          # => 3  (count occurrences of char)
s.gsub("l", "r")      # replace all
s.scan(/\d+/)         # find all regex matches => ["1", "2"]

# Interpolation
"Hello, #{name}!"
```

---

## Common Algorithm Patterns

```ruby
# Frequency count
def char_frequency(str)
  str.chars.each_with_object(Hash.new(0)) { |c, h| h[c] += 1 }
end

# Running total / single pass
total = 0
records.each do |r|
  total += r.value
end
average = total / records.size.to_f

# Two-pointer (on sorted array)
left, right = 0, arr.length - 1
while left < right
  # ...
  left += 1
  right -= 1
end

# Sliding window
window = arr[0..k-1]
(k...arr.length).each do |i|
  window << arr[i]
  window.shift
  # process window
end

# State machine (open/close tracking — what we did)
open = {}
records.each do |r|
  if r.type == "entry"
    open[r.id] = r
  elsif r.type == "exit" && open.key?(r.id)
    completed = open.delete(r.id)
    # process pair
  end
end
```

---

## Guard Clauses & Nil Safety

```ruby
def process(entry)
  return [] if entry.nil?
  return [] if entry.empty?
  # happy path below
end

# Safe navigation — returns nil instead of raising
user&.name
user&.address&.city

# Nil coalescing
value = result || "default"

# Conditional assignment
@cache ||= compute_something   # memoization pattern
```

---

## Useful One-Liners

```ruby
# Average
arr.sum.to_f / arr.size

# Max key in hash by value
hash.max_by { |k, v| v }.first   # => key with highest value

# Deduplicate while preserving order
arr.uniq

# Count occurrences of a value
arr.count(5)

# Build a hash from two arrays
keys   = [:a, :b, :c]
values = [1, 2, 3]
keys.zip(values).to_h   # => { a: 1, b: 2, c: 3 }

# Check if all characters are unique
str.chars.uniq.length == str.length

# Flatten one level
[[1,2],[3,4]].flat_map { |a| a }   # => [1, 2, 3, 4]

# Sort hash by value descending
hash.sort_by { |k, v| -v }.to_h
```

---

## Minitest (What the Interview Uses)

```ruby
require "minitest/autorun"
require_relative "../my_file"

class TestMyClass < Minitest::Test
  def setup
    @log = LogFile.new("fixtures/basic.txt")  # runs before each test
  end

  def test_something
    assert_equal 2, @log.count_journeys       # exact equality
    assert_nil @log.longest_journey           # is nil
    assert_in_delta 200.49, @log.average, 0.01  # float within tolerance
    assert_empty @log.incomplete_journeys     # empty array/hash/string
    assert @log.complete?                     # truthy
    refute @log.empty?                        # falsy
  end
end
```
