
# this is a shinydashboard for wsm

# 加载包 =====================================================================================
library(tidyverse)
library(lubridate)
library(shinydashboard)
library(plotly)
library(crosstalk)
library(highcharter)
library(mice)
library(DT)
library(recharts)

# ui.r =======================================================================================

ui <- dashboardPage(
  ## dashboardHeader =================================
  dashboardHeader(
    title = 'WSM秋季订货分析'
  ),
  ## dashboardSiderbar ===============================
  dashboardSidebar(
    sidebarMenu(
      ### menuitem01 ===================================
      menuItem(
        text = '2017年生意结构', tabName = 'tab01'
      ),
      ### menuitem02 ===================================
      menuItem(
        text = '2017秋品上市节奏', tabName = 'tab02'
      ),
      ### menuitem03 ===================================
      menuItem(
        text = '2017秋品销售分析', tabName = 'tab03'
      ),
      ### menuitem04 ===================================
      menuItem(
        text = '2018秋品订货分析', tabName = 'tab04'
      )
    )
  ), 
  ## dashboardBody ===================================
  dashboardBody(
    tabItems(
      ### menuitem01 ===================================
      tabItem(
        tabName = 'tab01', 
        fluidRow(
          tabBox(
            title = '2017年生意指标', 
            id = 'tabset1', 
            width = 12,
            height = '170px', 
            tabPanel(
              '整体', 
              valueBoxOutput('sale_num', width = 2), 
              valueBoxOutput('sale_amount', width = 2), 
              valueBoxOutput('origin_amount', width = 2), 
              valueBoxOutput('avg_sale_price', width = 2), 
              valueBoxOutput('avg_origin_price', width = 2), 
              valueBoxOutput('discount', width = 2)
            ),
            tabPanel(
              '秋季', 
              valueBoxOutput('sale_num_qiu', width = 2), 
              valueBoxOutput('sale_amount_qiu', width = 2), 
              valueBoxOutput('origin_amount_qiu', width = 2), 
              valueBoxOutput('avg_sale_price_qiu', width = 2), 
              valueBoxOutput('avg_origin_price_qiu', width = 2), 
              valueBoxOutput('discount_qiu', width = 2)
            ),
            tabPanel(
              '秋季-应季', 
              valueBoxOutput('sale_num_qiu_yingji', width = 2), 
              valueBoxOutput('sale_amount_qiu_yingji', width = 2), 
              valueBoxOutput('origin_amount_qiu_yingji', width = 2), 
              valueBoxOutput('avg_sale_price_qiu_yingji', width = 2), 
              valueBoxOutput('avg_origin_price_qiu_yingji', width = 2), 
              valueBoxOutput('discount_qiu_yingji', width = 2)
            )
          )
        ), 
        fluidRow(
          box(DTOutput('wsm_sale_2017_table'), 
              width = 12)
        ), 
        fluidRow(
          tabBox(
            title = '销售趋势和季节占比', 
            id = 'tabset2', 
            width = 12,
            height = '500px', 
            tabPanel(
              '销售数量', 
              box(highchartOutput('wsm_season_sale_num1'), 
                  width = 6), 
              box(highchartOutput('wsm_season_sale_num2'), 
                  width = 6)
            ),
            tabPanel(
              '销售金额', 
              box(highchartOutput('wsm_season_sale_amount1'), 
                  width = 6), 
              box(highchartOutput('wsm_season_sale_amount2'), 
                  width = 6)
            ),
            tabPanel(
              '吊牌金额', 
              box(highchartOutput('wsm_season_origin_amount1'), 
                  width = 6), 
              box(highchartOutput('wsm_season_origin_amount2'), 
                  width = 6)
            )
          )
        )
      ),
      ### menuitem02 ===================================
      tabItem(
        tabName = 'tab02',
        fluidRow(
          box(highchartOutput('qiu_cat1_num', height = 280), 
              width = 6),
          box(highchartOutput('qiu_cat1_price', height = 280), 
              width = 6)
        ),
        fluidRow(
          box(highchartOutput('qiu_shangshi_date'), 
              width = 12)
        )
      ),
      ### menuitem03 ===================================
      tabItem(
        tabName = 'tab03',
        fluidRow(
          box()
        )
      ),
      ### menuitem04 ===================================
      tabItem(
        tabName = 'tab04',
        fluidRow(
          box()
        )
      )
    )
  )
)


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
wsm_sale_2017_season <- wsm_goods_sale_2017 %>% 
  filter(sale_date >= '2017-01-01',
         sale_date <= '2017-12-31', 
         !region_name %in% c('电商', '一期特卖')) %>% 
  group_by(goods_season) %>% 
  summarise(sale_num = sum(sale_num, na.rm = TRUE), 
            sale_amount = round(sum(sale_amount, na.rm = TRUE)/10000, 1), 
            origin_amount = round(sum(origin_amount, na.rm = TRUE)/10000, 1)) %>% 
  mutate(sale_num_prop = paste(round(sale_num*100/sum(sale_num), 1), '%', sep = ''), 
         sale_amount_prop = paste(round(sale_amount*100/sum(sale_amount), 1), '%', sep = ''), 
         origin_amount_prop = paste(round(origin_amount*100/sum(origin_amount), 1), '%', sep = ''))








# server.r ===================================================================================

server <- function(input, output){
  
  ## tab01
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
  
  ## tab2
  output$qiu_cat1_num <- renderHighchart({
    wsm_goods_info %>% 
      filter(shangshi_date >= '2017-01-01', 
             shangshi_date <= '2017-12-31', 
             goods_season == '3-秋季', 
             goods_year == 2017) %>% 
      group_by(cat1_name) %>% 
      summarise(goods_num = n(), 
                avg_origin_price = mean(origin_price)) %>% 
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
                avg_origin_price = mean(origin_price)) %>% 
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
  

  
  
  
}


# app ========================================================================================

shinyApp(ui, server)
