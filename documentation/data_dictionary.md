# Data Dictionary

## Project Overview

This document defines the variables used in the Lannkz YouTube Packaging & Retention Analysis project.

The dataset contains 58 long-form YouTube videos. Data was exported from YouTube Studio, cleaned in Excel, and supplemented with manually assigned content classifications.

## YouTube Studio Variables

| Variable | Meaning | Why We Need It |
|---|---|---|
| `video_id` | Unique YouTube video identifier | Identifies each video and prevents duplicate records |
| `video_title` | Published title of the video | Identifies videos and supports future title analysis |
| `publish_date` | Date the video was published | Enables time-based analysis and provides context for channel growth |
| `video_duration_seconds` | Total video length in seconds | Allows comparisons of video length and retention |
| `engaged_views` | Views meeting YouTube's engaged-view criteria | Primary view metric for comparisons across the dataset |
| `avg_view_duration` | Average view duration in time format | Original retention metric from YouTube Studio |
| `avg_percentage_viewed` | Average percentage of a video watched | Primary retention metric for comparing videos of different lengths |
| `views` | YouTube's reported view count | Secondary reach metric; interpretation must account for the August 24, 2026 counting change |
| `watch_time_hours` | Total accumulated watch time in hours | Measures overall audience consumption |
| `subscribers_gained` | Subscribers attributed to the video | Measures subscriber acquisition |
| `impressions` | Number of eligible thumbnail impressions | Provides context for video distribution and CTR |
| `ctr` | Percentage of impressions that resulted in views | Primary metric for evaluating title and thumbnail packaging |
| `avd_seconds` | Average view duration converted into seconds | Enables numerical calculations and comparisons |

## Manually Tagged Variables

These variables were assigned by reviewing the subject, purpose, and context of each video. Ratings were not assigned based on performance metrics.

### `content_type`

Each video receives one primary content classification.

| Category | Definition |
|---|---|
| Scouting Report | Individual player evaluation in the Blue Lock Scouting Report series |
| Tactical Analysis | Examination of formations, positions, strategies, coaching, or football mechanics |
| Theory / Prediction | Predictions or speculation about future developments |
| Match Analysis | Breakdown or evaluation of a specific match, including match ratings |
| General Analysis | Broader rankings, critiques, and discussions not primarily tactical, predictive, or scouting |

### `football_relevance`

Measures how strongly real-world football principles influence the video's analysis.

| Rating | Definition |
|---|---|
| Low | Primarily focuses on Blue Lock storytelling, characters, philosophies, or community discussion, with little real-world football analysis |
| Medium | Meaningfully combines Blue Lock-specific analysis with real-world football principles, without either clearly dominating |
| High | Real-world football principles drive most of the video's analysis, such as tactical systems, positional suitability, or realistic player evaluation |

### `release_relevance`

Measures how closely the topic was connected to manga or anime developments **at the time of upload**, not at the time of analysis.

| Rating | Definition |
|---|---|
| Low | Topic had little connection to current manga/anime developments at upload |
| Medium | Topic was connected to an ongoing storyline or relevant character at upload |
| High | Topic directly addressed a recent chapter, episode, reveal, or major development at upload |

## Calculated Variables

| Variable | Calculation | Purpose |
|---|---|---|
| `avd_duration_ratio` | `avd_seconds / video_duration_seconds` | Independently estimates the fraction of video duration watched |
| `retention_difference` | `ABS(avd_duration_ratio * 100 - avg_percentage_viewed)` | Checks the difference between calculated and reported retention in percentage points |

### Retention Calculation Note

`avg_percentage_viewed` is the primary retention metric because it is reported directly by YouTube Studio.

`avd_duration_ratio` is retained as a validation metric. Small discrepancies can arise because exported average view duration is represented in whole seconds, while reported retention percentages may use more precise underlying values.

During validation, the maximum observed discrepancy was approximately 0.391 percentage points.

## Data Quality and Interpretation Notes

- The dataset contains 58 long-form videos.
- All videos have a unique video ID.
- All 58 videos have been assigned a `content_type`, `football_relevance`, and `release_relevance` classification.
- The `ctr` and `avg_percentage_viewed` columns are stored as percentage values, such as `4.5` for 4.5%, rather than decimal proportions.
- YouTube's view-counting methodology changed on August 24, 2026. `engaged_views` is preferred for comparisons across the dataset, while `views` is retained as a secondary metric.
- Manually assigned categories are qualitative judgments and should not be treated as objective measurements.
- Relationships between content classifications and performance should be interpreted as associations, not proof of causation.

## Potential Future Variables

The following variables may be added if they are useful for answering the project's research questions:

- `title_style` — classification of title structure or presentation.
- `thumbnail_style` — classification of thumbnail presentation.
- `hook_style` — classification of the video's opening approach.

These variables have not yet been collected and are not part of the current dataset.