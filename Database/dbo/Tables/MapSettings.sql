CREATE TABLE [dbo].[MapSettings] (
    [Id]               INT              IDENTITY (1, 1) NOT NULL,
    [AccountId]        UNIQUEIDENTIFIER NOT NULL,
    [ShowRxRange]      BIT              NOT NULL,
    [ShowTxRange]      BIT              NOT NULL,
    [ShowPingRange]    BIT              NOT NULL,
    [Theme]            NVARCHAR (10)    NOT NULL,
    [MapStyle]         NVARCHAR (100)   NOT NULL,
    [AnalogOnly]       BIT              NOT NULL,
    [OpenOnly]         BIT              NOT NULL,
    [StopClusteringAt] DECIMAL (10, 6)  NOT NULL,
    [ZoomLevel]        DECIMAL (10, 6)  NOT NULL,
    [LocationId]       UNIQUEIDENTIFIER NOT NULL,
    [Bands]            NVARCHAR (1000)  NULL,
    [Modes]            NVARCHAR (1000)  NULL,
    [EmergencyNets]    NVARCHAR (1000)  NULL,
    [CenterLat]        DECIMAL (10, 6)  NOT NULL,
    [CenterLong]       DECIMAL (10, 6)  NOT NULL,
    [ShowProperties]   BIT              NOT NULL,
    CONSTRAINT [PK_MapSettings] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_MapSettings_HomeLocation] FOREIGN KEY ([LocationId]) REFERENCES [dbo].[HomeLocation] ([LocationId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_MapSettings_AccountId]
    ON [dbo].[MapSettings]([AccountId] ASC);

