# create database sql;
use sql;



create table app_list
(apply_date date,
loan_no varchar(10) primary key,
apply_prin int,
result varchar(10));



desc app_list;
# apply_date loan_no apply_prin
# 申请日期 合同编号 申请金额



insert into app_list values 
("2018-2-5","GM290144",10000,"pass"),
("2018-3-1","GM290937",10000,"reject"),
("2018-4-17","GM296833",8000,"pass"),
("2018-5-11","GM310938",6000,"pass"),
("2018-5-25","GM327400",15000,"reject"),
("2018-6-18","GM350939",1000,"pass"),
("2018-10-12","GM380936",12000,"pass"),
("2018-11-5","GM400940",20000,"reject"),
("2018-2-5","GM290140",10000,"pass"),
("2018-3-1","GM290938",10000,"pass"),
("2018-4-17","GM296843",8000,"pass"),
("2018-5-11","GM310939",6000,"pass"),
("2018-5-25","GM327401",15000,"pass"),
("2018-6-18","GM350966",1000,"pass"),
("2018-10-12","GM380976",12000,"pass"),
("2018-11-5","GM400949",20000,"pass"),
("2018-2-5","GM290114",10000,"pass"),
("2018-3-1","GM290923",10000,"reject"),
("2018-4-17","GM29571",8000,"pass"),
("2018-5-11","GM310928",6000,"pass"),
("2018-5-25","GM32411",15000,"reject"),
("2018-6-18","GM351939",1000,"pass"),
("2018-10-12","GM376936",12000,"pass"),
("2018-11-5","GM441940",20000,"pass");



select * from app_list;
# apply_date 审批时间  loan_no 编号 apply_prin 金额  result 结果
# 2018-02-05	GM290114	10000	pass
# 2018-02-05	GM290140	10000	pass



# 1 所有日期的审批通过率及审批均值金额
# 通过率=审批通过个数 除以 总个数
# 平均申请金额，总金额 除以 总申请数据行条数
# count 对非空的结果求数量 不管是1或0，结果都是所有的通过与否的结果
select 
	apply_prin * (result='pass') as 审批通过项目的总金额,
	round((apply_prin * (result='pass'))/(sum(result='pass')),0) as 审批通过项目的均值金额,
	round(sum(result='pass')/count(result),2) as 审批通过率,
	sum(result='pass') as 审批通过数量,
	count(result='pass') as 审批总数,
	sum(result='reject') as 审批拒绝数量,
	count(result='reject') as 审批总数
from app_list;



# 2 每天的审批通过率及审批通过的平均申请金额
# 通过总金额：每个金额 乘以 通过的结果后求和，没通过为0 乘以 金额 等于0
# 通过总数：结果为pass的进行sum求和，为pass的=1，不为pass的=0
select
	apply_date,
	(sum(apply_prin * (result='pass'))) as 审批通过项目的总金额,
	round(sum(apply_prin * (result='pass')) / (sum(result='pass')),0) as 审批通过项目的均值金额,
	round(sum(result='pass')/count(result),2) as 审批通过率,
	sum(result='pass') as 审批通过数量,
	count(result='pass') as 审批总数,
	sum(result='reject') as 审批拒绝数量,
	count(result='reject') as 审批总数
from app_list
group by apply_date;
# apply_date	审批通过项目的总金额	审批通过率	审批通过项目的均值金额	审批通过数量	审批总数	审批拒绝数量	审批总数
# 2018-02-05	30,000	1	10,000	3	3	0	3
# 2018-03-01	10,000	0.33	10,000	1	3	2	3
# 2018-04-17	24,000	1	8,000	3	3	0	3
# 2018-05-11	18,000	1	6,000	3	3	0	3
# 2018-05-25	15,000	0.33	15,000	1	3	2	3
# 2018-06-18	3,000	1	1,000	3	3	0	3
# 2018-10-12	36,000	1	12,000	3	3	0	3
# 2018-11-05	40,000	0.67	20,000	2	3	1	3



select 
(apply_date) as 日期,
count(result='reject') as 通过个数,
count(result='pass') as 不通过个数,
count(result='reject')/count(result) as 通过率
from app_list
group by apply_date;
# 日期	通过个数	不通过个数	通过率
# 2018-02-05	3	3	1
# 2018-03-01	3	3	1
# 2018-04-17	3	3	1
# 2018-05-11	3	3	1
# 2018-05-25	3	3	1
# 2018-06-18	3	3	1
# 2018-10-12	3	3	1
# 2018-11-05	3	3	1



# 用sum求和能对满足条件的结果1或不满足的0进行求和 得到满足结果的总数
select 
(apply_date) as 日期,
sum(result='pass') as 通过个数,
sum(result='reject') as 不通过个数,
count(loan_no) as 合同编号总数,
sum(result='pass')/count(loan_no) as 审批通过率,
(sum(apply_prin * (result='pass'))) as 审批通过总金额,
sum(apply_prin * (result='pass'))/(sum((result='pass'))) as 审批通过均值
from app_list
group by apply_date;



# 每天的审批通过率及审批通过的平均申请金额
select apply_date,sum(result='pass')/count(loan_no) 审批通过率,
sum((result='pass')*apply_prin)/sum(result='pass') 审批通过的平均申请金额
from app_list
group by apply_date;
# apply_date	审批通过率	审批通过的平均申请金额
# 2018-02-05	1.0000	10000.0000
# 2018-03-01	0.3333	10000.0000
# 2018-04-17	1.0000	8000.0000
# 2018-05-11	1.0000	6000.0000
# 2018-05-25	0.3333	15000.0000
# 2018-06-18	1.0000	1000.0000
# 2018-10-12	1.0000	12000.0000
# 2018-11-05	0.6667	20000.0000



# 放款日期 合同编号 身份证号码 放款金额 已还本金 费率等级 逾期天数
create table loan_list
(loan_date date,
loan_no varchar(15),
id_no varchar(25),
loan_prin int,
paid_principal int,
product_rate varchar(2),
overdue_days int);



# 放款日期 合同编号 身份证号码 放款金额 已还本金 费率等级 逾期天数
insert into loan_list values
("2018-2-5","GM290144","1100001990",10000,8000,"A",null),
("2018-4-17","GM296833","5500001992",8000,1500,"D",11),
("2018-5-11","GM310938","2300001991",6000,5500,"D",null),
("2018-6-18","GM350939","4500001989",1000,0,"B",432),
("2018-4-18","GM296834","5100001992",6000,1500,"D",31),
("2018-4-20","GM296894","5100001982",60000,15000,"D",40),
("2018-3-20","GM296874","5100001987",13000,10000,"D",60);



select * from loan_list;
# 2018-02-05	GM290144	1100001990	10000	8000	A	
# 2018-04-17	GM296833	5500001992	8000	1500	D	11
# 2018-05-11	GM310938	2300001991	6000	5500	D	
desc loan_list;
# 放款日期     合同编号  身份证号码   放款金额        已还本金                   费率等级             逾期天数
# loan_date loan_no id_no       loan_prin   paid_principal  product_rate   overdue_days

# 2018年2-5月份，不同费率的放款笔数、放款金额、30天以上金额逾期率（剩余本金/放款金额）
# 剩余本金等于放款总金额减去已还本金
select product_rate as 费率等级,sum(loan_prin) as 放款金额1,
sum(loan_prin)-sum(paid_principal) as 剩余本金,
(sum(loan_prin)-sum(paid_principal))/(sum(loan_prin)) as 金额逾期率,
ifnull(sum((overdue_days>30)*(loan_prin-paid_principal)),0) as 逾期30天剩余本金,
(select sum(loan_prin) from loan_list where year(loan_date)=2018 and month(loan_date) between 2 and 5) as 放款金额2,
ifnull(sum((overdue_days>30)*(loan_prin-paid_principal))/(select sum(loan_prin) from loan_list where year(loan_date)=2018 and month(loan_date) between 2 and 5),0) 30天以上金额逾期率
from loan_list
where (year(loan_date)=2018) and (month(loan_date) between 2 and 5)
group by  product_rate;
# 费率等级	放款金额1	剩余本金	金额逾期率	逾期30天剩余本金	放款金额2	30天以上金额逾期率
# A	10,000	2,000	0.2	0	103,000	0
# D	93,000	59,500	0.6398	52,500	103,000	0.5097

select 
	product_rate,count(loan_no) as 放款笔数,
	sum(loan_prin) as 放款金额,
	ifnull(sum((overdue_days>30)*(loan_prin - paid_principal)),0) as 剩余本金30天,
	(select sum(loan_prin) from loan_list where year(loan_date)=2018 and month(loan_date) between 2 and 5) as 放款金额,
    ifnull(sum((overdue_days>30)*(loan_prin-paid_principal))/(select sum(loan_prin) from loan_list where year(loan_date)=2018 and month(loan_date) between 2 and 5),0) 30天以上金额逾期率
from loan_list
where year(loan_date)=2018 and month(loan_date) between 2 and 5
group by product_rate;
# product_rate	放款笔数	放款金额	剩余本金30天	放款金额	`30天以上金额逾期率`
# A	1	10000	0	103000	0.0000
# D	5	93000	52500	103000	0.5097



create table customer(id_no varchar(25),groupp varchar(25),age int);
insert into customer values
("1100001990","house",29),
("5500001992","creditcard",27),
("2300001991","creditcard",28),
("4500001989","creditcard",30),
("4500001988","house",31),
("5100001992","car",46),
("5100001982","car",35),
("5100001987","house",31);



select * from customer;
# id_no	groupp	age
# 1100001990	house	29
# 5500001992	creditcard	27
# 2300001991	creditcard	28
# 4500001989	creditcard	30
# 4500001988	house	31
# 5100001992	car	46
# 5100001982	car	35
# 5100001987	house	31
select * from loan_list;
# 放款日期     合同编号  身份证号码   放款金额        已还本金                   费率等级             逾期天数
# loan_date	loan_no	id_no	loan_prin	paid_principal	product_rate	overdue_days
# 2018-02-05	GM290144	1100001990	10000	8000	A	
# 2018-04-17	GM296833	5500001992	8000	1500	D	11



# 所有用户中，分组合同客户占比用户比例
select customer.groupp as 群体名称,
(count(loan_list.loan_no)) as loaner人数,
(select count(id_no) from customer) as customer人数,
(count(loan_list.loan_no))/(select count(id_no) from customer) as 合同客户Div所有客户
from customer left join loan_list on customer.id_no = loan_list.id_no
group by groupp;
# 群体名称	合同客户数	用户人数	合同客户占比总用户
#house	2	8	0.25
# creditcard	3	8	0.375
# car	2	8	0.25



# 所有放款客户中，不同客群类型的人数占比
# 合同客户中，每组合同客户占比
select groupp,
count(distinct loan_list.id_no) as 分组合同客户数,
(select distinct count(id_no) from loan_list) as 总合同用户数,
count(distinct loan_list.id_no)/(select distinct count(id_no) from loan_list) 人数占比
from loan_list left join customer on loan_list.id_no=customer.id_no
group by groupp;
# groupp	人数占比
# car	0.2857
# creditcard	0.4286
# house	0.2857


