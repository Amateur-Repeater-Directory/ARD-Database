CREATE TABLE [dbo].[HomeLocation] (
    [LocationId]       UNIQUEIDENTIFIER NOT NULL,
    [AccountId]        UNIQUEIDENTIFIER NOT NULL,
    [Name]             NVARCHAR (100)   NOT NULL,
    [Latitude]         DECIMAL (10, 6)  NOT NULL,
    [Longitude]        DECIMAL (10, 6)  NOT NULL,
    [Elevation]        DECIMAL (9, 3)   NULL,
    [AboveGroundLevel] DECIMAL (7, 3)   NULL,
    [CreatedDate]      DATETIME2 (7)    DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedDate]      DATETIME2 (7)    DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_HomeLocation] PRIMARY KEY CLUSTERED ([LocationId] ASC)
);

