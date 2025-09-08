CREATE PROCEDURE [dbo].[ElevationMap_GetLatestSamples]
  @AccountId UNIQUEIDENTIFIER,
  @LocationId UNIQUEIDENTIFIER,
  @RepeaterId UNIQUEIDENTIFIER
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @MapId INT;

  SELECT TOP (1) @MapId = ElevationMapId
  FROM dbo.ElevationMap
  WHERE AccountId = @AccountId AND LocationId = @LocationId
    AND RepeaterId = @RepeaterId
  ORDER BY CreatedDate DESC;

  IF @MapId IS NULL
  BEGIN
    -- Return empty set (callers can detect no rows)
    SELECT CAST(NULL AS INT) AS ElevationMapId,
           CAST(NULL AS INT) AS SampleIndex,
           CAST(NULL AS DECIMAL(18,10)) AS Latitude,
           CAST(NULL AS DECIMAL(18,10)) AS Longitude,
           CAST(NULL AS DECIMAL(9,3)) AS ElevationM
    WHERE 1 = 0;
    RETURN;
  END

  SELECT ElevationMapId = @MapId, SampleIndex, Latitude, Longitude, ElevationM
  FROM dbo.ElevationCache
  WHERE ElevationMapId = @MapId
  ORDER BY SampleIndex;
END
