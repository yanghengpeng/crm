<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()                        + request.getContextPath() + "/";
%>
<html>
<head>
    <base href="<%=basePath%>">
    <title>演示文件上传功能</title>
</head>
<body>
<%--
    文件上传的表单，必须满足三个条件
    1、表单组件标签只能使用<input type="file">
    2、请求方式只能用Post请求
           post请求:参数通过请求头提交到后台,参数放在URL后面;只能向后台提交文本数据;对参数长度有限制;数据不安全; 效率高
           get请求:参数通过请求体提交到后台;既能提交文件数据,又能提交二进制数据;理论上对参数长度没有限制;相对安全;效率相对较低
    3、文件上传的表单编码格式只能用multipart/form-data
           根据HTTP协议的规定,浏览器每次向后台提交参数,都会对参数进行统一编码,默认采用的编码格式是urlencoded
           urlencoded这种编码格式只能对文本数据进行编码
           浏览器每次向后台提交参数,都会首先把所有的参数转换成字符串,然后对这些数据统一进行urlencoded编码
           文件上传的表单编码格式只能用multipart/form-data:enctype="multipart/form-data"
--%>
   <form action="workbench/activity/fileUpload.do" method="post" enctype="multipart/form-data">
       <input type="file" name="myFile"> <br>
       <input type="text" name="myName"> <br>
       <input type="submit" value="上传">
   </form>
</body>
</html>
