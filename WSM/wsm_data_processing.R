# WSM数据处理

# 加载包
library(tidyverse)
library(lubridate)
library(plotly)
library(crosstalk)
library(mice)

# 加载数据 ============================================================
## 2017销售明细
wsm_sale_2017 <- read.table(file = "E:/dianjia/project_data/wsm/wsm_sale_2017.csv", 
                            header = TRUE, 
                            sep = ',', 
                            stringsAsFactors = FALSE)

### 查看数据
# View(head(wsm_sale_2017, 100))
# View(tail(wsm_sale_2017, 100))
# str(wsm_sale_2017)
### 数据格式
wsm_sale_2017$sale_date <- as.Date(wsm_sale_2017$sale_date)
wsm_sale_2017$sale_year <- year(wsm_sale_2017$sale_date)
wsm_sale_2017$goods_year <- as.integer(wsm_sale_2017$goods_year)
wsm_sale_2017$sale_quarter <- quarter(wsm_sale_2017$sale_date)
wsm_sale_2017$sale_month <- month(wsm_sale_2017$sale_date, label = TRUE)
wsm_sale_2017$sale_num <- as.integer(wsm_sale_2017$sale_num)
wsm_sale_2017$sale_amount <- as.numeric(wsm_sale_2017$sale_amount)
wsm_sale_2017$origin_amount <- as.numeric(wsm_sale_2017$origin_amount)
### 缺失值和异常值
# md.pattern(wsm_sale_2017[, 15:19])
# summary(wsm_sale_2017[, 15:19])

## 商品信息
wsm_goods_info <- read.table(file = "E:/dianjia/project_data/wsm/wsm_goods_info.csv", 
                             header = TRUE, 
                             sep = ',', 
                             stringsAsFactors = FALSE)
wsm_goods_info$shangshi_date <- as.Date(wsm_goods_info$shangshi_date)
### 查看数据
# str(wsm_goods_info)
# View(head(wsm_goods_info, 100))

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
View(head(wsm_orders_2018q3, 100))


# 数据汇总 ============================================================

## 7-12月：各季节销售占比(数量、金额)
wsm_goods_sale_2017 %>% 
  filter(sale_month >= '7月', 
         sale_date <= '2017-12-31') %>% 
  group_by(sale_month, goods_season) %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = sum(sale_amount, na.rm = TRUE), 
            origin_amount = sum(origin_amount, na.rm = TRUE)) %>% 
  hchart('column', 
         hcaes(x = sale_month, 
               y = sale_num, 
               group = goods_season)) %>% 
  hc_plotOptions(column = list(stacking = 'fill')) %>% 
  hc_add_theme(hc_theme_darkunica())

wsm_goods_sale_2017 %>% 
  filter(sale_month >= '7月', 
         sale_date <= '2017-12-31') %>% 
  group_by(sale_month, goods_season) %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = sum(sale_amount, na.rm = TRUE), 
            origin_amount = sum(origin_amount, na.rm = TRUE)) %>% 
  hchart('column', 
         hcaes(x = sale_month, 
               y = sale_amount, 
               group = goods_season)) %>% 
  hc_plotOptions(column = list(stacking = 'fill')) %>% 
  hc_add_theme(hc_theme_darkunica())


## 销售-
wsm_sale_sum <- wsm_sale_2017 %>% 
  filter(!region_name %in% c('电商', '一期特卖')) %>% 
  group_by(sale_year, sale_quarter, sale_month, up_down, cat1_name, goods_material, 
           goods_year, goods_season, goods_boduan1, is_guoji, discount_level) %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = sum(sale_amount, na.rm = TRUE), 
            origin_amount = sum(origin_amount, na.rm = TRUE)) %>% 
  arrange(sale_year, sale_quarter, sale_month)

write.csv(wsm_sale_sum, 
          file = 'E:/dianjia/project_data/wsm/wsm_sale_sum.csv', 
          row.names = FALSE)


## 上市节奏
## 2017年上市482个款，还有部分款没有上市日期，主要是外采特卖款，实际上市款数多于此数目
wsm_shangshi_2017 <- wsm_goods_info %>% 
  filter(shangshi_date <= '2017-12-31') %>% 
  group_by(shangshi_month, cat1_name, goods_material, goods_season, goods_boduan) %>% 
  summarise(goods_count = n()) %>% 
  arrange(shangshi_month)




wsm_sale_2017_month_q34 %>% 
  hchart(type = 'scatter', 
         hcaes(x = sale_month, 
               y = sale_amount, 
               z = sale_num, 
               group = is_guoji)) %>% 
  hc_legend(enabled = TRUE) %>% 
  hc_add_theme(hc_theme_flat())


wsm_sale_2017_cat1_q34 %>% 
  hchart(type = 'scatter', 
         hcaes(x = sale_num, 
               y = sale_amount, 
               z = discount, 
               group = cat1_name)) %>% 
  hc_legend(enabled = TRUE) %>% 
  hc_add_theme(hc_theme_flat())

wsm_goods_info %>% 
  filter(shangshi_date >= '2017-01-01', 
         shangshi_date <= '2017-12-31', 
         goods_season == '3-秋季') %>% 
  group_by(shangshi_date, cat1_name) %>% 
  summarise(goods_count = n()) %>% 
  hchart(type = 'column', 
         hcaes(x = shangshi_date, 
               y = goods_count, 
               group = cat1_name)) %>% 
  hc_plotOptions(column = list(stacking = 'fill')) %>% 
  hc_add_theme(hc_theme_flat())






write.csv(wsm_shangshi_2017, 
          file = './wsm_shangshi_2017', 
          row.names = FALSE)




## 处理库存数据
wsm_goods_stock <- read.table(file = "E:/dianjia/project_data/wsm/goods_stock_20180516.csv", 
                            header = TRUE, 
                            sep = ',', 
                            stringsAsFactors = FALSE)
View(head(wsm_goods_stock, 20))
str(wsm_goods_stock)

## 2017年秋季商品的库存数据
wsm_goods_stock_2017qiu <- wsm_goods_stock %>% 
  filter(年份 == 2017,
         季节 == '3-秋季')

write.csv(wsm_goods_stock_2017qiu, 
          file = 'E:/dianjia/project_data/wsm/wsm_goods_stock_2017qiu.csv', 
          row.names = FALSE)


## 处理销售数据
wsm_goods_sale_2017qiu <- read.table(file = "E:/dianjia/project_data/wsm/goods_sale_2017qiu.csv", 
                              header = TRUE, 
                              sep = ',', 
                              stringsAsFactors = FALSE)
View(head(wsm_goods_sale_2017qiu, 20))
str(wsm_goods_sale_2017qiu)
wsm_goods_sale_2017qiu$吊牌额 <- as.integer(wsm_goods_sale_2017qiu$吊牌额)
wsm_goods_sale_2017qiu$实收金额 <- as.integer(wsm_goods_sale_2017qiu$实收金额)
wsm_goods_sale_2017qiu[is.na(wsm_goods_sale_2017qiu)] <- 0


## 汇总到品类
wsm_goods_sale_2017qiu %>% 
  group_by(品类) %>% 
  summarise(sale_num = sum(数量), 
            origin_amount = sum(吊牌额), 
            sale_amount = sum(实收金额))


## 汇总到skc
wsm_goods_sale_2017qiu %>% 
  group_by(款号, 色号) %>% 
  summarise(sale_num = sum(数量), 
            origin_amount = sum(吊牌额), 
            sale_amount = sum(实收金额))



# 打印程序执行时间
## 开始时间
start_time <- Sys.time()
## 执行程序

for (i in 1:length(sale_201317$sale_quarter)){
  if (is.na(sale_201317$sale_goods_year[i])) {
    sale_201317$is_guoji[i] = '未知'
  } else if(sale_201317$sale_goods_year[i] > 1){
    sale_201317$is_guoji[i] = '过季'
  } else if(sale_201317$sale_goods_season[i] > 1){
    sale_201317$is_guoji[i] = '过季'
  } else {
    sale_201317$is_guoji[i] = '应季'
  }
}

## 结束时间
end_time <- Sys.time()
## 时间间隔
running_time <- end_time - start_time
running_time




