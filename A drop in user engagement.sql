-- to check weekly active users
SELECT 
  DATE_TRUNC('week', e.occurred_at), 
  COUNT(DISTINCT e.user_id) AS weekly_active_users
FROM 
  tutorial.yammer_events e
WHERE 
  e.event_type='engagement'
AND e.event_name='login'
GROUP BY 1

-- to compare and check if the drop is because of the new users
SELECT 
  DATE_TRUNC('day', created_at), 
  COUNT(*) AS all_users, 
  COUNT(CASE WHEN activated_at IS NOT NULL THEN user_id Else NULL END) AS activated_users 
FROM 
  tutorial.yammer_users 
WHERE 
  created_at >= '2014-06-01'
AND 
  created_at < '2014-09-01'
GROUP BY 1;

-- Retention Rate 
SELECT 
  DATE_TRUNC('week', z.occurred_at) AS "week",
  AVG(z.age_at_event) AS "Average Age during the week",
  COUNT(DISTINCT CASE WHEN z.user_age<7 THEN z.user_id ELSE NULL END) AS "less than 1 week",
  COUNT(DISTINCT CASE WHEN z.user_age<14 AND z.user_age>=7 THEN z.user_id ELSE NULL END) AS "1 week",
  COUNT(DISTINCT CASE WHEN z.user_age<21 AND z.user_age>=14 THEN z.user_id ELSE NULL END) AS "2 weeks",
  COUNT(DISTINCT CASE WHEN z.user_age<28 AND z.user_age>=21 THEN z.user_id ELSE NULL END) AS "3 weeks",
  COUNT(DISTINCT CASE WHEN z.user_age<35 AND z.user_age>=28 THEN z.user_id ELSE NULL END) AS "4 weeks",
  COUNT(DISTINCT CASE WHEN z.user_age<42 AND z.user_age>=35 THEN z.user_id ELSE NULL END) AS "5 weeks",
  COUNT(DISTINCT CASE WHEN z.user_age<49 AND z.user_age>=42 THEN z.user_id ELSE NULL END) AS "6 weeks",
  COUNT(DISTINCT CASE WHEN z.user_age<56 AND z.user_age>=49 THEN z.user_id ELSE NULL END) AS "7 weeks",
  COUNT(DISTINCT CASE WHEN z.user_age<63 AND z.user_age>=56 THEN z.user_id ELSE NULL END) AS "8 weeks",
  COUNT(DISTINCT CASE WHEN z.user_age<70 AND z.user_age>=63 THEN z.user_id ELSE NULL END) AS "9 weeks",
  COUNT(DISTINCT CASE WHEN z.user_age>=70 THEN z.user_id ELSE NULL END) AS "10+ weeks"
FROM
  (SELECT  e.occurred_at, u.user_id, DATE_TRUNC('week', u.activated_at) AS activation_week, 
           EXTRACT ( 'day' FROM e.occurred_at-u.activated_at) AS age_at_event,
           EXTRACT ('day' FROM '2014-09-01'::TIMESTAMP- u.activated_at ) AS user_age
   FROM tutorial.yammer_users u
   JOIN tutorial.yammer_events e 
   ON e.user_id=u.user_id
   AND e.event_type='engagement'
   AND e.event_name='login'
   AND e.occurred_at >= '2014-05-01'
   AND e.occurred_at < '2014-09-01'
   WHERE u.activated_at IS NOT NULL) z
GROUP BY 1;

-- user engagement by device type
SELECT 
  DATE_TRUNC('week', occurred_at), 
  COUNT(DISTINCT user_id) AS weekly_active_users,
  COUNT(DISTINCT CASE WHEN device IN ('ipad mini','samsumg galaxy tablet', 'nexus 10', 'nexus 7', 'kindle fire','nexus 5','ipad air') 
                    THEN user_id ELSE NULL END) AS "Tablet",
  COUNT(DISTINCT CASE WHEN device IN ('amazon fire phone', 'iphone 5', 'iphone 5s', 'nokia lumia 635', 'htc one', 'iphone 4s', 'samsung galaxy note', 'samsung galaxy s4') 
                    THEN user_id ELSE NULL END) AS "Phone",
  COUNT(DISTINCT CASE WHEN device IN ('dell inspiron desktop', 'macbook pro', 'asus chromebook', 'windows surface', 'macbook air', 'lenovo thinkpad', 'mac mini', 'acer aspire desktop', 'acer aspire notebook', 'dell inspiron notebook', 'hp pavilion desktop', 'hp pavilion desktop') 
                    THEN user_id ELSE NULL END) AS "Computer"                   
FROM 
  tutorial.yammer_events 
WHERE 
  event_type='engagement'
AND 
  event_name='login'
GROUP BY 1;

-- Is there any relation between user's email actions and the drop of engagement?
SELECT 
   DATE_TRUNC('week', occurred_at) AS active_week, 
   COUNT(DISTINCT CASE WHEN action='sent_weekly_digest' THEN user_id ELSE NULL END) AS email_delivered,
   COUNT(DISTINCT CASE WHEN action='email_open' THEN user_id ELSE NULL END) AS email_open,
   COUNT(DISTINCT CASE WHEN action='email_clickthrough' THEN user_id ELSE NULL END) AS email_clickthrough
FROM 
  tutorial.yammer_emails
GROUP BY 1;
