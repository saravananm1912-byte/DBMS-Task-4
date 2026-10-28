CREATE DATABASE IF NOT EXISTS order_management;
USE order_management;

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT NOT NULL,
    Order_Date DATE NOT NULL,
    Total_Amount DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (Total_Amount >= 0),
    Order_Status VARCHAR(20) NOT NULL DEFAULT 'Pending'
        CHECK (Order_Status IN ('Pending', 'Shipped', 'Delivered', 'Cancelled')),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);

CREATE TABLE Order_Details (
    Order_Detail_ID INT PRIMARY KEY,
    Order_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    UNIQUE (Order_ID, Product_ID),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID)
        ON DELETE CASCADE,
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);
INSERT INTO Orders
VALUES (301, 101, '2026-10-27', 0, 'Pending');

INSERT INTO Order_Details
VALUES
(401, 301, 201, 2, 750.00),
(402, 301, 202, 1, 400.00);

UPDATE Orders
SET Total_Amount = (
    SELECT SUM(Quantity * Price)
    FROM Order_Details
    WHERE Order_ID = 301
)
WHERE Order_ID = 301;

SELECT * FROM Orders;
SELECT * FROM Order_Details;
INSERT INTO Orders
VALUES (302, 102, CURRENT_DATE, 0, 'Pending');

INSERT INTO Order_Details
VALUES
(403, 302, 203, 1, 1200.00),
(404, 302, 204, 2, 550.00);

UPDATE Orders
SET Total_Amount = (
    SELECT SUM(Quantity * Price)
    FROM Order_Details
    WHERE Order_ID = 302
)
WHERE Order_ID = 302;
UPDATE Orders
SET Order_Status = 'Shipped'
WHERE Order_ID = 301;

UPDATE Orders
SET Order_Status = 'Delivered'
WHERE Order_ID = 302;
UPDATE Order_Details
SET Quantity = 3
WHERE Order_Detail_ID = 401;

UPDATE Orders
SET Total_Amount = (
    SELECT SUM(Quantity * Price)
    FROM Order_Details
    WHERE Order_ID = 301
)
WHERE Order_ID = 301;

SELECT
    o.Order_ID,
    c.Customer_Name,
    c.Phone,
    o.Order_Date,
    p.Product_Name,
    od.Quantity,
    od.Price,
    od.Quantity * od.Price AS Line_Total,
    o.Total_Amount,
    o.Order_Status
FROM Orders o
JOIN Customer c ON o.Customer_ID = c.Customer_ID
JOIN Order_Details od ON o.Order_ID = od.Order_ID
JOIN Product p ON od.Product_ID = p.Product_ID
ORDER BY o.Order_ID;
UPDATE Orders
SET Order_Status = 'Cancelled'
WHERE Order_ID = 301;

DELETE FROM Orders
WHERE Order_ID = 301
AND Order_Status = 'Cancelled';
SELECT
    c.Customer_ID,
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    o.Order_Status,
    o.Total_Amount
FROM Customer c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
ORDER BY c.Customer_ID, o.Order_Date;
SELECT
    p.Product_ID,
    p.Product_Name,
    o.Order_ID,
    c.Customer_Name,
    od.Quantity,
    od.Price,
    od.Quantity * od.Price AS Line_Total
FROM Order_Details od
JOIN Product p ON od.Product_ID = p.Product_ID
JOIN Orders o ON od.Order_ID = o.Order_ID
JOIN Customer c ON o.Customer_ID = c.Customer_ID
ORDER BY p.Product_Name;
SELECT
    p.Product_ID,
    p.Product_Name,
    COUNT(od.Order_Detail_ID) AS Times_Ordered
FROM Product p
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
LEFT JOIN Orders o ON od.Order_ID = o.Order_ID
    AND o.Order_Status <> 'Cancelled'
GROUP BY p.Product_ID, p.Product_Name;
SELECT
    p.Product_ID,
    p.Product_Name,
    COALESCE(SUM(
        CASE
            WHEN o.Order_Status <> 'Cancelled'
            THEN od.Quantity
            ELSE 0
        END
    ), 0) AS Total_Quantity_Sold
FROM Product p
LEFT JOIN Order_Details od ON p.Product_ID = od.Product_ID
LEFT JOIN Orders o ON od.Order_ID = o.Order_ID
GROUP BY p.Product_ID, p.Product_Name;
SELECT
    c.Customer_ID,
    c.Customer_Name,
    COUNT(o.Order_ID) AS Number_Of_Orders
FROM Customer c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
WHERE o.Order_Status <> 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name
HAVING COUNT(o.Order_ID) = (
    SELECT MAX(order_count)
    FROM (
        SELECT COUNT(*) AS order_count
        FROM Orders
        WHERE Order_Status <> 'Cancelled'
        GROUP BY Customer_ID
    ) AS order_counts
);
SELECT
    c.Customer_ID,
    c.Customer_Name,
    COALESCE(SUM(
        CASE
            WHEN o.Order_Status <> 'Cancelled'
            THEN o.Total_Amount
            ELSE 0
        END
    ), 0) AS Total_Spending
FROM Customer c
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Spending DESC;
SELECT ROUND(AVG(Total_Amount), 2) AS Average_Order_Value
FROM Orders
WHERE Order_Status <> 'Cancelled';
SELECT COALESCE(SUM(Total_Amount), 0) AS Total_Sales_Amount
FROM Orders
WHERE Order_Status <> 'Cancelled';