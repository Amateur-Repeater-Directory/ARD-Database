CREATE TABLE [dbo].[ElevationMap] (
    [ElevationMapId] INT              IDENTITY (1, 1) NOT NULL,
    [AccountId]      UNIQUEIDENTIFIER NOT NULL,
    [LocationId]     UNIQUEIDENTIFIER NOT NULL,
    [RepeaterId]     UNIQUEIDENTIFIER NOT NULL,
    [CreatedDate]    DATETIME2 (7)    CONSTRAINT [DF_ElevationMap_CreatedDate] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_ElevationMap] PRIMARY KEY CLUSTERED ([ElevationMapId] ASC),
    CONSTRAINT [FK_ElevationMap_HomeLocation] FOREIGN KEY ([LocationId]) REFERENCES [dbo].[HomeLocation] ([LocationId]) ON DELETE CASCADE,
    CONSTRAINT [FK_ElevationMap_Repeater] FOREIGN KEY ([RepeaterId]) REFERENCES [dbo].[Repeater] ([RepeaterId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ElevationMap_Location_Account_Repeater]
    ON [dbo].[ElevationMap]([LocationId] ASC, [AccountId] ASC, [RepeaterId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ElevationMap_Location_Account]
    ON [dbo].[ElevationMap]([LocationId] ASC, [AccountId] ASC);

