# 说明
# 1 阿里天池开源数据，淘宝广告点击数据集
# 2 石墨运行结果截图地址，需授权访问 https://shimo.im/docs/Drx8cThg3KQqrxcj/ 
# 3 时间，20200215


# 1 建库建表


create database taobaoad;
use taobaoad;

# 原始样本raw_sample
# user_id：脱敏过的用户ID
# adgroup_id：脱敏过的广告单元ID
# time_stamp：时间戳
# pid：资源位
# noclk：为1代表没有点击；为0代表点击
# clk：为0代表没有点击；为1代表点击
# 我们用前面7天的做训练样本（20170506-20170512），用第8天的做测试样本（20170513）
create table raw_sample(
user_id int,
adgroup_id int,
time_stamp bigint,
pid varchar(100),
noclk varchar(10),
clk varchar(10)
);
desc raw_sample;

# 广告基本信息表ad_feature
# adgroup_id：脱敏过的广告ID
# cate_id：脱敏过的商品类目ID
# campaign_id：脱敏过的广告计划ID
# customer_id:脱敏过的广告主ID
# brand：脱敏过的品牌ID
# price: 宝贝的价格
# 其中一个广告ID对应一个商品（宝贝），一个宝贝属于一个类目，一个宝贝属于一个品牌
create table ad_feature(
adgroup_id int,
cate_id int,
campaign_id int,
customer_id int,
brand int,
price float
);
desc ad_feature;

# userid：脱敏过的用户ID
# cms_segid：微群ID
# cms_group_id：cms_group_id
# final_gender_code：性别 1:男,2:女
# age_level：年龄层次
# pvalue_level：消费档次，1:低档，2:中档，3:高档
# shopping_level：购物深度，1:浅层用户,2:中度用户,3:深度用户
# occupation：是否大学生 ，1:是,0:否
# new_user_class_level：城市层级
create table user_profile(
userid int,
cms_segid int,
cms_group_id int,
final_gender_code varchar(10),
age_level varchar(100),
pvalue_level varchar(10),
shopping_level varchar(10),
occupation varchar(10),
new_user_class_level varchar(100)
);
desc user_profile;

# 用户的行为日志behavior_log
# 本数据集涵盖了raw_sample中全部用户22天内的购物行为(共七亿条记录)。字段说明如下
# user：脱敏过的用户ID；
# time_stamp：时间戳timestamp；
# cate：脱敏过的商品类目；
# brand: 脱敏过的品牌词；
# btag：行为类型,  包括以下四种：
# 类型     说明
# ipv     浏览
# cart     加入购物车
# fav     喜欢
# buy     购买
create table behavior_log(
user int,
time_stamp timestamp,
btag varchar(30),
cate varchar(100),
brand varchar(100)
);
desc behavior_log;


# 2 导入数据集CSV到数据库


# https://blog.csdn.net/qq_40134403/article/details/90352038
# Linux：file:///media/apple/A29E38759E384457/Study/data/20200116-alitianchi-taobaoad
# Windows；"E:\Study\data\20200116-alitianchi-taobaoad\ad_feature.csv"
# csv文件通过,逗号来分割，字符选择为gb2312
# optionally 可选择地；随意地；任选地
# enclosed 围住的，封闭的; 随函附上的; 附上的; 与外界隔绝的
# OPTIONALLY ENCLOSED BY '"' 的意思就是隔绝任意的双引号
# escaped 逃脱，摆脱，逃避 "escaped by"字符会被去除
# IGNORE 1 LINES 第一行为字段行 不作为数据行
load data infile "E:/Study/data/2020-all/ad_feature.csv"
fields terminated by ','
character set gb2312
optionally enclosed by '"'
escaped by '"'
lines terminated by '\r\n'
IGNORE 1 LINES
into table ad_feature;


# 3 数据集描述

select * from ad_feature limit 20;
SELECT * FROM ad_feature LIMIT 10; 
SELECT * FROM raw_sample LIMIT 20; DESC raw_sample; 
SELECT * FROM user_profile LIMIT 20; 
SELECT * FROM raw_sample LIMIT 2; 
SELECT * FROM ad_feature LIMIT 10;
SELECT COUNT(*) AS '广告信息总条数' FROM ad_feature; 
# 广告信息总条数 846811 
SELECT COUNT(*) AS '用户信息总条数' FROM user_profile; 
# 用户信息总条数 1061768 
SELECT COUNT(*) AS '点击广告的点击次数' FROM raw_sample WHERE clk=1;
# 广告点击次数 1366056


# 4 复制大表部分数据到小表


# 建立id_710164的表，将此ID的数据存储到单个小表
CREATE TABLE adgroup_id_710164 
( userid INT NOT NULL, 
adgroup_id INT NOT NULL, 
time_stamp  BIGINT(20), 
pid VARCHAR(100), 
noclk VARCHAR(10), 
clk VARCHAR(10) ); 

DESC adgroup_id_710164;

# 查询的结果第一步先执行，需要一定时间，再次进行插入后才提升插入不够抛出异常
# 将查询的结果保存到新表中，查询的内容为710164广告ID的数据多行
# The total number of locks exceeds the lock table size 异常抛出
# 不要忘记带;号，没有;号表示一条语句没有结束，显示的格式是 1M*1024*1024
# 修改 innodb_buffer_pool_size的值为3G：3*1024*1024*1024
show variables like "%_buffer%";
SET GLOBAL innodb_buffer_pool_size=67108864;

SELECT * FROM user_click_record WHERE adgroup_id LIKE '%710164' LIMIT 10; 

SELECT COUNT(*) FROM adgroup_id INSERT INTO adgroup_id_710164;

SELECT * FROM user_click_record WHERE adgroup_id LIKE '%710164%';


# 5 建立关联表且创建存储过程


# DELIMITER 定界符，分隔符 存储过程开始结束用$$随意符号
DELIMITER $$
SELECT
  `user_click_record`.`user_id`      AS `用户ID`,
  DATE_FORMAT(FROM_UNIXTIME(`user_click_record`.`time_stamp`),'%Y-%m-%d') AS `点击日期`,
  DATE_FORMAT(FROM_UNIXTIME(`user_click_record`.`time_stamp`),'%k:%i:%s') AS `点击时间`,
  `user_click_record`.`pid`          AS `资源位ID`,
  `user_click_record`.`noclk`        AS `没有点击广告`,
  `user_click_record`.`clk`          AS `有点击广告`,
  `user_info`.`new_user_class_level` AS `城市层级`,
  `user_info`.`age_level`            AS `年龄层次`,
  `user_info`.`final_gender_code`    AS `性别1男2女`,
  `user_info`.`pvalue_level`         AS `消费档次`,
  `user_info`.`occupation`           AS `是否大学生`,
  `user_info`.`shopping_level`       AS `购物深度`
FROM `user_info`
JOIN `user_click_record`
WHERE `user_info`.`userid` = `user_click_record`.`user_id`
$$ DELIMITER;


# 6 分组聚合计算点击率百分比


SELECT
view_people_analysis.`资源位ID`,
COUNT(*) AS '广告展示数',
SUM('有点击广告') AS '用户有点击数',
SUM('没有点击广告') AS '用户没点击数'
CONCAT(sum('有点击广告')/count(*),'%') as '用户点击率'
# CONCAT n. 合并多个数组；合并多个字符串
FROM view_people_analysis
WHERE view_people_analysis.`资源位ID` = '430539_1007' OR view_people_analysis.`资源位ID` = '430548_1007'
GROUP BY view_people_analysis.`资源位ID`
ORDER BY '广告展示数' DESC

# 未修改聚合的sum点击广告数据类型（varchar）则没发进行求和操作，显示结果为空
# 改动了varchar类型为int类型后，sum结果输出求和
# 由结果可知，539广告，样本展现数偏少，点击率却高，资源位得到有效推广价值更大
# concat()函数1.含义:将多个字符串连接成一个字符串
select `资源位ID`,sum(`没有点击广告`),
count(*) as '广告展现数',
sum(`有点击广告`),
sum(`没有点击广告`)/COUNT(`资源位ID`) as '没点击百分比',
CONCAT(ROUND(sum(`没有点击广告`)/COUNT(`资源位ID`)*100,2),'%') as '没有点击百分比',
CONCAT(ROUND(sum(`有点击广告`)/COUNT(`资源位ID`)*100,2),'%') as '有点击百分比'
from people_analysis_small
GROUP BY `资源位ID`;


# 7 每天每小时点击率百分比


# small部分数据集进行查询思路正确性
# SUBSTRING_INDEX，字符串分割，：分割，0为左边数据1为右边数据 取出小时数据
select SUBSTRING_INDEX(点击时间,':',1) as '每日小时数',
count(*) as '小时展现量',
sum(`有点击广告`) as '小时点击量',
CONCAT(ROUND(sum(`有点击广告`)/COUNT(`资源位ID`)*100,2),'%') as '小时点击百分比'
from people_analysis_small
group by CONVERT(SUBSTRING_INDEX(点击时间,':',1),SIGNED)
order by CONVERT(SUBSTRING_INDEX(点击时间,':',1),SIGNED) asc;

# 全量数据验证查询正确性
SELECT SUBSTRING_INDEX(点击时间,':',1) AS '每日小时数',
# substring_index方法获取点击时间字段中，按：拆分，第一个冒号前面的数据
# 这种方式可提取单个数字 8点钟1位数 或 12点钟两位数
COUNT(*) AS '小时展现量',
SUM(`有点击广告`) AS '小时点击量',
# 字段名称的引号，和，别名的引号不一样标识；
CONCAT(ROUND(SUM(`有点击广告`)/COUNT(`资源位ID`)*100,2),'%') AS '小时点击百分比'
FROM view_people_analysis
# CAST(value AS type) CONVERT 转换字符串类型为int类型
GROUP BY CONVERT(SUBSTRING_INDEX(点击时间,':',1),SIGNED)
ORDER BY CONVERT(SUBSTRING_INDEX(点击时间,':',1),SIGNED) ASC;
# 因为AS别名为双引号，经过测试发现groupby和orderby存在异常情况；
# 去掉AS后面的''，应该是可以引用成功


# 8 每星期每天点击率百分比


# 部分数据查询
# select date_format('2013-03-09','%Y-%m-%d')
# WEEKDAY(d) 返回 d 对应的工作日索引
# 0 表示周一,1 表示周二,,6 表示周日
select month(`点击日期`) as '月' from people_analysis_small limit 10;

select weekday(date_format(`点击日期`,'%Y-%m-%d'))+1 as '星期' from people_analysis_small limit 20;

# 因weekday方法是默认0为周一，6为周日，国内习惯1为周一，则+1做好适配
# 点击百分比为有点击广告的数据求和（有1无0），除以，每条数据的总和
# 结果的值乘以100后，round方法保留两个小数位
# concat方法可连接A数据和B%，则生成对应的百分比
# CAST(value AS type) CONVERT
select weekday(date_format(`点击日期`,'%Y-%m-%d'))+1 as '星期',
count(*) as '每日展现量',
sum(`有点击广告`) as '每日点击量',
ROUND(sum(`有点击广告`)/COUNT(`资源位ID`),4) as '每日点击占比',
CONCAT(ROUND(sum(`有点击广告`)/COUNT(`资源位ID`)*100,2),'%') as '每日点击百分比'
from people_analysis_small
group by weekday(date_format(`点击日期`,'%Y-%m-%d'))+1
order by weekday(date_format(`点击日期`,'%Y-%m-%d'))+1 asc;

# 全量数据查询
# MySQLweekday()函数WEEKDAY函数返回一个日期的工作日索引值
# 即星期一为0,星期二为1,星期日为6
SELECT WEEKDAY(DATE_FORMAT(`点击日期`,'%Y-%m-%d'))+1 AS '星期',
COUNT(*) AS '每日展现量',
SUM(`有点击广告`) AS '每日点击量',
ROUND(SUM(`有点击广告`)/COUNT(`资源位ID`),4) AS '每日点击占比',
CONCAT(ROUND(SUM(`有点击广告`)/COUNT(`资源位ID`)*100,2),'%') AS '每日点击百分比'
FROM view_people_analysis
# CAST(value AS type) CONVERT
GROUP BY WEEKDAY(DATE_FORMAT(`点击日期`,'%Y-%m-%d'))+1
ORDER BY WEEKDAY(DATE_FORMAT(`点击日期`,'%Y-%m-%d'))+1 ASC;


# 9 不同年龄层次点击率百分比


select `年龄层次`,count(*),sum(`有点击广告`),CONCAT(round((sum(`有点击广告`)/COUNT(*))*100,4),'%') as 点击率
from view_people_analysis_small
group by `年龄层次` ORDER BY `年龄层次` asc;

SELECT `年龄层次`,COUNT(*) AS 展现量,
SUM(`有点击广告`) AS 点击数,
CONCAT(ROUND((SUM(`有点击广告`)/COUNT(*))*100,4),'%') AS 点击率
FROM view_people_analysis 
GROUP BY `年龄层次` ORDER BY 点击率 DESC;


# 10 消费层次百分比


select `消费档次`,
count(*) as 广告展示量,
sum(`有点击广告`),
CONCAT(round((sum(`有点击广告`)/COUNT(*))*100,4),'%') as 点击率
from view_people_analysis_small
group by `消费档次`
ORDER BY `消费档次` asc;


# 11 购物深度百分比


select `购物深度`,
count(*) as 广告展示量,
sum(`有点击广告`),
CONCAT(round((sum(`有点击广告`)/COUNT(*))*100,4),'%') as 点击率
from view_people_analysis_small
group by `购物深度`
ORDER BY `购物深度` asc;

SELECT `购物深度`,
COUNT(*) AS 广告展示量,
SUM(`有点击广告`),
CONCAT(ROUND((SUM(`有点击广告`)/COUNT(*))*100,4),'%') AS 点击率
FROM view_people_analysis
GROUP BY `购物深度`
ORDER BY `购物深度` ASC;


# 12 不同性别消费百分比


select `性别1男2女`,
count(*) as 广告展示量,
sum(`有点击广告`),
CONCAT(round((sum(`有点击广告`)/COUNT(*))*100,4),'%') as 点击率
from view_people_analysis_small
group by `性别1男2女`
ORDER BY 点击率 asc;

select `性别1男2女`,
count(*) as 广告展示量,
sum(`有点击广告`),
CONCAT(round((sum(`有点击广告`)/COUNT(*))*100,4),'%') as 点击率
from view_people_analysisll
group by `性别1男2女`
ORDER BY 点击率 asc;
