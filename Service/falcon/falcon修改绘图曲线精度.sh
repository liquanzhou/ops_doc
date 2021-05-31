falcon修改绘图曲线精度.sh




http://book.open-falcon.org/zh/dev/change_graph_rra.html


默认的，Open-Falcon只保存最近12小时的原始监控数据，12小时之后的数据被降低精度、采样存储。

如果默认的精度不能满足你的需求，可以按照如下步骤，修改绘图曲线的存储精度。

第一步，修改graph组件的RRA，并重新编译graph组件
graph组件的RRA，定义在文件 graph/rrdtool/rrdtool.go中，默认如下:

// RRA.Point.Size
const (
    RRA1PointCnt   = 720 // 1m一个点存12h
    RRA5PointCnt   = 576 // 5m一个点存2d
    // ...
)

func create(filename string, item *cmodel.GraphItem) error {
    now := time.Now()
    start := now.Add(time.Duration(-24) * time.Hour)
    step := uint(item.Step)

    c := rrdlite.NewCreator(filename, start, step)
    c.DS("metric", item.DsType, item.Heartbeat, item.Min, item.Max)

    // 设置各种归档策略
    // 1分钟一个点存 12小时
    c.RRA("AVERAGE", 0.5, 1, RRA1PointCnt)

    // 5m一个点存2d
    c.RRA("AVERAGE", 0.5, 5, RRA5PointCnt)
    c.RRA("MAX", 0.5, 5, RRA5PointCnt)
    c.RRA("MIN", 0.5, 5, RRA5PointCnt)

    // ...

    return c.Create(true)
}
比如，你只想保存90天的原始数据，可以将代码修改为:

// RRA.Point.Size
const (
    RRA1PointCnt   = 129600 // 1m一个点存90d，取值 90*24*3600/60
)

func create(filename string, item *cmodel.GraphItem) error {
    now := time.Now()
    start := now.Add(time.Duration(-24) * time.Hour)
    step := uint(item.Step)

    c := rrdlite.NewCreator(filename, start, step)
    c.DS("metric", item.DsType, item.Heartbeat, item.Min, item.Max)

    // 设置各种归档策略
    // 1分钟一个点存 90d
    c.RRA("AVERAGE", 0.5, 1, RRA1PointCnt)

    return c.Create(true)
}
第二步，清除graph的历史数据
清除已上报的所有指标的历史数据，即删除所有的rrdfile。不删除历史数据，已上报指标的精度更改将不能生效。

第三步，重新部署graph服务
编译修改后的graph源码，关停原有的graph老服务、发布修改后的graph。

只需要修改graph组件、不需要修改Open-Falcon的其他组件，新的精度就能生效。你可以通过Dashboard、Screen来查看新的精度的绘图曲线。

1.1.1. 注意事项:
修改监控绘图曲线精度时，需要：

修改graph源代码，更新RRA
清除graph的历史数据。不删除历史数据，已上报指标的精度更改将不能生效
除了graph之外，Open-Falcon的其他任何组件 不需要被修改
修改RRA后，可能会出现"绘图曲线点数过多、浏览器被卡死"的问题。请合理规划RRA存储的点数，或者调整绘图曲线查询时的时间段选择。