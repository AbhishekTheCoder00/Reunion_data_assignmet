SELECT * FROM timeseriess limit 5;

WITH sorted_data AS (
    SELECT
        Name,
        Start,
        End,
        Activity,
        ROW_NUMBER() OVER (PARTITION BY Name ORDER BY Start) AS rn
    FROM
        timeseriess
),
grouped_data AS (
    SELECT
        Name,
        Start,
        End,
        Activity,
        rn,
        SUM(is_new_period) OVER (PARTITION BY Name ORDER BY Start) AS group_id
    FROM (
        SELECT
            Name,
            Start,
            End,
            Activity,
            rn,
            CASE
                WHEN LAG(End) OVER (PARTITION BY Name ORDER BY Start) >= Start THEN 0
                ELSE 1
            END AS is_new_period
        FROM
            sorted_data
    ) AS sub
)
SELECT
    Name,
    MIN(Start) AS Start,
    MAX(End) AS End,
    GROUP_CONCAT(Activity, ', ') AS Activities
FROM
    grouped_data
GROUP BY
    Name,
    group_id
ORDER BY
    Name,
    Start;


