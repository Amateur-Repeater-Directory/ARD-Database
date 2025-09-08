CREATE PROCEDURE dbo.ElevationMap_PurgeOlderThanDays
  @Days INT
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.ElevationMap
  WHERE CreatedDate < DATEADD(DAY, -@Days, SYSUTCDATETIME());
END
