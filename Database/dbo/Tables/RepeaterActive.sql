CREATE TABLE [dbo].[RepeaterActive] (
    [AccountId]    UNIQUEIDENTIFIER NOT NULL,
    [RepeaterId]   UNIQUEIDENTIFIER NOT NULL,
    [DeactivateOn] DATETIME         NOT NULL,
    CONSTRAINT [PK_RepeaterActive] PRIMARY KEY CLUSTERED ([AccountId] ASC),
    CONSTRAINT [FK_RepeaterActive_Repeater] FOREIGN KEY ([RepeaterId]) REFERENCES [dbo].[Repeater] ([RepeaterId]) ON DELETE CASCADE
);

