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
 


-- 查询多导购订单数
SELECT brand_id
,is_multi_guides
,COUNT(DISTINCT order_id) AS total_ord
FROM dw_order_basic_info_ds
WHERE p_day <= '20181121'
AND p_day >= '20181115'
AND order_type = '1'
GROUP BY brand_id
,is_multi_guides
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


-- 销售日报数据 dm_storage_day_report
-- 存放在阿里数加
SELECT t1.*
FROM dm_storage_day_report AS t1
WHERE t1.p_day = '20180327'
LIMIT 20
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
FROM dm_storage_sale_dm AS t1
LEFT JOIN dim_storage_info_dt AS t2
       ON t1.storage_id = t2.storage_id
WHERE t1.brand_id = 10091
  AND t1.p_day >= '20150101'
  AND t1.p_day <= '20180518'
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
FROM dim_date AS t1
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







-- 六町目销售预测 ====================================
-- 1. 权重指数拆分
-- 2. 天气

WITH 
-- 销售额
t1 AS
(SELECT t1.storage_id 
    ,t2.storage_name
    ,t2.province_name
    ,t2.city_name
    ,t1.p_day
    ,SUM(t1.total_sale_money_kpi/100) AS total_sale_money_kpi
FROM dm_storage_sale_dm AS t1
LEFT JOIN dim_storage_info_dt AS t2
       ON t1.storage_id = t2.storage_id
WHERE t1.brand_id = 10091
  AND t1.p_day >= '20160101'
  AND t1.p_day <= '20180518'
GROUP BY t1.storage_id
    ,t2.storage_name
    ,t2.province_name
    ,t2.city_name
    ,t1.p_day
),
-- 日期，星期和节假日标记
t2 AS
(SELECT REGEXP_REPLACE(t1.date_id, '-', '') AS date_id
    ,t1.date_id AS date_id2
    ,t1.day_of_week
    ,t1.day_of_week_name
    ,t1.holiday_mark
    ,t1.holiday_name
FROM dim_date AS t1
)
-- 汇总，得到
SELECT t2.date_id2 AS sale_date
    ,t1.province_name
    ,t1.city_name
    ,t1.storage_id
    ,t1.storage_name
    ,t2.day_of_week
    ,t2.day_of_week_name
    ,t2.holiday_mark
    ,t2.holiday_name
    ,t1.total_sale_money_kpi
FROM t1
LEFT JOIN t2 
       ON t1.p_day = t2.date_id
;


















SELECT p_day, 'v1' AS tt
  , COALESCE(SUM(sale_count_refund), 0) AS refund_amount
  , COALESCE(SUM(sale_money_refund), 0) AS refund_money
  , COALESCE(SUM(ord_count_refund), 0) AS ord_count_refund
  , COALESCE(SUM(spot_sale_money), 0) AS spot_sale_money_refund
  , COALESCE(SUM(short_sale_money), 0) AS short_sale_money_refund
  , COALESCE(SUM(spot_sale_count), 0) AS spot_sale_count_refund
  , COALESCE(SUM(short_sale_count), 0) AS short_sale_count_refund
FROM dw_order_refund_basic_info_1d
WHERE p_day >= '20160601'
  AND p_day <= '20161231'
GROUP BY p_day;

SELECT p_day, 'v2' AS tt
  , COALESCE(SUM(total_sale_count_refund), 0) AS refund_amount
  , COALESCE(SUM(total_sale_money_refund), 0) AS refund_money
  , COALESCE(SUM(total_ord_count_refund), 0) AS ord_count_refund
  , COALESCE(SUM(spot_sale_money_refund), 0) AS spot_sale_money_refund
  , COALESCE(SUM(short_sale_money_refund), 0) AS short_sale_money_refund
  , COALESCE(SUM(spot_sale_count_refund), 0) AS spot_sale_count_refund
  , COALESCE(SUM(short_sale_count_refund), 0) AS short_sale_count_refund
FROM dw_order_refund_basic_info_1d_v2
WHERE p_day >= '20160601'
  AND p_day <= '20161231'
GROUP BY p_day;

