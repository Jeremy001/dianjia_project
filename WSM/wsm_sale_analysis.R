
# this is a shinydashboard for wsm

# 加载包 =====================================================================================
library(tidyverse)
library(lubridate)
library(shinydashboard)
library(plotly)
library(crosstalk)


# 基础数据 ===================================================================================
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

## 商品信息
wsm_goods_info <- read.table(file = "./wsm_goods_info.txt", 
                             header = TRUE, 
                             sep = '\t', 
                             fileEncoding = 'utf-16',
                             stringsAsFactors = FALSE)
wsm_goods_info$shangshi_date <- as.Date(wsm_goods_info$shangshi_date)

## left_join，从商品信息表中获取goods_material,up_down,shangshi_date字段
wsm_sale_2017 <- left_join(x = wsm_sale_2017, 
                           y = wsm_goods_info[, c('goods_id', 'goods_material', 'up_down', 'shangshi_date')], 
                           by = c('goods_id' = 'goods_id'))
wsm_sale_2017 <- wsm_sale_2017 %>% 
  filter(sale_date <= '2017-12-31')

## 上市节奏
### 2017年上市482个款，还有部分款没有上市日期，主要是外采特卖款，实际上市款数多于此数目
wsm_shangshi_2017 <- wsm_goods_info %>% 
  filter(shangshi_date <= '2017-12-31') %>% 
  group_by(shangshi_month, cat1_name, goods_material, goods_season, goods_boduan) %>% 
  summarise(goods_count = n()) %>% 
  arrange(shangshi_month)

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
