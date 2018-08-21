# 加载包
library(tidyverse)

goods_info <- read.csv('E:/dianjia/project_data/edenbo/goods_info.csv', 
                       header = TRUE, 
                       stringsAsFactors = FALSE)
size_info <- read.csv('E:/dianjia/project_data/edenbo/size_info.csv', 
                      header = TRUE, 
                      stringsAsFactors = FALSE)
goods_size <- full_join(goods_info[, -12], 
                        size_info[, -3], 
                        by = c('尺码组名称' = '尺码组名称'))
goods_size <- goods_size[, c(1:11, 25, 12:24)]
write.csv(goods_size, 
          file = 'E:/dianjia/project_data/edenbo/goods_size.csv', 
          row.names = FALSE)





goods_size[1:10, c(1:11, 25, 12:24)]
size_info[, -3]

str(goods_info)

View(head(goods_info, 100))
