CREATE DATABASE IF NOT EXISTS paintings;
	

CREATE TABLE museums (
    museum_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255),
    city VARCHAR(255),
    state VARCHAR(255),
    postal VARCHAR(20),
    country VARCHAR(255),
    phone VARCHAR(20),
    url VARCHAR(255)
);

CREATE TABLE artists (
    artist_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    middle_names VARCHAR(255),
    last_name VARCHAR(50),
    nationality VARCHAR(50),
    style VARCHAR(50),
    birth INT,
    death INT
);


CREATE TABLE sizes (
    size_id INT PRIMARY KEY AUTO_INCREMENT,
    width DECIMAL(10,2) NOT NULL,
    height DECIMAL(10,2) NOT NULL,
    label VARCHAR(255)
);

CREATE TABLE imagelink (
    work_id INT PRIMARY KEY AUTO_INCREMENT,
    url VARCHAR(255),
    thumbnail_small_url VARCHAR(255),
    thumbnail_large_url VARCHAR(255)
);

CREATE TABLE productsize (
    work_id INT PRIMARY KEY AUTO_INCREMENT,
    size_id INT,
    sale_price DECIMAL(10, 2),
    regular_price DECIMAL(10, 2),
    FOREIGN KEY (size_id) REFERENCES sizes(size_id)
);

-- Fetch all the paintings which are not displayed on any museums
select* from works where museum_id is not null;

-- Are there museuems without any paintings?
select *
from museum m
LEFT JOIN work w
ON m.museum_id = w.museum_id
Where w.work_id is NULL
;

-- How many paintings have an asking price of more than their regular price?
select count(*) as total
from product_size
WHERE sale_price > regular_price;

-- Identify the paintings whose asking price is less than 50% of its regular price?

select * from
product_size
WHERE sale_price < (0.5 * regular_price);

-- Which canva size costs the most?

select c.label, p.sale_price
from
product_size p
JOIN canvas_size c
ON p.size_id = c.size_id
Group by c.label,p.sale_price
HAVING max(p.sale_price)
order by p.sale_price desc
limit 1;

-- Identify the museums with invalid city information in the given dataset

SELECT *
FROM museum
WHERE city REGEXP '^[0-9]';

 Fetch the top 10 most famous painting subject

select distinct subject, count(*)
from subject s
join work w on s.work_id=w.work_id
group by subject
order by count(*) desc
limit 10;

-- Identify the museums which are open on both Sunday and Monday. Display museum name, city.

SELECT m.name, m.city, m.state, m.country
FROM museum_hours mh
JOIN museum m ON mh.museum_id = m.museum_id
WHERE day IN ('Sunday', 'Monday')
GROUP BY m.name, m.city, m.state, m.country
HAVING COUNT( day) = 2
ORDER BY m.name;

-- How many museums are open every single day
select count(*) from
(SELECT museum_id,COUNT(museum_id)
FROM museum_hours
GROUP BY museum_id
HAVING COUNT(day) =7) a;

-- A Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)

select m.museum_id, m.name,
count(*) as no_of_painting
FROM museum m
JOIN work w
ON m.museum_id = w.museum_id
group by m.museum_id, m.name
order by count(*) desc
Limit 5;

--  Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)

select a.full_name, a.nationality, count(*) as no_of_painting
FROM artist a
JOIN work w
ON a.artist_id = w.artist_id
group by a.full_name, a.nationality
order by count(*) desc
limit 5
;

-- Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
select m.name,m.state, mh.day, mh.open-mh.close as long_e
from museum_hours mh
JOIN museum m
ON mh.museum_id = m.museum_id
order by mh.open-mh.close desc
limit 1
;

-- A Which museum has the most no of most popular painting style?
select m.name, w.style, count(*) as no_of_paint
from museum m
JOIN work w
on m.museum_id = w.museum_id
group by m.name, w.style
order by count(*) desc
limit 1;

-- Identify the artists whose paintings are displayed in multiple countries
select a.full_name, a.style, count(*) as no_of_pain
from artist a
JOIN work w ON a.artist_id= w.artist_id
JOIN museum m ON m.museum_id = w.museum_id
group by a.full_name, a.style
order by count(*) desc
limit 5;

-- A Which country has the 5th highest no of paintings

select m.country, count(*) as no_of_pain
from artist a
JOIN work w ON a.artist_id= w.artist_id
JOIN museum m ON m.museum_id = w.museum_id
group by m.country
order by count(*) desc
LIMIT 1
OFFSET 4
;

-- A Which are the 3 most popular and 3 least popular painting styles?

(select style, count(*) as no_of_paintings, 'Most Popular' as remarks
from work
group by style
order by count(*) desc
limit 3)

UNION

(select style, count(*) as no_of_paintings, 'Least Popular' as remarks
from work
group by style
order by count(*) asc
limit 3)
;

-- A Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality.
select a.full_name, a.nationality, count(*) as no_of_paintings
from work w
join artist a on a.artist_id=w.artist_id
join subject s on s.work_id=w.work_id
join museum m on m.museum_id=w.museum_id
where m.country <> 'USA' AND s.subject = 'Portraits'
group by a.full_name, a.nationality
order by count(*) desc
limit 1;

