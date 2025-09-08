CREATE   PROCEDURE dbo.ElevationMap_DeleteByLocation
    @AccountId  UNIQUEIDENTIFIER,
    @LocationId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRAN;

        -- 1) Delete cache rows for the matching map rows
        DELETE ec
        FROM dbo.ElevationCache AS ec
        INNER JOIN dbo.ElevationMap AS em
            ON em.ElevationMapId = ec.ElevationMapId
        WHERE em.AccountId = @AccountId
          AND em.LocationId = @LocationId;

        -- 2) Delete the map rows themselves
        DELETE em
        FROM dbo.ElevationMap AS em
        WHERE em.AccountId = @AccountId
          AND em.LocationId = @LocationId;

    COMMIT TRAN;
END
