CREATE VIEW [dbo].[vwRepeatersActive]
AS
SELECT a.UserName, ra.RepeaterId, ra.LocationId, ra.DeactivateOn
FROM  dbo.RepeaterActive AS ra 
INNER JOIN dbo.Accounts AS a ON ra.AccountId = a.Id