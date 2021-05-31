
学习文章
http://luyx30.blog.51cto.com/1029851/1364446

yum install rrdtool


# 创建数据库
rrdtool create a1.rrd --step 300 DS:connect:GAUGE:1200:0:655350 DS:cpu:GAUGE:1200:0:100 DS:load:GAUGE:1200:0:100 DS:memory:GAUGE:1200:0:100 DS:iowait:GAUGE:1200:0:100 RRA:AVERAGE:0.5:1:672 RRA:AVERAGE:0.5:4:720 RRA:AVERAGE:0.5:96:365 RRA:MAX:0.5:1:672 RRA:MAX:0.5:6:720 RRA:MAX:0.5:144:365

# 定时更新数据
# rrdtool update a1.rrd N:${connect}:${cpu}:${load}:${memory}:${iowait}
rrdtool update a1.rrd N:10:2:2:5000:5

# 生成图片
rrdtool graph 169-24.png \
--start `date -d "-7 day" +%s` \
--width 1090 --height 546 \
-t "169.24 系统性能监控" \
-v "使用率(%)" \
DEF:t1=a1.rrd:connect:AVERAGE \
DEF:t2=a1.rrd:cpu:AVERAGE \
DEF:t3=a1.rrd:load:AVERAGE \
DEF:t4=a1.rrd:memory:AVERAGE \
DEF:t5=a1.rrd:iowait:AVERAGE \
CDEF:v1=t1,655.35,/ \
COMMENT:" \n" \
COMMENT:'监控项：--------------当前值-----------平均值-----------最大值-----------' \
COMMENT:" \n" \
LINE1:v1#00FF00:"IP Connect" \
GPRINT:t1:LAST:%13.0lf \
GPRINT:t1:AVERAGE:%13.0lf \
GPRINT:t1:MAX:%13.0lf \
COMMENT:" \n" \
LINE1:t2#F0FF0F:"CPU    Used" \
GPRINT:t2:LAST:%13.2lf \
GPRINT:t2:AVERAGE:%13.2lf \
GPRINT:t2:MAX:%13.2lf \
COMMENT:" \n" \
LINE1:t3#FF0000:"System Load" \
GPRINT:t3:LAST:%13.2lf \
GPRINT:t3:AVERAGE:%13.2lf \
GPRINT:t3:MAX:%13.2lf \
COMMENT:" \n" \
LINE1:t4#000000:"Memory  Used" \
GPRINT:t4:LAST:%13.2lf \
GPRINT:t4:AVERAGE:%13.2lf \
GPRINT:t4:MAX:%13.2lf \
COMMENT:" \n" \
LINE1:t5#4B0082:"iowait Used" \
GPRINT:t5:LAST:%13.2lf \
GPRINT:t5:AVERAGE:%13.2lf \
GPRINT:t5:MAX:%13.2lf \
COMMENT:" \n" \
COMMENT:"上次更新\: $(date '+%Y-%m-%d %H\:%M\:%S')"