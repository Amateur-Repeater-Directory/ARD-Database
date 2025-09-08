CREATE TABLE [dbo].[DemographicStates] (
    [StateId] NVARCHAR (2)  NOT NULL,
    [State]   NVARCHAR (30) NOT NULL,
    CONSTRAINT [PK_DemographicStates_1] PRIMARY KEY CLUSTERED ([StateId] ASC)
);

