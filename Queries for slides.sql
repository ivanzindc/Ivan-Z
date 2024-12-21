-- Query 1

SELECT 		film.title, category.name,
			COUNT(rental.rental_id) AS rental_count
FROM  		category
JOIN		film_category
ON			category.category_id = film_category.category_id
JOIN        film
ON 			film.film_id = film_category.film_id
JOIN		inventory
ON 			inventory.film_id = film.film_id
JOIN  		rental
ON  		rental.inventory_id = inventory.inventory_id
WHERE		category.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
GROUP BY	1,2
ORDER BY 	2,1;

-- Query 2

WITH		family_or_not AS
				(SELECT category_id, name,
						CASE WHEN name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music') THEN 'Family'
						ELSE 'Other'
						END AS category_group
				 FROM  	category)
SELECT 		film.title, category.name,
			family_or_not.category_group,
			film.rental_duration AS rental_duration,
			NTILE(4) OVER
				(ORDER BY film.rental_duration) AS standard_quartile
FROM  		category
JOIN		film_category
ON			category.category_id = film_category.category_id
JOIN        film
ON 			film.film_id = film_category.film_id
JOIN  		family_or_not
ON  		film_category.category_id = family_or_not.category_id;

-- Query 3

WITH 		cta AS (SELECT 	c.customer_id AS id, SUM(p.amount)
			    	FROM   	customer c  
				 	JOIN   	payment p  
				 	ON  		p.customer_id = c.customer_id
				 	GROUP BY  	1
				 	ORDER BY	2 DESC
				 	LIMIT  	10)

SELECT  	DATE_TRUNC('month', p.payment_date) AS pay_mon, 
			c.first_name || ' ' || c.last_name AS fullname,
			COUNT(p.payment_id) AS pay_countpermonth, SUM(p.amount) AS pay_amount
FROM  		payment p  
JOIN  		customer c  
ON  		p.customer_id = c.customer_id
WHERE 		c.customer_id IN (SELECT id FROM CTA)
GROUP BY 	1,2
ORDER BY 	2;

-- Query 4 

SELECT      name, standard_quartile, SUM(film_count)
FROM        (
SELECT 		category.name AS name,
			film.rental_duration,
			NTILE(4) OVER
				(PARTITION BY film.rental_duration ORDER BY film.rental_duration) AS standard_quartile,
			COUNT(film.title) AS film_count
FROM  		category
JOIN		film_category
ON			category.category_id = film_category.category_id
JOIN        film
ON 			film.film_id = film_category.film_id

WHERE  		category.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
GROUP BY  	1,2
ORDER BY  	1, 2, 3) sub
GROUP BY  	1,2
ORDER BY	1,2;
