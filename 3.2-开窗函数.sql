# 建表1
create table user_goods_table(
user_name varchar(100),
goods_kind varchar(255));
# 建表2
create table t_user(
id int,
name varchar(100),
dept varchar(255),
salary int);



# 查看表结构
desc user_goods_table;
desc t_user;



# 插入数据
insert into user_goods_table values('张三','美食'),('李四','服饰');
insert into user_goods_table values('张三','服饰'),('李四','美食');
insert into user_goods_table values('王五','美食'),('赵六','服饰');
insert into user_goods_table values('王五','美容'),('王五','旅游');
insert into user_goods_table values('王五','美容'),('张三','旅游');
insert into user_goods_table values('王五','美容'),('李四','旅游');
insert into t_user values(1,'张三','美食部门',1000),(2,'李四','服饰部门',1100);
insert into t_user values(3,'王五','美食部门',1200),(4,'赵六','服饰部门',1300);
insert into t_user values(5,'钱七','美食部门',1400),(6,'李八','服饰部门',1500);
insert into t_user values(7,'赵九','美食部门',1600),(8,'黎十','服饰部门',1700);



# 查询结果
select * from user_goods_table;
select * from t_user;
/*
user_name	goods_kind
张三	美食
李四	服饰
张三	服饰
李四	美食
王五	美食
赵六	服饰
王五	美容
王五	旅游

1	张三	美食部门	1000
2	李四	服饰部门	1100
3	王五	美食部门	1200
4	赵六	服饰部门	1300
5	钱七	美食部门	1400
6	李八	服饰部门	1500
7	赵九	美食部门	1600
8	黎十	服饰部门	1700 */



# 查询每个用户购买品类排名
select user_name,count(goods_kind) from user_goods_table
group by user_name 
order by count(goods_kind) desc;
/* user_name	count(goods_kind)
王五	3
张三	2
李四	2
赵六	1 */



# 异常情况进行开窗品类内部求总数只得到一条数据问题
select user_name,goods_kind,count(goods_kind) as countkind,
RANK() over( PARTITION  by goods_kind  ORDER BY count(goods_kind)) as grouplist
from user_goods_table;
/* user_name	goods_kind	countkind	grouplist
张三	美食	8	1 */



# 只做分区不做排序后的开窗查询：
select user_name,goods_kind,
row_number() over( PARTITION  by goods_kind  ) as grouplist
from user_goods_table;
/*
user_name	goods_kind	grouplist
王五	旅游	1
李四	服饰	1
张三	服饰	2
赵六	服饰	3
王五	美容	1
张三	美食	1
李四	美食	2
王五	美食	3 */



# 部门开窗金额倒序算每个部门人数：
select  name,dept,salary,
row_number() over(PARTITION BY dept order by salary desc) as salary_rank
from t_user;
/* name	dept	salary	salary_rank
黎十	服饰部门	1700	1
李八	服饰部门	1500	2
赵六	服饰部门	1300	3
李四	服饰部门	1100	4
赵九	美食部门	1600	1
钱七	美食部门	1400	2
王五	美食部门	1200	3
张三	美食部门	1000	4 */



# 部门分组金额倒序的人中排名前2的数据查询：
select  tableb.name,tableb.dept,tableb.salary,salary_rank from 
(select  name,dept,salary,
row_number() over(PARTITION BY dept order by salary desc) as salary_rank
from t_user) as tableb where tableb.salary_rank=2;
/* name	dept	salary	salary_rank
李八	服饰部门	1500	2
钱七	美食部门	1400	2 */



# 
select  tableb.name,tableb.dept,tableb.salary,salary_rank from 
(select  name,dept,salary,
rank() over(PARTITION BY dept order by salary desc) as salary_rank
from t_user) as tableb;
/* 李八	服饰部门	2500	1
黎十	服饰部门	1700	2
李八	服饰部门	1500	3
赵六	服饰部门	1300	4
李四	服饰部门	1100	5
钱十一	美食部门	2200	1
赵九	美食部门	1600	2
钱七	美食部门	1400	3
王五	美食部门	1200	4
张三	美食部门	1000	5 */



insert into t_user values(9,'钱十一','美食部门',2200),(10,'李八','服饰部门',2500);
insert into t_user values(11,'张污污','美食部门',1400),(6,'李粑粑','服饰部门',1500);



# rownumber函数不会对相同salary结果进行排名一致处理
select  tableb.name,tableb.dept,tableb.salary,salary_rank from 
(select  name,dept,salary,
row_number() over(PARTITION BY dept order by salary desc) as salary_rank
from t_user) as tableb;
/* name	dept	salary	salary_rank
李八	服饰部门	2500	1
黎十	服饰部门	1700	2
李八	服饰部门	1500	3
李粑粑	服饰部门	1500	4
赵六	服饰部门	1300	5
李四	服饰部门	1100	6
钱十一	美食部门	2200	1
赵九	美食部门	1600	2
钱七	美食部门	1400	3
张污污	美食部门	1400	4
王五	美食部门	1200	5
张三	美食部门	1000	6 */



# rank函数将相同的排序结果保存排序序列号一致
select  tableb.name,tableb.dept,tableb.salary,salary_rank from 
(select  name,dept,salary,
rank() over(PARTITION BY dept order by salary desc) as salary_rank
from t_user) as tableb;
/* name	dept	salary	salary_rank
李八	服饰部门	2500	1
黎十	服饰部门	1700	2
李八	服饰部门	1500	3
李粑粑	服饰部门	1500	3
赵六	服饰部门	1300	5
李四	服饰部门	1100	6
钱十一	美食部门	2200	1
赵九	美食部门	1600	2
钱七	美食部门	1400	3
张污污	美食部门	1400	3
王五	美食部门	1200	5
张三	美食部门	1000	6 */



# 查询每个部门工资排名前2位的员工
select  tableb.name,tableb.dept,tableb.salary,salary_rank from 
(select  name,dept,salary,
rank() over(PARTITION BY dept order by salary desc) as salary_rank
from t_user) as tableb 
where salary_rank<=2;
/* name	dept	salary	salary_rank
李八	服饰部门	2500	1
黎十	服饰部门	1700	2
钱十一	美食部门	2200	1
赵九	美食部门	1600	2 */



# order by排序进行求和后并没有实现分组内的sum 而是所有 问题
select  tableb.name,tableb.dept,tableb.salary,salary_rank from 
(select  name,dept,salary,
rank() over(PARTITION BY dept order by sum(salary) desc) as salary_rank
from t_user) as tableb 
where salary_rank<=2;
/* name	dept	salary	salary_rank
张三	美食部门	1000	1 */



# 每个部门的金额进行从小到大累加排序 相同金额却没有增加问题
select  tableb.name,tableb.dept,tableb.salary,salary_sum from 
(select  name,dept,salary,
sum(salary)  over(PARTITION BY dept order by salary desc) as salary_sum
from t_user) as tableb;
/* name	dept	salary	salary_sum
李八	服饰部门	2500	2500
黎十	服饰部门	1700	4200
李八	服饰部门	1500	7200
李粑粑	服饰部门	1500	7200
赵六	服饰部门	1300	8500
李四	服饰部门	1100	9600
钱十一	美食部门	2200	2200
赵九	美食部门	1600	3800
钱七	美食部门	1400	6600
张污污	美食部门	1400	6600
王五	美食部门	1200	7800
张三	美食部门	1000	8800 */



# 先排除重复后再求和则正确结果：
select  DISTINCT tableb.salary_sum,dept from 
(select  name,dept,salary,
sum(salary)  over(PARTITION BY dept ) as salary_sum
from t_user) as tableb 
/* salary_sum	dept
9600	服饰部门
8800	美食部门 */
# 先查部门后查去重复则异常结果：
select  dept,DISTINCT tableb.salary_sum from 
(select  name,dept,salary,
sum(salary)  over(PARTITION BY dept ) as salary_sum
from t_user) as tableb;
/* [Err] 1064 - You have an error in your SQL syntax; */

