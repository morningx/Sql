# 20200221


# 1 汇总函数
# 查询确诊人数按城市排名
select 
cityname,
sum(people) 
from citytable 
group by city 
order by cityname desc;

select 城市,sum(确诊人数) from city group by 城市 order by sum(确诊人数) desc;


# 2 子查询
# 什么是子查询？子查询就是嵌套在主查询中的查询
# 主表中的字段和子表的字有相同字段，才能进行关联子查询
# 在SELECT中嵌套
# 相关子查询
# 外部查询返回  一行 ，子查询就执行一次
SELECT s.student_id,s.student_name,(SELECT class_name FROM t_class c WHERE c.class_id=s.class_id) FROM t_student s GROUP BY s.student_id;  


# 3 非相关子查询-查出所有值做判断
# 在WHERE中嵌套
# ALL运算符和子查询的结果逐一比较，必须全部满足时表达式的值才为真
# 子查询总共执行一次，执行完毕后后将值传递给外部查询
SELECT * FROM t_student 
WHERE student_subject='C语言' 
AND student_score>=ALL(SELECT student_score FROM t_student WHERE student_subject='C语言') ;

SELECT * FROM t_student 
WHERE student_subject='C语言' 
AND student_score >(SELECT student_score FROM t_student WHERE student_name='李四' AND student_subject='C语言'); 

SELECT * FROM t_student s1 
WHERE s1.student_score >= ALL(SELECT s2.student_score FROM t_student s2 WHERE s1.`student_subject`=s2.student_subjec

select * from table_a where a = all(select a from table_b)

select a from table_b

select * from table_a where a = 1


# 4.1 条件判断-case when else end

select 
users.name,
(case users.sex when 1 then '男' when 2 then '女' else 0 end ) as sex
from users;

select u_id , u_name , u_score ,
case when u_score >= 65.45 then '优秀'
when u_score >=60 and u_score<85 then '及格'
when u_score <60 then '不及格'
else '数据错误'
end 
from T_USER ;


# 4.2 条件判断+求和 sum(case when)
# 求男的多少个，女的多少个，空值多少个人
select 
sum(case users.sex when '男' then 1 else 0 end),
sum(case users.sex when '女' then 1 else 0 end),
sum(case users.sex when '空的' then 1 else 0 end)
from users;


# 5 汇总函数-count-sum-avg-max-min

# AVG()：返回某列的平均值
SELECT AVG(price) AS 平均价格 FROM products WHERE id = 1003;

# COUNT()：返回某列的行数
SELECT COUNT(id) AS 行数 FROM products;
SELECT COUNT(*) AS 行数 FROM products;

# MAX()：返回某列的最大值
SELECT MAX(price) AS 最大值 FROM products;

# MIN()：返回某列的最小值
SELECT MIN(price) AS 最小值 FROM products;

# SUM()：返回某列值之和
SELECT SUM(price) FROM products WHERE id = 1002;
SELECT SUM(price * price_num) FROM products WHERE id = 1002;




# 20200215


# 1 数据定义语言DDL


# 删除已存在的数据库（新型冠状病毒）
drop database xg;

# 建立数据库
create database xg;

show databases;
# 选择进入数据库

use xg;

set sql_safe_updates=0;
# 设置安全模式为0便于更新表字段及数据信息

# 创建表city城市表
create table city(id int,
城市 varchar(20) primary key,
确诊人数 int,
治愈人数 int,
死亡人数 int,
城市ID int,
各省及直辖市ID int,
更新时间 datetime);

# 创建表province省份表
create table province(
id int,
各省及直辖市 varchar(20) primary key,
确诊人数 int,
治愈人数 int,
死亡人数 int,
各省及直辖市ID int,
更新时间 datetime);

# 创建表popular人口表
create table popular(
id int,
各省及直辖市 varchar(20) primary key,
人口数量 float,
gdp float);

# 创建表hospital医院表
create table hospital(
id int,
各省及直辖市 varchar(20) primary key,
三甲医院数量 int);

# 显示所有表
show tables;

# 显示表结构
desc city;

# 删除id字段
alter table city drop id;
alter table province drop id;
alter table popular drop id;
alter table hospital drop id;


# 2 数据操作语言DML


# 导入表city数据
load data local infile "C://Users//beimo//Desktop//xg//city.txt"
into table city
fields terminated by ',' ignore 1 lines;

# 导入province数据
load data local infile "C:/Users/beimo/Desktop/xg/province.txt"
into table province
fields terminated by ',' ignore 1 lines;

# 导入population数据
load data local infile "C:/Users/beimo/Desktop/xg/population.txt"
into table popular 
fields terminated by ',' ignore 1 lines;

# 导入hospital数据
load data local infile "C:/Users/beimo/Desktop/xg/hospital.txt"
into table hospital 
fields terminated by ',' ignore 1 lines;

# 删除popiular表
delete from popiular;
truncate popular;
drop table popular;
drop table hospital;


# 3 数据查询语言DQL


# 单表查询
select * from city limit 10;
select * from province;
select * from popular;
select * from hospital;
select * from city;

# 查看总行数
select count(*) from city;
select count(*) from province;

# 查询不重复的数据
# 通过查询得到新的table时，必须有一个别名，即每个派生出来的表都必须有一个自己的别名
select distinct 各省及直辖市ID from city;
select count(*) from (select distinct 各省及直辖市ID from city) as t;

# 查询确诊人数前10的城市
select 城市,确诊人数 from city order by 确诊人数 desc limit 10; 

# 查询死亡人数前10的城市
select 城市,死亡人数 from city order by 死亡人数 desc limit 10; 

# 查询治愈人数前10的城市 
select 城市,治愈人数 from city order by 治愈人数 desc limit 10; 

# 查询确诊人数小于5的城市
select 城市,确诊人数 from city where 确诊人数<=5 order by 确诊人数;

# 查询确诊人数前5的省及直辖市
select 各省及直辖市,确诊人数 from province order by 确诊人数 desc limit 10;

# 查询人口数量前10的省及直辖市
select 各省及直辖市,人口数量 from popular order by 人口数量 desc limit 10;

# 查询三甲医院前10的省份
select 各省及直辖市,三甲医院数量 from hospital order by 三甲医院数量 desc limit 10;

# 查询确诊人数大于200且死亡人数为0的省份
select 城市,确诊人数,死亡人数 from city where 确诊人数>200 and 死亡人数=0;

# 查询确诊人数按城市排名
select 城市,sum(确诊人数) from city group by 城市 order by sum(确诊人数) desc;

# 多表查询,多表左连接
select province.各省及直辖市,sum(确诊人数) 总确诊人数,sum(死亡人数) 总死亡人数,sum(治愈人数) 总治愈人数,hospital.三甲医院数量,popular.人口数量 from
province left join popular on province.各省及直辖市=popular.各省及直辖市
left join hospital on province.各省及直辖市=hospital.各省及直辖市
group by 各省及直辖市 order by 总确诊人数 desc;
