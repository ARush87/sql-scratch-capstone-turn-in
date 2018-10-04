/* Learn SQL from Scratch
   Sept 18, 2018 - Nov 12, 2018
   Adam Rush */


-- 1. How many campaigns and sources does CoolTShirts use? Which source is used for each campaign?

--    1.1. How many distinct campaigns are there?

SELECT COUNT(DISTINCT utm_campaign)
FROM page_visits;


--    1.1.2. What are the distinct CoolTShirts campaigns?

SELECT DISTINCT utm_campaign AS 'campaign'
FROM page_visits;


--    1.2. How many distinct sources are there?

SELECT COUNT(DISTINCT utm_source)
FROM page_visits;


--    1.2.2. What are the distinct CoolTShirts traffic sources?

SELECT DISTINCT utm_source AS 'source'
FROM page_visits;


--    1.3. How are the campaigns and sources related?

SELECT DISTINCT utm_campaign AS 'campaign’, 
   utm_source AS 'source'
FROM page_visits;


--    1.4. What pages are on the CoolTShirts website?

SELECT DISTINCT page_name AS ‘page’
FROM page_visits;



-- 2. What is the user journey?

--    2.1. How many first touches is each campaign responsible for?

WITH first_touch AS (
   SELECT user_id,
      MIN(timestamp) AS first_touch_at
   FROM page_visits
   GROUP BY user_id)
SELECT pv.utm_campaign AS 'campaign',
   COUNT(*) AS 'count'
FROM first_touch AS ft
JOIN page_visits AS pv
   ON ft.user_id = pv.user_id
   AND ft.first_touch_at = pv.timestamp
GROUP BY 1
ORDER BY 2 DESC;

--    2.2. How many lasttouches is each campaign responsible for?

WITH last_touch AS (
   SELECT user_id,
      MAX(timestamp) AS last_touch_at
   FROM page_visits
   GROUP BY user_id)
SELECT pv.utm_campaign AS 'campaign’,
   COUNT(*) AS 'count'
FROM last_touch AS lt
JOIN page_visits AS pv
   ON lt.user_id = pv.user_id
   AND lt.last_touch_at = pv.timestamp
GROUP BY 1
ORDER BY 2 DESC;



-- 3. Optimizing the Campaign Budget

--    3.1. CoolTShirts can re-invest in 5 campaigns. Which should they pick and why?


WITH lp AS(
  SELECT utm_campaign AS 'campaign',
     COUNT(*) AS 'landing_page'
  FROM page_visits
  WHERE page_name = '1 - landing_page'
  GROUP BY 1),
sc AS( 
  SELECT utm_campaign AS 'campaign',
     COUNT(*) AS 'shopping_cart'
  FROM page_visits
  WHERE page_name = '2 - shopping_cart'
  GROUP BY 1),
cp AS(
  SELECT utm_campaign AS 'campaign',
     COUNT(*) AS 'checkout'    
  FROM page_visits
  WHERE page_name = '3 - checkout'
  GROUP BY 1),
pc AS(  
  SELECT utm_campaign AS 'campaign’,
     COUNT(*) AS 'purchase'
  FROM page_visits
  WHERE page_name = '4 - purchase'
  GROUP BY 1)
SELECT DISTINCT pv.utm_campaign AS 'campaign’,
   lp.landing_page AS 'landing_page',
   sc.shopping_cart AS 'shopping_cart',
   cp.checkout AS 'checkout',
   pc.purchase AS 'purchase'
FROM page_visits AS pv
LEFT JOIN lp
   ON lp.campaign = pv.utm_campaign
LEFT JOIN sc
   ON sc.campaign = pv.utm_campaign
LEFT JOIN cp
   ON cp.campaign = pv.utm_campaign
LEFT JOIN pc
   ON pc.campaign = pv.utm_campaign
GROUP BY 1;
