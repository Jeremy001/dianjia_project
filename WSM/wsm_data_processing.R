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
View(head(wsm_sale_2017, 100))
View(tail(wsm_sale_2017, 100))
str(wsm_sale_2017)
### 数据格式
wsm_sale_2017$sale_date <- as.Date(wsm_sale_2017$sale_date)
wsm_sale_2017$sale_year <- year(wsm_sale_2017$sale_date)
wsm_sale_2017$goods_year <- as.integer(wsm_sale_2017$goods_year)
wsm_sale_2017$sale_quarter <- quarter(wsm_sale_2017$sale_date)
wsm_sale_2017$sale_num <- as.integer(wsm_sale_2017$sale_num)
wsm_sale_2017$sale_amount <- as.numeric(wsm_sale_2017$sale_amount)
wsm_sale_2017$origin_amount <- as.numeric(wsm_sale_2017$origin_amount)
### 缺失值和异常值
md.pattern(wsm_sale_2017[, 15:19])
summary(wsm_sale_2017[, 15:19])

## 商品信息
wsm_goods_info <- read.table(file = "E:/dianjia/project_data/wsm/wsm_goods_info.csv", 
                             header = TRUE, 
                             sep = ',', 
                             stringsAsFactors = FALSE)
wsm_goods_info$shangshi_date <- as.Date(wsm_goods_info$shangshi_date)
str(wsm_goods_info)
View(head(wsm_goods_info, 100))

## left_join，从商品信息表中获取goods_material,up_down,shangshi_date字段
wsm_sale_2017 <- left_join(x = wsm_sale_2017, 
                           y = wsm_goods_info[, c('goods_id', 'goods_material', 'up_down', 'shangshi_date')], 
                           by = c('goods_id' = 'goods_id'))
wsm_sale_2017 <- wsm_sale_2017 %>% 
  filter(sale_date <= '2017-12-31')

wsm_sale_2017 %>%
  head(100) %>%
  View()


# 数据汇总 ============================================================

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

str(wsm_sale_sum)
View(head(wsm_sale_sum))

wsm_sale_2017 %>% 
  filter(!region_name %in% c('电商', '一期特卖')) %>% 
  head(100) %>% 
  View()

wsm_sale_2017 %>% 
  group_by(region_name) %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = sum(sale_amount, na.rm = TRUE), 
            origin_amount = sum(origin_amount, na.rm = TRUE)) %>% 
  View()





## 上市节奏
## 2017年上市482个款，还有部分款没有上市日期，主要是外采特卖款，实际上市款数多于此数目
wsm_shangshi_2017 <- wsm_goods_info %>% 
  filter(shangshi_date <= '2017-12-31') %>% 
  group_by(shangshi_month, cat1_name, goods_material, goods_season, goods_boduan) %>% 
  summarise(goods_count = n()) %>% 
  arrange(shangshi_month)

write.csv(wsm_shangshi_2017, 
          file = './wsm_shangshi_2017', 
          row.names = FALSE)











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




