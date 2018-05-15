
# this is a shinydashboard for wsm

# 加载包 =====================================================================================
library(tidyverse)
library(lubridate)
library(shinydashboard)
library(plotly)
library(crosstalk)
library(highcharter)
library(mice)
library(recharts)

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

write.csv(wsm_shangshi_2017, 
          file = './wsm_shangshi_2017', 
          row.names = FALSE)

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

# ui.r =======================================================================================

ui <- dashboardPage(
  ## dashboardHeader =================================
  dashboardHeader(
    title = 'WSM销售简析'
  ),
  ## dashboardSiderbar ===============================
  dashboardSidebar(
    sidebarMenu(
      ### menuitem01 ===================================
      menuItem(
        text = '销售表现', tabName = 'tab01'
      ),
      ### menuitem02 ===================================
      menuItem(
        text = '上市节奏', tabName = 'tab02'
      )
    )
  ), 
  ## dashboardBody ===================================
  dashboardBody(
    tabItems(
      tabItem(
        tabName = 'tab01'
      ),
      tabItem(
        tabName = 'tab02',
        fluidRow(
          box()
        )
      )
    )
  )
)



# server.r ===================================================================================

server <- function(input, output){
  
}


# app ========================================================================================

shinyApp(ui, server)
