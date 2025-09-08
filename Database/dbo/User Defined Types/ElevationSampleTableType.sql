CREATE TYPE [dbo].[ElevationSampleTableType] AS TABLE (
    [SampleIndex] INT        NOT NULL,
    [Latitude]    FLOAT (53) NOT NULL,
    [Longitude]   FLOAT (53) NOT NULL,
    [ElevationM]  FLOAT (53) NOT NULL);

