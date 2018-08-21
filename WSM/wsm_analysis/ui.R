
# this is a shinydashboard for wsm

# 加载包 =====================================================================================
library(tidyverse)
library(lubridate)
library(shinydashboard)
library(highcharter)
library(DT)

dashboardPage(
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
              '秋品', 
              valueBoxOutput('sale_num_qiu', width = 2), 
              valueBoxOutput('sale_amount_qiu', width = 2), 
              valueBoxOutput('origin_amount_qiu', width = 2), 
              valueBoxOutput('avg_sale_price_qiu', width = 2), 
              valueBoxOutput('avg_origin_price_qiu', width = 2), 
              valueBoxOutput('discount_qiu', width = 2)
            ),
            tabPanel(
              '应季-秋品', 
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
          tabBox(
            title = 'Q3-Q4秋品销售', 
            id = 'tabset1', 
            width = 12,
            tabPanel(
              '整体秋品', 
              fluidRow(
                valueBoxOutput('sale_num_qiu_q34', width = 2), 
                valueBoxOutput('sale_amount_qiu_q34', width = 2), 
                valueBoxOutput('origin_amount_qiu_q34', width = 2), 
                valueBoxOutput('avg_sale_price_qiu_q34', width = 2), 
                valueBoxOutput('avg_origin_price_qiu_q34', width = 2), 
                valueBoxOutput('discount_qiu_q34', width = 2)
              ),
              fluidRow(
                box(DTOutput('wsm_2017_qiu_q34_table'), width = 12)
              )
            ),
            tabPanel(
              '应季秋品', 
              fluidRow(
                valueBoxOutput('sale_num_qiu_yingji_q34', width = 2), 
                valueBoxOutput('sale_amount_qiu_yingji_q34', width = 2), 
                valueBoxOutput('origin_amount_qiu_yingji_q34', width = 2), 
                valueBoxOutput('avg_sale_price_qiu_yingji_q34', width = 2), 
                valueBoxOutput('avg_origin_price_qiu_yingji_q34', width = 2), 
                valueBoxOutput('discount_qiu_yingji_q34', width = 2)
              ),
              fluidRow(
                box(DTOutput('wsm_2017_qiu_q34_yingji_table'), width = 12)
              )
            ),
            tabPanel(
              '过季秋品', 
              fluidRow(
                valueBoxOutput('sale_num_qiu_guoji_q34', width = 2), 
                valueBoxOutput('sale_amount_qiu_guoji_q34', width = 2), 
                valueBoxOutput('origin_amount_qiu_guoji_q34', width = 2), 
                valueBoxOutput('avg_sale_price_qiu_guoji_q34', width = 2), 
                valueBoxOutput('avg_origin_price_qiu_guoji_q34', width = 2), 
                valueBoxOutput('discount_qiu_guoji_q34', width = 2)
              ),
              fluidRow(
                box(DTOutput('wsm_2017_qiu_q34_guoji_table'), width = 12)
              )
            ), 
            tabPanel(
              '应季VS过季', 
              fluidRow(
                box(DTOutput('sale_2017_q34_qiu_cat1_yingguo'), width = 12)
              )
            )
          )
        ), 
        fluidRow(
          tabBox(
            title = '应季过季和类目结构', 
            id = 'tabset2', 
            width = 12,
            height = '1100px', 
            tabPanel(
              '销售数量',
              fluidRow(
                box(highchartOutput('wsm_month_guoji_num1'), 
                    width = 5), 
                box(highchartOutput('wsm_cat_num1'), 
                    width = 7)
              ), 
              fluidRow(
                box(checkboxGroupInput('cat1_name1', 
                                       '请选择类目：', 
                                       choices = c('T恤', '半身裙', '衬衣', '大衣', '短裤', '风衣', '开衫', '连衣裙', 
                                                   '毛衣', '皮衣', '七分裤', '套头衫', '外套', '羽绒', '长裤'), 
                                       selected = '毛衣', 
                                       inline = TRUE), 
                    width = 12)
              ),
              fluidRow(
                box(highchartOutput('wsm_cat_num2'), 
                    width = 12)
              )
            ),
            tabPanel(
              '销售金额', 
              fluidRow(
                box(highchartOutput('wsm_month_guoji_sale1'), 
                    width = 5), 
                box(highchartOutput('wsm_cat_sale1'), 
                    width = 7)
              ), 
              fluidRow(
                box(checkboxGroupInput('cat1_name2', 
                                       '请选择类目：', 
                                       choices = c('T恤', '半身裙', '衬衣', '大衣', '短裤', '风衣', '开衫', '连衣裙', 
                                                   '毛衣', '皮衣', '七分裤', '套头衫', '外套', '羽绒', '长裤'), 
                                       selected = '毛衣', 
                                       inline = TRUE), 
                    width = 12)
              ), 
              fluidRow(
                box(highchartOutput('wsm_cat_sale2'), 
                    width = 12)
              )
            ),
            tabPanel(
              '吊牌金额', 
              fluidRow(
                box(highchartOutput('wsm_month_guoji_origin1'), 
                    width = 5), 
                box(highchartOutput('wsm_cat_origin1'), 
                    width = 7)
              ), 
              fluidRow(
                box(checkboxGroupInput('cat1_name3', 
                                       '请选择类目：', 
                                       choices = c('T恤', '半身裙', '衬衣', '大衣', '短裤', '风衣', '开衫', '连衣裙', 
                                                   '毛衣', '皮衣', '七分裤', '套头衫', '外套', '羽绒', '长裤'), 
                                       selected = '毛衣', 
                                       inline = TRUE), 
                    width = 12)
              ), 
              fluidRow(
                box(highchartOutput('wsm_cat_origin2'), 
                    width = 12)
              )
            )
          )
        )
      ),
      ### menuitem04 ===================================
      tabItem(
        tabName = 'tab04',
        fluidRow(
          valueBoxOutput('order_2018_qiu_goods_count', width = 2), 
          valueBoxOutput('order_2018_qiu_goods_num', width = 2), 
          valueBoxOutput('order_2018_qiu_sale_amount', width = 2),  # 假定7折
          valueBoxOutput('order_2018_qiu_origin_amount', width = 2), 
          valueBoxOutput('order_2018_qiu_avg_sale_price', width = 2), 
          valueBoxOutput('order_2018_qiu_avg_origin_price', width = 2)
        ),
        fluidRow(
          box(DTOutput('order_2018_qiu_table'), 
              width = 12)
        )
      )
    )
  )
)

