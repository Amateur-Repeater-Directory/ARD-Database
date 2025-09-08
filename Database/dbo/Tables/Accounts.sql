CREATE TABLE [dbo].[Accounts] (
    [Id]                UNIQUEIDENTIFIER NOT NULL,
    [Email]             NVARCHAR (200)   NOT NULL,
    [UserName]          NVARCHAR (30)    NOT NULL,
    [PasswordHash]      NVARCHAR (1000)  NOT NULL,
    [AcceptTerms]       BIT              NOT NULL,
    [Role]              INT              NOT NULL,
    [VerificationToken] NVARCHAR (1000)  NULL,
    [Verified]          DATETIME         NULL,
    [ResetToken]        NVARCHAR (1000)  NULL,
    [ResetTokenExpires] DATETIME         NULL,
    [PasswordReset]     DATETIME         NULL,
    [Created]           DATETIME         CONSTRAINT [DF_Accounts_Created] DEFAULT (getutcdate()) NOT NULL,
    [Updated]           DATETIME         CONSTRAINT [DF_Accounts_Updated] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_Accounts] PRIMARY KEY CLUSTERED ([Id] ASC)
);

