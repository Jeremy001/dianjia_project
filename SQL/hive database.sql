/*
���ݣ�dianjia database
���ڣ�2018-03-28
���ߣ���ɼ

��ʶ��
������������:
���ݳ�ȡextract:e_ods
������ϴtransform:ҵ���dwd_ ���Ա�dim_
���ݼӹ�transform:dw_
���ݼ���transform:dm_

���ݱ��з����������ֶ�p_day,string,ʾ����20180327����ѯʱ���Ϸ���
*/


<<<<<<< HEAD
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
=======
-- �޹� 10094
SELECT *
FROM dim_brand_info_dt AS t1
WHERE t1.p_day = '20180819'
  AND t1.brand_id = '10094'
;


SELECT t1.*
FROM dianjia_bdc.ods_brand_storage_kpi_target_dt AS t1
WHERE t1.p_day = '20180819'
  AND t1.brand_id = '10094'
  AND t1.target_type = 0	-- 0-��Ŀ�ꣻ1-��Ŀ��
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


-- ���ٸ��ŵ��8��Ŀ������ˣ�
-- ���ָ�����Ŀ���Ʒ�Ʒǳ��٣�ֻ��5���õ���Ȩ��ָ��ֽ���Ŀ�ꣻ
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

-- �ж���Ʒ�ƺ��ŵ��������ǵ��ŵ�ҵ�������ܣ�
-- ���������Ŀ�꣬��Ϊʹ���˸ù��ܣ�
WITH
t1 AS 
(SELECT t1.brand_id
	   ,t1.storage_id
	   ,t1.storage_name
FROM dianjia_bdc.dim_storage_info_dt AS t1
WHERE t1.p_day = '20180819'
  AND t1.storage_type = 1	-- 1-�����ŵ꣬2-���²ֿ⣬3-���ϲֿ⣬4-�����ŵ�
  AND t1.storage_status = 1		-- 1-�����ã�4-ͣ�ã�9-�ѹر�
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
  AND t1.storage_type = 1	-- 1-�����ŵ꣬2-���²ֿ⣬3-���ϲֿ⣬4-�����ŵ�
  AND t1.storage_status = 1		-- 1-�����ã�4-ͣ�ã�9-�ѹر�
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
  AND t1.storage_type = 1	-- 1-�����ŵ꣬2-���²ֿ⣬3-���ϲֿ⣬4-�����ŵ�
  AND t1.storage_status = 1		-- 1-�����ã�4-ͣ�ã�9-�ѹر�
  AND t1.brand_id NOT IN ('1', '10010', '10127')
  AND t2.p_day = '20180819'
  AND t2.target_type = 0
  AND t2.target_time = '2018-08'
  AND t2.brand_id NOT IN ('1', '10010', '10127')
) AS t1
;

-- �����Ϣ��
SELECT t1.*
FROM dianjia_bdc.dim_storage_info_dt AS t1
WHERE t1.p_day = '20180819'
  AND t1.brand_id = '10091'
  AND t1.storage_type = 1	-- 1-�����ŵ꣬2-���²ֿ⣬3-���ϲֿ⣬4-�����ŵ�
  AND t1.storage_status = 1		-- 1-�����ã�4-ͣ�ã�9-�ѹر�
LIMIT 50;


-- ��ֵĸ���״̬
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

-- ��Ʒ��ӵ�ж��ټ������ŵꣿ
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


-- ҵ��Ŀ��ĵ�����־
-- ����������(query.dianjia.io) �в�ѯ����ѯ�ŵ�Ŀ�굼����־
SELECT t1.* 
FROM amg_brand_target_opt_log AS t1
WHERE opt_type = 1
  AND target_type = 0    -- 0-��Ŀ�ꣻ1-��Ŀ��
  AND target_time = '2018-08'   -- ������·ݻ�������
  AND brand_id NOT IN (10010, 10127)
LIMIT 10;

SELECT DISTINCT t1.brand_id
FROM amg_brand_target_opt_log AS t1
WHERE t1.opt_type = 1
  AND t1.target_type = 0    -- 0-��Ŀ�ꣻ1-��Ŀ��
  AND t1.target_time = '2018-08'   -- ������·ݻ�������
  AND t1.brand_id <> 10010

-- ��ѯ����Ʒ�Ʋ�����ҵ��Ŀ������
SELECT t1.brand_id
	  ,SUM(t1.input_count) AS input_count
FROM
(SELECT t1.brand_id
	  	,COUNT(*) AS input_count
FROM amg_brand_target_opt_log AS t1
WHERE t1.opt_type = 1
  AND t1.target_type = 0    -- 0-��Ŀ�ꣻ1-��Ŀ��
  AND t1.target_time = '2018-08'   -- ������·ݻ�������
  AND t1.brand_id <> 10010
GROUP BY t1.brand_id
) AS t1
GROUP BY t1.brand_id
ORDER BY input_count DESC
;


-- ����Ʒ�ƵĻ�Ա��Ϣ�������dwd_crm_custom_basic_info_dt����
-- ÿ��һ������

-- ��ѯǰ10����Ա����Ϣ
SELECT t1.*
FROM dwd_crm_custom_basic_info_dt AS t1
WHERE p_day = '20180719'
LIMIT 10;

-- ��ȥ�أ���ѯ��Ա����[171W]
SELECT COUNT(t1.custom_id) AS custom_n
FROM dwd_crm_custom_basic_info_dt AS t1
WHERE p_day = '20180719'
;

-- ȥ�أ���ѯ��Ա����[127W]
-- �����ֻ�����ȥ��
SELECT COUNT(DISTINCT t1.mobile_phone) AS custom_n
FROM dwd_crm_custom_basic_info_dt AS t1
WHERE p_day = '20180719'
;

-- ����Ʒ�ƻ�Ա����
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

-- һ����Ա��ͬʱע�ᵽ���ٸ�Ʒ�ƣ�
-- ��Ʒ�ƵĻ�Ա�غ϶��ж�ߣ�[��Ϣ����]
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

-- �Ƚ����ʺ��޹��Ļ�Ա�غ϶�
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

-- Ʒ��ά�ȱ���������Ʒ��
>>>>>>> c067c4c78d3936d2a9a12d5523589ca4ab79f740
SELECT *
FROM dim_brand_child_relation_dt AS t1
LIMIT 10;
-- ����Ʒ�ƺϼ�879��������������ʺ�
SELECT COUNT(*)
FROM dim_brand_child_relation_dt AS t1
;


--Ʒ�Ʋ��� dim_brand_ranges_dt
-- ranges
-- ranges_name


-- �������ڵ�ά�ȱ� dim_date
SELECT *
FROM dim_date AS t1
LIMIT 10;

SELECT COUNT(*)
FROM dim_date AS t1
;

-- ��С���� 2016-01-01
SELECT MIN(t1.date_id)
FROM dim_date AS t1
;

-- ������� 2028-12-31
SELECT MAX(t1.date_id)
FROM dim_date AS t1
;


-- sku��Ϣ�� dim_good_sku_base_info_dt
SELECT t1.*
FROM dim_good_sku_base_info_dt AS t1
WHERE t1.p_day = '20180327'
LIMIT 10;


-- spu��Ϣ�� dim_good_spu_base_info_dt_v2 hue
-- ע�����string���͵��ֶΣ�Ϊ��ʱ��ʵ����=''
-- ��ˣ�ѡ��Ϊ��ʱӦд��: != ''
-- spu_status�ĺ���
SELECT t1.*
FROM dim_good_spu_base_info_dt_v2 AS t1
WHERE t1.p_day = '20180327'
	AND t1.section != ''
LIMIT 10;

-- spu��Ϣ�� dim_good_spu_base_info_dt ��������
SELECT t1.*
FROM dim_good_spu_base_info_dt AS t1
WHERE t1.p_day = '20180327'
LIMIT 10;
-- ��Ŀ���� 230 ��ô����Ŀ������һ����Ŀ��
SELECT COUNT(DISTINCT t1.cat_name) AS cat_count
FROM dim_good_spu_base_info_dt AS t1
WHERE t1.p_day = '20180327'
;
-- ����Ŀ��spu��TOP30
-- ����������ORDER BY�����LIMIT
-- ��Ŀ�ṹ�о������Ǻ������������˽�һ�£�����ҵ���ص�ҵ���ĵ�
SELECT t1.cat_name
		,COUNT(t1.brand_spu_id) AS spu_count
FROM dim_good_spu_base_info_dt AS t1
WHERE t1.p_day = '20180327'
GROUP BY t1.cat_name
ORDER BY spu_count DESC
LIMIT 30
;
-- spu״̬ spu_status 1��2��3�ֱ�ʲô���壿
SELECT t1.spu_status
		,COUNT(t1.brand_spu_id) AS spu_count
FROM dim_good_spu_base_info_dt AS t1
WHERE t1.p_day = '20180327'
GROUP BY t1.spu_status
;
-- spuĿǰ����������ά�ȣ�
-- Ʒ��brand����Ʒ��child_brand����Ŀcat_name���༶��Ŀcat_id1��2��3��4��5������С��big_cat��middle_cat��small_cat
-- ���year������season������ranges������ʱ��marker_time����������market_day
-- ϵ��series������Ʒ��section�������style�� �������ֱ�����ζ���ģ��ر�����Ʒ����ʲô���壿
-- ���Ƽ�suggest_price�����ۼ�sale_price �������Ӽ۸���ֶΣ���ͬƷ�ơ�Ʒ�࣬��ͬ�Ļ��ֱ�׼
-- ����fabric_category�����ϳɷ�main_fabric
SELECT t1.*
FROM dim_good_spu_base_info_dt AS t1
WHERE t1.p_day = '20180327'
	AND t1.fabric_category != ''
LIMIT 10;


-- ������Ϣ�� dim_guide_info_dt
SELECT t1.*
FROM dim_guide_info_dt AS t1
LIMIT 10;


-- �����Ϣ�� dim_storage_info_dt
-- storage_status 0,1,4,9 �ֱ�ʲô���壿
-- storage_type 0,1,2,3,4 �ֱ�ʲô���壿
-- channel_type 0������,1������,2ֱӪ,3,5,6?
-- storage_group��أ�������ˣ��������ŵ��湲��
-- storage_grade
-- start_business_date:��ҵ����
-- circulation_flag �Ƿ������ת��ʲô���壿
-- acreage:������������Ŀǰֻ��һ������������������µ���������¼�������ŵ�ֿ�������ŵ�ɳ������
-- pay_type:��������,����������������
-- property_type:��ҵ���ͣ�����Ϊ�գ��������£�MALL���ٻ������������ֵ�

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
-- ��ͬƷ���в�ͬ�ķּ���׼
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





-- ��֪�������; dm_brand_dc_guide_member_dm
SELECT t1.*
FROM dm_brand_dc_guide_member_dm AS t1
WHERE t1.p_day = '20180327'
ORDER BY t1.new_member_count DESC
LIMIT 10;


-- �ŵ�ÿ������

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


-- ���۶�ĵ�λ�Ƿ֣������Ҫͳ�Ƶ�Ԫ����Ҫ����100��
SELECT t1.*
FROM dm_storage_sale_dm AS t1
WHERE t1.brand_id = '10094'
	AND t1.p_day = '20180727'
LIMIT 20
;

-- �Ϻ��޹��������ڵ����ۼ������󣬳��ֽϴ�ĸ�������2018-4-23��-2017��������һ����Ʒ"����"�����ۼ���Ϊ����
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

-- dm_storage_sale_dm:ÿ�����ǵ��������
-- dm_storage_sale_dt:ÿ�����ǽ���������ۼ����ݣ�


-- �ɱ���
SELECT t1.*
FROM dim_good_sku_base_info_dt AS t1
WHERE t1.brand_id = '10094'
	AND t1.p_day = '20180729'
	AND t1.cost_price > 0
ORDER BY brand_sku_id
LIMIT 100
;


-- �ŵ���Ϣ��
-- dim_storage_info_dt
-- stotage_status: 1-���ã�4-ͣ�ã�9-�ر�
SELECT t1.*
FROM dim_storage_info_dt AS t1
WHERE t1.brand_id = '10094'
	AND p_day = '20180729'
ORDER BY t1.storage_code
LIMIT 105
;



-- ÿ��ɽ����
-- �������ܴ󣬲�����ʵ���ݰɣ�
SELECT t1.p_day
		,SUM(t1.total_sale_money) AS total_sale_money
FROM dm_storage_day_report AS t1
GROUP BY t1.p_day
ORDER BY t1.p_day
LIMIT 100
;
-- ÿ��ȱ����
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



-- �ͻ�������Ϣ�� dm_custom_basic_info_dt
SELECT t1.*
FROM dm_custom_basic_info_dt AS t1
WHERE t1.p_day = '20180327'
LIMIT 10
;


-- ��������spu�� dm_spu_order_join_sale_dm
-- һ��spu��ͬһ�������У���������Щspu��������
SELECT t1.*
FROM dm_spu_order_join_sale_dm AS t1
WHERE t1.p_day = '20180327'
LIMIT 10
;


-- ����ĿȨ��ָ�� ===================================

-- 1.2015-2018��������ʷ��������
-- hive
WITH 
t1 AS
(SELECT t1.storage_id
<<<<<<< HEAD
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
=======
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
>>>>>>> c067c4c78d3936d2a9a12d5523589ca4ab79f740
GROUP BY t1.storage_id
				,t2.storage_name
				,t2.province_name
				,t2.city_name
				,t2.storage_group_name
				,t2.storage_level1_area_name
				,t1.p_day
),
-- ����
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
<<<<<<< HEAD
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
=======
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
>>>>>>> c067c4c78d3936d2a9a12d5523589ca4ab79f740
ORDER BY t1.storage_id
    ,t1.p_day
--LIMIT 100
;


-- ����
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



-- ����ĿȨ��ָ�� ===================================







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

