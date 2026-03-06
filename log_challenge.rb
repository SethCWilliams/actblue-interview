DIRECTIONS = { "E" => "East", "W" => "West" }

class LogEntry
  attr_reader :timestamp, :license_plate, :booth_id, :direction, :booth_type

  def initialize(line)
    parts          = line.split(" ")
    @timestamp     = parts[0].to_f
    @license_plate = parts[1]
    @booth_id      = parts[2][0..-2]        # everything except last char
    @direction     = DIRECTIONS[parts[2][-1]] # last char mapped to full word
    @booth_type    = parts[3]
  end

  def to_s
    "#{@timestamp} | #{@license_plate} | booth: #{@booth_id} | #{@direction} | #{@booth_type}"
  end
end

class LogFile
  attr_reader :log_entries

  def initialize(file_path)
    @log_entries = File.readlines(file_path, chomp: true).map do |line|
      LogEntry.new(line)
    end
    process_journeys
  end

  def process_journeys
    @open_entries     = {}
    @complete_journeys = 0
    @journey_records  = []
    # Used a counter instead of a hash to easily track vehicles who start but don't finish a journey.
    @vehicle_journeys = {}
    @direction_counts = Hash.new(0)
    @booth_traffic    = Hash.new(0)

    @log_entries.each do |entry|
      @booth_traffic[entry.booth_id] += 1

      if entry.booth_type == "entry"
        @open_entries[journey_key(entry)] = entry
        @vehicle_journeys[entry.license_plate] ||= 0
      elsif entry.booth_type == "exit"
        key = journey_key(entry)
        if @open_entries.key?(key)
          open_entry = @open_entries.delete(key)
          duration   = entry.timestamp - open_entry.timestamp
          @complete_journeys += 1
          @journey_records   << { license_plate: open_entry.license_plate, duration: duration }
          @vehicle_journeys[entry.license_plate] += 1
          @direction_counts[open_entry.direction] += 1
        end
      end
    end
    @average_journey_duration = compute_average
  end

  # returns the number of complete journeys.
  def count_journeys
    @complete_journeys
  end

  # returns license plates of incomplete journeys.
  def incomplete_journeys
    @open_entries.keys.map(&:first)
  end

  # returns the average journey time for all journeys.
  def average_journey_time
    @average_journey_duration
  end

  # returns the number of journeys by vehicle.
  def journeys_by_vehicle
    @vehicle_journeys
  end

  # returns the license plate and duration of the longest journey.
  def longest_journey
    return nil if @journey_records.empty?
    @journey_records.max_by { |r| r[:duration] }
  end

  # returns count of complete journeys by direction.
  def journeys_by_direction
    @direction_counts
  end

  # returns the booth ID(s) with the most recorded traffic.
  def busiest_booth
    top_keys(@booth_traffic)
  end

  # returns the license plates of the most frequent travelers.
  def most_frequent_travelers
    top_keys(@vehicle_journeys)
  end

  private

  def journey_key(entry)
    [entry.license_plate, entry.direction]
  end

  def compute_average
    return 0 if @journey_records.empty?
    (@journey_records.sum { |r| r[:duration] } / @journey_records.size).round(2)
  end

  def top_keys(hash)
    return [] if hash.empty?
    max = hash.values.max
    hash.select { |_, v| v == max }.keys
  end
end

