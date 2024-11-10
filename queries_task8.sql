--task 8a
SELECT OrderDate, COUNT(*) AS 'Liczba Zam�wie�' FROM dbo.FactInternetSales
GROUP BY OrderDate
HAVING COUNT(*)<100
ORDER BY [Liczba Zam�wie�] DESC;

--task 8b
WITH MostExpensiveProducts AS(
	SELECT OrderDate, UnitPrice, RANK()
	OVER (PARTITION BY OrderDate ORDER BY UnitPrice DESC) as PriceRank
	FROM dbo.FactInternetSales)
SELECT OrderDate, UnitPrice FROM MostExpensiveProducts
WHERE PriceRank <= 3;
