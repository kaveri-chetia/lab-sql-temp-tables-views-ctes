USE sakila;
-- Create a Temporary Table
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT
    crs.customer_id,
    crs.customer_name,
    crs.email,
    COALESCE(SUM(p.amount), 0) AS total_paid
FROM
    customer_rental_summary crs
LEFT JOIN
    payment p
ON
    crs.customer_id = p.customer_id
GROUP BY
    crs.customer_id,
    crs.customer_name,
    crs.email;
--  Create a View
CREATE VIEW customer_rental_summary AS
SELECT 
    customer.customer_id, 
    CONCAT(customer.first_name, ' ', customer.last_name) AS customer_name,
    customer.email,
    COUNT(rental.rental_id) AS rental_count
FROM 
    customer
LEFT JOIN 
    rental 
ON 
    customer.customer_id = rental.customer_id
GROUP BY 
    customer.customer_id, 
    customer.first_name, 
    customer.last_name,
    customer.email;
    -- Step 3: Create a CTE and the Customer Summary Report
    
WITH customer_summary AS (
    SELECT
        crs.customer_id,
        crs.customer_name,
        crs.email,
        crs.rental_count,
        COALESCE(cps.total_paid, 0) AS total_paid
    FROM
        customer_rental_summary crs
    LEFT JOIN
        customer_payment_summary cps
    ON
        crs.customer_id = cps.customer_id
)

-- Step 2: Generate the final customer summary report
SELECT
    customer_name,
    email,
    rental_count,
    total_paid,
    CASE
        WHEN rental_count > 0 THEN total_paid / rental_count
        ELSE 0
    END AS average_payment_per_rental
FROM
    customer_summary;
