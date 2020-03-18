# create database sql;
use sql;



create table t_stu_profile(
stu_id varchar(10) primary key,
stu_name varchar(10),
gender varchar(10),
age int,
class_id varchar(10) not null
);
create table t_lesson(
lesson_id varchar(10) primary key,
lesson_name varchar(10)
);
create table t_score(
stu_id varchar(10) references t_stu_profile(stu_id),
lesson_id varchar(10) references t_lesson(lesson_id),
score int
);



insert into t_stu_profile values('001','郭东','F',16,'0611'),
								('002','李西','M',18,'0612'),
                                ('003','张北','F',16,'0613'),
                                ('004','钱南','M',17,'0611'),
                                ('005','王五','F',17,'0614'),
                                ('006','赵七','F',16,'0615');
insert into t_lesson values('L001','语文'),
						   ('L002','数学'),
                           ('L003','英语'),
                           ('L004','物理'),
                           ('L005','化学');
insert into t_score values ('001','L001',90),
						   ('001','L002',86),
                           ('002','L001',84),
                           ('002','L004',75),
                           ('003','L003',85),
                           ('004','L005',98);
 
                          
                          
select * from t_stu_profile;
/* stu_id	stu_name	gender	age	class_id
001	郭东	F	16	0611
002	李西	M	18	0612
003	张北	F	16	0613
004	钱南	M	17	0611
005	王五	F	17	0614
006	赵七	F	16	0615 */
select * from t_lesson;
/* lesson_id	lesson_name
L001	语文
L002	数学
L003	英语
L004	物理
L005	化学 */
select * from t_score;
/* stu_id	lesson_id	score
001	L001	90
001	L002	86
002	L001	84
002	L004	75
003	L003	85
004	L005	98 */
# 笛卡尔积，查询两张表会自动相乘
# 一个学生可以选择所有课程，每个课程都可以被选择全选
# 只是有没有得分的问题，可使用笛卡尔积进行乘积
select * from t_stu_profile,t_lesson;



desc t_stu_profile;
# stu_name gender age class_id
desc t_score;
# stu_id lesson_id score
desc t_lesson;
# lesson_id lesson_name



# 所有选手的课程得分，不管有无得分：学生、姓名、班级、课程
# 首先笛卡尔积 得到每个学生都可以选修任何课程 作为子表t
# 笛卡尔积t表和得分score表进行合并，前提是id相等且班级相等
# 主表为笛卡尔积表，这样则可以设置没有成绩score得分的为空值
# 副表为得分表，这样才可以将没有分数没选课程的人包含且显示为0
# 保证用户ID在笛卡尔积表和得分表一致，且课程ID在笛卡尔积表和得分表一致
select *
from (select * from t_stu_profile,t_lesson) t
left join 
t_score 
on t.stu_id=t_score.stu_id
and t.lesson_id=t_score.lesson_id;
# stu_id	stu_name	gender	age	class_id	lesson_id	lesson_name	stu_id	lesson_id	score
/* 001	郭东	F	16	0611	L001	语文	001	L001	90
001	郭东	F	16	0611	L002	数学	001	L002	86
002	李西	M	18	0612	L001	语文	002	L001	84
002	李西	M	18	0612	L004	物理	002	L004	75
003	张北	F	16	0613	L003	英语	003	L003	85
004	钱南	M	17	0611	L005	化学	004	L005	98
001	郭东	F	16	0611	L003	英语			
001	郭东	F	16	0611	L004	物理		*/	



# 只关联了笛卡尔积表和得分表的用户ID
# 存在很多学生的课程随意得分也有的问题
# 造成数据匹配成任意课程也有得分情况
select * from 
(select * from t_stu_profile,t_lesson) t
left join t_score on t.stu_id=t_score.stu_id;



# 笛卡尔积表和得分表通过了用户ID和课程ID 且连接 数据正确
# is not null 则获取socre不为空的结果
select * from 
(select * from t_stu_profile,t_lesson) t
left join t_score on t.stu_id=t_score.stu_id and t_score.lesson_id=t.lesson_id
where t_score.score is not null;
/* stu_id	stu_name	gender	age	class_id	lesson_id	lesson_name	stu_id	lesson_id	score
001	郭东	F	16	0611	L001	语文	001	L001	90
001	郭东	F	16	0611	L002	数学	001	L002	86
002	李西	M	18	0612	L001	语文	002	L001	84
002	李西	M	18	0612	L004	物理	002	L004	75
003	张北	F	16	0613	L003	英语	003	L003	85
004	钱南	M	17	0611	L005	化学	004	L005	98 */



# 学生没有参加考试的课程：学生、姓名、班级、课程
select t.stu_id,t.stu_name,t.class_id,t.lesson_name,t_score.score
from (select * from t_stu_profile,t_lesson) t
left join t_score 
on t.stu_id=t_score.stu_id
and t.lesson_id=t_score.lesson_id
where score is null;
/* stu_id	stu_name	class_id	lesson_name	score
001	郭东	0611	英语	[NULL]
001	郭东	0611	物理	[NULL]
001	郭东	0611	化学	[NULL] ...*/



desc t_stu_profile;
# stu_id stu_name gender age class_id
desc t_score;
# stu_id lesson_id score
desc t_lesson;
# lesson_id lesson_name
# 找出每门课程的前三名:课程、第一名（姓名+分数）、第二名（姓名+分数）、第三名（姓名+分数）
select t_lesson.lesson_name,t_stu_profile.stu_name,t_score.score,
row_number() over(partition by lesson_name order by t_score.score desc) as 排名
from t_lesson 
left join t_score on t_lesson.lesson_id = t_score.lesson_id
left join t_stu_profile on t_stu_profile.stu_id = t_score.stu_id 
/* lesson_name	stu_name	score	排名
化学	钱南	98	1
数学	郭东	86	1
物理	李西	75	1
英语	张北	85	1
语文	郭东	90	1
语文	李西	84	2 */



select 
t_lesson.lesson_id,
lesson_name,
stu_name,
score,
row_number() over(partition by lesson_name order by score desc) 排名
from t_lesson
left join t_score on t_lesson.lesson_id = t_score.lesson_id
left join t_stu_profile on t_score.stu_id = t_stu_profile.stu_id;
# lesson_id	lesson_name	stu_name	score	排名
# L005	化学	钱南	98	1
# L002	数学	郭东	86	1
# L004	物理	李西	75	1
# L003	英语	张北	85	1
# L001	语文	郭东	90	1
# L001	语文	李西	84	2



# 将各个科目排名结果转置横排
# IF(expr1,expr2,expr3)，如果expr1的值为true，则返回expr2的值，如果expr1的值为false
# 嵌套已经做好了开窗函数的数据行，存在同一个科目数据在两行的情况
select *,
if(排名=1,stu_name,null) as 排名第一,
if(排名=2,stu_name,null) as 排名第二,
if(排名=3,stu_name,null) as 排名第三
from
(select lesson_name,stu_name,score,row_number() over(partition by lesson_name) as 排名
from t_score
left join t_lesson on t_lesson.lesson_id =t_score.lesson_id 
left join t_stu_profile on t_score.stu_id =t_stu_profile.stu_id) t;
/* lesson_name	stu_name	score	排名	排名第一	排名第二	排名第三
化学	钱南	98	1	钱南	[NULL]	[NULL]
数学	郭东	86	1	郭东	[NULL]	[NULL]
物理	李西	75	1	李西	[NULL]	[NULL]
英语	张北	85	1	张北	[NULL]	[NULL]
语文	郭东	90	1	郭东	[NULL]	[NULL]
语文	李西	84	2	[NULL]	李西	[NULL] */



# 让每个名字都只出现一次，又能够显示所有的名字相同的人的id
# group_concat 将group by产生的同一个分组中的值连接起来，返回一个字符串结果
select *,
group_concat(if(排名=1,stu_name,null)) as 排名第一,
group_concat(if(排名=2,stu_name,null)) as 排名第二,
group_concat(if(排名=3,stu_name,null)) as 排名第三
from
(select lesson_name,stu_name,score,row_number() over(partition by lesson_name) as 排名
from t_score
left join t_lesson on t_lesson.lesson_id =t_score.lesson_id 
left join t_stu_profile on t_score.stu_id =t_stu_profile.stu_id) t
# group by lesson_name;
# lesson_name	stu_name	score	排名	排名第一	排名第二	排名第三
# 化学	钱南	98	1	钱南,郭东,李西,张北,郭东	李西	[NULL]



# group_concat 将分组后的分组结果一行展示
select *,
group_concat(if(排名=1,stu_name,null)) as 排名第一,
group_concat(if(排名=2,stu_name,null)) as 排名第二,
group_concat(if(排名=3,stu_name,null)) as 排名第三
from
(select lesson_name,stu_name,score,row_number() over(partition by lesson_name) as 排名
from t_score
left join t_lesson on t_lesson.lesson_id =t_score.lesson_id 
left join t_stu_profile on t_score.stu_id =t_stu_profile.stu_id) t
group by lesson_name;
/* lesson_name	stu_name	score	排名	排名第一	排名第二	排名第三
化学	钱南	98	1	钱南	[NULL]	[NULL]
数学	郭东	86	1	郭东	[NULL]	[NULL]
物理	李西	75	1	李西	[NULL]	[NULL]
英语	张北	85	1	张北	[NULL]	[NULL]
语文	郭东	90	1	郭东	李西	[NULL] */



select lesson_name,stu_name,
if(排名=1,concat(stu_name,'+',score),null) as 第一名,
if(排名=2,concat(stu_name,'+',score),null) as 第二名,
if(排名=3,concat(stu_name,'+',score),null) as 第三名
from 
(select 
t_lesson.lesson_id,
lesson_name,
stu_name,
score,
row_number() over(partition by lesson_name order by score desc) as 排名
from t_lesson
left join t_score on t_lesson.lesson_id = t_score.lesson_id
left join t_stu_profile on t_score.stu_id = t_stu_profile.stu_id) t;
# lesson_name	stu_name	第一名	第二名	第三名
# 化学	钱南					钱南+98		
# 数学	郭东					郭东+86		
# 物理	李西					李西+75		
# 英语	张北					张北+85		
# 语文	郭东					郭东+90		
# 语文	李西							李西+84	



# 功能：将group by产生的同一个分组中的值连接起来，返回一个字符串结果
select 
	lesson_name,排名,
    group_concat(if(排名=1,concat(stu_name,'+',score),null)) 第一名,
    group_concat(if(排名=2,concat(stu_name,'+',score),null)) 第二名,
    group_concat(if(排名=3,concat(stu_name,'+',score),null)) 第三名
from 
(select 
	lesson_name,
    stu_name,
    score,
    row_number() over(partition by lesson_name order by score desc) 排名
from t_lesson 
left join t_score on t_lesson.lesson_id=t_score.lesson_id
left join t_stu_profile on t_score.stu_id=t_stu_profile.stu_id) t
group by lesson_name;
# lesson_name	第一名	第二名	第三名
# 数学	郭东+86		
# 物理	李西+75		
# 英语	张北+85		
# 语文	郭东+90	李西+84	



desc t_stu_profile;
# stu_id stu_name gender age class_id
desc t_score;
# stu_id lesson_id score
desc t_lesson;
# lesson_id lesson_name
select * from t_score;



# 各个班级学生成绩：姓名、语文、数学、英语、物理、化学
select class_id,stu_id,stu_name,
group_concat(if(lesson_name='语文',score,null)) as 语文,
group_concat(if(lesson_name='数学',score,null)) as 数学,
group_concat(if(lesson_name='英语',score,null)) as 英语,
group_concat(if(lesson_name='物理',score,null)) as 物理,
group_concat(if(lesson_name='化学',score,null)) as 化学
from 
(select 
	t_score.stu_id,
	class_id,
	gender,
	lesson_name,
    stu_name,
    score,
    row_number() over(partition by lesson_name order by score desc) 排名
from t_score
left join t_lesson on t_lesson.lesson_id=t_score.lesson_id
left join t_stu_profile on t_score.stu_id=t_stu_profile.stu_id) t
group by stu_name;
# lesson_name	第一名	第二名	第三名
# 数学	郭东+86		
# 物理	李西+75		
# 英语	张北+85		
# 语文	郭东+90	李西+84



# 各个班级学生成绩：姓名、语文、数学、英语、物理、化学、总分
# NULL为0的结构出现了两个值 异常问题
select class_id,stu_id,stu_name,
group_concat(if(lesson_name='语文',score,0)) as 语文,
group_concat(if(lesson_name='数学',score,0)) as 数学,
group_concat(if(lesson_name='英语',score,0)) as 英语,
group_concat(if(lesson_name='物理',score,0)) as 物理,
group_concat(if(lesson_name='化学',score,0)) as 化学
from 
(select 
	t_score.stu_id,
	class_id,
	gender,
	lesson_name,
    stu_name,
    score,
    row_number() over(partition by lesson_name order by score desc) 排名
from t_score
left join t_lesson on t_lesson.lesson_id=t_score.lesson_id
left join t_stu_profile on t_score.stu_id=t_stu_profile.stu_id) t
group by stu_name;
/* class_id	stu_id	stu_name	语文	数学	英语	物理	化学	
0613	003	张北	0	0	85	0	0	
0612	002	李西	0,84	0,0	0,0	75,0	0,0	
0611	001	郭东	0,90	86,0	0,0	0,0	0,0	
0611	004	钱南	0	0	0	0	98	*/



# 各个班级学生成绩：姓名、语文、数学、英语、物理、化学、总分
# 多次试验未能拿到正确的总得分结果，只能两项相加，不能多项相加问题
select class_id,stu_id,stu_name,
group_concat(if(lesson_name='语文',score,null)) as 语文,
group_concat(if(lesson_name='数学',score,null)) as 数学,
group_concat(if(lesson_name='英语',score,null)) as 英语,
group_concat(if(lesson_name='物理',score,null)) as 物理,
group_concat(if(lesson_name='化学',score,null)) as 化学,
# (group_concat(if(lesson_name='语文',score,null)))+(group_concat(if(lesson_name='数学',score,null)))+(group_concat(if(lesson_name='物理',score,null)))+(group_concat(if(lesson_name='英语',score,null)))+(group_concat(if(lesson_name='化学',score,null))) as 总分
(group_concat(if(lesson_name='语文',score,null)))+(group_concat(if(lesson_name='物理',score,null))) as 语文数学1,
((group_concat(if(lesson_name='语文',score,null)))+(group_concat(if(lesson_name='物理',score,null))))+(group_concat(if(lesson_name='数学',score,null))) as 语文数学2
from 
(select 
	t_score.stu_id,
	class_id,
	gender,
	lesson_name,
    stu_name,
    score,
    row_number() over(partition by lesson_name order by score desc) 排名
from t_score
left join t_lesson on t_lesson.lesson_id=t_score.lesson_id
left join t_stu_profile on t_score.stu_id=t_stu_profile.stu_id) t
group by stu_name;
/* class_id	stu_id	stu_name	语文	数学	英语	物理	化学				语文数学1	语文数学2
0613	003	张北	[NULL]	[NULL]	85	[NULL]	[NULL]     			[NULL]	[NULL]
0612	002	李西	84	[NULL]	[NULL]	75	[NULL]	        		159	[NULL]
0611	001	郭东	90	86	[NULL]	[NULL]	[NULL]	       	 		[NULL]	[NULL]
0611	004	钱南	[NULL]	[NULL]	[NULL]	[NULL]	98	   		    [NULL]	[NULL] */



select * from t_score;
/* stu_id	lesson_id	score
001	L001	90
001	L002	86
002	L001	84
002	L004	75
003	L003	85
004	L005	98 */



select 
	t_score.stu_id,
	class_id,
	gender,
	lesson_name,
    stu_name,
    score,
    row_number() over(partition by lesson_name order by score desc) 排名
from t_score
left join t_lesson on t_lesson.lesson_id=t_score.lesson_id
left join t_stu_profile on t_score.stu_id=t_stu_profile.stu_id;
/* stu_id	class_id	gender	lesson_name	stu_name	score	排名
004	0611	M	化学	钱南	98	1
001	0611	F	数学	郭东	86	1
002	0612	M	物理	李西	75	1
003	0613	F	英语	张北	85	1
001	0611	F	语文	郭东	90	1
002	0612	M	语文	李西	84	2 */