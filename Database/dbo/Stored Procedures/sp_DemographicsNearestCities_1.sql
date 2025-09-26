CREATE PROCEDURE [dbo].[sp_DemographicsNearestCities]
    @Lat               float,
    @Lon               float,
    @TopN              int   = 20,
    @MaxRadiusMiles    float = 50.0,
    @GapMiles          float = 1.0,
    @GapRatio          float = 0.15,
    @CloseBandMiles    float = 10.0
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
    with_first_two AS
    (
        SELECT
            t.*,
            d1_m  = MAX(CASE WHEN rn = 1 THEN DistM END)   OVER (),
            d2_m  = MAX(CASE WHEN rn = 2 THEN DistM END)   OVER (),
            c1_up = MAX(CASE WHEN rn = 1 THEN UPPER(LTRIM(RTRIM(City))) END)    OVER (),
            s1_up = MAX(CASE WHEN rn = 1 THEN UPPER(LTRIM(RTRIM(StateId))) END) OVER (),
            c2_up = MAX(CASE WHEN rn = 2 THEN UPPER(LTRIM(RTRIM(City))) END)    OVER (),
            s2_up = MAX(CASE WHEN rn = 2 THEN UPPER(LTRIM(RTRIM(StateId))) END) OVER ()
        FROM topn AS t
    )
    SELECT
        wft.City,
        wft.StateId AS [State],                 -- 2-letter USPS code (existing)
        ds.[State]  AS StateName,               -- NEW: full state name
        wft.County,

        CAST(wft.DistMi AS decimal(10,3))  AS DistanceMiles,
        wft.Population,
        wft.Incorporated,
        wft.rn       AS [Rank],
        CAST(CASE WHEN wft.rn = 1 THEN 1 ELSE 0 END AS bit) AS IsDefault,

        CAST(
            CASE
                WHEN wft.d2_m IS NULL THEN 0
                WHEN ( (wft.d2_m - wft.d1_m) / @M_PER_MI ) <= @GapMiles
                     OR ( (wft.d2_m - wft.d1_m) <= (@GapRatio * wft.d1_m) )
                     OR ( (wft.d1_m / @M_PER_MI) <= @CloseBandMiles AND (wft.d2_m / @M_PER_MI) <= @CloseBandMiles )
                     OR ( wft.c1_up = wft.c2_up AND wft.s1_up <> wft.s2_up
                          AND ( (wft.d2_m - wft.d1_m) / @M_PER_MI <= @GapMiles
                                OR (wft.d2_m - wft.d1_m) <= (@GapRatio * wft.d1_m) ) )
                THEN 1 ELSE 0
            END
        AS bit) AS IsAmbiguous,

        CASE
            WHEN wft.d2_m IS NULL THEN 'single_candidate'
            WHEN ( (wft.d2_m - wft.d1_m) / @M_PER_MI ) <= @GapMiles THEN 'distance_tie'
            WHEN (wft.d2_m - wft.d1_m) <= (@GapRatio * wft.d1_m)        THEN 'distance_ratio_close'
            WHEN ( (wft.d1_m / @M_PER_MI) <= @CloseBandMiles
                   AND (wft.d2_m / @M_PER_MI) <= @CloseBandMiles ) THEN 'both_close'
            WHEN ( wft.c1_up = wft.c2_up AND wft.s1_up <> wft.s2_up
                   AND ( (wft.d2_m - wft.d1_m) / @M_PER_MI <= @GapMiles
                         OR (wft.d2_m - wft.d1_m) <= (@GapRatio * wft.d1_m) ) ) THEN 'same_name_cross_state'
            ELSE 'clear_winner'
        END AS AmbiguityReason
    FROM with_first_two AS wft
    LEFT JOIN dbo.DemographicStates AS ds
      ON ds.StateId = wft.StateId
    ORDER BY wft.rn;
END