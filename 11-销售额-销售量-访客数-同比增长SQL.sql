# create database sql;
use sql;
select 1+1;
# 2
select 1|0;
# 1
select 1*1;
# 1
select 1 and 1;
# 1
select 1 or 1;
# 1



create table table1(
dt date,
商品编码 varchar(10),
商品名称 text,
销量 int,
销额 int,
primary key(dt,商品编码));
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/table1.csv"
into table table1 fields terminated by ',' ignore 1 lines;



select * from table1;
# dt	商品编码	商品名称	销量	销额
# 2018-06-01	1060555	【东家智选】富士（FUJIFILM）年货节  Princiao Smart 小俏印  定制礼盒	1	5299
# 2018-06-01	1262947	爱普生（EPSON) L3156墨仓式智能无线照片打印机办公家用彩色喷墨一体机连供打印复印扫描	1	5299
select count(*) from table1;-- 3360
select count(distinct dt) from table1;-- 36
select count(distinct 商品编码) from table1;-- 100



create table table2(
商品编码 varchar(10) primary key,
品类 varchar(10),
品牌 varchar(10));
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/table2.csv"
into table table2 fields terminated by ',' ignore 1 lines;
select * from table2;
# 商品编码	品类	  品牌
# 1060555	打印机	富士
# 1262947	打印机	爱普生
select count(*) from table2;-- 100
select count(distinct 商品编码) from table2;-- 100
select count(distinct 品类) from table2;-- 7
select count(distinct 品牌) from table2;-- 50



create table table3(
dt date,
商品编码 varchar(10),
用户浏览ID varchar(20));
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/table3.csv"
into table table3
fields terminated by ','
ignore 1 lines;
select * from table3;
# dt	商品编码	`用户浏览ID`
# 2018-06-01	206068	100000007421 
# 2018-06-02	501964	100000014716 
select count(*) from table3;-- 5309
select count(distinct dt) from table3;-- 36
select count(distinct 商品编码) from table3;-- 100
select count(distinct 用户浏览ID) from table3;-- 201



# 查询商品名称包含关键词的商品信息
select * from table1
left join table2 on table1.商品编码 = table2.商品编码
where 商品名称 like '%荣耀%';
# dt	商品编码	商品名称	销量	销额	商品编码	品类	品牌
# 2018-06-01	3064789	荣耀MagicBook	5299	3064789	笔记本	华为
# 2018-06-01	3137713	荣耀MagicBook	5799	3137713	笔记本	华为



# T1表 销售量 销售额
# 19年销售额：sum((year(dt)=2019)*销售额，2019年的布尔值为1的乘以对应时间的销售额进行求和
# 所有单价为0的不计入销量汇总：if(品类<>'笔记本' and 销额/销量<>0,1,0)
# 笔记本单价500以下的不计入销量汇总：if(品类='笔记本' and 销额/销量>500,10)
# 19年与18年销量均为1-15号汇总销量：(day(dt)between 1 and 15)
# 19年销量=19年每天布尔值，乘以，笔记本大于500，乘以，非笔记本商品销量大于0,乘以，1-15号的数据，乘以销量
# 所有产品名称中含有补差价的产品不计入汇总：where 商品名称 not like '%补差价%'
select 品类,品牌,商品名称,
sum((year(dt)=2019)*if(品类='笔记本' and 销额/销量>500,1,if(品类<>'笔记本' and 销额/销量<>0,1,0))*(day(dt)between 1 and 15)*销量) as 销量19年,
sum((year(dt)=2019)*销额) as 销额19年,
sum((year(dt)=2018)*if(品类='笔记本' and 销额/销量>500,1,if(品类<>'笔记本' and 销额/销量<>0,1,0))*(day(dt)between 1 and 15)*销量) as 销量18年,
sum((year(dt)=2018)*销额) as 销额18年
from table1
left join table2
on table1.商品编码 = table2.商品编码
where 商品名称 not like '%补差价%'
group by 品类,品牌;
# 品类	品牌	商品名称	销量19年	销额19年	销量18年	销额18年
# 打印机	联想 联想 CS2010DW 彩色激光打印机	251	990102	39	186199
# 笔记本	小米 小米 笔记本电脑 深空灰	313	1586764	108	445978
# 笔记本	华为 荣耀MagicBook冰河银	252	1394404	95	384908



select * from table1;
# dt	商品编码	商品名称	销量	销额
# 2018-06-01	1060555	富士小俏印定制礼盒	1	5299
select * from table2;
# 商品编码    品类         品牌
# 1262947	打印机	爱普生
select * from table3;
# dt         商品编码   用户浏览ID
# 2018-06-01	206068	100000007421


# 2019年所有商品的流量数据，包括有销售的和无销售的
select 品类,品牌,count(distinct table3.`用户浏览ID` ) as 19年访问量
from table2
left join table1 on table2.商品编码 = table1.商品编码
left join table3 on table2.商品编码 = table3.商品编码
where 商品名称 not like '%补差价%' and year(table3.dt)=2019
group by 品类,品牌;



# 2019年所有有销售的商品的浏览数据
select 品类,品牌,count(distinct table3.`用户浏览ID` ) as 19年访问量
from table1
left join table2 on table1.商品编码 = table2.商品编码
left join table3 on table1.商品编码 = table3.商品编码
where 商品名称 not like '%补差价%' and year(table1.dt)=2019
group by 品类,品牌;
# 品类	品牌	`19年访问量`
# 一体机	 HQisQnse 19
# 一体机	 华硕	 19
# 一体机	 华硕         36
# 2018年所有有销售的商品的浏览数据
select 品类,品牌,count(distinct table3.`用户浏览ID` ) as 18年访问量
from table1
left join table2 on table1.商品编码 = table2.商品编码
left join table3 on table1.商品编码 = table3.商品编码
where 商品名称 not like '%补差价%' and year(table1.dt)=2018
group by 品类,品牌;
# 品类	品牌	`18年访问量`
# 一体机	华硕	  19
#一体机	华硕 36
# 一体机	富沐 19
	


# T2表 19年访客 18年访客
# 访客量定义为单日访问该品牌的去重用户数
# 如某用户id单日浏览了小米的三款产品，小米品牌访客量记1
select 品类,品牌,count(distinct 用户浏览ID) 19年访客量
from table1
left join table2 on table1.商品编码=table2.商品编码
left join table3 on table2.商品编码=table3.商品编码
where 商品名称 not like '%补差价%' and year(table3.dt)=2019
group by 品类,品牌;
# 品类	品牌	`19年访问量`
# 一体机	  HQisQnse	10
# 一体机 	华硕	 11
# 一体机	   华硕 18
select 品类,品牌,count(distinct 用户浏览ID) 18年访客量
from table1 
left join table2 on table1.商品编码=table2.商品编码
left join table3 on table2.商品编码=table3.商品编码
where 商品名称 not like '%补差价%' and year(table3.dt)=2018
group by 品类,品牌;
# 品类	品牌	`18年访客量`
# 一体机	    HQisQnse   10
# 一体机  	华硕  	9
# 一体机	华硕     20        
        


# 查询销量-销售额-浏览量-同比增长数据
# 1、所有单价为0的不计入销量汇总
# 2、笔记本单价500以下的不计入销量汇总
# 3、所有产品名称中带荣耀的华为产品，将产品品牌更改为华为
# 4、访客量定义为单日访问该品牌的去重用户数（如某用户id单日浏览了小米的三款产品，小米品牌访客量记1）
# 5、19年与18年销量均为1-15号汇总销量
# 6、同比数据可以以小数形式呈现，保留两位
# 7、所有产品名称中含有补差价的产品不计入汇总
# 8、表格呈现按照19年访客量分品类降序呈现
select t1.品类,t1.品牌,19年销量,19年销额,19年访客量,18年销量,18年销额,18年访客量,
(19年销量-18年销量)/18年销量 as 19年销量同比,
(19年销额-18年销额)/18年销额 as 19年销额同比,
(19年访客量-18年访客量)/18年访客量 as 19年访客量同比
from 
(select 品类,品牌,
sum((year(dt)=2019)*if(品类='笔记本' and 销额/销量>500,1,if(品类<>'笔记本' and 销额/销量<>0,1,0))*(day(dt) between 1 and 15)*销量) as 19年销量,
sum((year(dt)=2019)*销额) as 19年销额,
sum((year(dt)=2018)*if(品类='笔记本' and 销额/销量>500,1,if(品类<>'笔记本' and 销额/销量<>0,1,0))*(day(dt) between 1 and 15)*销量) as 18年销量,
sum((year(dt)=2018)*销额) as 18年销额
from table1 left join table2 on table1.商品编码=table2.商品编码 where 商品名称 not like '%补差价%' group by 品类,品牌) t1
join 
(select 品类,品牌,count(distinct table3.dt,用户浏览ID) as 19年访客量
from table1 left join table2 on table1.商品编码=table2.商品编码 left join table3 on table2.商品编码=table3.商品编码
where 商品名称 not like '%补差价%' and year(table3.dt)=2019 group by 品类,品牌) t2 
on t1.品类=t2.品类 and t1.品牌=t2.品牌 
join
(select 品类,品牌,count(distinct table3.dt,用户浏览ID) as 18年访客量
from table1 
left join table2 on table1.商品编码=table2.商品编码
left join table3 on table2.商品编码=table3.商品编码
where 商品名称 not like '%补差价%' and year(table3.dt)=2018
group by 品类,品牌) t3 on t2.品类=t3.品类 and t2.品牌=t3.品牌;
# 品类	品牌	`19年销量`	`19年销额`	`19年访客量`	`18年销量`	`18年销额`	`18年访客量`	`19年销量同比`	`19年销额同比`	`19年访客量同比`
# 一体机	HQisQnse 56	312771	10	40	167191	10	0.4000	0.8707	0.0000
# 一体机	华硕	 27	285372	11	64	212576	9	-0.5781	0.3424	0.2222
# 一体机	华硕 133	797631	20	70	341647	20	0.9000	1.3347	0.0000
# 一体机	富沐 63	333019	10	65	316505	10	-0.0308	0.0522	0.0000
