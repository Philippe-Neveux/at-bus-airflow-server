{{ config(materialized='table') }}

SELECT Time_spent_Alone as time_spent_alone,
      Stage_fear as stage_fear,
      Social_event_attendance as social_event_attendance,
      Going_outside as going_outside,
      Drained_after_socializing as drained_after_socializing,
      Friends_circle_size as friends_circle_size,
      Post_frequency as post_frequency,
      Personality as personality
FROM {{ ref('personality_dataset_updated') }}