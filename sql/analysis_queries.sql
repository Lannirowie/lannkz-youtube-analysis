-- Lannkz YouTube Analysis | SQLite 3.25+ (window functions)
-- Run against the `videos` table populated from data/processed/lannkz_videos_cleaned.csv.
-- CTR and avg_percentage_viewed are percentage points (e.g. 4.9 = 4.9%).
-- Engaged views are lifetime totals at the export snapshot, not age-normalized.
-- Unweighted averages are per-video averages.

-- 01. Channel Performance Baseline

SELECT
    COUNT(*) AS total_videos,
    ROUND(AVG(ctr), 2) AS avg_ctr,
    ROUND(AVG(avg_percentage_viewed), 2) AS avg_retention,
    ROUND(AVG(engaged_views), 0) AS avg_engaged_views
FROM videos;



-- 02. Performance by Content Type
-- Compare CTR, retention, and engaged views by format.

SELECT
    content_type,
    COUNT(*) AS video_count,
    ROUND(AVG(ctr), 2) AS avg_ctr,
    ROUND(AVG(avg_percentage_viewed), 2) AS avg_retention,
    ROUND(AVG(engaged_views), 0) AS avg_engaged_views
FROM videos
GROUP BY content_type
ORDER BY avg_engaged_views DESC;



-- 03. Median Engaged Views by Content Type
-- Reduces the influence of unusually successful videos.

WITH ranked AS (
    SELECT
        content_type,
        engaged_views,
        ROW_NUMBER() OVER (
            PARTITION BY content_type
            ORDER BY engaged_views
        ) AS row_num,
        COUNT(*) OVER (
            PARTITION BY content_type
        ) AS total
    FROM videos
)
SELECT
    content_type,
    MAX(total) AS video_count,
    ROUND(AVG(engaged_views), 0) AS median_engaged_views
FROM ranked
WHERE row_num IN (
    (total + 1) / 2,
    (total + 2) / 2
)
GROUP BY content_type
ORDER BY median_engaged_views DESC;



-- 04. Performance by Release Relevance
-- Compare timely videos against evergreen content.
-- Relevance was assessed at each video's publication date.

SELECT
    release_relevance,
    COUNT(*) AS video_count,
    ROUND(AVG(ctr), 2) AS avg_ctr,
    ROUND(AVG(avg_percentage_viewed), 2) AS avg_retention,
    ROUND(AVG(engaged_views), 0) AS avg_engaged_views
FROM videos
GROUP BY release_relevance
ORDER BY
    CASE release_relevance
        WHEN 'Low' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'High' THEN 3
    END;



-- 05. Performance by Football Relevance
-- Compare videos by real-world football connections in topic and/or analysis.

SELECT
    football_relevance,
    COUNT(*) AS video_count,
    ROUND(AVG(ctr), 2) AS avg_ctr,
    ROUND(AVG(avg_percentage_viewed), 2) AS avg_retention,
    ROUND(AVG(engaged_views), 0) AS avg_engaged_views
FROM videos
GROUP BY football_relevance
ORDER BY
    CASE football_relevance
        WHEN 'Low' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'High' THEN 3
    END;



-- 06. Performance by Video Duration
-- Compare percentage retention, watch duration, and reach.
-- Lifetime engaged views may be influenced by video age.

SELECT
    CASE
        WHEN video_duration_seconds < 600 THEN 'Under 10 minutes'
        WHEN video_duration_seconds < 900 THEN '10-15 minutes'
        ELSE '15+ minutes'
    END AS duration_group,
    COUNT(*) AS video_count,
    ROUND(AVG(avg_percentage_viewed), 2) AS avg_retention,
    ROUND(AVG(avd_seconds) / 60.0, 2) AS avg_minutes_watched,
    ROUND(AVG(engaged_views), 0) AS avg_engaged_views
FROM videos
GROUP BY duration_group
ORDER BY MIN(video_duration_seconds);



-- 07. CTR vs. Retention by Content Type
-- Investigate whether click-through rate and retention
-- have different relationships across video formats.
-- Correlation does not establish causation.

WITH means AS (
    SELECT
        content_type,
        AVG(ctr) AS avg_ctr,
        AVG(avg_percentage_viewed) AS avg_retention
    FROM videos
    GROUP BY content_type
),
centered AS (
    SELECT
        v.content_type,
        v.ctr - m.avg_ctr AS x,
        v.avg_percentage_viewed - m.avg_retention AS y
    FROM videos v
    JOIN means m
        ON v.content_type = m.content_type
)
SELECT
    content_type,
    COUNT(*) AS video_count,
    ROUND(
        SUM(x * y) /
        NULLIF(SQRT(SUM(x * x) * SUM(y * y)), 0),
        3
    ) AS ctr_retention_correlation
FROM centered
GROUP BY content_type
ORDER BY video_count DESC;

-- 08. Football Relevance x Release Relevance (MAIN RESEARCH QUESTION)
-- Median uses SQLite integer division; groups with small n are exploratory.
WITH ranked AS (
    SELECT football_relevance, release_relevance, ctr,
           avg_percentage_viewed, engaged_views,
           ROW_NUMBER() OVER (
               PARTITION BY football_relevance, release_relevance
               ORDER BY engaged_views
           ) AS rn,
           COUNT(*) OVER (
               PARTITION BY football_relevance, release_relevance
           ) AS n
    FROM videos
)
SELECT football_relevance, release_relevance,
       COUNT(*) AS video_count,
       ROUND(AVG(ctr), 2) AS avg_ctr,
       ROUND(AVG(avg_percentage_viewed), 2) AS avg_retention,
       ROUND(AVG(engaged_views), 0) AS mean_engaged_views,
       ROUND(AVG(CASE WHEN rn IN ((n+1)/2, (n+2)/2)
                      THEN engaged_views END), 0) AS median_engaged_views
FROM ranked
GROUP BY football_relevance, release_relevance
ORDER BY CASE football_relevance WHEN 'Low' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END,
         CASE release_relevance WHEN 'Low' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END;

-- 09. Release Relevance WITHIN Content Types (Finding 5)
WITH ranked AS (
    SELECT content_type, release_relevance, ctr,
           avg_percentage_viewed, engaged_views,
           ROW_NUMBER() OVER (
               PARTITION BY content_type, release_relevance
               ORDER BY engaged_views
           ) AS rn,
           COUNT(*) OVER (
               PARTITION BY content_type, release_relevance
           ) AS n
    FROM videos
)
SELECT content_type, release_relevance,
       COUNT(*) AS video_count,
       ROUND(AVG(ctr), 2) AS avg_ctr,
       ROUND(AVG(avg_percentage_viewed), 2) AS avg_retention,
       ROUND(AVG(engaged_views), 0) AS mean_engaged_views,
       ROUND(AVG(CASE WHEN rn IN ((n+1)/2, (n+2)/2)
                      THEN engaged_views END), 0) AS median_engaged_views
FROM ranked
GROUP BY content_type, release_relevance
ORDER BY content_type,
         CASE release_relevance WHEN 'Low' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END;

-- 10. Football Relevance WITHIN Content Types
-- Caution: content type and football relevance overlap strongly.
WITH ranked AS (
    SELECT content_type, football_relevance, ctr,
           avg_percentage_viewed, engaged_views,
           ROW_NUMBER() OVER (
               PARTITION BY content_type, football_relevance
               ORDER BY engaged_views
           ) AS rn,
           COUNT(*) OVER (
               PARTITION BY content_type, football_relevance
           ) AS n
    FROM videos
)
SELECT content_type, football_relevance,
       COUNT(*) AS video_count,
       ROUND(AVG(ctr), 2) AS avg_ctr,
       ROUND(AVG(avg_percentage_viewed), 2) AS avg_retention,
       ROUND(AVG(engaged_views), 0) AS mean_engaged_views,
       ROUND(AVG(CASE WHEN rn IN ((n+1)/2, (n+2)/2)
                      THEN engaged_views END), 0) AS median_engaged_views
FROM ranked
GROUP BY content_type, football_relevance
ORDER BY content_type,
         CASE football_relevance WHEN 'Low' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END;

-- 11. FC25 Sensitivity Check: General Analysis by Football Relevance
-- These two creative player-card videos are retained in the full dataset.
-- Exclude them ONLY in the sensitivity scenario using their stable video IDs.
WITH scenarios AS (
    SELECT 'All General Analysis' AS scenario, *
    FROM videos WHERE content_type = 'General Analysis'
    UNION ALL
    SELECT 'Excluding two FC25 videos' AS scenario, *
    FROM videos
    WHERE content_type = 'General Analysis'
      AND video_id NOT IN ('tsLxYAb1VHQ', 'VXTR3aEmaD0')
), ranked AS (
    SELECT scenario, football_relevance, engaged_views, ctr,
           avg_percentage_viewed,
           ROW_NUMBER() OVER (
               PARTITION BY scenario, football_relevance
               ORDER BY engaged_views
           ) AS rn,
           COUNT(*) OVER (
               PARTITION BY scenario, football_relevance
           ) AS n
    FROM scenarios
)
SELECT scenario, football_relevance,
       COUNT(*) AS video_count,
       ROUND(AVG(ctr), 2) AS avg_ctr,
       ROUND(AVG(avg_percentage_viewed), 2) AS avg_retention,
       ROUND(AVG(engaged_views), 0) AS mean_engaged_views,
       ROUND(AVG(CASE WHEN rn IN ((n+1)/2, (n+2)/2)
                      THEN engaged_views END), 0) AS median_engaged_views
FROM ranked
GROUP BY scenario, football_relevance
ORDER BY scenario,
         CASE football_relevance WHEN 'Low' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END;

-- 12. Content Type Composition of Each Relevance Combination
-- Helps identify confounding by video format.
SELECT football_relevance, release_relevance, content_type,
       COUNT(*) AS video_count
FROM videos
GROUP BY football_relevance, release_relevance, content_type
ORDER BY football_relevance, release_relevance, video_count DESC;

-- 13. Overall CTR vs. Retention Pearson Correlation
-- Descriptive association; not a causal estimate.
WITH means AS (
    SELECT AVG(ctr) AS mx, AVG(avg_percentage_viewed) AS my FROM videos
), centered AS (
    SELECT ctr - mx AS x, avg_percentage_viewed - my AS y
    FROM videos CROSS JOIN means
)
SELECT COUNT(*) AS video_count,
       ROUND(SUM(x*y) / NULLIF(SQRT(SUM(x*x)*SUM(y*y)),0), 3)
           AS ctr_retention_correlation
FROM centered;
