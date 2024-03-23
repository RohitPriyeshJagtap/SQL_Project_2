USE ig_clone;

SHOW TABLES;

-- Q1. How many times does the average user post?

SELECT AVG(post_count) AS count_per_user  FROM (
SELECT u.username, COUNT(u.username) AS post_count
FROM users u 
INNER JOIN photos p ON p.user_id = u.id
GROUP BY 1) AS user_count;

-- Q2. Find the top 5 most used hashtags.

SELECT t.id,t.tag_name, COUNT(*) AS count_of_hashtag FROM users u 
INNER JOIN photos p ON u.id = p.user_id
INNER JOIN photo_tags pt ON pt.photo_id = p.id
INNER JOIN tags t ON t.id = pt.tag_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5;

-- Q3. Find users who have liked every single photo on the site.

SELECT u.id,u.username FROM users u 
INNER JOIN likes l ON l.user_id = u.id
INNER JOIN photos p ON p.id = l.photo_id;

-- Q4. Retrieve a list of users along with their usernames and the rank of their account creation, ordered by the creation date in ascending order.

SELECT id, username, created_at AS account_created,RANK() OVER(ORDER BY created_at) AS rank_accountcreated FROM users;

-- Q5. List the comments made on photos with their comment texts, photo URLs, and usernames of users who posted the comments. Include the comment count for each photo

SELECT c.comment_text, image_url,u.username, COUNT(c.comment_text) OVER(PARTITION BY image_url) AS comment_count FROM users u 
INNER JOIN comments c ON c.user_id = u.id 
INNER JOIN photos p ON p.id = c.photo_id;

-- Q6. For each tag, show the tag name and the number of photos associated with that tag. Rank the tags by the number of photos in descending order.

SELECT t.tag_name,COUNT(p.image_url) AS no_of_photos ,RANK() OVER(ORDER BY COUNT(p.image_url) DESC) AS rank_by_photos,
DENSE_RANK() OVER(ORDER BY COUNT(p.image_url) DESC) AS denserank_by_photos
FROM tags t 
INNER JOIN photo_tags pt ON t.id = pt.tag_id 
INNER JOIN photos p ON p.id = pt.photo_id
GROUP BY 1;

-- Q7. List the usernames of users who have posted photos along with the count of photos they have posted. Rank them by the number of photos in descending order.

SELECT u.username, COUNT(p.image_url) AS photos_count,RANK() OVER(ORDER BY COUNT(p.image_url) DESC) AS rank_by_photos,
DENSE_RANK() OVER(ORDER BY COUNT(p.image_url) DESC) AS denserank_by_photos
FROM  users u 
INNER JOIN photos p ON p.user_id = u.id 
GROUP BY 1;

-- Q8. Display the username of each user along with the creation date of their first posted photo and the creation date of their next posted photo.

SELECT u.username, p.created_at, LEAD(p.created_at) OVER(PARTITION BY u.username) AS lead_creationdate FROM users u
INNER JOIN photos p ON p.user_id = u.id;

-- Q9. For each comment, show the comment text, the username of the commenter, and the comment text of the previous comment made on the same photo.

SELECT c.comment_text, u.username, p.image_url, LAG(c.comment_text) OVER(PARTITION BY p.image_url) AS previous_comment FROM photos p
INNER JOIN users u ON p.user_id = u.id 
INNER JOIN comments c ON u.id = c.user_id;

-- Q10. Show the username of each user along with the number of photos they have posted and the number of photos posted by the user before them and after them, based on the creation date.

WITH cte AS 
(SELECT u.username,COUNT(p.image_url) OVER(PARTITION BY u.username) AS num_photos,LEAD(p.image_url) OVER(PARTITION BY u.created_at) AS before_post, 
LAG(p.image_url) OVER(PARTITION BY u.created_at) AS after_post
FROM users u 
LEFT JOIN photos p ON p.user_id = u.id
ORDER BY 1)
SELECT * FROM cte;















