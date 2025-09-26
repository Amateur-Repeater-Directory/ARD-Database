CREATE TABLE [dbo].[RepeaterLosRating] (
    [RepeaterLosRatingId] UNIQUEIDENTIFIER CONSTRAINT [DF_RepeaterLosRating_RepeaterLosId] DEFAULT (newsequentialid()) NOT NULL,
    [RepeaterId]          UNIQUEIDENTIFIER NOT NULL,
    [LocationId]          UNIQUEIDENTIFIER NOT NULL,
    [AccountId]           UNIQUEIDENTIFIER NOT NULL,
    [StarRating]          INT              NOT NULL,
    CONSTRAINT [PK_RepeaterLineOfSightRating] PRIMARY KEY CLUSTERED ([RepeaterLosRatingId] ASC),
    CONSTRAINT [FK_RepeaterLosRating_HomeLocation] FOREIGN KEY ([LocationId]) REFERENCES [dbo].[HomeLocation] ([LocationId]),
    CONSTRAINT [FK_RepeaterLosRating_Repeater] FOREIGN KEY ([RepeaterId]) REFERENCES [dbo].[Repeater] ([RepeaterId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_RepeaterLosRating_Location_Account_Repeater]
    ON [dbo].[RepeaterLosRating]([LocationId] ASC, [AccountId] ASC, [RepeaterId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RepeaterLosRating_Location_Account]
    ON [dbo].[RepeaterLosRating]([LocationId] ASC, [AccountId] ASC);

