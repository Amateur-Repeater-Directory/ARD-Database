CREATE   PROCEDURE dbo.sp_ReverseGeocode_US
  @Lat float, @Lon float
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @pt geography = geography::Point(@Lat, @Lon, 4326);

  -- optional hits
  CREATE TABLE #place_hit (PlaceName nvarchar(100), PlaceStateId varchar(2), HitType varchar(10));
  CREATE TABLE #state_hit (PolyStateId varchar(2), StateName nvarchar(100));
  CREATE TABLE #county_hit (PolyCounty nvarchar(100));

  -- Try place polygons (table assumed: dbo.tl_2024_us_place(NAME, STUSPS, geog geography))
  IF OBJECT_ID('dbo.tl_2024_us_place','U') IS NOT NULL
     AND COL_LENGTH('dbo.tl_2024_us_place','geog')   IS NOT NULL
     AND COL_LENGTH('dbo.tl_2024_us_place','NAME')   IS NOT NULL
     AND COL_LENGTH('dbo.tl_2024_us_place','STUSPS') IS NOT NULL
  BEGIN
    -- inside first
    EXEC sp_executesql
      N'INSERT TOP (1) INTO #place_hit(PlaceName,PlaceStateId,HitType)
        SELECT p.NAME, p.STUSPS, ''inside''
        FROM dbo.tl_2024_us_place p
        WHERE p.geog.STIntersects(@pt)=1;',
      N'@pt geography', @pt=@pt;

    -- else nearest boundary
    IF NOT EXISTS(SELECT 1 FROM #place_hit)
    BEGIN
      EXEC sp_executesql
        N'INSERT TOP (1) INTO #place_hit(PlaceName,PlaceStateId,HitType)
          SELECT p.NAME, p.STUSPS, ''nearest''
          FROM dbo.tl_2024_us_place p
          ORDER BY p.geog.STDistance(@pt);',
        N'@pt geography', @pt=@pt;
    END
  END

  -- optional state polygon (dbo.tl_2024_us_state(STUSPS, NAME, geog))
  IF OBJECT_ID('dbo.tl_2024_us_state','U') IS NOT NULL
     AND COL_LENGTH('dbo.tl_2024_us_state','geog') IS NOT NULL
  BEGIN
    EXEC sp_executesql
      N'INSERT TOP (1) INTO #state_hit(PolyStateId,StateName)
        SELECT s.STUSPS, s.NAME FROM dbo.tl_2024_us_state s
        WHERE s.geog.STIntersects(@pt)=1;',
      N'@pt geography', @pt=@pt;
  END

  -- optional county polygon (dbo.tl_2024_us_county(NAME, geog))
  IF OBJECT_ID('dbo.tl_2024_us_county','U') IS NOT NULL
     AND COL_LENGTH('dbo.tl_2024_us_county','geog') IS NOT NULL
  BEGIN
    EXEC sp_executesql
      N'INSERT TOP (1) INTO #county_hit(PolyCounty)
        SELECT c.NAME FROM dbo.tl_2024_us_county c
        WHERE c.geog.STIntersects(@pt)=1;',
      N'@pt geography', @pt=@pt;
  END

  ;WITH nearest_city AS (
    SELECT TOP (1)
      d.Id, d.City, d.County, d.StateId, d.Population, d.Incorporated,
      @pt.STDistance(d.Geo) AS DistM
    FROM dbo.Demographics d
    ORDER BY @pt.STDistance(d.Geo)
  ),
  polygon_city AS (
    -- try to match polygon name/state to your Demographics row(s)
    SELECT TOP (1)
      d.Id, d.City, d.County, d.StateId, d.Population, d.Incorporated,
      @pt.STDistance(d.Geo) AS DistM
    FROM #place_hit ph
    JOIN dbo.Demographics d
      ON UPPER(LTRIM(RTRIM(d.StateId))) = UPPER(ph.PlaceStateId)
     AND UPPER(LTRIM(RTRIM(d.City)))    = UPPER(LTRIM(RTRIM(ph.PlaceName)))
    ORDER BY d.Population DESC, @pt.STDistance(d.Geo)
  )
  SELECT
    @Lat AS QueryLat, @Lon AS QueryLon,
    COALESCE(sh.PolyStateId, pc.StateId, nc.StateId) AS StateId,
    sh.StateName                                      AS StateName,
    COALESCE(ch.PolyCounty,  pc.County,  nc.County)   AS County,
    COALESCE(pc.City, nc.City)                        AS City,
    COALESCE(pc.Population, nc.Population)            AS Population,
    COALESCE(pc.Incorporated, nc.Incorporated)        AS Incorporated,
    COALESCE(pc.DistM, nc.DistM)                      AS DistanceMetersToCity,
    COALESCE(pc.DistM, nc.DistM) / 1609.344           AS DistanceMilesToCity,
    CASE
      WHEN EXISTS(SELECT 1 FROM #place_hit) AND EXISTS(SELECT 1 FROM polygon_city) THEN 'place_polygon'
      WHEN EXISTS(SELECT 1 FROM #place_hit) THEN 'place_polygon_unmatched_fallback'
      WHEN sh.PolyStateId IS NOT NULL OR ch.PolyCounty IS NOT NULL THEN 'mixed'
      ELSE 'nearest_city'
    END AS Source
  FROM nearest_city nc
  OUTER APPLY (SELECT TOP 1 * FROM polygon_city) pc
  LEFT JOIN #state_hit sh ON 1=1
  LEFT JOIN #county_hit ch ON 1=1;
END