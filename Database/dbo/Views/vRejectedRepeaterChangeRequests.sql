CREATE   VIEW vRejectedRepeaterChangeRequests AS
SELECT 
    r.RequestId,
    r.RepeaterId,
    r.AccountId,
    rep.Callsign,
    a.UserName AS AccountName,
    r.ChangeType,
    r.Status,
    v.FieldName,
    v.OldValue,
    v.NewValue,
    r.SubmittedDate,
    r.ReviewedBy,
    r.ReviewedDate
FROM dbo.RepeaterChangeRequests r
JOIN dbo.RepeaterChangeRequestValues v 
    ON r.RequestId = v.RequestId
LEFT JOIN dbo.Repeater rep
    ON r.RepeaterId = rep.RepeaterId
LEFT JOIN dbo.Accounts a
    ON r.AccountId = a.Id
WHERE r.Status = 'Rejected';
