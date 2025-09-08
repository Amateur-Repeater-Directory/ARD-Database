CREATE TABLE [dbo].[DemographicTimeZones] (
    [TimeZoneId] INT           IDENTITY (1, 1) NOT NULL,
    [TimeZone]   NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_DemographicTimeZones] PRIMARY KEY CLUSTERED ([TimeZoneId] ASC)
);

