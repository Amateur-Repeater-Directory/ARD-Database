CREATE PROCEDURE [dbo].[ElevationMap_InsertWithSamples]
  @AccountId       UNIQUEIDENTIFIER,
  @LocationId      UNIQUEIDENTIFIER,
  @RepeaterId      UNIQUEIDENTIFIER,
  @Samples         dbo.ElevationSampleTableType READONLY,
  @ElevationMapId  INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO dbo.ElevationMap (AccountId, LocationId, RepeaterId)
  VALUES (@AccountId, @LocationId, @RepeaterId);

  SET @ElevationMapId = SCOPE_IDENTITY();

  INSERT INTO dbo.ElevationCache (ElevationMapId, SampleIndex, Latitude, Longitude, ElevationM)
  SELECT @ElevationMapId, SampleIndex, Latitude, Longitude, ElevationM
  FROM @Samples;
END
