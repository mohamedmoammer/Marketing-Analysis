USE Marketing;

-- products data
SELECT * 
FROM products;

-- Categorize products based on their prices
SELECT *,
	CASE 
		WHEN Price < 50 THEN 'Low'
		WHEN Price BETWEEN 50 AND 200 THEN 'Medium'
		ELSE 'High'
	END AS PriceCategory
FROM products
ORDER BY Price DESC;

-- Customer data with geographic information
SELECT c.CustomerID, c.CustomerName, c.Email, c.Gender, c.Age, g.Country, g.City
FROM 
	customers AS c
	LEFT JOIN 
	geography AS g
ON c.GeographyID = g.GeographyID;

-- Customer count by each country
SELECT g.Country,COUNT(c.CustomerName) AS CustomerCount
FROM 
	customers AS c
	LEFT JOIN 
	geography AS g
ON c.GeographyID = g.GeographyID
GROUP BY 
	g.Country
ORDER BY CustomerCount DESC;

-- customer reviews data
SELECT * 
FROM customer_reviews;

-- Cleaning the white spaces issues on review text column
SELECT ReviewID, CustomerID,ProductID,ReviewDate,Rating, REPLACE(ReviewText,'  ',' ') AS ReviewText
FROM customer_reviews;

-- engagement data
SELECT * 
FROM engagement_data;

SELECT EngagementID,
	ContentID,
	UPPER(ContentType) AS ContentType,
	Likes,
	EngagementDate,
	CampaignID,
	ProductID,
	-- Splitting views and clicks
	LEFT(ViewsClicksCombined,CHARINDEX('-', ViewsClicksCombined) - 1) AS Views,
	RIGHT(ViewsClicksCombined,LEN(ViewsClicksCombined) - CHARINDEX('-', ViewsClicksCombined)) AS Clicks
FROM 
    engagement_data 

-- customer journey data
SELECT * 
FROM customer_journey;

SELECT JourneyID, 
	CustomerID,
	ProductID,
	VisitDate,
	Stage,
	Action,
	Duration,
	ROW_NUMBER() Over(
		PARTITION BY CustomerID, ProductID
		ORDER BY JourneyID
	) AS RowNum
FROM customer_journey;

-- showing the duplicates
WITH Duplicates AS (
	SELECT JourneyID,  
        CustomerID,  
        ProductID,  
        VisitDate,  
        Stage,  
        Action,  
        Duration,
	ROW_NUMBER() Over(
		PARTITION BY JourneyID,CustomerID, ProductID, VisitDate, Stage, Action
		ORDER BY JourneyID
	) AS RowNum
	FROM customer_journey
)
SELECT * 
FROM Duplicates
Where RowNum > 1;

SELECT 
	JourneyID,
	CustomerID,
	ProductID,
	VisitDate,
	Stage,
	Action,
	COALESCE(Duration, AvgDuration) AS Duration
FROM	
	(
	SELECT 
		JourneyID,
		CustomerID,
		ProductID,
		VisitDate,
		Stage,
		Action,
		Duration,
		AVG(Duration) OVER(
			PARTITION BY VisitDate
		) AS AvgDuration,
		ROW_NUMBER() OVER(
			PARTITION BY CustomerID,ProductID,VisitDate,Stage,Action
			ORDER BY JourneyID
		) AS RowNum
	FROM customer_journey
	) AS SubQuery
WHERE RowNum = 1;





