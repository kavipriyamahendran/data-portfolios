Use Foodie_fi
Go

/*************************************************************************
	QUESTION 1: How many customers has Foodie-Fi ever had? --
*************************************************************************/

Select Count(Distinct customer_id) As 'total_customers'
From subscriptions

--	OUTPUT
--	total_customers
--	---------------
--	1000

--	INSIGHTS
--	Food-Fi has had a total of 1000 customers so far

/*************************************************************************
	QUESTION 2: What is the monthly distribution of trial plan start_date 
	values for our dataset
*************************************************************************/

Select Month(start_date) as 'month', Count(customer_id) As 'no_of_trial_subscriptions'
From subscriptions
Where plan_id = 0      /* 0 - Trial Plan */
Group by Month(start_date)
Order by Month(start_date)

--	OUTPUT
--	month       no_of_trial_subscriptions
--	----------- -------------------------
--	1           88
--	2           68
--	3           94
--	4           81
--	5           88
--	6           79
--	7           89
--	8           88
--	9           87
--	10          79
--	11          75
--	12          84


--	INSIGHTS
--	Trial subscriptions are mostly uniform throughout the year
--	with lowest subscriptions in February and highest in March

/*************************************************************************
	QUESTION 3: After the year 2020, provide the breakdown of count of events for 
	each plan in the dataset
*************************************************************************/

Select P.plan_id, P.plan_name, Count(S.Customer_id) AS 'count_of_events'
From subscriptions S Inner Join Plans P
                     On S.plan_id = P.plan_id
Where Year(S.Start_date) > 2020
Group by P.plan_id, P.plan_name
Order by P.plan_id

--	OUTPUT
--	plan_id     plan_name     count_of_events
--	----------- ------------- ---------------
--	1           basic monthly 8
--	2           pro monthly   60
--	3           pro annual    63
--	4           churn         71

--	INSIGHTS
--	After the year 2020 there are
--		8 with basic monthly
--		60 with pro monthly
--		63 with pro annual and
--		71 have churned

/*************************************************************************
	QUESTION 4: What is the customer count and percentage of customers 
	who have churned rounded to 1 decimal place?
*************************************************************************/

Select Count(Distinct customer_id) AS 'total_customer', 
       Round((Cast((Count(Distinct customer_id)* 100) AS Float) / (Select Count(Distinct customer_id) From subscriptions)),1) AS 'percent_disconnect_customers'
From subscriptions
Where Plan_id = 4	/* Churn*/

--	OUTPUT
--	total_customer		percent_disconnect_customers
--	------------------------------------------------
--	307					30.7

--	INSIGHTS
--	307 customers have churned
--	30.7% of total customers have churned

/*************************************************************************
	QUESTION 5: How many customers have churned straight after their 
	initial free trial. What percentage is this rounded to the 
	nearest whole number?
*************************************************************************/

With cte_churned_customers (customer_id_cc, start_date_cc)
As
(
Select customer_id, start_date
From subscriptions
Where plan_id = 4 /*Churn*/
),

cte_trial_plan_customers (customer_id_tc, start_date_tc, trial_end_date)
As
(
Select customer_id, start_date, DateAdd(Day, 7, start_date)
From subscriptions
Where plan_id = 0 /*Trial*/
)

Select Count(customer_id_cc) AS 'churned_customers_after_free_trial_count', 
      Round((Cast((Count(customer_id_cc)*100) AS Float)/(Select Count(distinct customer_id) From subscriptions Where plan_id = 0)),0) 
	                                                                                 AS 'churned_customers_after_trial_percent'
From cte_churned_customers 
inner join cte_trial_plan_customers
on customer_id_cc = customer_id_tc 
Where start_date_cc BETWEEN start_date_tc AND trial_end_date

--	OUTPUT
--	churned_customers_after_free_trial_count churned_customers_after_trial_percent
--	---------------------------------------- ---------------------------------------
--	92                                       9

--	INSIGHTS
--	92 customers churned after free trial
--	9% of total customers churned after free trials

/*************************************************************************
	QUESTION 6: Show the count and percentage of plans that the customer 
	chose after the free trial.
*************************************************************************/

With cte_customer_plan_history 
As
(
Select customer_id, plan_id, start_date, 
       Row_Number() over (partition by customer_id order by start_date) as 'event_number'
From subscriptions     
)

Select P.plan_id, P.plan_name, Count(C.Customer_id) AS 'customer_count', 
	   Round(Cast(Count(C.Customer_id) * 100 as Float)/(select Count(distinct customer_id) from cte_customer_plan_history),2) 'percentage_of_customers'
From cte_customer_plan_history C Inner Join Plans P
                                 On C.plan_id = P.plan_id
Where C.event_number = 2 /* event_number 1 is trial plan, event_number 2 is the plan immediately after Trial */
Group by P.plan_id, P.plan_name
Order by P.plan_id


--	OUTPUT
--	plan_id     plan_name     customer_count percentage_of_customers
--	----------- ------------- -------------- -----------------------
--	1           basic monthly 546            54.6
--	2           pro monthly   325            32.5
--	3           pro annual    37             3.7
--	4           churn         92             9.2

--	INSIGHTS
--	After the free trial more than half of the subscribers
--  moved to the baic monthly plan
--		546 subscribers moved to basic monthly which is 54.6%
--		325 subscribers moved to monthly which is 32.5%
--		37 subscribers moved to pro annual which is 3.7%
--		92 subscribers churned which is 9.2%


/*************************************************************************
	QUESTION 7: What is the customer count and percentage breakdown of 
	all 5 plan_name values at 2020-12-31?
*************************************************************************/

With cte_customer_plan_history_desc
As
(
Select customer_id, plan_id, start_date
	 , Row_Number() over (partition by customer_id order by start_date Desc) as 'event_number'
  from subscriptions
  where start_date <= '2020-12-31'
)

Select P.plan_id, P.plan_name, Count(C.Customer_id) AS 'customer_count', 
		Round(Cast(Count(C.Customer_id) * 100 as Float)/(select Count(distinct customer_id) from cte_customer_plan_history_desc),2) 'percentage_of_customers' 
From cte_customer_plan_history_desc C Inner Join Plans P
                     On C.plan_id = P.plan_id
Where C.event_number = 1 /* event_mi,ner 1 is their current plan on 31-Dec-2020 */
Group by P.plan_id, P.plan_name
Order by P.plan_id 

--	OUTPUT
--	plan_id     plan_name     customer_count percentage_of_customers
--	----------- ------------- -------------- -----------------------
--	0           trial         19             1.9
--	1           basic monthly 224            22.4
--	2           pro monthly   326            32.6
--	3           pro annual    195            19.5
--	4           churn         236            23.6

--	INSIGHTS
--	On 31st December 2020, a third of subscribers were in pro monthly
--  a quarter of them have churned, around 20% of them were in pro annual,
--	22% of them with basic monthly and a very few in trial plans.


/*************************************************************************
	QUESTION 8: How many customers have upgraded to an annual plan 
	in 2020?
*************************************************************************/

Select count(*) As 'customers_upgraded_to_annual'
From subscriptions
Where Year(start_date) = 2020 AND Plan_id = 3 /* 3 - Annual plan */

--	OUTPUT
--	customers_upgraded_to_annual
--	----------------------------
--	195

--	INSIGHTS
--	A total of 195 subscribers upgraded to Pro Annual plan in 2020

/*************************************************************************
	QUESTION 9: How many days on average does it take for a customer to an 
	annual plan from the day they join Foodie-Fi?
*************************************************************************/

With cte_customers_with_trial_and_annual
As
(
Select Customer_id, Plan_id, start_date, Row_number() Over(Partition by Customer_id Order by [Start_date]) As 'event_number',
       First_value (Start_date) Over(partition by Customer_id Order by [Start_date]) AS 'first_value',
       Last_value(Start_date) Over(partition by Customer_id Order by [Start_date] Range Between Unbounded Preceding And Unbounded Following) As 'last_value'
From subscriptions
Where plan_id in (0, 3) /* 0 - Trial plan, 3 - Pro Annual plan */ and 
customer_id IN (Select customer_id From subscriptions Where plan_id = 3 /* Pro Annual plan */)
)

Select Count(customer_Id) AS 'total_customers',
       Round(Avg(Cast(Datediff(Day, First_value, Last_value ) As Float)),2) AS 'avg_days_to_annual_plan'    
From cte_customers_with_trial_and_annual
Where event_number = 1

--	OUTPUT
--	total_customers avg_days_to_annual_plan
--	--------------- -----------------------
--	258             104.62

--	INSIGHTS
--	There were a total of 258 subscribers that used 'Pro Annual' plan and on an average it took 105 days
--	to get to 'Pro Annual' plan since they joined
