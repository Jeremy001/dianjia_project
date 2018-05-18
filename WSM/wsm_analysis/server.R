
# this is a shinydashboard for wsm

# 加载包 =====================================================================================
library(tidyverse)
library(lubridate)
library(shinydashboard)
library(highcharter)
library(DT)

# 加载数据 ============================================================
## 2017销售明细
wsm_sale_2017 <- read.table(file = "E:/dianjia/project_data/wsm/wsm_sale_2017.csv", 
                            header = TRUE, 
                            sep = ',', 
                            stringsAsFactors = FALSE)
### 数据格式
wsm_sale_2017$sale_date <- as.Date(wsm_sale_2017$sale_date)
wsm_sale_2017$sale_year <- year(wsm_sale_2017$sale_date)
wsm_sale_2017$goods_year <- as.integer(wsm_sale_2017$goods_year)
wsm_sale_2017$sale_quarter <- quarter(wsm_sale_2017$sale_date)
wsm_sale_2017$sale_month <- month(wsm_sale_2017$sale_date, label = TRUE)
wsm_sale_2017$sale_num <- as.integer(wsm_sale_2017$sale_num)
wsm_sale_2017$sale_amount <- as.numeric(wsm_sale_2017$sale_amount)
wsm_sale_2017$origin_amount <- as.numeric(wsm_sale_2017$origin_amount)

## 商品信息
wsm_goods_info <- read.table(file = "E:/dianjia/project_data/wsm/wsm_goods_info.csv", 
                             header = TRUE, 
                             sep = ',', 
                             stringsAsFactors = FALSE)
wsm_goods_info$shangshi_date <- as.Date(wsm_goods_info$shangshi_date)

## left_join，从商品信息表中获取goods_material,up_down,shangshi_date字段
wsm_goods_sale_2017 <- left_join(x = wsm_sale_2017, 
                                 y = wsm_goods_info[, c('goods_id', 'goods_material', 'up_down', 'shangshi_date')],
                                 by = c('goods_id' = 'goods_id'))
wsm_goods_sale_2017 <- wsm_goods_sale_2017 %>% 
  filter(sale_date <= '2017-12-31')

## 2018Q3订货数据
wsm_orders_2018q3 <- read.table(file = "E:/dianjia/project_data/wsm/wsm_orders_2018q3.csv", 
                                header = TRUE, 
                                sep = ',', 
                                stringsAsFactors = FALSE)
wsm_orders_2018q3[is.na(wsm_orders_2018q3)] <- 0


# 数据汇总 ============================================================

## 2017年：数量、金额、平均单价、折扣率
### 
wsm_sale_2017_t <- wsm_goods_sale_2017 %>% 
  filter(sale_date >= '2017-01-01', 
         sale_date <= '2017-12-31', 
         !region_name %in% c('电商', '一期特卖')) %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 1), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 1)) %>% 
  mutate(avg_sale_price = round(sale_amount*10000/sale_num, 1), 
         avg_origin_price = round(origin_amount*10000/sale_num, 1), 
         discount = round(sale_amount/origin_amount, 2))
### 秋季货品
wsm_sale_2017_qiu <- wsm_goods_sale_2017 %>% 
  filter(sale_date >= '2017-01-01', 
         sale_date <= '2017-12-31', 
         !region_name %in% c('电商', '一期特卖'), 
         goods_season == '3-秋季') %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 1), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 1)) %>% 
  mutate(avg_sale_price = round(sale_amount*10000/sale_num, 1), 
         avg_origin_price = round(origin_amount*10000/sale_num, 1), 
         discount = round(sale_amount/origin_amount, 2))
### 秋季应季货品
wsm_sale_2017_qiu_yingji <- wsm_goods_sale_2017 %>% 
  filter(sale_date >= '2017-01-01', 
         sale_date <= '2017-12-31', 
         !region_name %in% c('电商', '一期特卖'), 
         goods_season == '3-秋季', 
         is_guoji == '应季') %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 1), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 1)) %>% 
  mutate(avg_sale_price = round(sale_amount*10000/sale_num, 1), 
         avg_origin_price = round(origin_amount*10000/sale_num, 1), 
         discount = round(sale_amount/origin_amount, 2))
### 秋季过季货品
wsm_sale_2017_qiu_guoji <- wsm_goods_sale_2017 %>% 
  filter(sale_date >= '2017-01-01', 
         sale_date <= '2017-12-31', 
         !region_name %in% c('电商', '一期特卖'), 
         goods_season == '3-秋季', 
         is_guoji == '过季') %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 1), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 1)) %>% 
  mutate(avg_sale_price = round(sale_amount*10000/sale_num, 1), 
         avg_origin_price = round(origin_amount*10000/sale_num, 1), 
         discount = round(sale_amount/origin_amount, 2))

### 汇总成一个表格
wsm_sale_2017_t2 <- rbind(wsm_sale_2017_t, wsm_sale_2017_qiu) %>% 
  rbind(wsm_sale_2017_qiu_yingji) %>% 
  rbind(wsm_sale_2017_qiu_guoji) %>% 
  t() %>% 
  as.data.frame()
wsm_sale_2017_t2 <- wsm_sale_2017_t2 %>% 
  mutate(V5 = paste(round(V2*100/V1, 1), '%', sep = ''),
         V6 = paste(round(V3*100/V2, 1), '%', sep = ''), 
         V7 = paste(round(V4*100/V2, 1), '%', sep = ''))
wsm_sale_2017_t2$index <- c('销售数量', '销售金额', '吊牌金额', '平均售价', '平均吊牌价', '折扣率')
wsm_sale_2017_t2 <- wsm_sale_2017_t2[, c('index', 'V1', 'V2', 'V5', 'V3', 'V6', 'V4', 'V7')]
colnames(wsm_sale_2017_t2) <- c('指标', '整体', '秋季商品', '秋季 V.S 整体', '应季商品', '应季商品 V.S 秋季', 
                                '过季商品', '过季商品 V.S 秋季')

### 月度趋势和季节结构
wsm_sale_2017_season_month <- wsm_goods_sale_2017 %>% 
  filter(sale_date >= '2017-01-01',
         sale_date <= '2017-12-31', 
         !region_name %in% c('电商', '一期特卖')) %>% 
  group_by(sale_month, goods_season) %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 1), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 1))

### Q3-Q4秋品
wsm_sale_2017_qiu_q34 <- wsm_goods_sale_2017 %>% 
  filter(sale_date >= '2017-07-01', 
         sale_date <= '2017-12-31', 
         !region_name %in% c('电商', '一期特卖'), 
         goods_season == '3-秋季') %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 1), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 1)) %>% 
  mutate(avg_sale_price = round(sale_amount*10000/sale_num, 1), 
         avg_origin_price = round(origin_amount*10000/sale_num, 1), 
         discount = round(sale_amount/origin_amount, 2))
### Q3-Q4应季秋品
wsm_sale_2017_qiu_yingji_q34 <- wsm_goods_sale_2017 %>% 
  filter(sale_date >= '2017-07-01', 
         sale_date <= '2017-12-31', 
         !region_name %in% c('电商', '一期特卖'), 
         goods_season == '3-秋季', 
         is_guoji == '应季') %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 1), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 1)) %>% 
  mutate(avg_sale_price = round(sale_amount*10000/sale_num, 1), 
         avg_origin_price = round(origin_amount*10000/sale_num, 1), 
         discount = round(sale_amount/origin_amount, 2))
### Q3-Q4过季秋品
wsm_sale_2017_qiu_guoji_q34 <- wsm_goods_sale_2017 %>% 
  filter(sale_date >= '2017-07-01', 
         sale_date <= '2017-12-31', 
         !region_name %in% c('电商', '一期特卖'), 
         goods_season == '3-秋季', 
         is_guoji == '过季') %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 1), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 1)) %>% 
  mutate(avg_sale_price = round(sale_amount*10000/sale_num, 1), 
         avg_origin_price = round(origin_amount*10000/sale_num, 1), 
         discount = round(sale_amount/origin_amount, 2))

### Q3-Q4月销售趋势:应季-过季
wsm_sale_2017_month_q34 <- wsm_goods_sale_2017 %>% 
  filter(sale_date >= '2017-07-01',
         sale_date <= '2017-12-31', 
         !region_name %in% c('电商', '一期特卖'), 
         goods_season == '3-秋季') %>% 
  group_by(sale_month, is_guoji) %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 1), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 1)) %>% 
  mutate(avg_sale_price = round(sale_amount*10000/sale_num, 1), 
         avg_origin_price = round(origin_amount*10000/sale_num, 1), 
         discount = round(sale_amount/origin_amount, 2))
### Q3-Q4月销售趋势:类目
wsm_sale_2017_month_q34_cat <- wsm_goods_sale_2017 %>% 
  filter(sale_date >= '2017-07-01',
         sale_date <= '2017-12-31', 
         !region_name %in% c('电商', '一期特卖'), 
         goods_season == '3-秋季') %>% 
  group_by(sale_month, cat1_name) %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 1), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 1)) %>% 
  mutate(avg_sale_price = round(sale_amount*10000/sale_num, 1), 
         avg_origin_price = round(origin_amount*10000/sale_num, 1), 
         discount = round(sale_amount/origin_amount, 2))

### Q3-Q4类目-整体
sale_2017_q34_qiu_cat1 <- wsm_goods_sale_2017 %>% 
  filter(sale_date >= '2017-07-01',
         sale_date <= '2017-12-31', 
         !region_name %in% c('电商', '一期特卖'), 
         goods_season == '3-秋季') %>% 
  group_by(cat1_name) %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 1), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 1)) %>% 
  mutate(avg_sale_price = round(sale_amount*10000/sale_num, 1), 
         avg_origin_price = round(origin_amount*10000/sale_num, 1), 
         discount = round(sale_amount/origin_amount, 2)) %>% 
  mutate(sale_num_prop = paste(round(sale_num*100/sum(sale_num), 1), '%', sep = ''), 
         sale_amount_prop = paste(round(sale_amount*100/sum(sale_amount), 1), '%', sep = ''), 
         origin_amount_prop = paste(round(origin_amount*100/sum(origin_amount), 1), '%', sep = '')) %>% 
  select(cat1_name, sale_num, sale_num_prop, sale_amount, sale_amount_prop, origin_amount, 
         origin_amount_prop, avg_sale_price, avg_origin_price, discount) %>% 
  arrange(-sale_amount)

### Q3-Q4类目-应季
sale_2017_q34_qiu_cat1_yingji <- wsm_goods_sale_2017 %>% 
  filter(sale_date >= '2017-07-01', 
         sale_date <= '2017-12-31', 
         !region_name %in% c('电商', '一期特卖'), 
         goods_season == '3-秋季', 
         is_guoji == '应季') %>% 
  group_by(cat1_name) %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 1), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 1)) %>% 
  mutate(avg_sale_price = round(sale_amount*10000/sale_num, 1), 
         avg_origin_price = round(origin_amount*10000/sale_num, 1), 
         discount = round(sale_amount/origin_amount, 2)) %>% 
  mutate(sale_num_prop = paste(round(sale_num*100/sum(sale_num), 1), '%', sep = ''), 
         sale_amount_prop = paste(round(sale_amount*100/sum(sale_amount), 1), '%', sep = ''), 
         origin_amount_prop = paste(round(origin_amount*100/sum(origin_amount), 1), '%', sep = '')) %>% 
  select(cat1_name, sale_num, sale_num_prop, sale_amount, sale_amount_prop, origin_amount, 
         origin_amount_prop, avg_sale_price, avg_origin_price, discount) %>% 
  arrange(-sale_amount)
### Q3-Q4类目-过季
sale_2017_q34_qiu_cat1_guoji <- wsm_goods_sale_2017 %>% 
  filter(sale_date >= '2017-07-01', 
         sale_date <= '2017-12-31', 
         !region_name %in% c('电商', '一期特卖'), 
         goods_season == '3-秋季', 
         is_guoji == '过季') %>% 
  group_by(cat1_name) %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 1), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 1)) %>% 
  mutate(avg_sale_price = round(sale_amount*10000/sale_num, 1), 
         avg_origin_price = round(origin_amount*10000/sale_num, 1), 
         discount = round(sale_amount/origin_amount, 2)) %>% 
  mutate(sale_num_prop = paste(round(sale_num*100/sum(sale_num), 1), '%', sep = ''), 
         sale_amount_prop = paste(round(sale_amount*100/sum(sale_amount), 1), '%', sep = ''), 
         origin_amount_prop = paste(round(origin_amount*100/sum(origin_amount), 1), '%', sep = '')) %>% 
  select(cat1_name, sale_num, sale_num_prop, sale_amount, sale_amount_prop, origin_amount, 
         origin_amount_prop, avg_sale_price, avg_origin_price, discount) %>% 
  arrange(-sale_amount)
### Q3-Q4:秋装整体、应季占比、过季占比
sale_2017_q34_qiu_cat1_yingguo <- 
  left_join(sale_2017_q34_qiu_cat1[, c('cat1_name', 'sale_num', 'sale_amount', 'origin_amount')], 
            sale_2017_q34_qiu_cat1_yingji[, c('cat1_name', 'sale_num', 'sale_amount', 'origin_amount')], 
            by = c('cat1_name' = 'cat1_name')) %>% 
  left_join(sale_2017_q34_qiu_cat1_guoji[, c('cat1_name', 'sale_num', 'sale_amount', 'origin_amount')], 
            by = c('cat1_name' = 'cat1_name'))
sale_2017_q34_qiu_cat1_yingguo[is.na(sale_2017_q34_qiu_cat1_yingguo)] <- 0
sale_2017_q34_qiu_cat1_yingguo <- sale_2017_q34_qiu_cat1_yingguo %>% 
  mutate(sale_num_prop = paste(round(sale_num.y*100/sale_num.x, 1), '%', sep = ''), 
         sale_amount_prop = paste(round(sale_amount.y*100/sale_amount.x, 1), '%', sep = ''), 
         origin_amount_prop = paste(round(origin_amount.y*100/origin_amount.x, 1), '%', sep = '')) %>% 
  select(cat1_name, sale_num.x, sale_num.y, sale_num_prop, sale_num, 
         sale_amount.x, sale_amount.y, sale_amount_prop, sale_amount, 
         origin_amount.x, origin_amount.y, origin_amount_prop, origin_amount)

colnames(sale_2017_q34_qiu_cat1) <- c('类目', '销售数量', '数量占比', '销售金额', '金额占比', 
                                      '吊牌金额', '吊牌占比', '平均售价', '平均吊牌价', '折扣')
colnames(sale_2017_q34_qiu_cat1_yingji) <- c('类目', '销售数量', '数量占比', '销售金额', '金额占比', 
                                             '吊牌金额', '吊牌占比', '平均售价', '平均吊牌价', '折扣')
colnames(sale_2017_q34_qiu_cat1_guoji) <- c('类目', '销售数量', '数量占比', '销售金额', '金额占比', 
                                            '吊牌金额', '吊牌占比', '平均售价', '平均吊牌价', '折扣')
colnames(sale_2017_q34_qiu_cat1_yingguo) <- c('类目', '销售数量', '应季数量', '应季数量占比', '过季数量', 
                                              '销售金额', '应季金额', '应季金额占比', '过季金额', 
                                              '吊牌金额', '应季吊牌', '应季吊牌占比', '过季吊牌')

qiu_cat1_date <- wsm_goods_sale_2017 %>% 
  filter(sale_date >= '2017-07-01', 
         sale_date <= '2017-12-31', 
         !region_name %in% c('电商', '一期特卖'), 
         goods_season == '3-秋季') %>% 
  group_by(cat1_name, sale_date) %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 1), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 1))


## 2018秋季订货数据 ===================================
### 类目对比：2017年上市、销售、2018年下单
#### 2018下单数据
order_2018_qiu_cat1 <- wsm_orders_2018q3 %>% 
  group_by(品类, 商品款号) %>% 
  summarise(goods_num = sum(合计), 
            origin_amount = sum(吊牌额)) %>% 
  group_by(品类) %>% 
  summarise(goods_count = n(), 
            goods_num = sum(goods_num), 
            origin_amount = round(sum(origin_amount)/10000, 1)) %>% 
  mutate(sale_amount = round(origin_amount*0.7, 1), 
         avg_sale_price = round(sale_amount*10000/goods_num, 1), 
         avg_origin_price = round(origin_amount*10000/goods_num, 1)) %>% 
  arrange(-goods_num)
#### 2017_qius上市款数
shangshi_2017_qiu_cat1 <- wsm_goods_info %>% 
  filter(shangshi_date >= '2017-01-01', 
         shangshi_date <= '2017-12-31', 
         goods_season == '3-秋季', 
         goods_year == 2017) %>% 
  group_by(cat1_name) %>% 
  summarise(shangshi_goods = n(), 
            avg_origin_price = round(mean(origin_price), 1)) %>% 
  arrange(-shangshi_goods)
#### join以上三个表，得到总表
sale_order_qiu_cat1 <- shangshi_2017_qiu_cat1[, 1:2] %>% 
  full_join(sale_2017_q34_qiu_cat1_yingji[, c(1:2, 4, 6)], 
            by = c('cat1_name' = '类目')) %>% 
  full_join(order_2018_qiu_cat1[, c(1:3, 5, 4)], 
            by = c('cat1_name' = '品类'))
sale_order_qiu_cat1[is.na(sale_order_qiu_cat1)] <- 0
sale_order_qiu_cat1_sum <- sapply(sale_order_qiu_cat1[, -1], 
                                  function(x) sum(x))
sale_order_qiu_cat1_sum <- as.data.frame(t(sale_order_qiu_cat1_sum))
sale_order_qiu_cat1_sum$cat1_name <- '合计'
sale_order_qiu_cat1_sum <- sale_order_qiu_cat1_sum[, c(9, 1:8)]
sale_order_qiu_cat1 <- rbind(sale_order_qiu_cat1, sale_order_qiu_cat1_sum)
sale_order_qiu_cat1 <- sale_order_qiu_cat1 %>% 
  mutate(goods_num_duibi = round(goods_num*100/销售数量, 1), 
         sale_amount_duibi = round(sale_amount*100/销售金额, 1), 
         origin_amount_duibi = round(origin_amount*100/吊牌金额, 1), 
         avg_sale_price_2017 = round(销售金额*10000/销售数量, 1), 
         avg_sale_price_2018 = round(sale_amount*10000/goods_num, 1), 
         avg_origin_price_2017 = round(吊牌金额*10000/销售数量, 1), 
         avg_origin_price_2018 = round(origin_amount*10000/goods_num, 1), 
         origin_price_duibi = round(avg_origin_price_2018*100/avg_origin_price_2017, 1))
sale_order_qiu_cat1 <- sale_order_qiu_cat1[, c(1:2, 6, 3, 7, 10, 4, 8, 11, 5, 9, 12, 13:17)]
names(sale_order_qiu_cat1) <- c('类目','17款数','18款数','17数量','18数量','数量同比%','17金额','18金额',
                                '金额同比%','17吊牌','18吊牌','吊牌同比%','17售价','18售价','17吊牌价', 
                                '18吊牌价','吊牌价同比%')


function(input, output){
  
  ## tab01 =======================================
  ### 总体
  output$sale_num <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_t$sale_num, 
      '销售数量', 
      icon = icon('credit-card')
    )
  })
  output$sale_amount <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_t$sale_amount, 
      '销售金额', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  output$origin_amount <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_t$origin_amount, 
      '吊牌金额', 
      icon = icon('credit-card')
    )
  })
  output$avg_sale_price <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_t$avg_sale_price, 
      '平均售价', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  output$avg_origin_price <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_t$avg_origin_price, 
      '平均吊牌价', 
      icon = icon('credit-card')
    )
  })
  output$discount <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_t$discount, 
      '折扣率', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  ### 秋季
  output$sale_num_qiu <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu$sale_num, 
      '销售数量', 
      icon = icon('credit-card')
    )
  })
  output$sale_amount_qiu <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu$sale_amount, 
      '销售金额', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  output$origin_amount_qiu <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu$origin_amount, 
      '吊牌金额', 
      icon = icon('credit-card')
    )
  })
  output$avg_sale_price_qiu <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu$avg_sale_price, 
      '平均售价', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  output$avg_origin_price_qiu <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu$avg_origin_price, 
      '平均吊牌价', 
      icon = icon('credit-card')
    )
  })
  output$discount_qiu <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu$discount, 
      '折扣率', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  ### 秋季-应季
  output$sale_num_qiu_yingji <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_yingji$sale_num, 
      '销售数量', 
      icon = icon('credit-card')
    )
  })
  output$sale_amount_qiu_yingji <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_yingji$sale_amount, 
      '销售金额', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  output$origin_amount_qiu_yingji <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_yingji$origin_amount, 
      '吊牌金额', 
      icon = icon('credit-card')
    )
  })
  output$avg_sale_price_qiu_yingji <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_yingji$avg_sale_price, 
      '平均售价', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  output$avg_origin_price_qiu_yingji <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_yingji$avg_origin_price, 
      '平均吊牌价', 
      icon = icon('credit-card')
    )
  })
  output$discount_qiu_yingji <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_yingji$discount, 
      '折扣率', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  ### data table
  output$wsm_sale_2017_table <- renderDT(
    wsm_sale_2017_t2, 
    rownames = FALSE, 
    options = list(
      dom = 't', 
      columnDefs = list(list(className = 'dt-center', targets = 1:7))
    )
  )
  ### 趋势图和季节结构
  output$wsm_season_sale_num1 <- renderHighchart({
    wsm_sale_2017_season_month %>% 
      hchart('column', 
             hcaes(x = sale_month, 
                   y = sale_num, 
                   group = goods_season)) %>% 
      hc_plotOptions(column = list(stacking = 'fill')) %>% 
      hc_add_theme(hc_theme_flat()) %>% 
      hc_title(text = '销售趋势')
  })
  output$wsm_season_sale_num2 <- renderHighchart({
    wsm_sale_2017_season_month %>%
      hchart('area', 
             hcaes(x = sale_month, 
                   y = sale_num, 
                   group = goods_season)) %>% 
      hc_plotOptions(area = list(stacking = 'percent')) %>% 
      hc_tooltip(pointFormat = "<span style='color:{series.color}'>{series.name}</span>:
                 <b>{point.percentage:.1f}%</b> ({point.y:,.0f})<br/>",
                 shared = TRUE) %>% 
      hc_add_theme(hc_theme_flat()) %>% 
      hc_title(text = '季节占比')
  })
  output$wsm_season_sale_amount1 <- renderHighchart({
    wsm_sale_2017_season_month %>% 
      hchart('column', 
             hcaes(x = sale_month, 
                   y = sale_amount, 
                   group = goods_season)) %>% 
      hc_plotOptions(column = list(stacking = 'fill')) %>% 
      hc_add_theme(hc_theme_flat()) %>% 
      hc_title(text = '销售趋势')
  })
  output$wsm_season_sale_amount2 <- renderHighchart({
    wsm_sale_2017_season_month %>%
      hchart('area', 
             hcaes(x = sale_month, 
                   y = sale_amount, 
                   group = goods_season)) %>% 
      hc_plotOptions(area = list(stacking = 'percent')) %>% 
      hc_tooltip(pointFormat = "<span style='color:{series.color}'>{series.name}</span>:
                 <b>{point.percentage:.1f}%</b> ({point.y:,.0f})<br/>",
                 shared = TRUE) %>% 
      hc_add_theme(hc_theme_flat()) %>% 
      hc_title(text = '季节占比')
  })
  output$wsm_season_origin_amount1 <- renderHighchart({
    wsm_sale_2017_season_month %>% 
      hchart('column', 
             hcaes(x = sale_month, 
                   y = origin_amount, 
                   group = goods_season)) %>% 
      hc_plotOptions(column = list(stacking = 'fill')) %>% 
      hc_add_theme(hc_theme_flat()) %>% 
      hc_title(text = '销售趋势')
  })
  output$wsm_season_origin_amount2 <- renderHighchart({
    wsm_sale_2017_season_month %>%
      hchart('area', 
             hcaes(x = sale_month, 
                   y = origin_amount, 
                   group = goods_season)) %>% 
      hc_plotOptions(area = list(stacking = 'percent')) %>% 
      hc_tooltip(pointFormat = "<span style='color:{series.color}'>{series.name}</span>:
                 <b>{point.percentage:.1f}%</b> ({point.y:,.0f})<br/>",
                 shared = TRUE) %>% 
      hc_add_theme(hc_theme_flat()) %>% 
      hc_title(text = '季节占比')
  })
  
  ## tab2 =======================================
  output$qiu_cat1_num <- renderHighchart({
    wsm_goods_info %>% 
      filter(shangshi_date >= '2017-01-01', 
             shangshi_date <= '2017-12-31', 
             goods_season == '3-秋季', 
             goods_year == 2017) %>% 
      group_by(cat1_name) %>% 
      summarise(goods_num = n(), 
                avg_origin_price = round(mean(origin_price), 1)) %>% 
      arrange(-goods_num) %>% 
      hchart(type = 'column', 
             hcaes(x = cat1_name, 
                   y = goods_num)) %>% 
      hc_add_theme(hc_theme_flat()) %>% 
      hc_title(text = '各类目秋季新品上市款数')
  })
  output$qiu_cat1_price <- renderHighchart({
    wsm_goods_info %>% 
      filter(shangshi_date >= '2017-01-01', 
             shangshi_date <= '2017-12-31', 
             goods_season == '3-秋季', 
             goods_year == 2017) %>% 
      group_by(cat1_name) %>% 
      summarise(goods_num = n(), 
                avg_origin_price = round(mean(origin_price), 1)) %>% 
      arrange(-goods_num) %>% 
      hchart(type = 'column', 
             hcaes(x = cat1_name, 
                   y = avg_origin_price)) %>% 
      hc_add_theme(hc_theme_flat()) %>% 
      hc_title(text = '各类目秋季新品平均吊牌价')
  })
  output$qiu_shangshi_date <- renderHighchart({
    wsm_goods_info %>% 
      filter(shangshi_date >= '2017-01-01', 
             shangshi_date <= '2017-12-31', 
             goods_season == '3-秋季') %>% 
      group_by(shangshi_date, cat1_name) %>% 
      summarise(goods_num = n()) %>% 
      hchart(type = 'column', 
             hcaes(x = shangshi_date, 
                   y = goods_num, 
                   group = cat1_name)) %>% 
      hc_plotOptions(column = list(stacking = 'fill')) %>% 
      hc_add_theme(hc_theme_flat()) %>% 
      hc_title(text = '2017秋季新品上市节奏')
  })
  
  
  ## tab03 =======================================
  ### 整体秋品
  output$sale_num_qiu_q34 <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_q34$sale_num, 
      '销售数量', 
      icon = icon('credit-card')
    )
  })
  output$sale_amount_qiu_q34 <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_q34$sale_amount, 
      '销售金额', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  output$origin_amount_qiu_q34 <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_q34$origin_amount, 
      '吊牌金额', 
      icon = icon('credit-card')
    )
  })
  output$avg_sale_price_qiu_q34 <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_q34$avg_sale_price, 
      '平均售价', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  output$avg_origin_price_qiu_q34 <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_q34$avg_origin_price, 
      '平均吊牌价', 
      icon = icon('credit-card')
    )
  })
  output$discount_qiu_q34 <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_q34$discount, 
      '折扣率', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  ### 应季秋品
  output$sale_num_qiu_yingji_q34 <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_yingji_q34$sale_num, 
      '销售数量', 
      icon = icon('credit-card')
    )
  })
  output$sale_amount_qiu_yingji_q34 <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_yingji_q34$sale_amount, 
      '销售金额', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  output$origin_amount_qiu_yingji_q34 <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_yingji_q34$origin_amount, 
      '吊牌金额', 
      icon = icon('credit-card')
    )
  })
  output$avg_sale_price_qiu_yingji_q34 <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_yingji_q34$avg_sale_price, 
      '平均售价', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  output$avg_origin_price_qiu_yingji_q34 <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_yingji_q34$avg_origin_price, 
      '平均吊牌价', 
      icon = icon('credit-card')
    )
  })
  output$discount_qiu_yingji_q34 <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_yingji_q34$discount, 
      '折扣率', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  ### 过季秋品
  output$sale_num_qiu_guoji_q34 <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_guoji_q34$sale_num, 
      '销售数量', 
      icon = icon('credit-card')
    )
  })
  output$sale_amount_qiu_guoji_q34 <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_guoji_q34$sale_amount, 
      '销售金额', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  output$origin_amount_qiu_guoji_q34 <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_guoji_q34$origin_amount, 
      '吊牌金额', 
      icon = icon('credit-card')
    )
  })
  output$avg_sale_price_qiu_guoji_q34 <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_guoji_q34$avg_sale_price, 
      '平均售价', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  output$avg_origin_price_qiu_guoji_q34 <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_guoji_q34$avg_origin_price, 
      '平均吊牌价', 
      icon = icon('credit-card')
    )
  })
  output$discount_qiu_guoji_q34 <- renderValueBox({
    valueBox(
      value = wsm_sale_2017_qiu_guoji_q34$discount, 
      '折扣率', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  ### wsm_2017_qiu_q34_table
  output$wsm_2017_qiu_q34_table <- renderDT(
    sale_2017_q34_qiu_cat1, 
    rownames = FALSE, 
    options = list(
      dom = 't', 
      columnDefs = list(list(className = 'dt-center', targets = 1:9))
    )
  )
  ### wsm_2017_qiu_q34_yingji_table
  output$wsm_2017_qiu_q34_yingji_table <- renderDT(
    sale_2017_q34_qiu_cat1_yingji, 
    rownames = FALSE, 
    options = list(
      dom = 't', 
      columnDefs = list(list(className = 'dt-center', targets = 1:9))
    )
  )
  ### wsm_2017_qiu_q34_guoji_table
  output$wsm_2017_qiu_q34_guoji_table <- renderDT(
    sale_2017_q34_qiu_cat1_guoji, 
    rownames = FALSE, 
    options = list(
      dom = 't', 
      columnDefs = list(list(className = 'dt-center', targets = 1:9))
    )
  )
  ### sale_2017_q34_qiu_cat1_yingguo
  output$sale_2017_q34_qiu_cat1_yingguo <- renderDT(
    sale_2017_q34_qiu_cat1_yingguo, 
    rownames = FALSE, 
    options = list(
      dom = 't', 
      columnDefs = list(list(className = 'dt-center', targets = 1:12))
    )
  )
  
  ### 月份、过季、类目
  output$wsm_month_guoji_num1 <- renderHighchart({
    wsm_sale_2017_month_q34 %>% 
      hchart('area', 
             hcaes(x = sale_month, 
                   y = sale_num, 
                   group = is_guoji)) %>% 
      hc_plotOptions(area = list(stacking = 'fill')) %>% 
      hc_add_theme(hc_theme_flat()) %>% 
      hc_title(text = '应季 VS 过季')
  })
  output$wsm_cat_num1 <- renderHighchart({
    wsm_sale_2017_month_q34_cat %>% 
      hchart('column', 
             hcaes(x = sale_month, 
                   y = sale_num, 
                   group = cat1_name)) %>% 
      hc_plotOptions(column = list(stacking = 'fill')) %>% 
      hc_add_theme(hc_theme_flat()) %>% 
      hc_title(text = '类目销售结构') %>% 
      hc_legend(align = 'right', 
                verticalAlign = 'middle', 
                layout = 'vertical')
  })
  output$wsm_cat_num2 <- renderHighchart({
    if (is.null(input$cat1_name1))
      return()
    qiu_cat1_date %>% 
      filter(cat1_name %in% input$cat1_name1) %>% 
      hchart('line', 
             hcaes(x = sale_date, 
                   y = sale_num, 
                   group = cat1_name)) %>% 
      hc_plotOptions(column = list(stacking = 'fill')) %>% 
      hc_add_theme(hc_theme_flat()) %>% 
      hc_title(text = '类目销售趋势') %>% 
      hc_legend(align = 'right', 
                verticalAlign = 'middle', 
                layout = 'vertical')
  })
  output$wsm_month_guoji_sale1 <- renderHighchart({
    wsm_sale_2017_month_q34 %>% 
      hchart('area', 
             hcaes(x = sale_month, 
                   y = sale_amount, 
                   group = is_guoji)) %>% 
      hc_plotOptions(area = list(stacking = 'fill')) %>% 
      hc_add_theme(hc_theme_flat()) %>% 
      hc_title(text = '应季 VS 过季')
  })
  output$wsm_cat_sale1 <- renderHighchart({
    wsm_sale_2017_month_q34_cat %>% 
      hchart('column', 
             hcaes(x = sale_month, 
                   y = sale_amount, 
                   group = cat1_name)) %>% 
      hc_plotOptions(column = list(stacking = 'fill')) %>% 
      hc_add_theme(hc_theme_flat()) %>% 
      hc_title(text = '类目销售结构') %>% 
      hc_legend(align = 'right', 
                verticalAlign = 'middle', 
                layout = 'vertical')
  })
  output$wsm_cat_sale2 <- renderHighchart({
    if (is.null(input$cat1_name2))
      return()
    qiu_cat1_date %>% 
      filter(cat1_name %in% input$cat1_name2) %>% 
      hchart('line', 
             hcaes(x = sale_date, 
                   y = sale_amount, 
                   group = cat1_name)) %>% 
      hc_plotOptions(column = list(stacking = 'fill')) %>% 
      hc_add_theme(hc_theme_flat()) %>% 
      hc_title(text = '类目销售趋势') %>% 
      hc_legend(align = 'right', 
                verticalAlign = 'middle', 
                layout = 'vertical')
  })
  output$wsm_month_guoji_origin1 <- renderHighchart({
    wsm_sale_2017_month_q34 %>% 
      hchart('area', 
             hcaes(x = sale_month, 
                   y = origin_amount, 
                   group = is_guoji)) %>% 
      hc_plotOptions(area = list(stacking = 'fill')) %>% 
      hc_add_theme(hc_theme_flat()) %>% 
      hc_title(text = '应季 VS 过季')
  })
  output$wsm_cat_origin1 <- renderHighchart({
    wsm_sale_2017_month_q34_cat %>% 
      hchart('column', 
             hcaes(x = sale_month, 
                   y = origin_amount, 
                   group = cat1_name)) %>% 
      hc_plotOptions(column = list(stacking = 'fill')) %>% 
      hc_add_theme(hc_theme_flat()) %>% 
      hc_title(text = '类目销售结构') %>% 
      hc_legend(align = 'right', 
                verticalAlign = 'middle', 
                layout = 'vertical')
  })
  output$wsm_cat_origin2 <- renderHighchart({
    if (is.null(input$cat1_name3))
      return()
    qiu_cat1_date %>% 
      filter(cat1_name %in% input$cat1_name3) %>% 
      hchart('line', 
             hcaes(x = sale_date, 
                   y = origin_amount, 
                   group = cat1_name)) %>% 
      hc_plotOptions(column = list(stacking = 'fill')) %>% 
      hc_add_theme(hc_theme_flat()) %>% 
      hc_title(text = '类目销售趋势') %>% 
      hc_legend(align = 'right', 
                verticalAlign = 'middle', 
                layout = 'vertical')
  })
  
  ## tab04 =======================================
  
  output$order_2018_qiu_goods_count <- renderValueBox({
    valueBox(
      value = sum(order_2018_qiu_cat1$goods_count), 
      '款数', 
      icon = icon('credit-card')
    )
  })
  output$order_2018_qiu_goods_num <- renderValueBox({
    valueBox(
      value = sum(order_2018_qiu_cat1$goods_num),
      '件数', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  output$order_2018_qiu_sale_amount <- renderValueBox({
    valueBox(
      value = sum(order_2018_qiu_cat1$sale_amount), 
      '销售金额', 
      icon = icon('credit-card')
    )
  })
  output$order_2018_qiu_origin_amount <- renderValueBox({
    valueBox(
      value = sum(order_2018_qiu_cat1$origin_amount), 
      '吊牌金额', 
      icon = icon('credit-card')
    )
  })
  output$order_2018_qiu_avg_sale_price <- renderValueBox({
    valueBox(
      value = round(sum(order_2018_qiu_cat1$sale_amount)*10000/sum(order_2018_qiu_cat1$goods_num), 1), 
      '平均售价', 
      icon = icon('credit-card'), 
      color = 'purple'
    )
  })
  output$order_2018_qiu_avg_origin_price <- renderValueBox({
    valueBox(
      value = round(sum(order_2018_qiu_cat1$origin_amount)*10000/sum(order_2018_qiu_cat1$goods_num), 1), 
      '平均吊牌价', 
      icon = icon('credit-card')
    )
  })
  output$order_2018_qiu_table <- DT::renderDT({
    datatable(sale_order_qiu_cat1, 
              rownames = FALSE, 
              extensions = 'Buttons', 
              options = list(
                dom = 't', 
                buttons = c('excel', 'csv', 'copy'), 
                pageLength = 20, 
                columnDefs = list(list(className = 'dt-center', targets = 1:16), 
                                  list(width = '40px', targets = 1)))) %>%
      formatStyle('数量同比%',
                  backgroundColor = styleInterval(100, c('orange', 'lightgreen'))) %>% 
      formatStyle('金额同比%',
                  backgroundColor = styleInterval(100, c('orange', 'lightgreen'))) %>% 
      formatStyle('吊牌同比%',
                  backgroundColor = styleInterval(100, c('orange', 'lightgreen'))) %>% 
      formatStyle('吊牌价同比%',
                  backgroundColor = styleInterval(100, c('orange', 'lightgreen')))
  })
  
}


