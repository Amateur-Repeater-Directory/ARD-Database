CREATE TABLE [dbo].[RefreshToken] (
    [Id]              INT              IDENTITY (1, 1) NOT NULL,
    [AccountId]       UNIQUEIDENTIFIER NOT NULL,
    [Token]           NVARCHAR (1000)  NULL,
    [Expires]         DATETIME         NOT NULL,
    [Created]         DATETIME         NOT NULL,
    [CreatedByIp]     NVARCHAR (100)   NULL,
    [Revoked]         DATETIME         NULL,
    [RevokedByIp]     NVARCHAR (100)   NULL,
    [ReplacedByToken] NVARCHAR (1000)  NULL,
    [ReasonRevoked]   NVARCHAR (1000)  NULL,
    CONSTRAINT [PK_RefreshToken] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_RefreshToken_Accounts_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Accounts] ([Id]) ON DELETE CASCADE
);

