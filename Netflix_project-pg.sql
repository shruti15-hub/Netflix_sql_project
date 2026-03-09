----------Netflix project--------------
drop table if exists netflix;

create table netflix(
show_id	varchar(10),
type	varchar(50),
title	varchar(150),
director varchar(208),
casts	varchar(771),
country varchar(154),
date_added	varchar(50),
release_year int,
rating	varchar(10),
duration varchar(15),
listed_in	varchar(100),
description varchar(250)

);
select * from netflix;
select count(*)  as total_content from netflix;
select distinct type from netflix;

-------------- Buisness problems  ----------------

--1.count the number of movies vs TV shows
select type,count(*) as type_movie from netflix group by type;

--2.find the most common rating for movies and TV shows
select type ,rating,count(*) ,
rank() over(partition by type order by count(*) desc) as ranking
from netflix group by 1,2 order by 3 desc;
  --OR--
 select type,rating from(
select type,rating,count(*),
rank() over(partition by type order by count(*) desc) as ranking
from netflix
group by 1,2
 ) as t1
 where ranking=1;
 
------3.List all movies released in a specific year(eg;2020) ---------
select  * from netflix where type='Movie' and
release_year=2020;

------4.find top 5 countries with the most content on netflix  ------
select country,count(show_id) as total_content from netflix group by 1;

---OR (split all country)
select string_To_Array(country,',') as total_content from netflix;

--it split all country-- unnest(string_to_array)
select unnest(string_To_Array(country,',')) as new_country from netflix;

--- showing all country group by with total content
select unnest(string_To_Array(country,',')) as new_country ,
count(show_id) as total_content
from netflix
group by 1
order by 2 desc
limit 5;

-----5. Identify the longest movie----
select * from netflix where  type='Movie' and duration=(select max(duration) from netflix);

----6. find content added in the last 5 years ----

SELECT * 
from netflix 
where TO_DATE(date_added,'Month DD,YYY') >= current_date - interval '5 years'

select current_date - interval '5 years'

---7. find all the movies /Tv shows by director 'Rajiv chilaka'---
select * from netflix where director like '%Rajiv Chilaka%';

---8.list all TV shows with more than 5 seasons----
select * from netflix where type = 'TV Show' and
duration > '5 sessions'

select * from netflix where type='TV Show' and
split_part(duration,' ',1)::numeric > 5

----9. count the number of content items in each genre
    ---(split genre)--
select unnest(string_to_array(listed_in,',')) as genre,
count(show_id) as  total_content
from netflix  
group by 1

-----10. find each year and the average number of content release by India on netflix
---return top 5 year with highest avg content release
--(to_date which convert into date)
--(::numeric for convert into numeric)

select 
extract(year from to_date(date_added,'Month DD, YYYY')) as year,
count(*),
count(*)::numeric/(select count(*) from netflix 
where country='India')::numeric *100,2
as avg_content_per_year
from netflix
where country='India'
group by 1


---11.list all movies that are documentries----

select * from netflix where
listed_in LIKE '%Documentaries%'

--12.find all content without a director---

select * from netflix where director is null;

--13. find how many movies actor 'salman khan' appered in last 10 years---
select * from netflix
where casts ILIKE '%Salman Khan%' and release_year > extract(year from current_date) - 10

--14. find the top 10 actors who have appeard in th highest number of
--- movies produced in india
select 
unnest(string_to_array(casts,',')) as actors,
count(*) as total_content
from netflix
where country ILIKE '%India'
group by 1
order by 2 desc
limit 10


---15. Categorize the content based on the presence of the keyword
-- 'kill' and 'violence' in the description fields.label content containig these keyword
--as 'Bad' and all other content as 'Good'. count  how many items fall into each category
with new_table
as
(
select *, 
case
when description ILIKE '%kill%' or
      description Ilike '%violence%' then 'Bad_content'
	  else 'Good Content'
	  end category
from netflix
)
select category,
count(*) as total_content from new_table
group by 1

-------------------------------------------------------------------------------------------------------








