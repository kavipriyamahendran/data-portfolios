Use Foodie_fi
Go

/*

CHALLENGE A. Customer Journey:
------------------------------

Based off the 8 sample customers provided in the sample from the subscriptions table, 
write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join to 
make your explanations a bit easier!

customer_id	plan_id	start_date
1	0	2020-08-01
1	1	2020-08-08
2	0	2020-09-20
2	3	2020-09-27
11	0	2020-11-19
11	4	2020-11-26
13	0	2020-12-15
13	1	2020-12-22
13	2	2021-03-29
15	0	2020-03-17
15	2	2020-03-24
15	4	2020-04-29
16	0	2020-05-31
16	1	2020-06-07
16	3	2020-10-21
18	0	2020-07-06
18	2	2020-07-13
19	0	2020-06-22
19	2	2020-06-29
19	3	2020-08-29

*/

/*
QUERIES TO ANALYZE THE SAMPLE
*/

IF OBJECT_ID('tempdb..#AnalysisFromSample') IS NOT NULL DROP TABLE #AnalysisFromSample
GO

Select S.customer_id, S.plan_id,S.start_date AS 'activity_date', P.plan_name
into #AnalysisFromSample
From subscriptions S Inner Join Plans P
                     ON S.Plan_id = P.Plan_id
Where customer_id IN (1,2,11,13,15,16,18,19)
order by customer_id, plan_id

Select * 
From #AnalysisFromSample

Select Distinct Customer_id
From #AnalysisFromSample 

select * from plans

Select * 
	 , DATEDIFF(DD, LAG(activity_date,1) OVER (PARTITION BY customer_id ORDER BY activity_date), activity_date) days_since_last_activity
From #AnalysisFromSample

Select Customer_id, Plan_id, activity_date, Plan_name
From #AnalysisFromSample
Where Plan_id = 0

Select Customer_id, Plan_id, activity_date, Plan_name
From #AnalysisFromSample
Where Plan_id >=1

DROP TABLE #AnalysisFromSample

/*
BRIEF CUSTOMER JOURNEY OF EACH CUSTOMER
=======================================

customer_id 1 went to basic monthly after the trial period of 7 days
customer_id 2 upgraded to 'Pro Annual' plan right after the trial period
customer_id 11 didn't continue the subscription after the trial period
customer_id 13 started with basic monthly after the trial and in little
  over three months upgraded to pro monthly plan
cusomter_id 15 started with pro monthly after trial but discontinued the
  service in little over a month
customer_id 16 began with basic monthly and upgraded to pro annual in 
  around four and half months
customer_id 18 went with pro monthly after trial
customer_id 19 started with pro monthly after trial and upgraded to pro annual
  in a couple of months

*/
