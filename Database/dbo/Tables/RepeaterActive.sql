CREATE TABLE [dbo].[RepeaterActive] (
    [AccountId]    UNIQUEIDENTIFIER   NOT NULL,
    [RepeaterId]   UNIQUEIDENTIFIER   NOT NULL,
    [LocationId]   UNIQUEIDENTIFIER   NOT NULL,
    [DeactivateOn] DATETIMEOFFSET (3) NOT NULL,
    PRIMARY KEY CLUSTERED ([AccountId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_RepeaterActive_RepeaterId]
    ON [dbo].[RepeaterActive]([RepeaterId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RepeaterActive_Expire]
    ON [dbo].[RepeaterActive]([DeactivateOn] ASC);

