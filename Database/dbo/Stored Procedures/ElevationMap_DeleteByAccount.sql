CREATE   PROCEDURE dbo.ElevationMap_DeleteByAccount
    @AccountId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRAN;

        -- Delete dependent cache rows first
        DELETE ec
        FROM dbo.ElevationCache AS ec
        INNER JOIN dbo.ElevationMap AS em
            ON em.ElevationMapId = ec.ElevationMapId
        WHERE em.AccountId = @AccountId;

        -- Then delete the map rows
        DELETE FROM dbo.ElevationMap
        WHERE AccountId = @AccountId;

    COMMIT TRAN;
END
