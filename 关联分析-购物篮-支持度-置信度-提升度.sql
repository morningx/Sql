
# 1 背景：

# 时间：20200222
# 主体内容：购物篮分析、关联分析、频繁模式、支持度、置信度、提升度、不同商品相关性分析
# 笑话：啤酒和尿布会同时出现在很多购物记录里，把啤酒和尿布的销售货架放在一起，进而让啤酒和尿布的销量进一步提高



# 2 目录：

# 目录1：背景
# 目录2：知识点
# 目录3：知识点
# 目录4：进入数据库建表 
# 目录5：插入数据行到表内  
# 目录6：频繁模式     
# 目录7：支持度
# 目录8：支持度-置信度     
# 目录9：支持度-置信度-提升度   
# 目录10：支持度-置信度-提升度-相关性分析



# 3 知识点：

# 3.1 购物篮：
# 一个超市里每天有很多的购物记录，每个记录相当于在超市发生的一笔结算，一个购物者把篮子里的商品都一起扫码付账。

# 3.2 频繁模式：
# 每个购买记录中出现的各种单品其实体现的是一种组合的性质，单品的组合在记录中是无序的；
# 也就是无法知道在记录1中究竟是先“购买”了啤酒然后诱使他又“购买”了香烟，还是先“购买”了香烟后来又购买了啤酒;
# 因此只能研究一个无序的组合，这种组合就叫做“模式”;
# 有的出现频率很低，有的出现频率很高，一般认为频率较高的通常更有指导意义，这种高频率的模式就被称作“频繁模式”；
# 所有的频繁项集的问题都能用基于关系型数据库的统计方法进行分析;
# 如果规模巨大则可以用分布式关系型数据库或者抽样数据进行分析;

# 3.3 衡量频繁模式-支持度-置信度
# 频率较高的模式叫做频繁模式。衡量频率的指标有两个：一个是支持度，一个是置信度；
# 设置门限“最小支持度”和“最小置信度”，支持度和置信度同时高于这两个门限就可以认为是频繁模式了；
# 找出频繁项集实际是找出同时满足最小支持度和最小置信度的模式
# 啤酒=>香烟[support=40%；confidence=100%]
# 香烟=>啤酒[support=40%；confidence=67%]
# confidence 信心；信任；自信心；信赖
# support 支持；支护；支撑；支援

# 3.4 支持度和置信度多高才算高
# 在生活中各超市各卖场的购物篮分析场景里，支持度和置信度都远没有上述例子这么高；
# 很大数量的支持度和置信度可能都只有百分之零点几或者百分之零点零几；
# 在所有商品中找出所有的模式，会发现有一些模式的支持度和置信度同时都比其他高很多；
# 这时可以考虑用所有模式的支持度的平均值和置信度的平均值作为参考，适当提高一些作为阈值做过滤；
# 如果单纯支持度高或者置信度高能否直接被认为是频繁模式呢？
# 如果支持度高置信度低，说明这两种情况确实同时出现，但是“转化率”可能比较低；
# 如果支持度比较低，但是转化率比较高，说明这种模式在所有的模式里很平常，甚至可能不能算“频繁”；
# 通常还是会选择支持度和置信度都高于阈值的门限的模式作为频繁模式；

# 3.4 支持度
# 两物品支持度：找到两物品同时出现在所有购物篮的个数，除以，购物篮订单总数，得到支持度；

# 3.5 置信度
# 置信度是有“方向性”的，如果说购买啤酒的记录里有100%的记录都购买了香烟，那么就说购买啤酒后购买香烟的置信度为100%；
# 反向地看，如果购买了香烟的记录有67%的记录都购买了啤酒，那么就说购买香烟后购买啤酒的置信度为67%。

# 3.6 Apriori算法
# 1 先设置一个最小支持度作为阈值门限值进行扫描，假设设置的最小支持度为40%；
# 2 扫描所有满足最小支持度的单品，假设有一个单品和另一个单品组合的模式满足最小支持度40%；
# 那该单品首先必须在所有购买记录中出现的概率大于等于40%才有可能，这是一个必要条件；
# 所以扫描所有满足最小支持度的单品，找出大于等于40%的；
# 大量小于40%的单品已经被过滤掉了，这个过程在算法中叫剪枝，再逐级组合查找模式时，有很多的单品可以不考虑；
# 3 查找满足条件的2项模式。根据已经过滤出的单品，组合一下看候选的2项模式有哪些；
# 做一个笛卡儿乘积，候选的2项模式，啤酒和香烟，出现过2次，2/5=40%，啤酒和酸奶，出现过1次，1/5=20%；
# 在所有已经滤出的2项模式中，找出满足最小支持度的2项模式（满足最小支持度为40%的2项模式）
# 4 做一个笛卡儿乘积，候选的3项模式，啤酒香烟酸奶20%支持度；
# 所有候选的3项模式都“阵亡”了，全都不满足40%的门限要求；
# 因为我们也不可能找到满足条件的3项、4项以及以后任何多种符合条件的频繁模式了；
# 这样实际上求出的是所有的满足支持度和置信度的频繁项集，2项、3项……一直到N项；
# 只要它们满足设置的支持度和置信度，就都能被计算出来；

# 3.7 求出所有两项频繁模式：
# 计算两项频繁模式，“啤酒=>香烟”的支持度和置信度；
# 求解那些“哪两个”单品的组合的支持度和置信度能够满足要求；
# 穷举了在所有购买记录中的各次购买清单里的组合，而且正反向组合各存在一次；
# A=>B是有方向的，分别代表啤酒和香烟，和分别代表香烟和啤酒是两种不同的情况；
# 所有单品A或B出现在购物篮总订单的个数，除以，购物篮订单数，得到单个商品的支持度；
# 所有单品B的置信度，AB共有出现次数在购物篮，除以，A出现次数在购物篮，得到B在A发生后的置信度；

# 3.8 求出所有两项频繁模式相关程度：
# 算出有较高支持度和较高置信度的频繁模式之后，要对这些频繁模式进行一些复合人类行为的分析
# 易于被人理解，对于新的或检验数据是有效的，是潜在有用的，是新颖的；
# 这些特点带有很浓郁的主观色彩，如新颖、是否有用，这些观点本身就是因人而异的；
# Apriori能够过滤出关联度较高的模式，但是还不能对相关性做出解释
# 啤酒=>香烟[support=40%；confidence=100%]，也就是Type1=>Type2[支持度，置信度]的频繁项集（关联规则）的记述方式
# Type1=>Type2[支持度，置信度，关联度]，其中关联度记作correlation
# 等号左边是A和B的相关性定义，右边分子是发生A的情况下发生B的概率，分母是发生B的概率；
# 提升度Lift，P(A,B)=P(B|A)/P(B)=[P(A&B)/P(A)]/P(B)，与朴素贝叶斯公式类似；
# 当相关性是1时，P（B|A）与P（B）相等，也就是说在全样本空间内，B发生的概率和在发生A的情况下发生B的概率是一样的，那么它们就是毫无关系；
# 当相关性大于1时，P（B|A）大于P（B），也就是说在全样本空间内，发生A的情况下发生B的概率要比单独统计B发生的概率要大，那么B和A是正相关的。换句话说，A的发生促进了B的发生；
# 相反，当相关性小于1时，P（B|A）小于P（B），也就是说在全样本空间内，发生A的情况下发生B的概率要比单独统计B发生的概率要小，那么B和A是负相关的。换句话说，A的发生抑制了B的发生；

# 3.9 稀有模式和负相关：
# 稀有模式，是支持度远低于设定的支持度的模式；
# 频繁模式设定支持度时，设置的这个门限阈值要么是行业内的一个经验值要么是挑选的大量支持度统计的平均值，大于这个数字，就认为是一个频繁模式；
# 设置一个比这个数字小得多的值作为过滤条件，比这个值小很多的值才是稀有模式；
# 在实际生产生活中可以考虑用支持度倒排序的功能去找那些支持度极低的模式；
# 负相关一种事物的增加同时就对应另一种事物的减少，这种直观感觉下的两种事物就是负相关的；
# 这个月购买数码产品的预算一共是3000元，那么买了数码照相机，购买PS4游戏机的预算就不足，导致不能购买PS4游戏机；
# 不是观察一个人的行为了，而是观察很多人在大量购买行为中出现的这种取舍性的负相关行为；
# 当发现有一些物品X和Y都比较频繁，但是却通常只出现其中一个时，可以来进行统计分析；
# 看看这些负相关的物品是否满足了人们在某一大领域的需求，进而估算人们在这个领域的预算规模和购物规律；
# 如果X和Y都是频繁的，但是很少或者不一起出现，那么就说X和Y是负相关的，X和Y组成的模式是负相关模式；
# 在病症治疗或者基因分析中同样可以用负模式挖掘的方法来发现那些有关联的疾病或抗体；
# 在得过A疾病的患者中，罹患B疾病的病人比例比普通人小很多，那么就可以推断很可能A疾病会让病人同时具备抵抗B疾病的抗体;


# 4 进入数据库建表：
# 订单流水号orderserial，订单类别ordertype
show databases;
use hello;
create table Buy_list(
OrderSerial varchar(255),
OrderType varchar(255)
);

# 表字段列名信息及查询表记录行信息
desc Buy_list;
select * from buy_list;



# 5 插入数据行到表内： 
insert into buy_list values('0001','啤酒');
insert into buy_list values('0001','香烟');
insert into buy_list values('0001','白菜');
insert into buy_list values('0001','鸡蛋');
insert into buy_list values('0001','酸奶');
insert into buy_list values('0001','卫生纸');
insert into buy_list values('0002','红酒');
insert into buy_list values('0002','香烟');
insert into buy_list values('0002','巧克力糖');
insert into buy_list values('0002','酸奶');
insert into buy_list values('0003','牙刷');
insert into buy_list values('0003','奶糖');
insert into buy_list values('0003','食盐');
insert into buy_list values('0003','冷冻鸡肉');
insert into buy_list values('0003','卫生纸');
insert into buy_list values('0004','啤酒');
insert into buy_list values('0004','一次性酒杯');
insert into buy_list values('0004','香烟');
insert into buy_list values('0004','瓜子');
insert into buy_list values('0004','花生');
insert into buy_list values('0004','油炸薯片');
insert into buy_list values('0005','酸奶');
insert into buy_list values('0005','巧克力糖');
insert into buy_list values('0005','味精');



# 6 频繁模式：    
# 频率较高的模式叫做频繁模式，白酒商品出现在购物篮篮子比较多，则叫频繁模式
# 购买（啤酒，香烟）模式的支持度为40%，那就是说所有的购买记录里（例子里是5个），有40%的购买记录都包含这种模式。

select OrderSerial,OrderType as Type1 from buy_list;
select `OrderSerial` ,`OrderType` as Type2 from buy_list;
# 0001	啤酒
# 0001	香烟
# 0001	香烟

# 计算笛卡尔积，数据集一个品牌乘以自己得到矩阵行；
select R1.OrderSerial as OrderSerial,R1.Type1,R2.Type2
from (select OrderSerial,OrderType as Type1 from buy_list) as R1
inner join (select `OrderSerial` ,`OrderType` as Type2 from buy_list) as R2
on R1.Type1 = R2.Type2;
# 0001	啤酒	啤酒
# 0004	啤酒	啤酒
# 0001	香烟	香烟
# 0001	香烟	香烟

# 计算笛卡尔积后将品类1和品类2相同的去掉，相同的则为买两件而不是一件出现两次
select R1.OrderSerial as OrderSerial,R1.Type1,R2.Type2
from (select OrderSerial,OrderType as Type1 from buy_list) as R1
inner join (select `OrderSerial` ,`OrderType` as Type2 from buy_list) as R2
on R1.OrderSerial = R2.OrderSerial
and R1.Type1 <> R2.Type2;
# 0001	香烟	啤酒
# 0001	香烟	啤酒
# 0001	白菜	啤酒

# 计算笛卡尔积，去掉Type1和Type2的相同品类，得到结果保存到patterns两物品频繁模式表
create table patterns (
OrderSerial varchar(255),Type1 varchar(255),Type2 varchar(255)) 
as select R1.OrderSerial as OrderSerial,R1.Type1,R2.Type2
from (select OrderSerial,OrderType as Type1 from buy_list) as R1
inner join (select `OrderSerial` ,`OrderType` as Type2 from buy_list) as R2
on R1.OrderSerial = R2.OrderSerial
and R1.Type1 <> R2.Type2;

select * from patterns;
# 0001	香烟	啤酒
# 0001	香烟	啤酒
# 0001	白菜	啤酒

# 每行不同类型Type1和2，进行汇总计算出support为两物品频繁模式的个数
select Type1,Type2,count(*) support from patterns group by `Type1` ,`Type2` ;
# 香烟	啤酒	3
# 白菜	啤酒	1
# 鸡蛋	啤酒	1
# 酸奶	啤酒	1

# 每行不同类型Type1和2，进行汇总计算出support为两物品频繁模式的个数
select Type1,Type2,count(*) support from patterns group by `Type1` ,`Type2` order by  support desc;
# 香烟	啤酒	3
# 香烟	酸奶	3
# 啤酒	香烟	3
# 酸奶	香烟	3
# 巧克力糖	酸奶	2
# 香烟	卫生纸	2

# 香烟啤酒 = 啤酒香烟，这个假设，则除以2，得到support两物品组合的频繁模式值
# 可以不除以2，向量有方向，AB物品和BA物品不一致，从向量角度考虑
select Type1,Type2,count(*)/2 as support from patterns group by `Type1` ,`Type2` ;
# 香烟	啤酒	1.5000
# 白菜	啤酒	0.5000
# 鸡蛋	啤酒	0.5000
# 酸奶	啤酒	0.5000

create view two_type_count_support as
select Type1,Type2,count(*) support from patterns group by `Type1` ,`Type2` order by  support desc;

select count(*) from patterns;
# 108

select count(distinct OrderSerial) from patterns;
# 去重订单编号则为insert数据的1-5个订单，每个订单购物篮多个商品



# 7 支持度：    
# 两个商品的支持度view视图值 除以 购物篮个数 得到 两个物品支持度
select 
Type1 as '物品品类1',
Type2 as '物品品类2',
support as '两物品组合结果数',
(select count(distinct OrderSerial) from patterns) as '订单购物篮总数',
(support/(select count(distinct OrderSerial) from patterns)) as '两物品支持度'
from two_type_count_support;
# 物品品类1 物品品类2 两物品组合结果数  订单购物篮总数  两物品支持度
# 香烟	啤酒 	3	5	0.6000
# 香烟	酸奶 	3	5	0.6000
# 啤酒	香烟 	3	5	0.6000

# 两商品频繁模式支持度
# Type1=>Type2 
create view two_order_support as 
select 
Type1 as '物品品类1',
Type2 as '物品品类2',
support as '两物品组合结果数',
(select count(distinct OrderSerial) from patterns) as '订单购物篮总数',
(support/(select count(distinct OrderSerial) from patterns)) as '两物品支持度'
from two_type_count_support;
# 物品品类1 物品品类2 两物品组合结果数  订单购物篮总数  两物品支持度
# 香烟	啤酒 	3	5	0.6000
# 香烟	酸奶 	3	5	0.6000
# 啤酒	香烟 	3	5	0.6000

select * from two_order_support;
desc two_order_support;
select * from two_order_support where 两物品支持度>=0.4;
# 物品品类1 物品品类2 两物品组合结果数 订单购物篮总数 两物品支持度
# 香烟		啤酒		3	5	0.6000
# 香烟		酸奶		3	5	0.6000
# 啤酒		香烟		3	5	0.6000
# 酸奶		香烟		3	5	0.6000
# 巧克力糖	酸奶		2	5	0.4000

# 查询两物品频繁模式支持度包含值的种类，大于0.4的结果从业务角度考虑更有价值；
select distinct 两物品支持度 from two_order_support;
# 两物品支持度
# 0.6000
# 0.4000
# 0.2000



# 8 支持度-置信度：      
# 支持度，概率值，两物品同时出现在购物篮单个订单内的数量，除以，总订单数；
# 置信度，条件概率值，A=>B两物品同时出现的概率，除以，A物品出现在购物篮订单的个数；
# 订单分类：ABC、ACD、BCD、ADE、BCE
# A=>C，AC一起在购物篮概率为：ABC/ACD个数为2，总购物篮5个，则支持度概率为：2/5=40%；
# A=>C，买A后会买C的置信度为：AC一起个数为2，A前导项在5个购物篮总有3个，则概率为：2/3=67%
# B尿布=>C啤酒，BC一起在购物篮概率为：ABC/BCD/BCE个数为3，总购物篮5个，则支持度概率为：3/5=60%；
# B尿布=>C啤酒，买B尿布后会买C啤酒的置信度为：BC一起个数为3，B尿布前导项在5个购物篮总有3个，则概率为：3/3=100%
# B=>CD，支持度为：BCD1个，1/5=20%；置信度为：1/3=33%
# 求Type1=>Type2的置信度，即用同时有Type2和Type1的购买记录数除以所有含有Type1的购买记录数

# 查询购物篮原始数据订单内每个品类type的数量
create view type_counts as 
select count(*) as type_count,`OrderType` 
from buy_list group by `OrderType` ;

select * from type_counts;
# type_count `OrderType`
# 2	啤酒 # 4	香烟 # 1	白菜 # 1	鸡蛋 # 3	酸奶 # 2	卫生纸
# 1	红酒 # 2	巧克力糖 # 1	牙刷 # 1	奶糖 # 1	食盐 # 1	冷冻鸡肉
# 1	一次性酒杯  # 1 瓜子 # 1	花生 # 1	油炸薯片 # 1	味精

select * from two_order_support;

create view zhichidu_zhixindu as
select 物品品类1,物品品类2,两物品支持度, 
(select type_count from type_counts 
where type_counts.OrderType=two_order_support.物品品类1 )
as 物品品类1在购物篮总个数,
两物品支持度/(select type_count from type_counts 
where type_counts.OrderType=two_order_support.物品品类1 ) as 置信度
from two_order_support
order by 置信度 desc;

# 查询视图内支持度高的且置信度高的数据行作为关联分析使用
select * from zhichidu_zhixindu;
select * from zhichidu_zhixindu order by 两物品支持度 desc,置信度 desc;
select * from zhichidu_zhixindu order by 两物品支持度 desc;



# 9 支持度-置信度-提升度：           
# 计算出有较高支持度和较高置信度的频繁模式之后
# 提升度（Lift）是一种简单的关联度度量，也是一种比较容易实现的统计方法
# Apriori能够过滤出关联度较高的模式，但是还不能对相关性做出解释

# Type1=>Type2[支持度，置信度，关联度]，其中关联度记作correlation
# 提升度P(A,B)=P(B|A)/P(B)
# 等号左边是A和B的相关性定义，右边分子是发生A的情况下发生B的概率，分母是发生B的概率

# 当相关性是1时，P（B|A）与P（B）相等，也就是说在全样本空间内
# B发生的概率和在发生A的情况下发生B的概率是一样的，那么它们就是毫无关系
# 当相关性小于1时，P（B|A）小于P（B），也就是说在全样本空间内
# 发生A的情况下发生B的概率要比单独统计B发生的概率要小，那么B和A是负相关的。

# 订单分类：ABC、ACD、BCD、ADE、BCE
# A啤酒=>B尿布，提升度P(A,B)=P(B|A)/P(B)
# P(B|A)，A啤酒发生后B尿布的概率为置信度，AB支持度为1个，A个数为3个，置信度为1/3=33%
# P(B)，B的概率在购物车订单5个中有3个，概率为3/5=60%
# 提升度P(A,B)=P(B|A)/P(B)，(1/3)/(3/5) = 1/3 * 5/3 = 5/9=0.56=56%，关联提升度为56%，则A和B提升度为56%
# P(C)=4/5=80%，P(C|A)=P(C&A)=2/5=40%，
# P(A,C)=P(C|A)/P(CB)，40%/80%=50%，则A和B提升关联度为50%
# AC关联度50%<AB关联度56%，则AB进行推荐在真实情况较好

# 提升度P(A,B)=P(B|A)/P(B)=P(A&B)/P(A)
# P(B|A)=A发生下B的概率为置信度=P(A=>B)=(P(type1=>type2)=P(A&B)/P(A)= AB支持度 除以 A概率
# P(B)，P(type2)，物品品类2，单个物品的概率，在购物篮总数上
select * from buy_list;
# 0001	啤酒
# 0001	香烟
select * from two_order_support;
# 物品品类1 物品品类2 两物品组合结果数 订单购物篮总数 两物品支持度
# 香烟		啤酒				3			5			0.6000
# 香烟		酸奶				3			5			0.6000
# 啤酒		香烟				3			5			0.6000
select * from two_type_count_support;
# `Type1`  `Type2`  support
#   香烟		啤酒			3
#   香烟		酸奶			3
#   啤酒		香烟	  		3
select 物品品类1 from two_order_support;

select * from buy_list;
# `OrderSerial`  `OrderType`
# 0001	啤酒
# 0001	香烟

select * from two_order_support;
# 两物品支持度字段为 P(A&B)
# 订单购物篮总数为原始数据buy_list的订单总数，作为计算PA或PB的分母
# PA为物品品类1，PB为物品品类2
# 物品品类1 物品品类2 两物品组合结果数 订单购物篮总数 两物品支持度
# 香烟		啤酒				3			5			0.6000
# 香烟		酸奶				3			5			0.6000
# 啤酒		香烟				3			5			0.6000

select two_order_support.物品品类1 ,(select count(*) from buy_list)
from two_order_support
where two_order_support.物品品类1 = buy_list.`OrderType` 

select OrderType,count(*) from buy_list where `OrderType` ='香烟';
# 4 
select OrderType,count(*) from buy_list group by `OrderType` ;
# OrderType,count(*)
# 香烟	4
# 白菜	1

# 原始购物篮数据buylist，找到唯一的商品名称，求商品的个数
# 商品个数 除以 购物篮总数 则为 该单一商品的支持度
select 
OrderType,count(*) as 单个商品在购物篮总个数, 
count(*)/5 as 单个商品的支持度概率
from buy_list group by `OrderType` ;
# `OrderType` 单个商品在购物篮总个数  单个商品的支持度概率
# 啤酒				2					0.4000
# 香烟				4					0.8000

# 创建视图PAPB，存储购物篮原始表内单个商品的支持度
create view PAPB as select 
OrderType,count(*) as 单个商品在购物篮总个数, 
count(*)/5 as 单个商品的支持度概率
from buy_list 
group by `OrderType` ;

select * from PAPB;
# `OrderType`  单个商品在购物篮总个数   单个商品的支持度概率
#   啤酒					2					0.4000
# 	香烟					4					0.8000
# 	白菜					1					0.2000

# 以下只需要所有PAPB表单个商品的支持度，在物品品类1出现的商品即可
# 以上单一商品的支持度和 two_order_support表的物品品类1一样的品类，则获取该列表的PA
select distinct PAPB.`OrderType`,PAPB.单个商品的支持度概率 
from PAPB,two_order_support 
where PAPB.`OrderType` = two_order_support.物品品类1;
# `OrderType` 单个商品的支持度概率
# 香烟	0.8000
# 啤酒	0.4000
# 酸奶	0.6000

# 以上单一商品的支持度和 two_order_support表的物品品类2一样的品类，则获取该列表的PB
select distinct PAPB.`OrderType`,PAPB.单个商品的支持度概率 
from PAPB,two_order_support 
where PAPB.`OrderType` = two_order_support.物品品类2;
# `OrderType`  单个商品的支持度概率
# 啤酒	0.4000
# 酸奶	0.6000
# 香烟	0.8000
# 香烟	0.8000
# 酸奶	0.6000

# 提升度P(A,B)=P(B|A)/P(B)=[P(A&B)/P(A)]/P(B)
# 提升度（Lift）是一种简单的关联度度量，也是一种比较容易实现的统计方法
select two_order_support.物品品类1,
two_order_support.两物品支持度,
papb.单个商品的支持度概率,
two_order_support.两物品支持度/papb.单个商品的支持度概率 as PAB除PA
from two_order_support,papb
where two_order_support.物品品类1=papb.`OrderType` ;

create view PAPB_PA_PB as 
select two_order_support.物品品类1,
two_order_support.两物品支持度,
papb.单个商品的支持度概率,
two_order_support.两物品支持度/papb.单个商品的支持度概率 as PAB除PA,
two_order_support.物品品类2,
(two_order_support.两物品支持度/papb.单个商品的支持度概率)/papb.单个商品的支持度概率 as PAB除PA除PB
from two_order_support,papb
where two_order_support.物品品类1=papb.`OrderType` ;

select * from PAPB_PA_PB;
# 物品品类1  两物品支持度  单个商品的支持度概率 		 `PAB除PA`  		     物品品类2  		`PAB除PA除PB`
#   香烟			0.6000			0.8000			0.75000000		        啤酒				0.937500000000
#   香烟			0.6000			0.8000			0.75000000	                酸奶				0.937500000000
#	 啤酒		0.6000			0.4000			1.50000000			香烟				3.750000000000
#	 酸奶		0.6000			0.6000			1.00000000			香烟				1.666666666667



# 10 支持度-置信度-提升度-相关性分析：   
# Apriori能够过滤出关联度较高的模式，但是还不能对相关性做出解释
# Type1=>Type2[支持度，置信度，关联度]，其中关联度记作correlation
# 有关相关规则的分析，提升度（Lift）是一种简单的关联度度量
# 提升度Lift，P(A,B)=P(B|A)/P(B)=[P(A&B)/P(A)]/P(B)，与朴素贝叶斯公式类似
# 等号左边是A和B的相关性定义，右边分子是发生A的情况下发生B的概率，分母是发生B的概率
create view lift as
select 物品品类1 as 物品品类1_A,
物品品类2 as 物品品类2_B,
单个商品的支持度概率 as 物品品类1的单品类的支持度_PA,
PAB除PA as 品类1推品类2的置信度_PAB_PA,
PAB除PA除PB as 提升度__PAB_PA_PB
from PAPB_PA_PB 
order by PAB除PA除PB desc;

select * from lift;
# 求相关性分析的过程中仍然是对支持度的求解
# 只是要对单品独立的购买行为也要求解
# 看看这个支持度起的作用是促进购买概率上升还是下降

# 当相关性是1时，P（B|A）与P（B）相等，也就是说在全样本空间内，
# B发生的概率和在发生A的情况下发生B的概率是一样的，那么它们就是毫无关系。
# 物品品类1_A  物品品类2_B  物品品类1的单品类的支持度_PA  品类1推品类2的置信度_PAB_PA  提升度__PAB_PA_PB
#   酸奶			巧克力糖			0.6000						0.66666667					1.111111111111

# 当相关性小于1时，P（B|A）小于P（B），也就是说在全样本空间内，
# 发生A的情况下发生B的概率要比单独统计B发生的概率要小，那么B和A是负相关的。换句话说，A的发生抑制了B的发生。
# 物品品类1_A  物品品类2_B  物品品类1的单品类的支持度_PA  品类1推品类2的置信度_PAB_PA  提升度__PAB_PA_PB
#   香烟			油炸薯片				0.8000					0.25000000					0.312500000000

# 当相关性大于1时，P（B|A）大于P（B），也就是说在全样本空间内，
# 发生A的情况下发生B的概率要比单独统计B发生的概率要大，那么B和A是正相关的。换句话说，A的发生促进了B的发生。
# 物品品类1_A  物品品类2_B  物品品类1的单品类的支持度_PA  品类1推品类2的置信度_PAB_PA  提升度__PAB_PA_PB
# 	瓜子			啤酒				0.2000						1.00000000					5.000000000000
# 	一次性酒杯	啤酒				0.2000						1.00000000					5.000000000000