CREATE TABLE [dbo].[RepeaterChangeRequestValues] (
    [ValueId]   INT              IDENTITY (1, 1) NOT NULL,
    [RequestId] UNIQUEIDENTIFIER NOT NULL,
    [FieldName] NVARCHAR (100)   NOT NULL,
    [OldValue]  NVARCHAR (MAX)   NULL,
    [NewValue]  NVARCHAR (MAX)   NULL,
    PRIMARY KEY CLUSTERED ([ValueId] ASC),
    CONSTRAINT [FK_ChangeRequestValues_Requests] FOREIGN KEY ([RequestId]) REFERENCES [dbo].[RepeaterChangeRequests] ([RequestId]) ON DELETE CASCADE
);

