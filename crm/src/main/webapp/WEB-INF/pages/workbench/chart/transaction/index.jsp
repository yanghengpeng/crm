<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()                        + request.getContextPath() + "/";
%>
<html>
<head>
    <base href="<%=basePath%>">
    <%--引用jQuery--%>
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <%--引入echarts插件--%>
    <script type="text/javascript" src="jquery/echarts/echarts.min.js"></script>
    <script type="text/javascript">
        //对容器调用工具函数
        $(function () {

            //发起请求
            $.ajax({
                url:"workbench/chart/transaction/queryCountOfTranGroupByStage.do",
                type:"post",
                dataType:"json",
                success:function (data) {
                    //调用echarts工具函数
                    //基于准备好的Dom容器，初始化echarts实例
                    var myChart = echarts.init(document.getElementById('main'));

                    //指定图表的配置项和数据
                    var option = {
                        title: {
                            text: '交易统计图标',
                            subtext:'交易图标中各个阶段的数量'
                        },
                        tooltip: {
                            trigger: 'item',
                            formatter: '{a} <br/>{b} : {c}'
                        },
                        toolbox: {
                            feature: {
                                dataView: { readOnly: false },
                                restore: {},
                                saveAsImage: {}
                            }
                        },
                        series: [
                            {
                                name: '数据量',
                                type: 'funnel',
                                left: '10%',
                                width: '80%',
                                label: {
                                    formatter: '{b}'
                                },
                                labelLine: {
                                    show: false
                                },
                                itemStyle: {
                                    opacity: 0.7
                                },
                                emphasis: {
                                    label: {
                                        position: 'inside',
                                        formatter: '{b}: {c}'
                                    }
                                },
                                data:data
                                /*[
                                    { value: 60, name: 'Visit' },
                                    { value: 40, name: 'Inquiry' },
                                    { value: 20, name: 'Order' },
                                    { value: 80, name: 'Click' },
                                    { value: 100, name: 'Show' }
                                ]*/
                            }
                        ]
                    }

                    //使用刚指定的配置项和数据显示图表
                    myChart.setOption(option);
                }
            })
        })
    </script>
</head>
<body>
<%--为echarts准备一个Dom容器--%>
<div id="main" style="width: 600px;height: 400px;"></div>
</body>
</html>
