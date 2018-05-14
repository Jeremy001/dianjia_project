# WSM数据处理

# 加载包
library(tidyverse)
library(lubridate)
library(plotly)
library(crosstalk)

# 加载数据 ============================================================
## 2017销售明细
wsm_sale_2017 <- read.table(file = "./wsm_sale_2017.txt", 
                            header = TRUE, 
                            sep = '\t', 
                             fileEncoding = 'utf-16',
                             stringsAsFactors = FALSE)
wsm_sale_2017$sale_date <- as.Date(wsm_sale_2017$sale_date)
wsm_sale_2017$goods_year <- as.integer(wsm_sale_2017$goods_year)
wsm_sale_2017$sale_quarter <- quarter(wsm_sale_2017$sale_date)
wsm_sale_2017$sale_num <- as.integer(wsm_sale_2017$sale_num)
wsm_sale_2017$sale_amount <- as.numeric(wsm_sale_2017$sale_amount)
wsm_sale_2017$origin_amount <- as.numeric(wsm_sale_2017$origin_amount)

# View(head(wsm_sale_2017, 100))
View(tail(wsm_sale_2017, 100))
# str(wsm_sale_2017)

## 商品信息
wsm_goods_info <- read.table(file = "./wsm_goods_info.txt", 
                             header = TRUE, 
                             sep = '\t', 
                             fileEncoding = 'utf-16',
                             stringsAsFactors = FALSE)
wsm_goods_info$shangshi_date <- as.Date(wsm_goods_info$shangshi_date)
# str(wsm_goods_info)
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

## 上市节奏
## 2017年上市482个款，还有部分款没有上市日期，主要是外采特卖款，实际上市款数多于此数目
wsm_shangshi_2017 <- wsm_goods_info %>% 
  filter(shangshi_date >= '2017-01-01', 
         shangshi_date <= '2017-12-31') %>% 
  group_by(shangshi_month, cat1_name, goods_material, goods_season, goods_boduan) %>% 
  summarise(goods_count = n()) %>% 
  arrange(shangshi_month)

write.csv(wsm_shangshi_2017, 
          file = './wsm_shangshi_2017', 
          row.names = FALSE)

## 销售明细-到类目
wsm_sale_cat %>% 
  group_by(sale_month) %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 2), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 2)) %>% 
  View()



sale_year <- sale_2013_2017 %>% 
  group_by(sale_year) %>% 
  summarise(goods_num = sum(goods_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 2), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 2), 
            settel_amount = round(sum(settel_amount, na.rm = TRUE)/10000, 2)) %>% 
  mutate(origin_price = round(origin_amount/goods_num*10000,2), 
         sale_price = round(sale_amount/goods_num*10000, 2),
         discount_rate = round(sale_amount/origin_amount, 2))


sale_201317 %>% 
  head(100) %>% 
  View()


sale_201317$cat2_id <- NULL

sale_201317 %>% 
  group_by(cat1_name, cat2_name) %>% 
  summarise(count_n = n()) %>% 
  View()

sale_201317 %>% 
  filter(cat2_name == '未定义') %>% 
  group_by(cat1_name, cat2_name) %>% 
  summarise(count_n = n()) %>% 
  View()


cat_level <- read.table(file = './data/xmoom_cat_level.txt', 
                        header = TRUE, 
                        sep = ';', 
                        stringsAsFactors = FALSE, 
                        fileEncoding = 'utf-16')

View(cat_level)
str(cat_level)

cat_level %>% 
  group_by(cat_level1_id) %>% 
  summarise(count_n = n()) %>% 
  filter(count_n == 1) %>% 
  View()

cat_level %>% 
  filter(cat_level1_id %in% c('B', 'G','H', 'J', 'P', 'TZ', 'Z'))


## 把数据写出 =================================================
write.csv(sale_201317, 
          file = 'sale_2013_2017.csv', 
          row.names = FALSE)


View(head(sale_2013_2017, 100))


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




