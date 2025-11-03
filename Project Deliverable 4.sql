--Author: Gavin Morrow
/* ========================================================================================
This stored procedure with Select is used to allow someone to see how many stops a
specific route might have assuming they ask for a route that does exist in King County Metro
otherwise we will give an error. With our Queries we can see that Route 1 has 7 stops
and Route 45 has 8 stops granted this might be outdated and only accounts for the Route
Going ONE WAY.
   ======================================================================================== */
GO
CREATE OR ALTER PROCEDURE dbo.route_num_stations (
    @route_name varchar(50)
)
AS 
BEGIN 
    IF NOT EXISTS (SELECT * FROM routes WHERE routes.route_short_name = @route_name)
    BEGIN
        THROW 50004, 'Route Does not Exist', 1;
    END
    ELSE
    BEGIN
        SELECT @route_name AS [Route], (SELECT COUNT(DISTINCT s.stations_id)
                                        FROM routes r
                                        JOIN route_stations rs ON r.route_id = rs.route_id
                                        JOIN stations s ON rs.stations_id = s.stations_id
                                        WHERE r.route_short_name = @route_name) AS num_stops
    END
END
GO

--Checking the stops for the 1 bus line NOT THE ONE LINE
GO
EXECUTE dbo.route_num_stations @route_name = '1'

--Checking stops for the 45
GO
EXECUTE dbo.route_num_stations @route_name = '45'

--Checking to make sure our error throw works
GO 
EXECUTE dbo.route_num_stations @route_name = 'fake route'


/* ===================================================================================
   With Climate change on the rise I wanted to see which agencies were using the most 
   electric or hybrid which would use mostly electricity and comapre them by ranking. 
   First we put these percentages into a temp table and upon inspection they are close
   but Sound Transit uses the most electric or partially electric vehicles at 11.22%.
   We figure this out using two Ctes, the first to get only the electric and hybrid
   percentages, and the second to sum those up into an electric and hybrid percent.
   Finally we do the ranking in our Select statement to get our results.
   =================================================================================== */ 
DROP TABLE IF EXISTS #temp_bus_type_percentages
CREATE TABLE #temp_bus_type_percentages ( 
    agency_name VARCHAR(255), 
    bus_type VARCHAR(50), 
    total_buses INT, 
    percent_by_type DECIMAL(5, 2) 
)
INSERT INTO #temp_bus_type_percentages 
SELECT a.agency_name, b.bus_type, COUNT(b.bus_id) AS total_buses, 
CAST(100.0 * COUNT(b.bus_id) / SUM(COUNT(b.bus_id)) OVER (PARTITION BY a.agency_name) AS DECIMAL(5, 2)) AS percent_by_type 
FROM Buses b 
JOIN trip_details td ON b.bus_id = td.bus_id
JOIN Routes r ON td.route_id = r.route_id 
JOIN Agency a ON r.agency_id = a.agency_id
GROUP BY ROLLUP(a.agency_name, b.bus_type) 
ORDER BY a.agency_name, b.bus_type;

WITH cte_electric_buses
AS (SELECT agency_name, bus_type, percent_by_type FROM #temp_bus_type_percentages
    WHERE bus_type = 'electric bus'
    OR bus_type = 'hybrid'),

cte_electric_and_hybrid_percent
AS (SELECT agency_name, SUM(percent_by_type) AS electric_and_hybrid_percent
    FROM cte_electric_buses
    GROUP BY agency_name)

SELECT *, RANK() OVER (ORDER BY electric_and_hybrid_percent DESC) AS agency_electricity_rank
FROM cte_electric_and_hybrid_percent