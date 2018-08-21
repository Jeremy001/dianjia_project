/*
内容：dianjia database
日期：2018-03-28
作者：云杉

常识：
数据生产流程:
数据抽取extract:e_ods
数据清洗transform:业务表dwd_ 属性表dim_
数据加工transform:dw_
数据集市transform:dm_

数据表都有分区，分区字段p_day,string,示例：20180327，查询时带上分区
*/


-- 棉购 10094
SELECT *
FROM dim_brand_info_dt AS t1
WHERE t1.p_day = '20180819'
  AND t1.brand_id = '10094'
;


SELECT t1.*
FROM dianjia_bdc.ods_brand_storage_kpi_target_dt AS t1
WHERE t1.p_day = '20180819'
  AND t1.brand_id = '10094'
  AND t1.target_type = 0	-- 0-月目标；1-日目标
LIMIT 10;




SELECT t1.*
FROM dianjia_bdc.ods_brand_storage_kpi_target_dt AS t1
WHERE t1.p_day = '20180819'
  AND t1.brand_id = '10094'
  AND t1.target_type = 0
  AND t1.storage_id = '220241367157178368'
ORDER BY target_time
LIMIT 50
;


-- 多少个门店的8月目标更新了？
-- 发现更新了目标的品牌非常少，只有5家用到了权重指标分解月目标；
SELECT (CASE WHEN t1.last_modify_time >= '2018-08-15' THEN '1' ELSE 0 END) AS is_online_update
		,COUNT(DISTINCT t1.brand_id) AS brand_count
		,COUNT(DISTINCT t1.storage_id) AS storage_count
FROM dianjia_bdc.ods_brand_storage_kpi_target_dt AS t1
WHERE t1.p_day = '20180819'
  AND t1.target_type = 0
  AND t1.target_time = '2018-08'
  AND t1.brand_id NOT IN ('1', '10010', '10127')
GROUP BY (CASE WHEN t1.last_modify_time >= '2018-08-15' THEN '1' ELSE 0 END)
;

-- 有多少品牌和门店用了我们的门店业绩管理功能？
-- 如果设置了目标，认为使用了该功能；
WITH
t1 AS 
(SELECT t1.brand_id
	   ,t1.storage_id
	   ,t1.storage_name
FROM dianjia_bdc.dim_storage_info_dt AS t1
WHERE t1.p_day = '20180819'
  AND t1.storage_type = 1	-- 1-线下门店，2-线下仓库，3-线上仓库，4-线上门店
  AND t1.storage_status = 1		-- 1-已启用，4-停用，9-已关闭
  AND t1.brand_id = '10091'
  --AND t1.brand_id NOT IN ('1', '10010', '10127')
),
t2 AS 
(SELECT t2.storage_id
	   ,t2.target_time
	   ,t2.target_kpi_value
	   ,t2.last_modify_time
FROM dianjia_bdc.ods_brand_storage_kpi_target_dt AS t2
WHERE t2.p_day = '20180819'
  AND t2.target_type = 0
  AND t2.target_time = '2018-08'
  AND t2.brand_id = '10091'
  --AND t2.brand_id NOT IN ('1', '10010', '10127')
)

SELECT t1.brand_id
	   ,t1.storage_id
	   ,t1.storage_name
	   ,t2.target_time
	   ,t2.target_kpi_value
	   ,t2.last_modify_time
FROM t1
LEFT JOIN t2
	   ON t1.storage_id = t2.storage_id
;



SELECT t1.brand_id
	  ,t1.company_name
	  ,SUM(CASE WHEN t1.target_kpi_value IS NULL THEN 1 ELSE 0 END) AS is_null_n
	  ,SUM(CASE WHEN t1.target_kpi_value = 0 THEN 1 ELSE 0 END) AS is_0_n
	  ,SUM(CASE WHEN t1.target_kpi_value > 0 THEN 1 ELSE 0 END) AS shezhi_n
	  ,COUNT(*) AS total_n
FROM
(SELECT t1.brand_id
	   ,t3.company_name
	   ,t1.storage_id
	   ,t1.storage_name
	   ,t2.target_time
	   ,t2.target_kpi_value
	   ,t2.last_modify_time
FROM
(SELECT t1.brand_id
	   ,t1.storage_id
	   ,t1.storage_name
FROM dianjia_bdc.dim_storage_info_dt AS t1
WHERE t1.p_day = '20180819'
  AND t1.storage_type = 1	-- 1-线下门店，2-线下仓库，3-线上仓库，4-线上门店
  AND t1.storage_status = 1		-- 1-已启用，4-停用，9-已关闭
  --AND t1.brand_id = '10091'
  AND t1.brand_id NOT IN ('1', '10010', '10127')
) AS t1
LEFT JOIN
(SELECT t2.storage_id
	   ,t2.target_time
	   ,t2.target_kpi_value
	   ,t2.last_modify_time
FROM dianjia_bdc.ods_brand_storage_kpi_target_dt AS t2
WHERE t2.p_day = '20180819'
  AND t2.target_type = 0
  AND t2.target_time = '2018-08'
  --AND t2.brand_id = '10091'
  AND t2.brand_id NOT IN ('1', '10010', '10127')
) AS t2
ON t1.storage_id = t2.storage_id
LEFT JOIN 
(SELECT t3.brand_id
	   ,t3.company_name	
FROM dianjia_bdc.dim_brand_info_dt AS t3
WHERE t3.p_day = '20180819'
) AS t3
ON t1.brand_id = t3.brand_id
) AS t1
GROUP BY t1.brand_id
		,t1.company_name
ORDER BY total_n DESC
LIMIT 100
;




SELECT COUNT(*) AS count_n
FROM 
(SELECT t1.brand_id
	   ,t1.storage_id
	   ,t1.storage_name
	   ,t2.target_time
	   ,t2.target_kpi_value
	   ,t2.last_modify_time
FROM dianjia_bdc.dim_storage_info_dt AS t1
LEFT JOIN dianjia_bdc.ods_brand_storage_kpi_target_dt AS t2
	   ON t1.storage_id = t2.storage_id
WHERE t1.p_day = '20180819'
  AND t1.storage_type = 1	-- 1-线下门店，2-线下仓库，3-线上仓库，4-线上门店
  AND t1.storage_status = 1		-- 1-已启用，4-停用，9-已关闭
  AND t1.brand_id NOT IN ('1', '10010', '10127')
  AND t2.p_day = '20180819'
  AND t2.target_type = 0
  AND t2.target_time = '2018-08'
  AND t2.brand_id NOT IN ('1', '10010', '10127')
) AS t1
;

-- 店仓信息表
SELECT t1.*
FROM dianjia_bdc.dim_storage_info_dt AS t1
WHERE t1.p_day = '20180819'
  AND t1.brand_id = '10091'
  AND t1.storage_type = 1	-- 1-线下门店，2-线下仓库，3-线上仓库，4-线上门店
  AND t1.storage_status = 1		-- 1-已启用，4-停用，9-已关闭
LIMIT 50;


-- 店仓的各种状态
SELECT t1.storage_status
		,t1.storage_type
		,COUNT(storage_id) AS storage_count
FROM dianjia_bdc.dim_storage_info_dt AS t1
WHERE t1.p_day = '20180819'
  AND t1.storage_type = 1
  AND t1.brand_id NOT IN ('1', '10010', '10127')
GROUP BY t1.storage_status
		,t1.storage_type
ORDER BY t1.storage_status
		,t1.storage_type
LIMIT 100;

-- 各品牌拥有多少家线下门店？
SELECT t1.brand_id
		,t2.brand_name
		,COUNT(t1.storage_id) AS storage_count
FROM dianjia_bdc.dim_storage_info_dt AS t1
LEFT JOIN dianjia_bdc.dim_brand_info_dt AS t2
	   ON t1.brand_id = t2.brand_id
WHERE t1.p_day = '20180819'
  AND t1.storage_type = 1
  AND t1.storage_status = 1
  AND t1.brand_id NOT IN ('1', '10010', '10127')
GROUP BY t1.brand_id
		,t2.brand_name
ORDER BY storage_count DESC
LIMIT 100;


-- 业绩目标的导入日志
-- 在配置中心(query.dianjia.io) 中查询，查询门店目标导入日志
SELECT t1.* 
FROM amg_brand_target_opt_log AS t1
WHERE opt_type = 1
  AND target_type = 0    -- 0-月目标；1-日目标
  AND target_time = '2018-08'   -- 导入的月份或者日期
  AND brand_id NOT IN (10010, 10127)
LIMIT 10;

SELECT DISTINCT t1.brand_id
FROM amg_brand_target_opt_log AS t1
WHERE t1.opt_type = 1
  AND t1.target_type = 0    -- 0-月目标；1-日目标
  AND t1.target_time = '2018-08'   -- 导入的月份或者日期
  AND t1.brand_id <> 10010

-- 查询多少品牌操作了业绩目标设置
SELECT t1.brand_id
	  ,SUM(t1.input_count) AS input_count
FROM
(SELECT t1.brand_id
	  	,COUNT(*) AS input_count
FROM amg_brand_target_opt_log AS t1
WHERE t1.opt_type = 1
  AND t1.target_type = 0    -- 0-月目标；1-日目标
  AND t1.target_time = '2018-08'   -- 导入的月份或者日期
  AND t1.brand_id <> 10010
GROUP BY t1.brand_id
) AS t1
GROUP BY t1.brand_id
ORDER BY input_count DESC
;


-- 所有品牌的会员信息都存放在dwd_crm_custom_basic_info_dt表中
-- 每天一个快照

-- 查询前10个会员的信息
SELECT t1.*
FROM dwd_crm_custom_basic_info_dt AS t1
WHERE p_day = '20180719'
LIMIT 10;

-- 不去重，查询会员数量[171W]
SELECT COUNT(t1.custom_id) AS custom_n
FROM dwd_crm_custom_basic_info_dt AS t1
WHERE p_day = '20180719'
;

-- 去重，查询会员数量[127W]
-- 根据手机号码去重
SELECT COUNT(DISTINCT t1.mobile_phone) AS custom_n
FROM dwd_crm_custom_basic_info_dt AS t1
WHERE p_day = '20180719'
;

-- 各个品牌会员数量
SELECT t1.brand_id
				,t1.brand_name
				,COUNT(t1.custom_id) AS custom_n
FROM dwd_crm_custom_basic_info_dt AS t1
WHERE p_day = '20180719'
GROUP BY t1.brand_id
				,t1.brand_name
ORDER BY custom_n DESC 
LIMIT 100
;

-- 一个会员会同时注册到多少个品牌？
-- 各品牌的会员重合度有多高？[信息报告]
SELECT brand_n
				,COUNT(mobile_phone) AS custom_n
FROM 
(SELECT t1.mobile_phone
				,COUNT(t1.brand_id) AS brand_n
FROM dwd_crm_custom_basic_info_dt AS t1
WHERE p_day = '20180719'
GROUP BY t1.mobile_phone
) AS t2
GROUP BY brand_n
;

-- 比较三彩和棉购的会员重合度
SELECT brand_n
				,COUNT(mobile_phone) AS custom_n
FROM 
(SELECT t1.mobile_phone
				,COUNT(t1.brand_id) AS brand_n
FROM dwd_crm_custom_basic_info_dt AS t1
WHERE t1.p_day = '20180719'
	AND t1.brand_id IN ('10018', '10094')
GROUP BY t1.mobile_phone
) AS t2
GROUP BY brand_n
; 

-- 品牌维度表，包含父子品牌
SELECT *
FROM dim_brand_child_relation_dt AS t1
LIMIT 10;
-- 父子品牌合计879，里面包括测试帐号
SELECT COUNT(*)
FROM dim_brand_child_relation_dt AS t1
;


--品牌波段 dim_brand_ranges_dt
-- ranges
-- ranges_name


-- 关于日期的维度表 dim_date
SELECT *
FROM dim_date AS t1
LIMIT 10;

SELECT COUNT(*)
FROM dim_date AS t1
;

-- 最小日期 2016-01-01
SELECT MIN(t1.date_id)
FROM dim_date AS t1
;

-- 最大日期 2028-12-31
SELECT MAX(t1.date_id)
FROM dim_date AS t1
;


-- sku信息表 dim_good_sku_base_info_dt
SELECT t1.*
FROM dim_good_sku_base_info_dt AS t1
WHERE t1.p_day = '20180327'
LIMIT 10;


-- spu信息表 dim_good_spu_base_info_dt_v2 hue
-- 注意表中string类型的字段，为空时，实际上=''
-- 因此，选择不为空时应写成: != ''
-- spu_status的含义
SELECT t1.*
FROM dim_good_spu_base_info_dt_v2 AS t1
WHERE t1.p_day = '20180327'
	AND t1.section != ''
LIMIT 10;

-- spu信息表 dim_good_spu_base_info_dt 阿里数加
SELECT t1.*
FROM dim_good_spu_base_info_dt AS t1
WHERE t1.p_day = '20180327'
LIMIT 10;
-- 类目数量 230 这么多类目？都是一级类目？
SELECT COUNT(DISTINCT t1.cat_name) AS cat_count
FROM dim_good_spu_base_info_dt AS t1
WHERE t1.p_day = '20180327'
;
-- 各类目的spu数TOP30
-- 阿里数加中ORDER BY必须跟LIMIT
-- 类目结构感觉还不是很清晰，后续了解一下，最好找到相关的业务文档
SELECT t1.cat_name
		,COUNT(t1.brand_spu_id) AS spu_count
FROM dim_good_spu_base_info_dt AS t1
WHERE t1.p_day = '20180327'
GROUP BY t1.cat_name
ORDER BY spu_count DESC
LIMIT 30
;
-- spu状态 spu_status 1、2、3分别什么含义？
SELECT t1.spu_status
		,COUNT(t1.brand_spu_id) AS spu_count
FROM dim_good_spu_base_info_dt AS t1
WHERE t1.p_day = '20180327'
GROUP BY t1.spu_status
;
-- spu目前有以下属性维度：
-- 品牌brand、子品牌child_brand、类目cat_name、多级类目cat_id1、2、3、4、5、大中小类big_cat、middle_cat、small_cat
-- 年份year、季节season、波段ranges、上市时间marker_time、上市天数market_day
-- 系列series？、商品层section？、风格style？ 这三个分别是如何定义的？特别是商品层是什么含义？
-- 吊牌价suggest_price、销售价sale_price 可以增加价格带字段，不同品牌、品类，不同的划分标准
-- 面料fabric_category、面料成分main_fabric
SELECT t1.*
FROM dim_good_spu_base_info_dt AS t1
WHERE t1.p_day = '20180327'
	AND t1.fabric_category != ''
LIMIT 10;


-- 导购信息表 dim_guide_info_dt
SELECT t1.*
FROM dim_guide_info_dt AS t1
LIMIT 10;


-- 店仓信息表 dim_storage_info_dt
-- storage_status 0,1,4,9 分别什么含义？
-- storage_type 0,1,2,3,4 分别什么含义？
-- channel_type 0代理商,1加盟商,2直营,3,5,6?
-- storage_group相关，店仓联盟，联盟内门店库存共享
-- storage_grade
-- start_business_date:开业日期
-- circulation_flag 是否参与流转，什么含义？
-- acreage:面积，看来店仓目前只有一个面积，建议区分以下的面积：试衣间面积、门店仓库面积、门店可陈列面积
-- pay_type:收银类型,自收银，非自收银
-- property_type:物业类型，多数为空，现有以下：MALL、百货、特卖场、街道

SELECT t1.*
FROM dim_storage_info_dt AS t1
WHERE t1.p_day = '20180327'
LIMIT 10
;
-- storage_status
SELECT t1.storage_status
		,COUNT(t1.storage_id) AS storage_count
FROM dim_storage_info_dt AS t1
WHERE t1.p_day = '20180327'
GROUP BY t1.storage_status
;
-- storage_type
SELECT t1.storage_type
		,COUNT(t1.storage_id) AS storage_count
FROM dim_storage_info_dt AS t1
WHERE t1.p_day = '20180327'
GROUP BY t1.storage_type
;
-- channel_type
SELECT t1.channel_type
		,COUNT(t1.storage_id) AS storage_count
FROM dim_storage_info_dt AS t1
WHERE t1.p_day = '20180327'
GROUP BY t1.channel_type
;
-- storage_grade_id,storage_grade_name
-- 不同品牌有不同的分级标准
SELECT t1.brand_id
		,t1.storage_grade_name
		,COUNT(t1.storage_id) AS storage_count
FROM dim_storage_info_dt AS t1
WHERE t1.p_day = '20180327'
GROUP BY t1.brand_id
		,t1.storage_grade_name
;
-- pay_type
SELECT t1.pay_type
		,COUNT(t1.storage_id) AS storage_count
FROM dim_storage_info_dt AS t1
WHERE t1.p_day = '20180327'
GROUP BY t1.pay_type
;
-- property_type
SELECT t1.property_type
		,COUNT(t1.storage_id) AS storage_count
FROM dim_storage_info_dt AS t1
WHERE t1.p_day = '20180327'
GROUP BY t1.property_type
;





-- 不知表具体用途 dm_brand_dc_guide_member_dm
SELECT t1.*
FROM dm_brand_dc_guide_member_dm AS t1
WHERE t1.p_day = '20180327'
ORDER BY t1.new_member_count DESC
LIMIT 10;


-- 门店每日销售

SELECT SUBSTR(t1.p_day, 1, 6) AS year_month
				,SUM(t1.total_sale_money_kpi) AS total_sale_money_kpi
FROM dm_storage_sale_dm AS t1
WHERE t1.brand_id = '10091'
	AND t1.p_day >= '20180101'
	AND t1.p_day <= '20180730'
GROUP BY SUBSTR(t1.p_day, 1, 6)
ORDER BY year_month
LIMIT 10
;


-- 销售额的单位是分，即如果要统计到元，需要除以100；
SELECT t1.*
FROM dm_storage_sale_dm AS t1
WHERE t1.brand_id = '10094'
	AND t1.p_day = '20180727'
LIMIT 20
;

-- 上海棉购部分日期的销售件数有误，出现较大的负数，如2018-4-23，-2017，发现有一个商品"定金"的销售件数为负；
SELECT t1.p_day
				,COUNT(DISTINCT t1.storage_id) AS store_num
				,SUM(t1.total_sale_count_kpi) AS sale_goods_num
				,SUM(t1.total_sale_money_kpi/100) AS sale_goods_amount
				,SUM(t1.total_sale_money_kpi/100)/COUNT(DISTINCT t1.storage_id) AS avg_sale_amount 
FROM dm_storage_sale_dm AS t1
WHERE t1.brand_id = '10094'
	AND t1.p_day >= '20180101'
GROUP BY t1.p_day
ORDER BY t1.p_day
LIMIT 300
;

-- dm_storage_sale_dm:每天存的是当天的数据
-- dm_storage_sale_dt:每天存的是截至该天的累计数据；


-- 成本价
SELECT t1.*
FROM dim_good_sku_base_info_dt AS t1
WHERE t1.brand_id = '10094'
	AND t1.p_day = '20180729'
	AND t1.cost_price > 0
ORDER BY brand_sku_id
LIMIT 100
;


-- 门店信息表
-- dim_storage_info_dt
-- stotage_status: 1-启用，4-停用，9-关闭
SELECT t1.*
FROM dim_storage_info_dt AS t1
WHERE t1.brand_id = '10094'
	AND p_day = '20180729'
ORDER BY t1.storage_code
LIMIT 105
;



-- 每天成交金额
-- 数据量很大，不是真实数据吧？
SELECT t1.p_day
		,SUM(t1.total_sale_money) AS total_sale_money
FROM dm_storage_day_report AS t1
GROUP BY t1.p_day
ORDER BY t1.p_day
LIMIT 100
;
-- 每天缺货率
SELECT t1.brand_id
				,t1.brand_name
				,t1.p_day
				,SUM(t1.total_sale_count_kpi) AS total_sale_count_kpi
				,SUM(t1.short_sale_count_kpi) AS short_sale_count_kpi
				,SUM(t1.short_sale_count_kpi)/SUM(t1.total_sale_count_kpi) AS short_sale_count_rate_kpi
FROM dm_storage_day_report AS t1
WHERE t1.p_day >= '20180101'
	AND t1.brand_id = '10091'
GROUP BY t1.brand_id
				,t1.brand_name
				,t1.p_day
ORDER BY t1.p_day
LIMIT 100
;



-- 客户基本信息表 dm_custom_basic_info_dt
SELECT t1.*
FROM dm_custom_basic_info_dt AS t1
WHERE t1.p_day = '20180327'
LIMIT 10
;


-- 关联销售spu表 dm_spu_order_join_sale_dm
-- 一个spu在同一个订单中，跟其他哪些spu关联购买
SELECT t1.*
FROM dm_spu_order_join_sale_dm AS t1
WHERE t1.p_day = '20180327'
LIMIT 10
;


-- 六丁目权重指标 ===================================

-- 1.2015-2018三年多的历史销售数据
-- hive
WITH 
t1 AS
(SELECT t1.storage_id
				,t2.storage_name
				,t2.province_name
				,t2.city_name
				,t2.storage_group_name
				,t2.storage_level1_area_name
				,t1.p_day
				,SUM(t1.total_sale_money_kpi/100) AS total_sale_money_kpi
FROM default.dm_storage_sale_dm AS t1
LEFT JOIN default.dim_storage_info_dt AS t2
			 ON t1.storage_id = t2.storage_id
WHERE t1.brand_id = 10091
	AND t1.p_day >= '20150101'
	AND t1.p_day <= '20180413'
GROUP BY t1.storage_id
				,t2.storage_name
				,t2.province_name
				,t2.city_name
				,t2.storage_group_name
				,t2.storage_level1_area_name
				,t1.p_day
),
-- 日期
t2 AS
(SELECT REGEXP_REPLACE(t1.date_id, '-', '') AS date_id
		,t1.calendar_month
		,t1.day_of_month
		,t1.day_of_week
		,t1.day_of_week_name
		,t1.holiday_mark
		,t1.holiday_name
FROM default.dim_date AS t1
)
SELECT t1.storage_id
				,t1.storage_name
				,t1.province_name
				,t1.city_name
				,t1.storage_group_name
				,t1.storage_level1_area_name
				,t1.p_day
		,t2.calendar_month
		,t2.day_of_month
		,t2.day_of_week
		,t2.day_of_week_name
		,t2.holiday_mark
		,t2.holiday_name
				,t1.total_sale_money_kpi
FROM t1
LEFT JOIN t2 
		 ON t1.p_day = t2.date_id
ORDER BY t1.storage_id
		,t1.p_day
--LIMIT 100
;


-- 日期
SELECT REGEXP_REPLACE(t1.date_id, '-', '') AS date_id
		,t1.calendar_month
		,t1.day_of_month
		,t1.day_of_week
		,t1.day_of_week_name
		,t1.holiday_mark
		,t1.holiday_name
FROM default.dim_date AS t1
WHERE t1.date_id >= '2016-01-01'
	AND t1.date_id <= '2018-12-31'
ORDER BY date_id
;



-- 六丁目权重指标 ===================================




