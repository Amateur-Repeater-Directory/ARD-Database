CREATE   FUNCTION dbo.RandomizeLatLon
(
    @lat       DECIMAL(18,10),           -- degrees
    @lon       DECIMAL(18,1),           -- degrees
    @minMiles  DECIMAL(6,3) = 2.0,
    @maxMiles  DECIMAL(6,3) = 10.0,
    @seed      BIGINT                  -- deterministic per row (e.g., hash of your PK)
)
RETURNS TABLE
AS
RETURN
WITH R AS
(
    -- Deterministic pseudo-randoms in [0,1) derived from inputs.
    -- (CHECKSUM is deterministic; we avoid RAND/NEWID inside the UDF.)
    SELECT
        u = (ABS(CHECKSUM(@seed, N'u', @lat, @lon)) + 0.5) / 2147483647.5,  -- 0..1
        v = (ABS(CHECKSUM(@seed, N'v', @lon, @lat)) + 0.5) / 2147483647.5   -- 0..1
),
P AS
(
    SELECT
        -- Bearing (radians)
        bearing = 2.0 * PI() * CAST(u AS float),

        -- Choose ONE of the two lines below:

        -- (A) Uniform *radius* in [min,max]:
        miles   = CAST(@minMiles AS float) + (CAST(@maxMiles AS float) - CAST(@minMiles AS float)) * CAST(v AS float)

        -- (B) Uniform *area* over the ring (uncomment to use):
        --miles = SQRT( CAST(@minMiles AS float) * CAST(@minMiles AS float)
        --            + (CAST(@maxMiles AS float) * CAST(@maxMiles AS float)
        --              - CAST(@minMiles AS float) * CAST(@minMiles AS float)) * CAST(v AS float) )
    FROM R
),
G AS
(
    SELECT
        d    = miles * 1609.344,         -- meters
        Rm   = 6371000.0,                -- Earth radius (m)
        lat1 = RADIANS(CAST(@lat AS float)),
        lon1 = RADIANS(CAST(@lon AS float)),
        brg  = bearing
    FROM P
),
D AS
(
    SELECT
        ang     = d / Rm,
        sinLat1 = SIN(lat1),
        cosLat1 = COS(lat1),
        sinAng  = SIN(d / Rm),
        cosAng  = COS(d / Rm),
        lat1, lon1, brg
    FROM G
),
Dest AS
(
    SELECT
        lat2 = ASIN( sinLat1 * cosAng + cosLat1 * sinAng * COS(brg) ),
        lon2 = lon1 + ATN2( SIN(brg) * sinAng * cosLat1,
                            cosAng - sinLat1 * SIN( ASIN( sinLat1 * cosAng + cosLat1 * sinAng * COS(brg) ) ) )
    FROM D
),
Deg AS
(
    SELECT
        LatDeg = DEGREES(lat2),
        LonDeg = DEGREES(lon2)
    FROM Dest
),
Norm AS
(
    -- Normalize longitude to [-180, 180]
    SELECT
        LatDeg,
        LonDeg =
            CASE
                WHEN LonDeg >  180.0 THEN LonDeg - 360.0
                WHEN LonDeg < -180.0 THEN LonDeg + 360.0
                ELSE LonDeg
            END
    FROM Deg
)
SELECT
    Lat = CAST(ROUND(LatDeg, 6) AS DECIMAL(18,10)),
    Lon = CAST(ROUND(LonDeg, 6) AS DECIMAL(18,10))
FROM Norm;