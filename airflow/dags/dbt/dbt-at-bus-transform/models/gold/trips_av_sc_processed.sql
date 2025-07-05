{{
  config(
    materialized='table',
    description='Processed trips data with trip durations, waiting times, and time slots for Avondale to Sagrada Cantina routes'
  )
}}

With trips_with_multiple_stops AS (SELECT 
    t.*
  FROM {{ ref('trips_consolidated') }} t
  INNER JOIN (
    SELECT 
      trip_id, 
      service_date, 
      route_id,
      COUNT(*) as stop_count
    FROM {{ ref('trips_consolidated') }}
    GROUP BY trip_id, service_date, route_id
    HAVING COUNT(*) > 1
  ) filtered ON t.trip_id = filtered.trip_id 
    AND t.service_date = filtered.service_date 
    AND t.route_id = filtered.route_id
  WHERE t.route_id != '191-203'
),
trips_with_datetime AS (
  SELECT 
    stop_id,
    trip_id,
    route_id,
    trip_start_time,
    arrival_time,
    -- Parse service_date as date
    PARSE_DATE('%Y-%m-%d', service_date) as service_date,
    -- Combine service_date and arrival_time into datetime
    PARSE_DATETIME('%Y-%m-%d %H:%M:%S', CONCAT(service_date, ' ', arrival_time)) as start_datetime
  FROM trips_with_multiple_stops
),
trips_with_duration AS (
-- Calculate trip duration and arrival datetime
  SELECT 
    *,
    -- Get the next arrival time for the same trip (final destination)
    LEAD(start_datetime) OVER (
      PARTITION BY trip_id, service_date 
      ORDER BY start_datetime ASC
    ) as arrival_datetime,
    -- Calculate trip duration in minutes
    TIMESTAMP_DIFF(
      LEAD(start_datetime) OVER (
        PARTITION BY trip_id, service_date 
        ORDER BY start_datetime ASC
      ),
      start_datetime,
      MINUTE
    ) as trip_duration
  FROM trips_with_datetime
),
trips_cleaned as (
  SELECT *
  FROM trips_with_duration
  WHERE trip_duration IS NOT NULL 
  ORDER BY start_datetime ASC
),
final_trips AS (
  SELECT 
    *,
    -- Calculate next route bus waiting time
    TIMESTAMP_DIFF(
      LEAD(start_datetime) OVER (
        PARTITION BY route_id, service_date 
        ORDER BY start_datetime ASC
      ),
      start_datetime,
      MINUTE
    ) as next_route_bus_waiting_time,
    
    -- Calculate next bus waiting time (any route)
    TIMESTAMP_DIFF(
      LEAD(start_datetime) OVER (
        PARTITION BY service_date 
        ORDER BY start_datetime ASC
      ),
      start_datetime,
      MINUTE
    ) as next_bus_waiting_time,
    
    -- Get day of week
    FORMAT_DATE('%A', service_date) as day_of_timeslot,
    
    -- Create time slot based on hour
    CASE 
      WHEN EXTRACT(HOUR FROM start_datetime) >= 11 AND EXTRACT(HOUR FROM start_datetime) < 12 
        THEN 'Start at 12'
      WHEN EXTRACT(HOUR FROM start_datetime) >= 10 AND EXTRACT(HOUR FROM start_datetime) < 11 
        THEN 'Start at 11'
      ELSE 'Other'
    END as time_slot,
    
    -- Get weekday number (1=Monday, 7=Sunday)
    EXTRACT(DAYOFWEEK FROM start_datetime) as weekday,
    
    -- Add walk time to trip duration based on route_id
    CASE 
      WHEN route_id = '195-203' THEN trip_duration + 25
      WHEN route_id = '22R-202' THEN trip_duration + 22
      WHEN route_id = '18-202' THEN trip_duration + 17
      ELSE -1
    END as trip_duration_with_walk
  FROM trips_cleaned
)
SELECT 
  ft.stop_id,
  ft.trip_id,
  ft.route_id,
  s.stop_name,
  ft.trip_start_time,
  ft.service_date,
--   ft.arrival_time,
  ft.start_datetime,
  ft.arrival_datetime,
  ft.trip_duration,
  ft.trip_duration_with_walk,
  ft.next_route_bus_waiting_time,
  ft.next_bus_waiting_time,
  ft.day_of_timeslot,
  ft.time_slot,
  ft.weekday
FROM final_trips ft
LEFT JOIN {{ ref('stops_consolidated') }} s 
ON ft.stop_id = s.stop_id AND ft.service_date = s.api_date_ingestion