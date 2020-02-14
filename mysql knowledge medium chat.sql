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
into table city1
fields terminated by ',' ignore 1 lines;

# 导入province数据
load data local infile "C:/Users/beimo/Desktop/xg/province.txt"
into table province1 
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
select province1.各省及直辖市,sum(确诊人数) 总确诊人数,sum(死亡人数) 总死亡人数,sum(治愈人数) 总治愈人数,hospital.三甲医院数量,popular.人口数量 from
province left join popular on province.各省及直辖市=popular.各省及直辖市
left join hospital on province.各省及直辖市=hospital.各省及直辖市
group by 各省及直辖市 order by 总确诊人数 desc;
