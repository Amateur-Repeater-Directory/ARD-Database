CREATE TABLE [dbo].[Repeater] (
    [RepeaterId]                UNIQUEIDENTIFIER NOT NULL,
    [OutputFrequency]           DECIMAL (10, 6)  NULL,
    [InputFrequency]            DECIMAL (10, 6)  NOT NULL,
    [Offset]                    DECIMAL (10, 3)  NULL,
    [OffsetSign]                CHAR (1)         NULL,
    [Band]                      NVARCHAR (20)    NULL,
    [ToneMode]                  NVARCHAR (20)    NULL,
    [CTCSSTx]                   DECIMAL (10, 2)  NULL,
    [CTCSSRx]                   DECIMAL (10, 2)  NULL,
    [IsCrossTone]               BIT              DEFAULT ((0)) NOT NULL,
    [Callsign]                  NVARCHAR (20)    NULL,
    [Latitude]                  DECIMAL (18, 10) NOT NULL,
    [Longitude]                 DECIMAL (18, 10) NOT NULL,
    [State]                     NVARCHAR (50)    NOT NULL,
    [County]                    NVARCHAR (100)   NULL,
    [NearestCity]               NVARCHAR (100)   NULL,
    [Notes]                     NVARCHAR (1000)  NULL,
    [IsLatLongPrecise]          BIT              DEFAULT ((0)) NOT NULL,
    [IsOperational]             BIT              DEFAULT ((1)) NOT NULL,
    [IsOpen]                    BIT              DEFAULT ((1)) NOT NULL,
    [IsCoordinated]             BIT              DEFAULT ((0)) NOT NULL,
    [ARES]                      BIT              DEFAULT ((0)) NOT NULL,
    [RACES]                     BIT              DEFAULT ((0)) NOT NULL,
    [SKYWARN]                   BIT              DEFAULT ((0)) NOT NULL,
    [CreatedDate]               DATETIME2 (7)    DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedDate]               DATETIME2 (7)    DEFAULT (sysutcdatetime()) NOT NULL,
    [HasLatLongError]           BIT              DEFAULT ((0)) NOT NULL,
    [Elevation]                 DECIMAL (9, 3)   NULL,
    [AboveGroundLevel]          DECIMAL (7, 3)   NULL,
    [IsAboveGroundLevelPrecise] BIT              CONSTRAINT [DF_Repeater_IsAboveGroundLevelPrecise] DEFAULT ((0)) NOT NULL,
    [Geo]                       AS               ([geography]::Point([Latitude],[Longitude],(4326))) PERSISTED,
    [Modes]                     NVARCHAR (100)   NULL,
    CONSTRAINT [PK_Repeater] PRIMARY KEY CLUSTERED ([RepeaterId] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_Repeater_State]
    ON [dbo].[Repeater]([State] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Repeater_LatLon]
    ON [dbo].[Repeater]([Latitude] ASC, [Longitude] ASC);


GO
CREATE SPATIAL INDEX [SIDX_Repeater_Geo]
    ON [dbo].[Repeater] ([Geo]);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Repeater_Physical]
    ON [dbo].[Repeater]([Callsign] ASC, [State] ASC, [NearestCity] ASC, [OutputFrequency] ASC, [InputFrequency] ASC, [Offset] ASC, [OffsetSign] ASC);

