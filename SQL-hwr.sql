use sakila;

select * from actor limit 5;

select first_name, last_name from actor;

select first_name, last_name, upper(concat(first_name,' ',last_name)) as Actor_name from actor;

-- You need to find the ID number, first name, and last name of an actor, of whom you know only 
-- the first name, "Joe." What is one query would you use to obtain this information?

select actor_id, first_name, last_name from actor where first_name = 'Joe';

select actor_id, first_name, last_name from actor where last_name LIKE '%gen%';

-- Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

select actor_id, first_name, last_name from actor where last_name LIKE '%li%' order by last_name, first_name;

-- Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China
select * from country limit 5;

select country_id from country where country in ('Afghanistan', 'Bangladesh', 'China');

-- Add a middle_name column to the table actor. Position it between first_name and last_name.
-- Hint: you will need to specify the data type.

alter table actor add middle_name varchar(30);
select * from actor limit 5;
-- alter table middle_name change   after column first_name 

alter table actor change column middle_name middle_name varchar(30) after first_name;


alter table actor modify column middle_name blob;

-- 3c. Now delete the middle_name column.
alter table actor drop column middle_name;
select * from actor limit 5;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name,count(*) from actor group by last_name;
-- 4b. List last names of actors and the number of actors who have that last name, but 
-- only for names that are shared by at least two actors
select last_name,count(*) as num from actor group by last_name having num > 1;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as 
-- GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the
-- record.
update actor
set first_name = 'HARPO'
where first_name = 'GROUCHO' and last_name='WILLIAMS';

select * from actor where FIRST_name='HARPO';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all!
-- In a single query, if the first name of the actor is currently HARPO, change it to
-- GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY
-- ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
-- IF(condition, value_if_true, value_if_false)

UPDATE actor SET first_name = IF (first_name = 'harpo','GROUCHO', 'MUCHO GROUCHO') where actor_id=172;
select * from actor;


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
create table address1 (
	address_id int not null auto_increment,
    address varchar(50) not null,
    address2 VARCHAR(50) default null,
    district varchar(30) not null,
    city_id int not null,
    postal_code int not null,
    phone int not null,
    location geometry not null,
    last_update date not null DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY  (address_id),
    FOREIGN KEY (city_id) REFERENCES city (city_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
select * from address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

select first_name, last_name, address from staff join address on staff.address_id = address.address_id;
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

select first_name, last_name, sum(amount) from staff join payment on staff.staff_id = payment.staff_id group by staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select * from film_actor;
select * from film;
select title, count(actor_id) from film inner join film_actor on film.film_id = film_actor.film_id group by film.film_id;
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select * from inventory limit 5;
select film_id from film where title = 'Hunchback Impossible';
select film_id,count(film_id) from inventory where film_id = (select film_id from film where title = 'Hunchback Impossible');

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
-- ![Total amount paid](Images/total_payment.png)
select * from payment limit 5;
select * from customer limit 5;
select first_name, last_name, sum(amount) from customer inner join payment on customer.customer_id = payment.customer_id 
group by customer.customer_id order by last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters K and Q have also soared in popularity. Use subqueries
-- to display the titles of movies starting with the letters K and Q whose language is English.
select * from film limit 5;
select title,name from film inner join language on film.language_id = language.language_id 
where (title like 'K%' or title like 'Q%') and language.name = 'English';

select title from film where (title like 'K%' or title like 'Q%') and language_id = (select language_id from language where name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
-- SUB QUERY
select first_name, last_name from actor where actor_id 
in (select actor_id from film_actor 
where film_id = (select film_id from film where title = 'Alone Trip'));

-- JOIN
select first_name, last_name 
from actor 
inner join film_actor on actor.actor_id = film_actor.actor_id
inner join film on film_actor.film_id = film.film_id
where title = 'Alone Trip';

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and 
-- email addresses of all Canadian customers. Use joins to retrieve this information.
select * from address limit 5;
select * from city limit 5;
select * from country limit 5;
select * from customer limit 5;
-- JOIN
select first_name, last_name, email
from customer
join address on customer.address_id = address.address_id
join city on address.city_id = city.city_id
join country on city.country_id = country.country_id
where country.country = 'Canada';
-- 
-- SUB QUERY
select country_id from country where country = 'Canada';
select first_name from customer where address_id 
in (select address_id from address where city_id 
in (select city_id from city where country_id = 20));

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
select * from CATEGORY;
select * from FILM_CATEGORY limit 5;
select * from FILM_TEXT limit 5;

select title from film_text
inner join film_category on film_text.film_id = film_category.film_id
inner join category on film_category.category_id = category.category_id
where category.category_id = 8;


-- 7e. Display the most frequently rented movies in descending order.
select * from RENTAL limit 5;
select * from inventory limit 5;
select * from film_text limit 5;

select title, count(title)
from film_text
inner join inventory on film_text.film_id = inventory.film_id
inner join rental on inventory.inventory_id = rental.inventory_id
group by title
order by count(title) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select * from payment limit 5;
select * from inventory limit 5;
select * from store limit 5;

select store_id,sum(amount) 
from payment
inner join store on payment.staff_id = store.manager_staff_id
group by staff_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select * from store limit 5;
select * from address limit 5;
select * from city where city_id in (300,576);
select * from country where country_id in (20,8);

select store_id, city, country
from store
join address on store.address_id = address.address_id
join city on address.city_id = city.city_id
join country on city.country_id = country.country_id;


-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: 
-- category, film_category, inventory, payment, and rental.)
select * from category;
select * from film_category limit 5;
select * from inventory limit 5;
select * from rental limit 5;
select * from payment limit 5;


select category.name, sum(amount)
from category
join film_category on category.category_id = film_category.category_id
join inventory on film_category.film_id = inventory.film_id
join rental on inventory.inventory_id = rental.inventory_id
join payment on rental.rental_id = payment.rental_id
group by category.name
order by sum(amount) desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
--  Use the solution from the problem above to create a view. If you haven't
-- solved 7h, you can substitute another query to create a view.

create view top_five_genres as
select category.name, sum(amount)
from category
join film_category on category.category_id = film_category.category_id
join inventory on film_category.film_id = inventory.film_id
join rental on inventory.inventory_id = rental.inventory_id
join payment on rental.rental_id = payment.rental_id
group by category.name
order by sum(amount) desc
limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_five_genres;


