--SELECT * FROM sales;
--SELECT * FROM customer;
-------------- RFM Calculate ----------------
WITH RFM_Base
AS
(
SELECT b.Customer_Name AS CustomerName,
	DATEDIFF (DAY, MAX(a.Order_Date), CONVERT(DATE, GETDATE())) AS Recency_Value,
	COUNT (DISTINCT a.Order_Date) AS Frequency_Value,
	ROUND(SUM(a.Sales), 2) AS Monetary_Value
FROM sales AS a
INNER JOIN customer AS b ON a.Customer_ID = b.Customer_ID
GROUP BY b.Customer_Name
)
--SELECT * FROM RFM_Base
, RFM_Score
AS 
(
	SELECT *,
		NTILE(5) OVER (ORDER BY Recency_Value DESC) AS R_Score,
		NTILE(5) OVER (ORDER BY Frequency_Value ASC) AS F_Score,
		NTILE(5) OVER (ORDER BY Monetary_Value ASC) AS M_Score
	FROM RFM_Base
)
--SELECT * FROM RFM_Score
, RFM_Final
AS
(
	SELECT *,
		CONCAT(R_Score, F_Score, M_Score) AS RFM_Overall --Cộng chuỗi
		-- , (R_Score + F_Score + M_Score) AS RFM_Overall --Cộng 3 cột lại, tuy nhiên giá trị dạng số
		-- , CAST(R_Score AS char(1)) + CAST(F_Score AS char(1)) + CAST(M_Score AS char(1)) AS RFM_Overall2 --Để tránh trường hợp trên thì ép kiểu thành kiểu chuỗi, vì gtr chỉ có từ 1->5 nên để mặc định là char(1)
	FROM RFM_Score
)
--SELECT * FROM RFM_Final
--SELECT * FROM [segment_scores]
SELECT f.*, s.Segment
FROM RFM_Final f
JOIN [segment_scores] s ON f.RFM_Overall = s.Scores;
--------------------------------
