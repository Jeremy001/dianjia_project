
# X-MOOM数据分析

# 加载包 =============================================================================
library(tidyverse)
library(recharts)
library(lubridate)
library(plotly)
library(ggthemes)
library(crosstalk)
library(DT)
options(digits = 2)

# 导入数据 ==========================================================================
sale_2013_2017 <- read.table('E:/dianjia/project_data/xmoom/sale_2013_2017.csv',
                             sep = ',', 
                             header = TRUE, 
                             stringsAsFactors = FALSE)

View(head(sale_2013_2017))
## 数据汇总

### 年
sale_year <- sale_2013_2017 %>% 
  group_by(sale_year) %>% 
  summarise(goods_num = sum(goods_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 2), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 2), 
            settel_amount = round(sum(settel_amount, na.rm = TRUE)/10000, 2)) %>% 
  mutate(origin_price = round(origin_amount/goods_num*10000,2), 
         sale_price = round(sale_amount/goods_num*10000, 2),
         discount_rate = round(sale_amount/origin_amount, 2))

datatable(sale_year, 
          rownames = FALSE)

### 年+季
sale_year_quarter <- sale_2013_2017 %>% 
  group_by(sale_year, sale_quarter) %>% 
  summarise(goods_num = sum(goods_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 2), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 2), 
            settel_amount = round(sum(settel_amount, na.rm = TRUE)/10000, 2)) %>% 
  mutate(origin_price = round(origin_amount/goods_num*10000,2), 
         sale_price = round(sale_amount/goods_num*10000, 2),
         discount_rate = round(sale_amount/origin_amount, 2))
#### 转换成列联表
llb_year_quarter <- xtabs(sale_amount ~sale_year + sale_quarter, data = sale_year_quarter)  
prop.table(llb_year_quarter, 1)


#### 商品数量、金额上下半年的比例约为：4：6
#### 金额：Q1至Q4的比例约为：0.22：0.18：0.22：0.38
#### 数量：Q1至Q4的比例约为：0.18：0.22：0.28：0.32


### 年+月+商品季节
sale_year_goods_season <- sale_2013_2017 %>% 
  group_by(sale_year, sale_month, goods_season) %>% 
  summarise(goods_num = sum(goods_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 2), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 2), 
            settel_amount = round(sum(settel_amount, na.rm = TRUE)/10000, 2)) %>% 
  mutate(origin_price = round(origin_amount/goods_num*10000,2), 
         sale_price = round(sale_amount/goods_num*10000, 2),
         discount_rate = round(sale_amount/origin_amount, 2))
#### 转换成列联表
llb_year_goods_season <- sale_year_goods_season %>% 
  filter(sale_year == 2017, sale_month >= 7)
llb_year_goods_season_2 <- xtabs(sale_amount ~goods_season + sale_month, 
                                 data = llb_year_goods_season)  
prop.table(llb_year_goods_season_2, 1)
addmargins(prop.table(llb_year_goods_season_2))*100
addmargins(prop.table(llb_year_goods_season_2))

sale_year_goods_season %>% 
  filter(goods_season == '3-秋') %>% 
  group_by(sale_year, goods_season) %>% 
  summarise(goods_num = sum(goods_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE), 2), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE), 2), 
            settel_amount = round(sum(settel_amount, na.rm = TRUE), 2)) %>% 
  mutate(origin_price = round(origin_amount/goods_num*10000,2), 
         sale_price = round(sale_amount/goods_num*10000, 2),
         discount_rate = round(sale_amount/origin_amount, 2)) %>% 
  View()


CrossTable(llb_year_goods_season$goods_season, llb_year_goods_season$sale_month, digits = 2)


### 年+月
sale_year_month <- sale_2013_2017 %>% 
  group_by(sale_year, sale_month) %>% 
  summarise(goods_num = sum(goods_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 2), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 2), 
            settel_amount = round(sum(settel_amount, na.rm = TRUE)/10000, 2)) %>% 
  mutate(origin_price = round(origin_amount/goods_num*10000,2), 
         sale_price = round(sale_amount/goods_num*10000, 2),
         discount_rate = round(sale_amount/origin_amount, 2))
#### 转换成列联表
test_data <- sale_year_month %>% 
  filter(sale_year >= 2016)
llb_goods_num <- xtabs(goods_num ~sale_year + sale_month, data = test_data)  
prop.table(llb_goods_num, 1)

### 联动图，2013-2017年总销售额和各月销售额
sd_sale_year_month <- SharedData$new(sale_year_month, 
                                     ~sale_year, 
                                     'Select a year')
base_plot <- plot_ly(sd_sale_year_month, 
                     color = I('lightblue'), 
                     height = 500) %>% 
  group_by(sale_year)
#### 总图，年汇总对比,bar-chart
p1 <- base_plot %>% 
  summarise(goods_num = sum(goods_num)) %>% 
  arrange(sale_year) %>% 
  add_bars(x = ~goods_num, 
           y = ~factor(sale_year, levels = sale_year), 
           hoverinfo = 'x + y') %>% 
  layout(barmode = 'overlay', 
         xaxis = list(title = 'goods_num'), 
         yaxis = list(title = ''))
#### 分图，月趋势，line-chart
p2 <- base_plot %>% 
  add_lines(x = ~sale_month, 
            y = ~goods_num) %>% 
  layout(xaxis = list(title = ''))
#### 组合主图和分图，联动
subplot(p1, p2, titleX = TRUE, widths = c(0.3, 0.7)) %>% 
  layout(margin = list(l = 100)) %>% 
  hide_legend() %>% 
  highlight(dynamic = TRUE, selectize = TRUE)





### 部分日期内批发退货单退货商品较多，当天的销售数据为负数，如2013/2/28,2014/3/4
### 部分日期做了特卖，当天销售数量、连带很高，折扣率低，如2013/1/14,2013/2/16



### 2017下半年秋季商品销售
sale_2017_q3 <- sale_2013_2017 %>% 
  filter(sale_year == 2017, 
         sale_month >= 7, 
         goods_season == '3-秋') %>% 
  mutate(sale_date = as.Date(sale_date)) %>% 
  group_by(sale_year, sale_month, sale_date, cat1_name) %>% 
  summarise(goods_num = sum(goods_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 2), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 2))

sale_2017_q3 %>% 
  group_by(cat1_name) %>% 
  summarise(goods_num = sum(goods_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE), 2), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE), 2)) %>% 
  mutate(goods_num_prop = round(goods_num/sum(goods_num)*100, 2), 
         sale_amount_prop = round(sale_amount/sum(sale_amount)*100, 2)) %>% 
  arrange(-goods_num) %>% 
  View()






View(head(sale_2017_q3, 100))

### 2017下半年销售总量
sale_2017_q3 %>% 
  group_by(sale_year) %>% 
  summarise(goods_num = sum(goods_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE), 2), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE), 2), 
            settel_amount = round(sum(settel_amount, na.rm = TRUE), 2)) %>% 
  View()
### 2017下半年各类目销售量
sale_2017_q3 %>% 
  group_by(cat1_name) %>% 
  summarise(goods_num = sum(goods_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE), 2), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE), 2), 
            settel_amount = round(sum(settel_amount, na.rm = TRUE), 2)) %>% 
  mutate(goods_num_prop = round(goods_num/sum(goods_num)*100, 2), 
         sale_amount_prop = round(sale_amount/sum(sale_amount)*100, 2), 
         origin_amount_prop = round(origin_amount/sum(origin_amount)*100, 2)) %>% 
  arrange(cat1_name) %>% 
  View()

## 动画，不同类目不同的销售趋势，应该有不同的导入时间
head(sale_2017_q3) %>% 
  View()





### 联动图，2017年秋季各类目销售总件数和销售趋势(日)
sd_sale_2017_q3 <- SharedData$new(sale_2017_q3, 
                                     ~cat1_name, 
                                     '请选择一级类目：')
base_plot <- plot_ly(sd_sale_2017_q3, 
                     color = I('black'), 
                     height = 400) %>% 
  filter(cat1_name != 'A针织衫') %>% 
  group_by(cat1_name)
#### 总图，年汇总对比,bar-chart
p1 <- base_plot %>% 
  summarise(goods_num = sum(goods_num)) %>% 
  arrange(goods_num) %>% 
  add_bars(x = ~goods_num, 
           y = ~factor(cat1_name, levels = cat1_name), 
           hoverinfo = 'x + y') %>% 
  layout(barmode = 'overlay', 
         xaxis = list(title = 'goods_num'), 
         yaxis = list(title = ''))
p1
#### 分图，月趋势，line-chart
p2 <- base_plot %>% 
  add_lines(x = ~sale_date, 
            y = ~goods_num, 
            alpha = 0.5) %>% 
  layout(xaxis = list(title = ''))
p2
#### 组合主图和分图，联动
subplot(p1, p2, titleX = TRUE, widths = c(0.3, 0.7)) %>% 
  layout(margin = list(l = 120)) %>% 
  hide_legend() %>% 
  highlight(dynamic = TRUE, selectize = TRUE)


## 每天销售数据
sale_2013_2017_date <- sale_2013_2017 %>% 
  group_by(sale_year, sale_quarter, sale_month, sale_date) %>% 
  summarise(order_count = n_distinct(order_id), 
            store_count = n_distinct(store_id), 
            goods_num = sum(goods_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 2), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 2), 
            settel_amount = round(sum(settel_amount, na.rm = TRUE)/10000, 2)) %>% 
  mutate(origin_price = origin_amount/goods_num*10000, 
         sale_price = sale_amount/goods_num*10000,
         discount_rate = sale_amount/origin_amount, 
         sale_amount_per_store = round(sale_amount/store_count,2),
         kedanjia = sale_amount/order_count*10000, 
         liandailv = goods_num/order_count)

## 每月各季节商品的销售数据
## 
sale_2013_2017_month_season <- sale_2013_2017 %>% 
  group_by(sale_year, sale_quarter, sale_month, goods_season) %>% 
  summarise(goods_num = sum(goods_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 2), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 2), 
            settel_amount = round(sum(settel_amount, na.rm = TRUE)/10000, 2)) %>% 
  mutate(origin_price = origin_amount/goods_num*10000, 
         sale_price = sale_amount/goods_num*10000,
         discount_rate = sale_amount/origin_amount)

p <- sale_2013_2017_month_season %>% 
  filter(sale_year >= 2015) %>% 
  ggplot(aes(x = sale_month, 
             y = sale_amount,
             fill = goods_season)) + 
  geom_bar(position = 'stack', 
           stat = 'identity') + 
  facet_wrap(~sale_year) + 
  theme_solarized(light = FALSE) + 
  scale_colour_solarized("red")

ggplotly(p)

sale_2013_2017_month_season %>% 
  filter(sale_year >= 2015, 
         goods_season %in% c('春季', '夏季', '秋季', '冬季')) %>% 
  ggplot(aes(x = sale_month, y = sale_amount, fill = goods_season)) + 
  geom_area(position = 'stack') + 
  facet_grid(sale_year~.) + 
  theme_stata() + 
  scale_colour_stata()

sale_2013_2017_month_season %>% 
  filter(sale_year == 2017) %>% 
  eArea(xvar = ~sale_month, 
        yvar = ~goods_num, 
        series = ~goods_season, 
        theme = 1)

sale_2013_2017_month_season %>% 
  filter(sale_year == 2017) %>% 
  eLine(xvar = ~sale_month, 
        yvar = ~goods_num, 
        series = ~goods_season)


sale_2013_2017 %>% 
  filter(sale_year == 2017) %>% 
  group_by(goods_year) %>% 
  summarise(sale_amount = sum(sale_amount)) %>% 
  ggplot(aes(x = goods_year, y = sale_amount)) + 
  geom_bar(stat = 'identity')

View(sale_2013_2017_date)

sale_2013_2017 %>% 
  filter(sale_year == 2017, 
         sale_month == 1) %>% 
  View()


sale_2013_2017 %>% 
  filter(sale_date == '2017/12/1') %>% 
  View()


sale_2013_2017 %>% 
  group_by(sale_year, sale_quarter) %>% 
  summarise(goods_num = sum(goods_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 2), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 2)) %>% 
  mutate(year_quarter = paste(sale_year, sale_quarter, sep = '_'), 
         origin_price = origin_amount/goods_num*10000, 
         sale_price = sale_amount/goods_num*10000,
         discount_rate = sale_amount/origin_amount) %>% 
  View()

sale_2013_2017 %>% 
  group_by(sale_year, sale_month) %>% 
  summarise(goods_num = sum(goods_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 2), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 2)) %>% 
  mutate(year_month = paste(sale_year, sale_month, sep = '_'), 
         origin_price = origin_amount/goods_num*10000, 
         sale_price = sale_amount/goods_num*10000,
         discount_rate = sale_amount/origin_amount) %>% 
  View()

sale_2013_2017 %>% 
  filter(sale_year == 2017, 
         sale_month >= 11) %>% 
  group_by(sale_date) %>% 
  summarise(goods_num = sum(goods_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 2), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 2)) %>% 
  mutate(origin_price = origin_amount/goods_num*10000, 
         sale_price = sale_amount/goods_num*10000,
         discount_rate = sale_amount/origin_amount) %>% 
  order_by(sale_date) %>% 
  View()



### 年+季销售
sale_2013_2017 %>% 
  group_by(sale_year, sale_quarter) %>% 
  summarise(goods_num = sum(goods_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 2), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 2)) %>% 
  mutate(year_quarter = paste(sale_year, sale_quarter, sep = '_'), 
         discount_rate = sale_amount/origin_amount) %>% 
  eBar(xvar = ~year_quarter, ~goods_num, 
       stack = TRUE)


sale_2013_2017 %>% 
  group_by(sale_year, sale_quarter) %>% 
  summarise(goods_num = sum(goods_num, na.rm = TRUE), 
            sale_amount = sum(sale_amount, na.rm = TRUE)/10000, 
            origin_amount = sum(origin_amount, na.rm = TRUE)/10000) %>% 
  mutate(year_quarter = paste(sale_year, sale_quarter, sep = '_'), 
         discount_rate = sale_amount/origin_amount) %>% 
  eLine(xvar = ~year_quarter, 
        yvar = ~origin_amount)


str(sale_2013_2017)
sale_2013_2017_year
View(head(sale_2013_2017))
quarter('2018-01-01')













