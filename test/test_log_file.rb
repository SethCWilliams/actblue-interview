require "minitest/autorun"
require_relative "../log_challenge"

FIXTURES = File.join(__dir__, "fixtures")

class TestCountJourneys < Minitest::Test
  def test_basic
    log = LogFile.new("#{FIXTURES}/basic.txt")
    assert_equal 2, log.count_journeys
  end

  def test_empty
    log = LogFile.new("#{FIXTURES}/empty.txt")
    assert_equal 0, log.count_journeys
  end

  def test_multi_journey_same_vehicle
    log = LogFile.new("#{FIXTURES}/multi_journey.txt")
    assert_equal 2, log.count_journeys
  end

  def test_uturn_does_not_count
    log = LogFile.new("#{FIXTURES}/uturn.txt")
    assert_equal 0, log.count_journeys
  end
end


class TestIncompleteJourneys < Minitest::Test
  def test_basic
    log = LogFile.new("#{FIXTURES}/basic.txt")
    assert_equal ["ABC999"], log.incomplete_journeys
  end

  def test_empty
    log = LogFile.new("#{FIXTURES}/empty.txt")
    assert_equal [], log.incomplete_journeys
  end

  def test_all_complete
    log = LogFile.new("#{FIXTURES}/multi_journey.txt")
    assert_equal [], log.incomplete_journeys
  end
end


class TestAverageJourneyTime < Minitest::Test
  def test_basic
    log = LogFile.new("#{FIXTURES}/basic.txt")
    # HTT736: 1200.901 - 1000.589 = 200.312
    # XYZ123: 1500.789 - 1300.123 = 200.666
    # average: (200.312 + 200.666) / 2 = 200.489 → rounded to 200.49
    assert_equal 200.49, log.average_journey_time
  end

  def test_empty
    log = LogFile.new("#{FIXTURES}/empty.txt")
    assert_equal 0, log.average_journey_time
  end

  def test_multi_journey_same_vehicle
    log = LogFile.new("#{FIXTURES}/multi_journey.txt")
    # HTT736 trip 1: 1200.901 - 1000.589 = 200.312
    # HTT736 trip 2: 1500.000 - 1300.000 = 200.000
    # average: (200.312 + 200.000) / 2 = 200.156
    assert_equal 200.16, log.average_journey_time
  end
end


class TestJourneysByVehicle < Minitest::Test
  def test_basic
    log = LogFile.new("#{FIXTURES}/basic.txt")
    assert_equal 1, log.journeys_by_vehicle["HTT736"]
    assert_equal 1, log.journeys_by_vehicle["XYZ123"]
    assert_equal 0, log.journeys_by_vehicle["ABC999"]
  end

  def test_multi_journey_same_vehicle
    log = LogFile.new("#{FIXTURES}/multi_journey.txt")
    assert_equal 2, log.journeys_by_vehicle["HTT736"]
  end
end

class TestLongestJourney < Minitest::Test
  def test_basic
    log = LogFile.new("#{FIXTURES}/basic.txt")
    # HTT736: 200.312s, XYZ123: 200.666s → XYZ123 is longest
    result = log.longest_journey
    assert_equal "XYZ123", result[:license_plate]
    assert_in_delta 200.666, result[:duration], 0.001
  end

  def test_empty
    log = LogFile.new("#{FIXTURES}/empty.txt")
    assert_nil log.longest_journey
  end
end


class TestJourneysByDirection < Minitest::Test
  def test_basic
    log = LogFile.new("#{FIXTURES}/basic.txt")
    assert_equal 1, log.journeys_by_direction["East"]
    assert_equal 1, log.journeys_by_direction["West"]
  end

  def test_multi_journey_same_vehicle
    log = LogFile.new("#{FIXTURES}/multi_journey.txt")
    assert_equal 2, log.journeys_by_direction["East"]
    assert_equal 0, log.journeys_by_direction["West"]
  end

  def test_empty
    log = LogFile.new("#{FIXTURES}/empty.txt")
    assert_equal 0, log.journeys_by_direction["East"]
    assert_equal 0, log.journeys_by_direction["West"]
  end
end


class TestBusiestBooth < Minitest::Test
  def test_clear_winner
    log = LogFile.new("#{FIXTURES}/busiest_booth.txt")
    # B1: AAA entry, AAA main_road, AAA exit, BBB entry = 4 hits
    # B2: BBB exit = 1 hit
    assert_equal ["B1"], log.busiest_booth
  end

  def test_empty
    log = LogFile.new("#{FIXTURES}/empty.txt")
    assert_equal [], log.busiest_booth
  end
end


class TestMostFrequentTravelers < Minitest::Test
  def test_basic
    log = LogFile.new("#{FIXTURES}/basic.txt")
    assert_equal ["HTT736", "XYZ123"], log.most_frequent_travelers
  end

  def test_empty
    log = LogFile.new("#{FIXTURES}/empty.txt")
    assert_equal [], log.most_frequent_travelers
  end

  def test_multi_journey_same_vehicle
    log = LogFile.new("#{FIXTURES}/multi_journey.txt")
    assert_equal ["HTT736"], log.most_frequent_travelers
  end
end
