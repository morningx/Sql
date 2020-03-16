# create database sql;
use sql;



# invest投资；（把资金）投入
# 投资表，投资时间，用户ID，投资产品，投资金额
create table cmn_investment_request(
Created_at datetime,
User_id varchar(10),
invest_item varchar(10),
invest_amount decimal(38,10)
);



# 业务员表，用户ID，开始时间，结束时间，业务员ID
# 业务员有跟进联系对应的用户ID，产生了对应的投资行为
create table dim_agent(
User_id varchar(10),
Start_date datetime,
End_date datetime,
Agent_id varchar(10)
);



insert into cmn_investment_request values
('2017-11-01 01:32:00','A123','CFH',100000),
('2017-12-25 03:42:00','A123','AX',450000),
('2017-12-11 17:42:00','A123','CH',700000),
('2017-12-06 20:06:00','B456','CFH',1500000),
('2017-12-16 14:32:00','B456','AX',800000),
('2017-12-26 17:22:00','B456','AX',600000),
('2018-11-01 14:32:00','C789','JUIN',300000);



insert into dim_agent values
('A123','2016-01-01 00:00:00','2017-12-04 23:59:59',10001),
('A123','2017-12-05 00:00:00','3001-12-31 23:59:59',10002),
('B456','2015-10-31 00:00:00','2016-12-15 23:59:59',10001),
('B456','2016-12-16 00:00:00','3001-12-31 23:59:59',10003),
('C789','2015-01-01 00:00:00','3001-12-31 23:59:59',10002);



select * from cmn_investment_request;
select * from dim_agent;
desc cmn_investment_request; # Created_at User_id invest_item invest_amount
desc dim_agent; # User_id Start_date End_date Agent_id



# 单个用户每笔投资大于50万的用户
select 
	Created_at,
	User_id,
	TRUNCATE(sum(invest_amount)/count(invest_amount),2) as 用户投资均值
from cmn_investment_request
where year(Created_at)=2017
group by User_id;
# having sum(invest_amount)/count(invest_amount) > 500000
# `Created_at`	`User_id`	用户投资均值
# 2017-11-01 01:32:00	A123	416666.66
# 2017-12-06 20:06:00	B456	966666.66

select user_id,min(invest_amount)
from cmn_investment_request
where year(created_at)=2017
group by user_id
having min(invest_amount)>500000;
# user_id	min(invest_amount)
# B456	600,000



# 计算2017年仅投资过CFH和AX产品的用户

select * from cmn_investment_request;
desc cmn_investment_request; # Created_at User_id invest_item   invest_amount
desc dim_agent; # User_idStart_dateEnd_dateAgent_id

select distinct User_id
from cmn_investment_request
where year(Created_at)=2017
and invest_item = 'AX' or invest_item = 'CFH';
# User_id
# A123
# B456

select 
User_id,group_concat(distinct invest_item order by invest_item desc) as 投资产品
from cmn_investment_request
where year(Created_at)=2017
group by User_id
having 投资产品 = 'CFH,AX';
# User_id	投资产品
# B456	CFH,AX



# 归属于10002业务员的投资金额

select * from cmn_investment_request;
select * from dim_agent;
desc cmn_investment_request; # Created_at User_id invest_item   invest_amount
desc dim_agent; # User_id Start_date End_date Agent_id

# 考虑到业务员必须在开始时间和结束时间内，用户创建的购买订单才有效
# 否则就是别人锁定的收益
select d.Agent_id,sum(c.invest_amount)
from cmn_investment_request as c
left join dim_agent as d 
on c.User_id = d.User_id
where (d.Agent_id = 10002) 
and (Created_at between Start_date and End_date);
# Agent_id	sum(invest_amount)
# 10002	1,450,000

select Agent_id,sum(invest_amount)
from cmn_investment_request t1
left join dim_agent t2
on t1.user_id = t2.user_id
and created_at between start_date and end_date
where Agent_id = 10002;
# Agent_id	sum(invest_amount)
# 10002	1,450,000

select di.Agent_id,sum(cm.invest_amount) 
from cmn_investment_request as cm
left join dim_agent as di
on (cm.User_id = di.User_id) 
and (cm.Created_at between di.Start_date and di.End_date)
where di.Agent_id = 10002
group by Agent_id;
# Agent_id	sum(cm.invest_amount)
# 10002	1,450,000

