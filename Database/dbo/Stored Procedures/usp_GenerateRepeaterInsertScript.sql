CREATE   PROCEDURE dbo.usp_GenerateRepeaterInsertScript
  @ImportBatchId UNIQUEIDENTIFIER = NULL,   -- optional filter
  @State          NVARCHAR(50)    = N'OK',  -- default OK
  @IncludeTransaction BIT         = 1
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @Out TABLE (RowNum INT IDENTITY(1,1), ScriptLine NVARCHAR(MAX));
  DECLARE @Header NVARCHAR(MAX), @Footer NVARCHAR(MAX);

  /*

  -- Example: generate OK script for a batch
  EXEC dbo.usp_GenerateRepeaterInsertScript
    @ImportBatchId = 'PUT-YOUR-BATCH-ID',
    @State = N'OK',
    @IncludeTransaction = 1;

  */

  SET @Header = N'/* === Generated Repeater INSERT script ===
SourceState     = ' + COALESCE(@State, N'(NULL)') + N'
ImportBatchId   = ' + COALESCE(CONVERT(nvarchar(36), @ImportBatchId), N'(NULL)') + N'
GeneratedAtUtc  = ' + CONVERT(nvarchar(30), SYSUTCDATETIME(), 126) + N'
============================================================= */' + CHAR(13)+CHAR(10)
  + CASE WHEN @IncludeTransaction=1 THEN N'SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;' + CHAR(13)+CHAR(10) ELSE N'' END;

  SET @Footer = CASE WHEN @IncludeTransaction=1 THEN CHAR(13)+CHAR(10)+N'  COMMIT;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  THROW;
END CATCH;' ELSE N'' END;

  INSERT @Out (ScriptLine) VALUES (@Header);

  ;WITH Approved AS (
    SELECT s.*
    FROM dbo.RepeaterStaging s
    JOIN dbo.RepeaterStagingMeta m ON m.StagingId = s.StagingId
    WHERE (@ImportBatchId IS NULL OR m.ImportBatchId = @ImportBatchId)
      AND (@State IS NULL OR s.[State] = @State)
      AND s.InputFrequency IS NOT NULL
      AND s.Latitude IS NOT NULL
      AND s.Longitude IS NOT NULL
      AND s.[State] IS NOT NULL
  )
  INSERT @Out (ScriptLine)
  SELECT
    'INSERT dbo.Repeater
(
  RepeaterId,
  OutputFrequency, InputFrequency, [Offset], OffsetSign, Band,
  ToneMode, CTCSSTx, CTCSSRx, IsCrossTone, Callsign,
  Latitude, Longitude, [State], County, NearestCity, Notes,
  IsLatLongPrecise, IsOperational, IsOpen, IsCoordinated,
  ARES, RACES, SKYWARN,
  CreatedDate, UpdatedDate,
  HasLatLongError, Elevation, AboveGroundLevel, IsAboveGroundLevelPrecise
)
VALUES
(
  NEWID(), ' +
    -- OutputFrequency
    COALESCE(CONVERT(varchar(32), s.OutputFrequency), 'NULL') + ', ' +
    -- InputFrequency (required)
    CONVERT(varchar(32), s.InputFrequency) + ', ' +
    -- Offset (fallback to math if NULL)
    COALESCE(CONVERT(varchar(32), s.[Offset]),
             'ABS(' + CONVERT(varchar(32), s.OutputFrequency) + '-' + CONVERT(varchar(32), s.InputFrequency) + ')') + ', ' +
    -- OffsetSign (fallback to math if NULL)
    COALESCE(
      CASE WHEN s.OffsetSign IS NULL THEN
        'CASE WHEN ' + CONVERT(varchar(32), s.OutputFrequency) + ' > ' + CONVERT(varchar(32), s.InputFrequency) + ' THEN ''+'''
        + ' WHEN ' + CONVERT(varchar(32), s.OutputFrequency) + ' < ' + CONVERT(varchar(32), s.InputFrequency) + ' THEN ''-'''
        + ' ELSE NULL END'
      ELSE  '''' + s.OffsetSign + '''' END,
      'NULL'
    ) + ', ' +
    -- Band
    COALESCE(N'N''' + REPLACE(s.Band,'''','''''') + '''', 'NULL') + ', ' +
    -- ToneMode
    COALESCE(N'N''' + REPLACE(s.ToneMode,'''','''''') + '''', 'NULL') + ', ' +
    -- CTCSSTx / Rx
    COALESCE(CONVERT(varchar(32), s.CTCSSTx), 'NULL') + ', ' +
    COALESCE(CONVERT(varchar(32), s.CTCSSRx), 'NULL') + ', ' +
    -- IsCrossTone
    CONVERT(varchar(1), COALESCE(s.IsCrossTone,0)) + ', ' +
    -- Callsign
    COALESCE(N'N''' + REPLACE(s.Callsign,'''','''''') + '''', 'NULL') + ', ' +
    -- Lat/Lon
    CONVERT(varchar(50), s.Latitude) + ', ' + CONVERT(varchar(50), s.Longitude) + ', ' +
    -- State
    N'N''' + REPLACE(s.[State],'''','''''') + ''', ' +
    -- County
    COALESCE(N'N''' + REPLACE(s.County,'''','''''') + '''', 'NULL') + ', ' +
    -- NearestCity
    COALESCE(N'N''' + REPLACE(s.NearestCity,'''','''''') + '''', 'NULL') + ', ' +
    -- Notes
    COALESCE(N'N''' + REPLACE(s.Notes,'''','''''') + '''', 'NULL') + ', ' +
    -- Flags
    CONVERT(varchar(1), COALESCE(s.IsLatLongPrecise,0)) + ', ' +
    CONVERT(varchar(1), COALESCE(s.IsOperational,1)) + ', ' +
    CONVERT(varchar(1), COALESCE(s.IsOpen,1)) + ', ' +
    CONVERT(varchar(1), COALESCE(s.IsCoordinated,0)) + ', ' +
    CONVERT(varchar(1), COALESCE(s.ARES,0)) + ', ' +
    CONVERT(varchar(1), COALESCE(s.RACES,0)) + ', ' +
    CONVERT(varchar(1), COALESCE(s.SKYWARN,0)) + ', ' +
    -- Dates
    'SYSUTCDATETIME(), SYSUTCDATETIME(), ' +
    -- HasLatLongError
    CONVERT(varchar(1), COALESCE(s.HasLatLongError,0)) + ', ' +
    -- Elevation
    COALESCE(CONVERT(varchar(32), s.Elevation), 'NULL') + ', ' +
    -- AGL (default 150 if NULL)
    COALESCE(CONVERT(varchar(32), s.AboveGroundLevel), '150.0') + ', ' +
    -- AGL precise flag (0 if defaulted)
    CASE WHEN s.AboveGroundLevel IS NULL
         THEN '0'
         ELSE CONVERT(varchar(1), COALESCE(s.IsAboveGroundLevelPrecise,0)) END + '
);'
  FROM Approved s
  ORDER BY s.Callsign, s.OutputFrequency, s.Latitude, s.Longitude;

  INSERT @Out (ScriptLine) VALUES (@Footer);

  SELECT ScriptLine
  FROM @Out
  ORDER BY RowNum;
END