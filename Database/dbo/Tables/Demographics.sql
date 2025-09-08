CREATE TABLE [dbo].[Demographics] (
    [Id]           INT              IDENTITY (1, 1) NOT NULL,
    [StateId]      NVARCHAR (2)     NOT NULL,
    [City]         NVARCHAR (70)    NOT NULL,
    [County]       NVARCHAR (50)    NOT NULL,
    [TimeZoneId]   INT              NULL,
    [Latitude]     DECIMAL (18, 10) NOT NULL,
    [Longitude]    DECIMAL (18, 10) NOT NULL,
    [Population]   INT              NULL,
    [Incorporated] BIT              NULL,
    [Zips]         NVARCHAR (MAX)   NULL,
    [Geo]          AS               ([geography]::Point([Latitude],[Longitude],(4326))) PERSISTED,
    CONSTRAINT [PK_Demographics_1] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Demographics_States] FOREIGN KEY ([StateId]) REFERENCES [dbo].[DemographicStates] ([StateId]),
    CONSTRAINT [FK_Demographics_TimeZones] FOREIGN KEY ([TimeZoneId]) REFERENCES [dbo].[DemographicTimeZones] ([TimeZoneId])
);


GO
CREATE SPATIAL INDEX [SIDX_Demographics_Geo]
    ON [dbo].[Demographics] ([Geo]);


GO
CREATE SPATIAL INDEX [SIX_Demographics_Geo]
    ON [dbo].[Demographics] ([Geo])
    WITH  (
            CELLS_PER_OBJECT = 16
          );

