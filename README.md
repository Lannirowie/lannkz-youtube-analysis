
# Lannkz YouTube Packaging & Retention Analysis

## Project Overview

An end-to-end analysis of 58 YouTube videos from
Lannkz, a Blue Lock tactical-analysis channel.

The project investigates three questions:

1. What makes viewers click?
2. What makes viewers stay?
3. What should change in future uploads?

## Power BI Dashboard

![Lannkz YouTube Analytics Dashboard](images/dashboard_overview.png)

The interactive dashboard summarizes performance
across 58 videos, including:

- Average click-through rate (CTR)
- Average viewer retention
- Engaged views by content type
- Retention by video duration
- Filters for content type and release relevance

The dashboard was developed using Power BI Desktop.

## Tools Used

- Excel and Power Query — data cleaning
- SQLite — exploratory data analysis
- Power BI — interactive dashboard

## Project Workflow

1. Exported YouTube Studio analytics.
2. Cleaned and validated the dataset.
3. Categorized videos by content type, football
   relevance, and release relevance.
4. Analyzed CTR, retention, engaged views, and duration.
5. Built an interactive Power BI dashboard.
6. Developed evidence-based content recommendations.



## Key Findings

### 1. Scouting Reports Show Strong Typical Performance
- Highest median engaged views: 30,175.
- Highest average retention: 44.24%.
- Based on 21 videos.

### 2. Longer Videos Generate More Watch Time per View
- Under 10 minutes: 3.60 minutes average view duration.
- 10–15 minutes: 4.88 minutes.
- 15+ minutes: 6.40 minutes.
- Longer videos had lower percentage retention.

### 3. CTR and Retention Vary by Content Type
- General Analysis: r = -0.627.
- Tactical Analysis: r = -0.535.
- Scouting Reports: r = +0.309.
- These relationships are correlations, not causal effects.

### 4. Timely Videos Show Higher Average Reach
- High release relevance: 75,812 average engaged views.
- Low release relevance: 44,426 average engaged views.
- Results may be influenced by outliers and video age.

## Recommendations

- Maintain Scouting Reports as a core content format.
- Choose video length based on topic depth rather than
  percentage retention alone.
- Review high-CTR, low-retention videos for possible
  mismatches between packaging and opening content.
- Balance timely manga-related videos with evergreen analysis.

## Limitations

- Observational analysis of 58 videos from one channel.
- Lifetime performance metrics are influenced by video age.
- Some content categories have small sample sizes.
- Correlations do not establish causation.
- YouTube's view-counting methodology changed in August 2026;
  engaged views were used for more consistent comparisons.
