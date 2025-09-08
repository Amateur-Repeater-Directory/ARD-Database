CREATE TABLE [dbo].[ElevationCache] (
    [ElevationMapId] INT              NOT NULL,
    [SampleIndex]    INT              NOT NULL,
    [Latitude]       DECIMAL (18, 10) NOT NULL,
    [Longitude]      DECIMAL (18, 10) NOT NULL,
    [ElevationM]     DECIMAL (9, 3)   NOT NULL,
    CONSTRAINT [PK_ElevationCache] PRIMARY KEY CLUSTERED ([ElevationMapId] ASC, [SampleIndex] ASC),
    CONSTRAINT [FK_ElevationCache_ElevationMap] FOREIGN KEY ([ElevationMapId]) REFERENCES [dbo].[ElevationMap] ([ElevationMapId]) ON DELETE CASCADE
);

