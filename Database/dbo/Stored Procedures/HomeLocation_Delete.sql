CREATE PROCEDURE [dbo].[HomeLocation_Delete]
    @AccountId  UNIQUEIDENTIFIER,
    @LocationId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRAN;

		DELETE 
		FROM dbo.RepeaterConnection 
		WHERE AccountId = @AccountId AND LocationId = @LocationId;

		DELETE 
		FROM dbo.RepeaterLosRating 
		WHERE AccountId = @AccountId AND LocationId = @LocationId;

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

		DELETE 
		FROM dbo.HomeLocation 
		WHERE LocationId = @LocationId AND AccountId = @AccountId;

    COMMIT TRAN;
END