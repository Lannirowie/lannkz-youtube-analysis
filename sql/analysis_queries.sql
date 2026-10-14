

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
-- Compare videos based on their use of real-world football analysis.

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
        SQRT(SUM(x * x) * SUM(y * y)),
        3
    ) AS ctr_retention_correlation
FROM centered
GROUP BY content_type
ORDER BY video_count DESC;


