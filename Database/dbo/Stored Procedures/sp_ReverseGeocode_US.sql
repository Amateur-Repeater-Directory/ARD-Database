CREATE   PROCEDURE [dbo].[sp_ReverseGeocode_US]
    @Lat float,
    @Lon float
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @pt geography = geography::Point(@Lat, @Lon, 4326);

    ----------------------------------------------------------------------
    -- 1) Nearest city from Demographics (with or without Geo column)
    ----------------------------------------------------------------------
    ;WITH nearest_city AS (
        -- Branch to use persisted Geo if it exists for speed
        SELECT TOP (1)
            d.City,
            d.County,
            d.StateId,
            d.Population,
            d.Incorporated,
            -- distance from query point to city point
            CASE 
              WHEN COL_LENGTH('dbo.Demographics','Geo') IS NOT NULL 
              THEN @pt.STDistance(d.Geo)
              ELSE @pt.STDistance(geography::Point(d.Latitude, d.Longitude, 4326))
            END AS DistM
        FROM dbo.Demographics AS d
        ORDER BY 
            CASE 
              WHEN COL_LENGTH('dbo.Demographics','Geo') IS NOT NULL 
              THEN @pt.STDistance(d.Geo)
              ELSE @pt.STDistance(geography::Point(d.Latitude, d.Longitude, 4326))
            END
    ),

    ----------------------------------------------------------------------
    -- 2) Optional polygon hits (exact state/county if TIGER polygons exist)
    ----------------------------------------------------------------------
    state_hit AS (
        SELECT TOP (1)
            s.STUSPS     AS PolyStateId,
            s.NAME       AS StateName
        FROM dbo.tl_2024_us_state AS s
        WHERE COL_LENGTH('dbo.tl_2024_us_state','geog') IS NOT NULL
          AND s.geog.STIntersects(@pt) = 1
    ),
    county_hit AS (
        SELECT TOP (1)
            c.NAME       AS PolyCounty
        FROM dbo.tl_2024_us_county AS c
        WHERE COL_LENGTH('dbo.tl_2024_us_county','geog') IS NOT NULL
          AND c.geog.STIntersects(@pt) = 1
    )

    ----------------------------------------------------------------------
    -- 3) Final select with graceful fallback when polygons aren't present
    ----------------------------------------------------------------------
    SELECT
        @Lat  AS QueryLat,
        @Lon  AS QueryLon,

        -- Prefer polygon-derived state/county when available
        COALESCE(sh.PolyStateId, nc.StateId)      AS StateId,
        sh.StateName                               AS StateName,      -- NULL if no polygons table
        COALESCE(ch.PolyCounty,  nc.County)       AS County,

        nc.City                                    AS NearestCity,
        nc.Population                              AS NearestCityPopulation,
        nc.Incorporated                            AS NearestCityIncorporated,

        nc.DistM                                   AS DistanceMetersToCity,
        nc.DistM / 1609.344                        AS DistanceMilesToCity,

        CASE 
          WHEN sh.PolyStateId IS NOT NULL AND ch.PolyCounty IS NOT NULL THEN 'polygon'
          WHEN sh.PolyStateId IS NOT NULL OR  ch.PolyCounty IS NOT NULL THEN 'mixed'
          ELSE 'nearest_city'
        END AS SourceForStateCounty
    FROM nearest_city nc
    LEFT JOIN state_hit  sh ON 1 = 1
    LEFT JOIN county_hit ch ON 1 = 1;
END
