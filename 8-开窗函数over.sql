# 1 分组的数据行内部函数操作：
# 怎么样得到各部门工资排名前N名员工列表?查找各部门每人工资占部门总工资的百分比？环比如何计算？
# 使用传统的SQL实现起来比较困难。这类需求都有一个共同的特点，需要在单表中满足某些条件的结果集内部做一些函数操作
# 不是简单的表连接，也不是简单的聚合可以实现的
# 通常费了大半天时间写出来一堆长长的晦涩难懂的SQL，且性能低下，难以维护
# 要解决此类问题最方便的就是使用开窗函数。
# 2 聚合的每行都有数据值：
# 为记录集合，开窗函数也就是在满足某种条件的记录集合上执行的特殊函数
# 对于每条记录都要在此窗口内执行函数，有的函数随着记录不同，窗口大小都是固定的，这种属于静态窗口
# 有的函数则相反，不同的记录对应着不同的窗口，这种动态变化的窗口叫滑动窗口
# 开窗函数的本质还是聚合运算，只不过它更具灵活性，它对数据的每一行，都使用与该行相关的行进行计算并返回计算结果
# 开窗函数和普通聚合函数的区别
# 聚合函数是将多条记录聚合为一条
# 而开窗函数是每条记录都会执行，有几条记录执行完还是几条
# 聚合函数也可以用于开窗函数中
# 3 开窗函数分类：
# percent百分比；百分数；百分率 row列；排；一列   rank等级；级别；军衔；排 dense浓厚的；密度大的；密实
# lead带领；导程；引领  lag延迟；走得慢；网络延迟
# 序号函数：row_number() / rank() / dense_rank()
# 分布函数：percent_rank() / cume_dist()
# 前后函数：lag() / lead()
# 头尾函数：first_value() / last_value()
# 4 窗口关键词 over：
# 窗口由over关键字用来指定函数执行的窗口范围
# partition by子句：按照指定字段进行分区，两个分区由边界分隔，开窗函数在不同的分区内分别执行，在跨越分区边界时重新初始化
# order by子句：按照指定字段进行排序，开窗函数将按照排序后的记录顺序进行编号
# frame框架；车架；边框



create database sql;
use sql;



create table order_tab(order_id int,user_no varchar(3),amount int,create_date date); 
insert into order_tab values 
(1,'001',100,'2019-01-01'),
(2,'001',300,'2019-01-02'),
(3,'001',500,'2019-01-02'),
(4,'001',800,'2019-01-03'),
(5,'001',900,'2019-01-04'),
(6,'002',500,'2019-01-03'),
(7,'002',600,'2019-01-04'),
(8,'002',300,'2019-01-10'),
(9,'002',800,'2019-01-16'),
(10,'002',800,'2019-01-22');
select * from order_tab;
desc order_tab;
# order_id user_no amount create_date



select *,sum(amount) as sum_amount from order_tab;
# order_id	user_no	amount	create_date	sum_amount
# 1	001	100	2019-01-01	5600



# over无参数，所有行都进行sum计算一样的结果
select *,sum(amount) over() as sum_amount from order_tab;
# order_id	user_no	amount	create_date	sum_amount
# 1	001	100	2019-01-01	5600
# 2	001	300	2019-01-02	5600
# 3	001	500	2019-01-02	5600
# 4	001	800	2019-01-03	5600
# 5	001	900	2019-01-04	5600



# 通过noID号进行分区，每个区的值一样
select *,sum(amount) over(partition by user_no) sum_amount from order_tab;
# order_id	user_no	amount	create_date	sum_amount
# 1	001	100	2019-01-01	2,600
# 2	001	300	2019-01-02	2,600
# 3	001	500	2019-01-02	2,600



# 查询每个用户按时间顺序的累计订单金额
select *,sum(amount) over(partition by user_no order by create_date) sum_amount from order_tab;
# order_id	user_no	amount	create_date	sum_amount
# 1	001	100	2019-01-01	100
# 2	001	300	2019-01-02	900
# 3	001	500	2019-01-02	900
# 4	001	800	2019-01-03	1,700
# 5	001	900	2019-01-04	2,600



# 查询每个订单动态计算包括本订单和按时间顺序前后两个订单金额,三个订单求和
# 使用 between frame_start and frame_end 语法来表示行范围
# preceding在先的；前面的；先前的  following以下的；跟踪；跟随
select *,
sum(amount) over(partition by user_no order by create_date desc rows between 1 preceding and 1 following) as sum_amount
from order_tab;
# order_id	user_no	amount	create_date	sum_amount
# 5	001	900	2019-01-04	1700
# 4	001	800	2019-01-03	2000
# 2	001	300	2019-01-02	1600



select * from order_tab;
# order_id	user_no	amount	create_date
# 1	001	100	2019-01-01
# 2	001	300	2019-01-02
# 3	001	500	2019-01-02
# 4	001	800	2019-01-03
# 5	001	900	2019-01-04
# 6	002	500	2019-01-03
# 7	002	600	2019-01-04
# 8	002	300	2019-01-10
# 9	002	800	2019-01-16
# 10 002	800	2019-01-22



# 查询不同用户的订单金额-分组聚合
select user_no,sum(amount) as sum_amount
from order_tab
group by user_no;
# user_no	sum_amount
# 001	2600
# 002	3000
# 查询不同用户的订单金额-分组聚合开窗
select user_no,
sum(amount) over() as sum_amount
from order_tab
group by user_no;
# user_no sum_amount
# 001	600
# 002	600
select *,
sum(amount) over(partition by user_no) as sum_amount
from order_tab;
# order_id	user_no	amount	create_date	sum_amount
# 1	001	100	2019-01-01	2,600
# 2	001	300	2019-01-02	2,600
# 3	001	500	2019-01-02	2,600
# 4	001	800	2019-01-03	2,600
# 5	001	900	2019-01-04	2,600
# 6	002	500	2019-01-03	3,000
# 7	002	600	2019-01-04	3,000
# 8	002	300	2019-01-10	3,000
# 9	002	800	2019-01-16	3,000
# 10	002	800	2019-01-22	3,000



# partition by user_no 每个userno的分区内进行聚合计算
# order by create_date 分区内进行排序通过create_date字段
select *,
sum(amount) over(partition by user_no order by create_date) as sum_amount
from order_tab;
/* order_id	user_no	amount	create_date	sum_amount
1	001	100	2019-01-01	100
2	001	300	2019-01-02	900
3	001	500	2019-01-02	900
4	001	800	2019-01-03	1,700
5	001	900	2019-01-04	2,600
6	002	500	2019-01-03	500
7	002	600	2019-01-04	1,100
8	002	300	2019-01-10	1,400
9	002	800	2019-01-16	2,200
10	002	800	2019-01-22	3,000 */



# preceding 在前的；上述的
# avg聚合函数进行over开窗操作
# 开窗参数分区方式partition by user_no
# 开窗参数分区内排序order by create_date 
# 开窗参数分区内选取每一行的前一行1和后一行2 rows between 2 preceding and 1 following
# 针对userid的当前分区内，id=001
# 001分区，当前行的前一行和后一方，第一行没有前面，则为当前行和后一方，求和除以2
# 001分区，第三行，当前行3，前一行2，后一行4，三条记录求和，除以3；
# 001分区，第5行，前4，后无，两条记录求和，除以2；
# 针对userid的当前分区内，id=002
# 002分区，当前行的前一行和后一方，第一行没有前面，则为当前行和后一方，求和除以2
# 002分区，第三行，当前行3，前一行2，后一行4，三条记录求和，除以3；
# 002分区，第5行，前4，后无，两条记录求和，除以2；
select *,
avg(amount) over(partition by user_no order by create_date rows between 2 preceding and 1 following) as 开窗分组排序求均值
from order_tab;
# order_id	user_no	amount	create_date	开窗分组排序求均值
# 1	001	100	2019-01-01	200.0000
# 2	001	300	2019-01-02	300.0000
# 3	001	500	2019-01-02	425.0000
# 4	001	800	2019-01-03	625.0000
# 5	001	900	2019-01-04	733.3333
# 6	002	500	2019-01-03	550.0000
# 7	002	600	2019-01-04	466.6667
# 8	002	300	2019-01-10	550.0000
# 9	002	800	2019-01-16	625.0000
# 10 002	800	2019-01-22	633.3333



# 查询每个用户按时间顺序的最近两天的订单金额
# range范围；值域；全距 interval间隔；区间；时间间隔 preceding在先的；前面的；先前的
select *,
sum(amount) over(partition by user_no order by create_date range interval 2 day preceding) sum_amount 
from order_tab;
# order_id	user_no	amount	create_date	sum_amount
# 1	001	100	2019-01-01	100
# 2	001	300	2019-01-02	900
# 3	001	500	2019-01-02	900
# 4	001	800	2019-01-03	1700
# 5	001	900	2019-01-04	2500
# 6	002	500	2019-01-03	500
# 7	002	600	2019-01-04	1100
# 8	002	300	2019-01-10	300
# 9	002	800	2019-01-16	800
# 10	002	800	2019-01-22	800



# 查询排名，同一用户开窗，按金额倒序排列
# 问题是相同金额的800 应该显示都是1，而不是1和2
select *,row_number() over(partition by user_no order by amount desc) as 排名1 from order_tab;
/* order_id	user_no	amount	create_date	排名1
5	001	900	2019-01-04	1
4	001	800	2019-01-03	2
3	001	500	2019-01-02	3
2	001	300	2019-01-02	4
1	001	100	2019-01-01	5
9	002	800	2019-01-16	1
10	002	800	2019-01-22	2
7	002	600	2019-01-04	3
6	002	500	2019-01-03	4
8	002	300	2019-01-10	5 */



# 开窗函数结果嵌套查询部分开窗数据
select * from (select *,row_number() over(partition by user_no order by amount desc) as row_num from order_tab) t where row_num<=3;
/* order_id	user_no	amount	create_date	row_num
5	001	900	2019-01-04	1
4	001	800	2019-01-03	2
3	001	500	2019-01-02	3
9	002	800	2019-01-16	1
10	002	800	2019-01-22	2
7	002	600	2019-01-04	3 */



# 把相同的结果排名数字相同化处理
# row_number函数就不能满足需求
# 两个订单的金额都是800，随机排为第一和第二，但实际两笔订单金额应该并列第一
# rank和dense_rank函数 与row_number函数类似，只是在出现重复值时处理逻辑不同
# rank等级；级别；军衔；排； dense浓厚的；密度大的；密实
select * 
from 
(select *,
row_number() over(partition by user_no order by amount desc) as row_num1,
rank() over(partition by user_no order by amount desc) as row_num2 
from order_tab) t 
where row_num1<=3;
/* order_id	user_no	amount	create_date	row_num1	row_num2
5	001	900	2019-01-04	1	1
4	001	800	2019-01-03	2	2
3	001	500	2019-01-02	3	3
9	002	800	2019-01-16	1	1
10	002	800	2019-01-22	2	1
7	002	600	2019-01-04	3	3 */



# row_number解决开窗分组内部排名
# rank解决开窗内部相同值显示同一数字问题
# dense_rank解决开窗内部相同数字导致后续断了排序数字问题
select * 
from 
(select *,
row_number() over(partition by user_no order by amount desc) as row_num1,
rank() over(partition by user_no order by amount desc) as row_num2,
dense_rank() over(partition by user_no order by amount desc) as row_num3
from order_tab) t 
where row_num1<=3;
/* order_id	user_no	amount	create_date	row_num1	row_num2	row_num3
5	001	900	2019-01-04	1	1	1
4	001	800	2019-01-03	2	2	2
3	001	500	2019-01-02	3	3	3
9	002	800	2019-01-16	1	1	1
10	002	800	2019-01-22	2	1	1
7	002	600	2019-01-04	3	3	2 */



# 查询每个用户订单金额从高到底排名
# rank等级；级别；军衔；排  dense浓厚的；密度大的；密实
select 
		*,
		row_number() over(partition by user_no order by amount desc) as 排名1,
        rank() over(partition by user_no order by amount desc) as 排名2,
        dense_rank() over(partition by user_no order by amount desc) as 排名3
from order_tab;
# order_id	user_no	amount	create_date	排名1	排名2	排名3
# 5	001	900	2019-01-04	1	1	1
# 4	001	800	2019-01-03	2	2	2
# 3	001	500	2019-01-02	3	3	3
# 2	001	300	2019-01-02	4	4	4
# 1	001	100	2019-01-01	5	5	5
# 9	002	800	2019-01-16	1	1	1
# 10 002	800	2019-01-22	2	1	1
# 7	002	600	2019-01-04	3	3	2
# 6	002	500	2019-01-03	4	4	3
# 8	002	300	2019-01-10	5	5	4


# 开窗函数针对分组后内部每一行进行求和平均最大最小计数
select *,
sum(amount) over(partition by user_no order by order_id) sum1,
avg(amount) over(partition by user_no order by order_id) avg1,
max(amount) over(partition by user_no order by order_id) max1,
min(amount) over(partition by user_no order by order_id) min1,
count(amount) over(partition by user_no order by order_id) count1
from order_tab;
/* order_id	user_no	amount	create_date	sum1	avg1	max1	min1	count1
1	001	100	2019-01-01	100	100	100	100	1
2	001	300	2019-01-02	400	200	300	100	2
3	001	500	2019-01-02	900	300	500	100	3
4	001	800	2019-01-03	1,700	425	800	100	4
5	001	900	2019-01-04	2,600	520	900	100	5
6	002	500	2019-01-03	500	500	500	500	1
7	002	600	2019-01-04	1,100	550	600	500	2
8	002	300	2019-01-10	1,400	466.6667	600	300	3
9	002	800	2019-01-16	2,200	550	800	300	4
10	002	800	2019-01-22	3,000	600	800	300	5 */