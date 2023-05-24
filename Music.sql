--  who is the senior most employee based on job title?
 select *from employee order by levels desc limit 1;
 
--  which country have the most invoices?
select count(*) as c , billing_country from invoice group by billing_country
order by c desc;

-- what are top 3 values of total invoices?
select total from invoice order by total desc limit 3;


-- which city have the best customers also having highest invoice total?
select sum(total) as r, billing_city from invoice group by billing_city order by r desc limit 1

-- who is the best customer or one who spent the most money?
select customer.first_name,customer.last_name,sum(invoice.total) as c from 
customer join invoice 
on customer.customer_id=invoice.customer_id
group by customer.customer_id order by c desc limit 1

-- write a query to return email,first name,last name & genre of all rock music listeners?
select distinct email,first_name,last_name from customer 
join  invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id in(
select track_id from track join genre on 
	track.genre_id=genre.genre_id
	where genre.name like 'Rock'
) order by email 

-- Name the artist who have written the most rock music in the dataset & total track
-- count of top 10 rock bands?
select  artist.artist_id,artist.name , count(artist.artist_id) as No_of_songs from artist 
join album on artist.artist_id=album.artist_id
join track on album.album_id=track.album_id
join genre on track.genre_id=genre.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by No_of_songs desc
limit 10

-- Return all the song name having length longer than the average song length
--  return name and millisec
select name, milliseconds from track where milliseconds >(
	select avg(milliseconds) as time from track
) 
order by milliseconds desc

-- Find how much amount spent on each artist by the customers?
with best_selling_artist as (
	select artist.artist_id as artist_id, artist.name as artist_name,
	sum(invoice_line.unit_price* invoice_line.quantity) as total_sales
	from invoice_line
	join track on invoice_line.track_id=track.track_id
	join album on track.album_id= album.album_id
	join artist on album.artist_id=artist.artist_id
	group by 1
	order by 3 desc
	limit 1
)
select c.customer_id, c.first_name,c.last_name,bsa.artist_name,
sum(il.unit_price * il.quantity)as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=il.track_id
join album alb on alb.album_id=t.album_id
join best_selling_artist bsa on bsa.artist_id=alb.artist_id
group by 1 , 2 , 3, 4
order by 5 desc;

-- Find most popular music genre of each country?
-- popular in the sense as the genre with highest number of purchases
with popular_genre as(
select count(il.quantity)as purchases , customer.country,genre.name,genre.genre_id,
row_number() over(partition by customer.country order by count(il.quantity)desc) as rowno
from invoice_line il
join invoice i on i.invoice_id=il.invoice_id
join customer on customer.customer_id=i.customer_id
join track on track.track_id=il.track_id
join genre on genre.genre_id=track.genre_id
group by 2, 3,4
order by 2 asc, 1 desc
)
select * from popular_genre where rowno=1

-- Find the customer who spent the most on music for each country
with customer_with_country as(
select c.customer_id,first_name,last_name,billing_country, sum(total) as total_spending, 
row_number() over (partition by billing_country order by sum(total) desc) as rowno
	from invoice
	join customer c on c.customer_id=invoice.customer_id
	group by 1,2,3,4
	order by 4 asc, 5 desc
	)
	select * from customer_with_country where rowno=1
