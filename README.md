# ActBlue Interview Prep: Seth Williams

## Overview

This repository contains Ruby solutions to object-oriented programming challenges
prepared in practice for the ActBlue technical assessment through Karat.

## Personal Note

I was unsure about what questions would be asked beyond the point I reached in the initial interview, so I worked through likely follow-up scenarios with Claude to prepare.
I also added business value for each scenario to help with the 'why' of each issue. That's just for me personally. 

## Files

```
actblue-interview/
├── log_challenge.rb        # solution only
└── test/
    ├── test_log_file.rb    # full test suite
    └── fixtures/
        ├── basic.txt               # happy path — 2 complete, 1 incomplete
        ├── multi_journey.txt       # same vehicle completes 2 journeys
        ├── uturn.txt               # entry East, exit West — should not count
        ├── busiest_booth.txt       # clear single booth winner for traffic test
        └── empty.txt               # empty log file
```

## Challenge Description

Given a log file of vehicle recordings at interstate booths, implement a `LogFile`
class that parses and analyzes the data.

## Running

```bash
ruby test/test_log_file.rb
```

Tests use Ruby's built-in `minitest` framework and run automatically.

---

### Data Format

Each line in the log file represents a single booth recording:

```
1000.589 HTT736 B1E entry
```

| Field | Description |
|-------|-------------|
| `timestamp` | Float, seconds since epoch |
| `license_plate` | Vehicle identifier |
| `booth_id + direction` | Booth ID with direction appended (`E` = East, `W` = West) |
| `booth_type` | `entry`, `exit`, or `main_road` |

Records are in chronological order — no sorting required.

### Booth Types

- **entry** — vehicle entering the interstate
- **exit** — vehicle leaving the interstate
- **main_road** — vehicle passing a mid-route booth (ignored for journey tracking)

### Journey Rules

- A complete journey is an `entry` → `exit` pair for the same vehicle traveling the same direction
- Direction must match — an East entry cannot be closed by a West exit (no U-turns)
- If a vehicle has two consecutive entries before an exit, the first is discarded
- Incomplete journeys do not count toward any totals

---

## Methods Implemented

### `count_journeys`
Returns the total number of complete journeys across all vehicles.

**Business value:** Baseline throughput metric for the interstate system. Used to measure traffic volume over time, compare peak vs off-peak periods, and inform infrastructure capacity planning.

### `incomplete_journeys`
Returns an array of license plates for vehicles that entered but never exited.

**Business value:** Identifies vehicles still on the interstate at the time of the log snapshot, useful for real-time traffic monitoring. A high incomplete rate may also indicate a malfunctioning exit booth or a data pipeline issue.

### `average_journey_time`
Returns the average duration in seconds across all complete journeys, rounded to 2 decimal places.

**Business value:** Core performance indicator for the interstate system. A rising average journey time signals congestion. Can be tracked over time to measure the impact of infrastructure changes, lane additions, or speed limit adjustments.

### `journeys_by_vehicle`
Returns a hash of `license_plate => journey_count` for all vehicles that appeared in the log, including those with 0 complete journeys.

**Business value:** Identifies frequent users of the interstate. Useful for toll billing, commuter pattern analysis, and flagging vehicles that repeatedly enter without exiting — which could indicate toll evasion or a vehicle in distress.

### `most_frequent_travelers`
Returns an array of license plates tied for the highest journey count.

**Business value:** Identifies the heaviest interstate users. Useful for frequent traveler programs, commercial vehicle tracking, and flagging vehicles that may warrant additional inspection.

### `longest_journey`
Returns a hash of `{ license_plate, duration }` for the single longest complete journey.

**Business value:** Flags outliers — an unusually long journey may indicate a breakdown, an accident, or a driver stopped on the shoulder. Useful for incident detection and roadside assistance dispatch.

### `journeys_by_direction`
Returns a hash of `{ "East" => count, "West" => count }` for complete journeys.

**Business value:** Measures directional traffic flow imbalance. Useful for identifying commuter patterns (e.g. heavy westbound in the morning, eastbound in the evening) and optimizing dynamic lane allocation.

### `busiest_booth`
Returns an array of booth ID(s) with the highest total traffic recordings.

**Business value:** Informs maintenance scheduling and staffing. A booth handling disproportionate traffic is a bottleneck risk and may need hardware upgrades or an additional lane.
