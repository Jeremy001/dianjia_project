# X-MOOM数据处理

# 加载包
library(tidyverse)
library(lubridate)

# 加载数据 ============================================================

## 2013-2015销售额
sale_2013_2015 <- read.table(file = "./data/sale_2013_2015.txt",
                             header = TRUE, 
                             sep = '\t', 
                             fileEncoding = 'utf-16',
                             stringsAsFactors = FALSE)

## 2016销售额
sale_2016 <- read.table(file = "./data/sale_2016_2.txt",
                        header = TRUE, 
                        sep = '\t', 
                        fileEncoding = 'utf-16',
                        stringsAsFactors = FALSE)

## 2017销售额
sale_2017 <- read.table(file = "./data/sale_2017.txt",
                        header = TRUE, 
                        sep = '\t', 
                        fileEncoding = 'utf-16',
                        stringsAsFactors = FALSE)

## 2018Q1销售额
sale_2018_q1 <- read.table(file = "./data/sale_2018q1.txt", 
                           header = TRUE, 
                           sep = '\t',
                           fileEncoding = "utf-16",
                           stringsAsFactors = FALSE)

## union 2013-2017的5年数据
sale_2013_2017 <- sale_2013_2015 %>% 
  rbind(sale_2016) %>% 
  rbind(sale_2017)

## 处理基础字段 ===================================================
## 去掉部分字段：拨段名称(重)15、商品属性6名称17、商品年份(重)23
sale_2013_2017 <- sale_2013_2017[, c(1:14, 16, 18:22, 24:30)]

## 设置2013_2017字段名称为英文
colnames(sale_2013_2017) <- c('sale_year', 'sale_month', 'sale_date', 'qudao', 'region', 
                              'store_id', 'store_name', 'store_level_name', 'store_level_id', 
                              'order_id', 'goods_year', 'sale_price', 'origin_price', 
                              'boduan_name', 'kuoxing', 'cat1_name', 'cat2_name', 'origin_cat', 
                              'designer', 'season', 'goods_name', 'order_type', 'goods_id', 
                              'goods_num', 'origin_amount', 'sale_amount', 'settel_amount')

## 剔除origin_price = 0 的记录
sale_2013_2017 <- sale_2013_2017 %>% 
  filter(origin_price > 0)

## 根据日期生成季度字段
sale_2013_2017$sale_quarter <- quarter(sale_2013_2017$sale_date)

## 修改sale_date字段的类型为日期
sale_2013_2017$sale_date <- as.Date(sale_2013_2017$sale_date)

## 处理年份 =======================================================

## 处理goods_year为数字，不足4位的补足成4位，前面加20
### 两种方法：str_sub(), str_replace()
for (i in 1:length(sale_201317$goods_year)){
  if (sale_201317$goods_year[i] == '未定义'){
    sale_201317$goods_year[i] = '未定义'
  }else if (nchar(sale_201317$goods_year[i]) == 5){
    sale_201317$goods_year[i] = str_replace(sale_201317$goods_year[i], '年', '')
  }else {
    sale_201317$goods_year[i] = paste('20', 
                                      str_replace(sale_201317$goods_year[i], '年', ''),
                                      sep = '')
  }
}

## 处理季节 =======================================================

## 商品季节中去除年份
for (i in 1:length(sale_2013_2017$season)){
  if(sale_2013_2017$season[i] == '未定义'){
    sale_2013_2017$goods_season[i] = '未定义'
  } else {
    sale_2013_2017$goods_season[i] = str_sub(sale_2013_2017$season[i], 4, 4)
  }
}
sale_2013_2017$season <- NULL

## 商品季节：1-春、2-夏、3-秋、4-冬、5-未定义
### 1-春
sale_chun <- sale_2013_2017 %>% 
  filter(goods_season == '春') %>% 
  mutate(goods_season = paste('1', '春', sep = '-'))
### 2-夏
sale_xia <- sale_2013_2017 %>% 
  filter(goods_season == '夏') %>% 
  mutate(goods_season = paste('2', '夏', sep = '-'))
### 3-秋
sale_qiu <- sale_2013_2017 %>% 
  filter(goods_season == '秋') %>% 
  mutate(goods_season = paste('3', '秋', sep = '-'))
### 4-冬
sale_dong <- sale_2013_2017 %>% 
  filter(goods_season == '冬') %>% 
  mutate(goods_season = paste('4', '冬', sep = '-'))
### 5-未定义
sale_weidingyi <- sale_2013_2017 %>% 
  filter(goods_season == '未定义') %>% 
  mutate(goods_season = paste('5', '未定义', sep = '-'))
### rbind
sale_201317 <- sale_chun %>% 
  rbind(sale_xia) %>% 
  rbind(sale_qiu) %>% 
  rbind(sale_dong) %>% 
  rbind(sale_weidingyi)
### 季节编码
sale_201317$goods_season_id <- as.integer(str_sub(sale_201317$goods_season, 1, 1))

## 处理过季 =======================================================

## 过季商品标记
### sale_year - goods_year
sale_201317$sale_goods_year <- sale_201317$sale_year - as.integer(sale_201317$goods_year)
### sale_quater - goods_season_id
sale_201317$sale_goods_season <- sale_201317$sale_quarter - sale_201317$goods_season_id

### 如果年份是未定义，则不知是否过季
### 如果商品年份小于销售年份，则是过季商品
### 如果商品年份=销售年份，但是销售季度>商品季节+1，则是过季商品
### 其他的是应季商品
for (i in 1:length(sale_201317$sale_quarter)){
  if (is.na(sale_201317$sale_goods_year[i])) {
    sale_201317$is_guoji[i] = '未知'
  } else if(sale_201317$sale_goods_year[i] > 0){
    sale_201317$is_guoji[i] = '过季'
  } else if(sale_201317$sale_goods_season[i] > 1){
    sale_201317$is_guoji[i] = '过季'
  } else {
    sale_201317$is_guoji[i] = '应季'
  }
}


## 处理一二级类目 =================================================

## 处理异常数据
sale_201317[sale_201317$cat1_name == '未定义' & 
              sale_201317$cat2_name == 'GA皮草', 
            "cat1_name"] <- 'G皮草'
sale_201317[sale_201317$cat1_name == '未定义' & 
              sale_201317$cat2_name == 'ND长裤', 
            "cat1_name"] <- 'N牛仔裤'

## 处理只有一个二级类目的一级类目，部分的二级类目是"未定义"
## cat1_name %in% c('G皮草', 'J马夹', 'TZ套装')
## cat2_name %in% c('GA皮草', 'JA马夹', 'TZ套装')
sale_201317[sale_201317$cat1_name == 'G皮草' & 
              sale_201317$cat2_name == '未定义', 
            "cat2_name"] <- 'GA皮草'
sale_201317[sale_201317$cat1_name == 'J马夹' & 
              sale_201317$cat2_name == '未定义', 
            "cat2_name"] <- 'JA马夹'
sale_201317[sale_201317$cat1_name == 'TZ套装' & 
              sale_201317$cat2_name == '未定义', 
            "cat2_name"] <- 'TZ套装'

## 老的类目：'女装'和'未定义'，一二级类目统一为'old'
## 套装：一级类目=二级类目='TZ'
## 剩余的一级类目提取第一个字符，二级类目提取前两个字符
for (i in 1:length(sale_201317$cat1_name)){
  if (sale_201317$cat1_name[i] %in% c('女装', '未定义')) {
    sale_201317$cat1_id[i] = sale_201317$cat1_name[i]
    sale_201317$cat2_id[i] = sale_201317$cat2_name[i]
  } else if(sale_201317$cat2_name[i] == '未定义'){
    sale_201317$cat1_id[i] = str_sub(sale_201317$cat1_name, 1, 1)
    sale_201317$cat2_id[i] = '未定义'
  } else if(sale_201317$cat1_name[i] == 'TZ套装'){
    sale_201317$cat1_id[i] = 'TZ'
    sale_201317$cat2_id[i] = 'TZ'
  } else {
    sale_201317$cat1_id[i] = str_sub(sale_201317$cat1_name, 1, 1)
    sale_201317$cat2_id[i] = str_sub(sale_201317$cat2_name, 1, 2)
  }
}


# 打印程序执行时间
## 开始时间
start_time <- Sys.time()
## 执行程序
for (i in 1:length(sale_201317$cat1_name)){
  if (sale_201317$cat1_name[i] %in% c('女装', '未定义')) {
    sale_201317$cat1_id[i] = sale_201317$cat1_name[i]
    sale_201317$cat2_id[i] = sale_201317$cat2_name[i]
  } else if(sale_201317$cat2_name[i] == '未定义'){
    sale_201317$cat1_id[i] = str_sub(sale_201317$cat1_name, 1, 1)
    sale_201317$cat2_id[i] = '未定义'
  } else if(sale_201317$cat1_name[i] == 'TZ套装'){
    sale_201317$cat1_id[i] = 'TZ'
    sale_201317$cat2_id[i] = 'TZ'
  } else {
    sale_201317$cat1_id[i] = str_sub(sale_201317$cat1_name, 1, 1)
    sale_201317$cat2_id[i] = str_sub(sale_201317$cat2_name, 1, 2)
  }
}
## 结束时间
end_time <- Sys.time()
## 时间间隔
running_time <- end_time - start_time
running_time



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
          file = 'sale_2013_2017.csv')




