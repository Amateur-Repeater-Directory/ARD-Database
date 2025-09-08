CREATE TABLE [dbo].[RepeaterConnection] (
    [RepeaterConnectionId] UNIQUEIDENTIFIER NOT NULL,
    [RepeaterId]           UNIQUEIDENTIFIER NOT NULL,
    [LocationId]           UNIQUEIDENTIFIER NOT NULL,
    [AccountId]            UNIQUEIDENTIFIER NOT NULL,
    [CanPing]              BIT              NOT NULL,
    [CanReceive]           BIT              NOT NULL,
    [CanTransmit]          BIT              NOT NULL,
    CONSTRAINT [PK_RepeaterConnection] PRIMARY KEY CLUSTERED ([RepeaterConnectionId] ASC, [RepeaterId] ASC, [LocationId] ASC, [AccountId] ASC),
    CONSTRAINT [FK_RepeaterConnection_HomeLocation] FOREIGN KEY ([LocationId]) REFERENCES [dbo].[HomeLocation] ([LocationId]) ON DELETE CASCADE,
    CONSTRAINT [FK_RepeaterConnection_Repeater] FOREIGN KEY ([RepeaterId]) REFERENCES [dbo].[Repeater] ([RepeaterId]) ON DELETE CASCADE
);

