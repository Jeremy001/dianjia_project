/*
ÄÚÈİ£ºdianjia database
ÈÕÆÚ£º2018-03-28
×÷Õß£ºÔÆÉ¼

³£Ê¶£º
Êı¾İÉú²úÁ÷³Ì:
Êı¾İ³éÈ¡extract:e_ods
Êı¾İÇåÏ´transform:ÒµÎñ±ídwd_ ÊôĞÔ±ídim_
Êı¾İ¼Ó¹¤transform:dw_
Êı¾İ¼¯ÊĞtransform:dm_

Êı¾İ±í¶¼ÓĞ·ÖÇø£¬·ÖÇø×Ö¶Îp_day,string,Ê¾Àı£º20180327£¬²éÑ¯Ê±´øÉÏ·ÖÇø
*/


<<<<<<< HEAD
-- æŸ¥è¯¢å¤šå¯¼è´­è®¢å•æ•°
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



-- å“ç‰Œç»´åº¦è¡¨ï¼ŒåŒ…å«çˆ¶å­å“ç‰Œ
=======
-- ÃŞ¹º 10094
SELECT *
FROM dim_brand_info_dt AS t1
WHERE t1.p_day = '20180819'
  AND t1.brand_id = '10094'
;


SELECT t1.*
FROM dianjia_bdc.ods_brand_storage_kpi_target_dt AS t1
WHERE t1.p_day = '20180819'
  AND t1.brand_id = '10094'
  AND t1.target_type = 0	-- 0-ÔÂÄ¿±ê£»1-ÈÕÄ¿±ê
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


-- ¶àÉÙ¸öÃÅµêµÄ8ÔÂÄ¿±ê¸üĞÂÁË£¿
-- ·¢ÏÖ¸üĞÂÁËÄ¿±êµÄÆ·ÅÆ·Ç³£ÉÙ£¬Ö»ÓĞ5¼ÒÓÃµ½ÁËÈ¨ÖØÖ¸±ê·Ö½âÔÂÄ¿±ê£»
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

-- ÓĞ¶àÉÙÆ·ÅÆºÍÃÅµêÓÃÁËÎÒÃÇµÄÃÅµêÒµ¼¨¹ÜÀí¹¦ÄÜ£¿
-- Èç¹ûÉèÖÃÁËÄ¿±ê£¬ÈÏÎªÊ¹ÓÃÁË¸Ã¹¦ÄÜ£»
WITH
t1 AS 
(SELECT t1.brand_id
	   ,t1.storage_id
	   ,t1.storage_name
FROM dianjia_bdc.dim_storage_info_dt AS t1
WHERE t1.p_day = '20180819'
  AND t1.storage_type = 1	-- 1-ÏßÏÂÃÅµê£¬2-ÏßÏÂ²Ö¿â£¬3-ÏßÉÏ²Ö¿â£¬4-ÏßÉÏÃÅµê
  AND t1.storage_status = 1		-- 1-ÒÑÆôÓÃ£¬4-Í£ÓÃ£¬9-ÒÑ¹Ø±Õ
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
  AND t1.storage_type = 1	-- 1-ÏßÏÂÃÅµê£¬2-ÏßÏÂ²Ö¿â£¬3-ÏßÉÏ²Ö¿â£¬4-ÏßÉÏÃÅµê
  AND t1.storage_status = 1		-- 1-ÒÑÆôÓÃ£¬4-Í£ÓÃ£¬9-ÒÑ¹Ø±Õ
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
  AND t1.storage_type = 1	-- 1-ÏßÏÂÃÅµê£¬2-ÏßÏÂ²Ö¿â£¬3-ÏßÉÏ²Ö¿â£¬4-ÏßÉÏÃÅµê
  AND t1.storage_status = 1		-- 1-ÒÑÆôÓÃ£¬4-Í£ÓÃ£¬9-ÒÑ¹Ø±Õ
  AND t1.brand_id NOT IN ('1', '10010', '10127')
  AND t2.p_day = '20180819'
  AND t2.target_type = 0
  AND t2.target_time = '2018-08'
  AND t2.brand_id NOT IN ('1', '10010', '10127')
) AS t1
;

-- µê²ÖĞÅÏ¢±í
SELECT t1.*
FROM dianjia_bdc.dim_storage_info_dt AS t1
WHERE t1.p_day = '20180819'
  AND t1.brand_id = '10091'
  AND t1.storage_type = 1	-- 1-ÏßÏÂÃÅµê£¬2-ÏßÏÂ²Ö¿â£¬3-ÏßÉÏ²Ö¿â£¬4-ÏßÉÏÃÅµê
  AND t1.storage_status = 1		-- 1-ÒÑÆôÓÃ£¬4-Í£ÓÃ£¬9-ÒÑ¹Ø±Õ
LIMIT 50;


-- µê²ÖµÄ¸÷ÖÖ×´Ì¬
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

-- ¸÷Æ·ÅÆÓµÓĞ¶àÉÙ¼ÒÏßÏÂÃÅµê£¿
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


-- Òµ¼¨Ä¿±êµÄµ¼ÈëÈÕÖ¾
-- ÔÚÅäÖÃÖĞĞÄ(query.dianjia.io) ÖĞ²éÑ¯£¬²éÑ¯ÃÅµêÄ¿±êµ¼ÈëÈÕÖ¾
SELECT t1.* 
FROM amg_brand_target_opt_log AS t1
WHERE opt_type = 1
  AND target_type = 0    -- 0-ÔÂÄ¿±ê£»1-ÈÕÄ¿±ê
  AND target_time = '2018-08'   -- µ¼ÈëµÄÔÂ·İ»òÕßÈÕÆÚ
  AND brand_id NOT IN (10010, 10127)
LIMIT 10;

SELECT DISTINCT t1.brand_id
FROM amg_brand_target_opt_log AS t1
WHERE t1.opt_type = 1
  AND t1.target_type = 0    -- 0-ÔÂÄ¿±ê£»1-ÈÕÄ¿±ê
  AND t1.target_time = '2018-08'   -- µ¼ÈëµÄÔÂ·İ»òÕßÈÕÆÚ
  AND t1.brand_id <> 10010

-- ²éÑ¯¶àÉÙÆ·ÅÆ²Ù×÷ÁËÒµ¼¨Ä¿±êÉèÖÃ
SELECT t1.brand_id
	  ,SUM(t1.input_count) AS input_count
FROM
(SELECT t1.brand_id
	  	,COUNT(*) AS input_count
FROM amg_brand_target_opt_log AS t1
WHERE t1.opt_type = 1
  AND t1.target_type = 0    -- 0-ÔÂÄ¿±ê£»1-ÈÕÄ¿±ê
  AND t1.target_time = '2018-08'   -- µ¼ÈëµÄÔÂ·İ»òÕßÈÕÆÚ
  AND t1.brand_id <> 10010
GROUP BY t1.brand_id
) AS t1
GROUP BY t1.brand_id
ORDER BY input_count DESC
;


-- ËùÓĞÆ·ÅÆµÄ»áÔ±ĞÅÏ¢¶¼´æ·ÅÔÚdwd_crm_custom_basic_info_dt±íÖĞ
-- Ã¿ÌìÒ»¸ö¿ìÕÕ

-- ²éÑ¯Ç°10¸ö»áÔ±µÄĞÅÏ¢
SELECT t1.*
FROM dwd_crm_custom_basic_info_dt AS t1
WHERE p_day = '20180719'
LIMIT 10;

-- ²»È¥ÖØ£¬²éÑ¯»áÔ±ÊıÁ¿[171W]
SELECT COUNT(t1.custom_id) AS custom_n
FROM dwd_crm_custom_basic_info_dt AS t1
WHERE p_day = '20180719'
;

-- È¥ÖØ£¬²éÑ¯»áÔ±ÊıÁ¿[127W]
-- ¸ù¾İÊÖ»úºÅÂëÈ¥ÖØ
SELECT COUNT(DISTINCT t1.mobile_phone) AS custom_n
FROM dwd_crm_custom_basic_info_dt AS t1
WHERE p_day = '20180719'
;

-- ¸÷¸öÆ·ÅÆ»áÔ±ÊıÁ¿
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

-- Ò»¸ö»áÔ±»áÍ¬Ê±×¢²áµ½¶àÉÙ¸öÆ·ÅÆ£¿
-- ¸÷Æ·ÅÆµÄ»áÔ±ÖØºÏ¶ÈÓĞ¶à¸ß£¿[ĞÅÏ¢±¨¸æ]
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

-- ±È½ÏÈı²ÊºÍÃŞ¹ºµÄ»áÔ±ÖØºÏ¶È
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

-- Æ·ÅÆÎ¬¶È±í£¬°üº¬¸¸×ÓÆ·ÅÆ
>>>>>>> c067c4c78d3936d2a9a12d5523589ca4ab79f740
SELECT *
FROM dim_brand_child_relation_dt AS t1
LIMIT 10;
-- ¸¸×ÓÆ·ÅÆºÏ¼Æ879£¬ÀïÃæ°üÀ¨²âÊÔÕÊºÅ
SELECT COUNT(*)
FROM dim_brand_child_relation_dt AS t1
;


--Æ·ÅÆ²¨¶Î dim_brand_ranges_dt
-- ranges
-- ranges_name


-- ¹ØÓÚÈÕÆÚµÄÎ¬¶È±í dim_date
SELECT *
FROM dim_date AS t1
LIMIT 10;

SELECT COUNT(*)
FROM dim_date AS t1
;

-- ×îĞ¡ÈÕÆÚ 2016-01-01
SELECT MIN(t1.date_id)
FROM dim_date AS t1
;

-- ×î´óÈÕÆÚ 2028-12-31
SELECT MAX(t1.date_id)
FROM dim_date AS t1
;


-- skuĞÅÏ¢±í dim_good_sku_base_info_dt
SELECT t1.*
FROM dim_good_sku_base_info_dt AS t1
WHERE t1.p_day = '20180327'
LIMIT 10;


-- spuĞÅÏ¢±í dim_good_spu_base_info_dt_v2 hue
-- ×¢Òâ±íÖĞstringÀàĞÍµÄ×Ö¶Î£¬Îª¿ÕÊ±£¬Êµ¼ÊÉÏ=''
-- Òò´Ë£¬Ñ¡Ôñ²»Îª¿ÕÊ±Ó¦Ğ´³É: != ''
-- spu_statusµÄº¬Òå
SELECT t1.*
FROM dim_good_spu_base_info_dt_v2 AS t1
WHERE t1.p_day = '20180327'
	AND t1.section != ''
LIMIT 10;

-- spuĞÅÏ¢±í dim_good_spu_base_info_dt °¢ÀïÊı¼Ó
SELECT t1.*
FROM dim_good_spu_base_info_dt AS t1
WHERE t1.p_day = '20180327'
LIMIT 10;
-- ÀàÄ¿ÊıÁ¿ 230 ÕâÃ´¶àÀàÄ¿£¿¶¼ÊÇÒ»¼¶ÀàÄ¿£¿
SELECT COUNT(DISTINCT t1.cat_name) AS cat_count
FROM dim_good_spu_base_info_dt AS t1
WHERE t1.p_day = '20180327'
;
-- ¸÷ÀàÄ¿µÄspuÊıTOP30
-- °¢ÀïÊı¼ÓÖĞORDER BY±ØĞë¸úLIMIT
-- ÀàÄ¿½á¹¹¸Ğ¾õ»¹²»ÊÇºÜÇåÎú£¬ºóĞøÁË½âÒ»ÏÂ£¬×îºÃÕÒµ½Ïà¹ØµÄÒµÎñÎÄµµ
SELECT t1.cat_name
		,COUNT(t1.brand_spu_id) AS spu_count
FROM dim_good_spu_base_info_dt AS t1
WHERE t1.p_day = '20180327'
GROUP BY t1.cat_name
ORDER BY spu_count DESC
LIMIT 30
;
-- spu×´Ì¬ spu_status 1¡¢2¡¢3·Ö±ğÊ²Ã´º¬Òå£¿
SELECT t1.spu_status
		,COUNT(t1.brand_spu_id) AS spu_count
FROM dim_good_spu_base_info_dt AS t1
WHERE t1.p_day = '20180327'
GROUP BY t1.spu_status
;
-- spuÄ¿Ç°ÓĞÒÔÏÂÊôĞÔÎ¬¶È£º
-- Æ·ÅÆbrand¡¢×ÓÆ·ÅÆchild_brand¡¢ÀàÄ¿cat_name¡¢¶à¼¶ÀàÄ¿cat_id1¡¢2¡¢3¡¢4¡¢5¡¢´óÖĞĞ¡Ààbig_cat¡¢middle_cat¡¢small_cat
-- Äê·İyear¡¢¼¾½Úseason¡¢²¨¶Îranges¡¢ÉÏÊĞÊ±¼ämarker_time¡¢ÉÏÊĞÌìÊımarket_day
-- ÏµÁĞseries£¿¡¢ÉÌÆ·²ãsection£¿¡¢·ç¸ñstyle£¿ ÕâÈı¸ö·Ö±ğÊÇÈçºÎ¶¨ÒåµÄ£¿ÌØ±ğÊÇÉÌÆ·²ãÊÇÊ²Ã´º¬Òå£¿
-- µõÅÆ¼Ûsuggest_price¡¢ÏúÊÛ¼Ûsale_price ¿ÉÒÔÔö¼Ó¼Û¸ñ´ø×Ö¶Î£¬²»Í¬Æ·ÅÆ¡¢Æ·Àà£¬²»Í¬µÄ»®·Ö±ê×¼
-- ÃæÁÏfabric_category¡¢ÃæÁÏ³É·Ömain_fabric
SELECT t1.*
FROM dim_good_spu_base_info_dt AS t1
WHERE t1.p_day = '20180327'
	AND t1.fabric_category != ''
LIMIT 10;


-- µ¼¹ºĞÅÏ¢±í dim_guide_info_dt
SELECT t1.*
FROM dim_guide_info_dt AS t1
LIMIT 10;


-- µê²ÖĞÅÏ¢±í dim_storage_info_dt
-- storage_status 0,1,4,9 ·Ö±ğÊ²Ã´º¬Òå£¿
-- storage_type 0,1,2,3,4 ·Ö±ğÊ²Ã´º¬Òå£¿
-- channel_type 0´úÀíÉÌ,1¼ÓÃËÉÌ,2Ö±Óª,3,5,6?
-- storage_groupÏà¹Ø£¬µê²ÖÁªÃË£¬ÁªÃËÄÚÃÅµê¿â´æ¹²Ïí
-- storage_grade
-- start_business_date:¿ªÒµÈÕÆÚ
-- circulation_flag ÊÇ·ñ²ÎÓëÁ÷×ª£¬Ê²Ã´º¬Òå£¿
-- acreage:Ãæ»ı£¬¿´À´µê²ÖÄ¿Ç°Ö»ÓĞÒ»¸öÃæ»ı£¬½¨ÒéÇø·ÖÒÔÏÂµÄÃæ»ı£ºÊÔÒÂ¼äÃæ»ı¡¢ÃÅµê²Ö¿âÃæ»ı¡¢ÃÅµê¿É³ÂÁĞÃæ»ı
-- pay_type:ÊÕÒøÀàĞÍ,×ÔÊÕÒø£¬·Ç×ÔÊÕÒø
-- property_type:ÎïÒµÀàĞÍ£¬¶àÊıÎª¿Õ£¬ÏÖÓĞÒÔÏÂ£ºMALL¡¢°Ù»õ¡¢ÌØÂô³¡¡¢½ÖµÀ

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
-- ²»Í¬Æ·ÅÆÓĞ²»Í¬µÄ·Ö¼¶±ê×¼
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





-- ²»Öª±í¾ßÌåÓÃÍ¾ dm_brand_dc_guide_member_dm
SELECT t1.*
FROM dm_brand_dc_guide_member_dm AS t1
WHERE t1.p_day = '20180327'
ORDER BY t1.new_member_count DESC
LIMIT 10;


-- ÃÅµêÃ¿ÈÕÏúÊÛ

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


-- ÏúÊÛ¶îµÄµ¥Î»ÊÇ·Ö£¬¼´Èç¹ûÒªÍ³¼Æµ½Ôª£¬ĞèÒª³ıÒÔ100£»
SELECT t1.*
FROM dm_storage_sale_dm AS t1
WHERE t1.brand_id = '10094'
	AND t1.p_day = '20180727'
LIMIT 20
;

-- ÉÏº£ÃŞ¹º²¿·ÖÈÕÆÚµÄÏúÊÛ¼şÊıÓĞÎó£¬³öÏÖ½Ï´óµÄ¸ºÊı£¬Èç2018-4-23£¬-2017£¬·¢ÏÖÓĞÒ»¸öÉÌÆ·"¶¨½ğ"µÄÏúÊÛ¼şÊıÎª¸º£»
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

-- dm_storage_sale_dm:Ã¿Ìì´æµÄÊÇµ±ÌìµÄÊı¾İ
-- dm_storage_sale_dt:Ã¿Ìì´æµÄÊÇ½ØÖÁ¸ÃÌìµÄÀÛ¼ÆÊı¾İ£»


-- ³É±¾¼Û
SELECT t1.*
FROM dim_good_sku_base_info_dt AS t1
WHERE t1.brand_id = '10094'
	AND t1.p_day = '20180729'
	AND t1.cost_price > 0
ORDER BY brand_sku_id
LIMIT 100
;


-- ÃÅµêĞÅÏ¢±í
-- dim_storage_info_dt
-- stotage_status: 1-ÆôÓÃ£¬4-Í£ÓÃ£¬9-¹Ø±Õ
SELECT t1.*
FROM dim_storage_info_dt AS t1
WHERE t1.brand_id = '10094'
	AND p_day = '20180729'
ORDER BY t1.storage_code
LIMIT 105
;



-- Ã¿Ìì³É½»½ğ¶î
-- Êı¾İÁ¿ºÜ´ó£¬²»ÊÇÕæÊµÊı¾İ°É£¿
SELECT t1.p_day
		,SUM(t1.total_sale_money) AS total_sale_money
FROM dm_storage_day_report AS t1
GROUP BY t1.p_day
ORDER BY t1.p_day
LIMIT 100
;
-- Ã¿ÌìÈ±»õÂÊ
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



-- ¿Í»§»ù±¾ĞÅÏ¢±í dm_custom_basic_info_dt
SELECT t1.*
FROM dm_custom_basic_info_dt AS t1
WHERE t1.p_day = '20180327'
LIMIT 10
;


-- ¹ØÁªÏúÊÛspu±í dm_spu_order_join_sale_dm
-- Ò»¸öspuÔÚÍ¬Ò»¸ö¶©µ¥ÖĞ£¬¸úÆäËûÄÄĞ©spu¹ØÁª¹ºÂò
SELECT t1.*
FROM dm_spu_order_join_sale_dm AS t1
WHERE t1.p_day = '20180327'
LIMIT 10
;


-- Áù¶¡Ä¿È¨ÖØÖ¸±ê ===================================

-- 1.2015-2018ÈıÄê¶àµÄÀúÊ·ÏúÊÛÊı¾İ
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
-- ÈÕÆÚ
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


-- ÈÕÆÚ
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



-- Áù¶¡Ä¿È¨ÖØÖ¸±ê ===================================







-- å…­ç”ºç›®é”€å”®é¢„æµ‹ ====================================
-- 1. æƒé‡æŒ‡æ•°æ‹†åˆ†
-- 2. å¤©æ°”

WITH 
-- é”€å”®é¢
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
-- æ—¥æœŸï¼Œæ˜ŸæœŸå’ŒèŠ‚å‡æ—¥æ ‡è®°
t2 AS
(SELECT REGEXP_REPLACE(t1.date_id, '-', '') AS date_id
    ,t1.date_id AS date_id2
    ,t1.day_of_week
    ,t1.day_of_week_name
    ,t1.holiday_mark
    ,t1.holiday_name
FROM dim_date AS t1
)
-- æ±‡æ€»ï¼Œå¾—åˆ°
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

