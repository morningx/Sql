# 20200215

drop database xg;

-- 数据定义语言DDL
#建立数据库
create database xg;

show databases;
#选择进入数据库
use xg;
set sql_safe_updates=0;

#创建表1
create table city1(id int,
城市 varchar(20) primary key,
确诊人数 int,
治愈人数 int,
死亡人数 int,
城市ID int,
各省及直辖市ID int,
更新时间 datetime);

#创建表2
create table province1(
id int,
各省及直辖市 varchar(20) primary key,
确诊人数 int,
治愈人数 int,
死亡人数 int,
各省及直辖市ID int,
更新时间 datetime);

#创建表3
create table popular(
id int,
各省及直辖市 varchar(20) primary key,
人口数量 float,
gdp float);

#创建表4
create table hospital(
id int,
各省及直辖市 varchar(20) primary key,
三甲医院数量 int);

#显示所有表
show tables;

#显示表结构
desc city1;
#删除id字段
alter table city1 drop id;
alter table province1 drop id;
alter table popular drop id;
alter table hospital drop id;

-- 数据操作语言DML
#导入表1数据
load data local infile "C://Users//beimo//Desktop//xg//city1.txt"
into table city1
fields terminated by ',' ignore 1 lines;
#导入表2数据
load data local infile "C:/Users/beimo/Desktop/xg/province1.txt"
into table province1 
fields terminated by ',' ignore 1 lines;
#导入表3数据
load data local infile "C:/Users/beimo/Desktop/xg/population.txt"
into table popular 
fields terminated by ',' ignore 1 lines;
#导入表4数据
load data local infile "C:/Users/beimo/Desktop/xg/hospital.txt"
into table hospital 
fields terminated by ',' ignore 1 lines;
#删除表popiular
delete from popiular;
truncate popular;
drop table popular;
drop table hospital;



-- 数据查询语言DQL
#单表查询
#全表查询
select * from city1 limit 10;
select * from province1;
select * from popular;
select * from hospital;

#查看总行数
select count(*) from city1;
select count(*) from province1;

#查询不重复的数据
select distinct 各省及直辖市ID from city1;
select count(*) from (select distinct 各省及直辖市ID from city1)t;

#查询确诊人数前10的城市
select 城市,确诊人数 from city1 order by 确诊人数 desc limit 10; 

#查询死亡人数前10的城市
select 城市,死亡人数 from city1 order by 死亡人数 desc limit 10; 

#查询治愈人数前10的城市 
select 城市,治愈人数 from city1 order by 治愈人数 desc limit 10; 

#查询确诊人数小于5的城市
select 城市,确诊人数 from city1 where 确诊人数<=5 order by 确诊人数;

#查询确诊人数前5的省及直辖市
select 各省及直辖市,确诊人数 from province1 order by 确诊人数 desc limit 10;

#查询人口数量前10的省及直辖市
select 各省及直辖市,人口数量 from popular order by 人口数量 desc limit 10;

#查询三甲医院前10的省份
select 各省及直辖市,三甲医院数量 from hospital order by 三甲医院数量 desc limit 10;

#查询确诊人数大于200且死亡人数为0的省份
select 城市,确诊人数,死亡人数 from city1 where 确诊人数>200 and 死亡人数=0;

#查询确诊人数按城市排名
select 城市,sum(确诊人数) from city1 group by 城市 order by sum(确诊人数) desc;

#多表查询
#多表左连接
select * from province1;
select * from city1;
select * from hospital;
select * from popular;

select province1.各省及直辖市,sum(确诊人数) 总确诊人数,sum(死亡人数) 总死亡人数,sum(治愈人数) 总治愈人数,hospital.三甲医院数量,popular.人口数量 from
province1 left join popular on province1.各省及直辖市=popular.各省及直辖市
left join hospital on province1.各省及直辖市=hospital.各省及直辖市
group by 各省及直辖市 order by 总确诊人数 desc;
