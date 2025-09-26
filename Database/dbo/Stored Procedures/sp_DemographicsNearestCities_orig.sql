CREATE   PROCEDURE [dbo].[sp_DemographicsNearestCities_orig]
    @Lat               float,
    @Lon               float,
    @TopN              int   = 5,      -- how many rows to return
    @MaxRadiusMiles    float = 50.0,   -- prefer results within this radius, but still return TopN overall
    @GapMiles          float = 1.0,    -- ambiguity rule: absolute gap in miles between #1 and #2
    @GapRatio          float = 0.15,   -- ambiguity rule: relative gap (% of #1 distance)
    @CloseBandMiles    float = 10.0    -- ambiguity rule: both #1 and #2 are “nearby”
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @pt geography = geography::Point(@Lat, @Lon, 4326);
    DECLARE @M_PER_MI float = 1609.344;

    ;WITH candidates AS
    (
        SELECT
            d.City,
            d.StateId,
            d.County,
            d.Population,
            d.Incorporated,
            DistM   = @pt.STDistance(d.Geo),
            DistMi  = @pt.STDistance(d.Geo) / @M_PER_MI
        FROM dbo.Demographics AS d
    ),
    -- Prefer rows within @MaxRadiusMiles, but still allow outside if needed
    pref AS
    (
        SELECT
            *,
            PreferFlag = CASE WHEN DistMi <= @MaxRadiusMiles THEN 0 ELSE 1 END
        FROM candidates
    ),
    topn AS
    (
        SELECT TOP (@TopN)
            City,
            StateId,
            County,
            Population,
            Incorporated,
            DistM,
            DistMi,
            rn = ROW_NUMBER() OVER (ORDER BY PreferFlag, DistM, City, StateId)
        FROM pref
        ORDER BY PreferFlag, DistM, City, StateId
    ),
    -- Extract first/second rows’ values for ambiguity checks
    with_first_two AS
    (
        SELECT
            t.*,
            d1_m  = MAX(CASE WHEN rn = 1 THEN DistM END)   OVER (),
            d2_m  = MAX(CASE WHEN rn = 2 THEN DistM END)   OVER (),
            c1_up = MAX(CASE WHEN rn = 1 THEN UPPER(LTRIM(RTRIM(City))) END)   OVER (),
            s1_up = MAX(CASE WHEN rn = 1 THEN UPPER(LTRIM(RTRIM(StateId))) END)OVER (),
            c2_up = MAX(CASE WHEN rn = 2 THEN UPPER(LTRIM(RTRIM(City))) END)   OVER (),
            s2_up = MAX(CASE WHEN rn = 2 THEN UPPER(LTRIM(RTRIM(StateId))) END)OVER ()
        FROM topn AS t
    )
    SELECT
        City,
        StateId AS [State],
        County,

        -- helpful extras:
        CAST(DistMi AS decimal(10,3))  AS DistanceMiles,
        Population,
        Incorporated,
        rn       AS [Rank],
        CAST(CASE WHEN rn = 1 THEN 1 ELSE 0 END AS bit) AS IsDefault,

        -- same value on every row in this result set (overall ambiguity flags/reason)
        CAST(
            CASE
                WHEN d2_m IS NULL THEN 0
                WHEN ( (d2_m - d1_m) / @M_PER_MI ) <= @GapMiles
                     OR ( (d2_m - d1_m) <= (@GapRatio * d1_m) )
                     OR ( (d1_m / @M_PER_MI) <= @CloseBandMiles AND (d2_m / @M_PER_MI) <= @CloseBandMiles )
                     OR ( c1_up = c2_up AND s1_up <> s2_up
                          AND ( (d2_m - d1_m) / @M_PER_MI <= @GapMiles
                                OR (d2_m - d1_m) <= (@GapRatio * d1_m) ) )
                THEN 1 ELSE 0
            END
        AS bit) AS IsAmbiguous,

        CASE
            WHEN d2_m IS NULL THEN 'single_candidate'
            WHEN ( (d2_m - d1_m) / @M_PER_MI ) <= @GapMiles THEN 'distance_tie'
            WHEN (d2_m - d1_m) <= (@GapRatio * d1_m)        THEN 'distance_ratio_close'
            WHEN ( (d1_m / @M_PER_MI) <= @CloseBandMiles
                   AND (d2_m / @M_PER_MI) <= @CloseBandMiles ) THEN 'both_close'
            WHEN ( c1_up = c2_up AND s1_up <> s2_up
                   AND ( (d2_m - d1_m) / @M_PER_MI <= @GapMiles
                         OR (d2_m - d1_m) <= (@GapRatio * d1_m) ) ) THEN 'same_name_cross_state'
            ELSE 'clear_winner'
        END AS AmbiguityReason
    FROM with_first_two
    ORDER BY rn;
END