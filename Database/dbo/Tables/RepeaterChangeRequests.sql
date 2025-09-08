CREATE TABLE [dbo].[RepeaterChangeRequests] (
    [RequestId]     UNIQUEIDENTIFIER DEFAULT (newid()) NOT NULL,
    [RepeaterId]    UNIQUEIDENTIFIER NULL,
    [AccountId]     UNIQUEIDENTIFIER NOT NULL,
    [ChangeType]    VARCHAR (10)     NOT NULL,
    [Status]        VARCHAR (10)     DEFAULT ('Pending') NOT NULL,
    [SubmittedDate] DATETIME2 (7)    DEFAULT (sysutcdatetime()) NOT NULL,
    [ReviewedBy]    UNIQUEIDENTIFIER NULL,
    [ReviewedDate]  DATETIME2 (7)    NULL,
    PRIMARY KEY CLUSTERED ([RequestId] ASC)
);

