CREATE   VIEW vRepeaterChangeRequestSummary AS
SELECT 
    r.RequestId,
    r.RepeaterId,
    rep.Callsign,
    r.AccountId,
    a.UserName AS AccountName,
    r.ChangeType,
    r.Status,
    r.SubmittedDate,
    r.ReviewedBy,
    r.ReviewedDate
FROM dbo.RepeaterChangeRequests r
LEFT JOIN dbo.Repeater rep
    ON r.RepeaterId = rep.RepeaterId
LEFT JOIN dbo.Accounts a
    ON r.AccountId = a.Id;
