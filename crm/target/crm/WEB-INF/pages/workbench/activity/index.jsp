<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()                        + request.getContextPath() + "/";
%>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<link rel="stylesheet" type="text/css" href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css">

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>

<script type="text/javascript">

	$(function(){
		//给创建按钮添加单击事件
        $("#createActivityBtn").click(function () {
        	//可以做一些初始化工作
			//清空上次创建市场活动时填写的表单数据-------->清空表单数据
			$("#createActivityForm").get(0).reset();         //jQuery对象转dom对象
			//弹出创建市场活动的模态窗口
			$("#createActivityModal").modal("show");

		})

		//给保存按钮添加单击事件
		$("#saveCreateActivityBtn").click(function () {
			//发请求---收集参数
			var owner = $("#create-marketActivityOwner").val();
            var name = $.trim($("#create-marketActivityName").val());
            var startDate = $("#create-startDate").val();
            var endDate = $("#create-endDate").val();
            var cost = $.trim($("#create-cost").val());
            var description = $.trim($("#create-description").val());

            //表单验证---判断参数是否合法
			if(owner == ""){
				alert("所有者不能为空");
				return;
			}
			if(name == ""){
				alert("名称不能为空");
				return;
			}
			if(startDate != "" && endDate != ""){
				//使用字符串的大小代替日期的大小
				if(endDate < startDate){
					alert("结束日期不能比开始日期小");
					return;
				}
			}
			//成本只能为非负整数-------->正则表达式  ^(([1-9]\d*)|0)$
			var regExp = /^(([1-9]\d*)|0)$/;
			if(!regExp.test(cost)){
				alert("成本只能是非负整数");
			}

			//发送ajax请求
			$.ajax({
				url:"workbench/activity/saveCreateActivity.do",
				data:{
					owner:owner,
					name:name,
					startDate:startDate,
					endDate:endDate,
					cost:cost,
					description:description
				},
				type:"post",
				dataType:"json",
				success:function (data){
				   //创建活动保存后，重新刷新页面
                   if(data.code == "1"){
					   //关闭模态窗口
					   $("#createActivityModal").modal("hide");
					   //刷新市场活动列，显示第一页数据，保持每页显示条数不变   ------>后面再做
					   queryActivityByConditionForPage(1,$("#demo_pag1").bs_pagination("getOption","rowsPerPage"));
				   }else{
                   	   //提示信息
					   alert(data.message);
					   $("#createActivityModal").modal("show");
				   }
				}
			})
		})

		//给开始日期、结束日期文本框添加日历插件
		$(".myDate").datetimepicker({
			language:"zh-CN",     //设置语言
			format:"yyyy-mm-dd",  //日期格式
			minView:"month",      //可以选择的最小视图
			//initialDate:new Date(), //初始化显示的日期
			autoclose:true,       //选择完日期或者时间之后，是否自动关闭日历
			todayBtn:true,        //是否显示"今天"按钮
			clearBtn:true         //清空按钮
		})

		//当市场页面加载完成的时候，展示所有数据的第一页以及所有数据的总记录条数，默认每页显示10条
		queryActivityByConditionForPage(1,10);

		//给"查询"按钮添加单击事件
        $("#queryActivityBtn").click(function () {
             //当用户点击"查询"按钮，查询所有符合条件的数据的第一页以及所有符合条件的总条数
			queryActivityByConditionForPage(1,$("#demo_pag1").bs_pagination("getOption","rowsPerPage"));
		})

		//给全选按钮，添加单击事件
        $("#chechAll").click(function () {
            //如果"全选"按钮是点中的状态，则列表中所有的checkbox都选中
/*			if(this.checked == true){
				$("#tBody input[type='checkbox']").prop("checked",true);
			}else {
				$("#tBody input[type='checkbox']").prop("checked",false);
			}*/
			$("#tBody input[type='checkbox']").prop("checked",this.checked)
		})

		//这种方法不会起效果，因为  选择器.事件(function(){})只能给固有元素添加事件
/*		$("#tBody input[type='checkbox']").click(function () {
			//所有的checkbox选中，那么全选就选中，有一个没选中，全选就不选中
			if($("#tBody input[type='checkbox']").size() == $("#tBody input[type='checkbox']:checked").size()){
				$("#chechAll").prop("checked", true);
			}else{
				$("#chechAll").prop("checked", false);
			}
		})*/
        $("#tBody").on("click","input[type='checkbox']", function () {
			if($("#tBody input[type='checkbox']").size() == $("#tBody input[type='checkbox']:checked").size()){
				$("#chechAll").prop("checked", true);
			}else{
				$("#chechAll").prop("checked", false);
			}
		})

        //删除市场活动
		$("#deleteActivityBtn").click(function () {
			//收集参数，获取列表中选中的checkbox，再获取他们的value值（id）
			//获取列表中选中的checkbox
			var checkedIds = $("#tBody input[type = 'checkbox']:checked");
			if(checkedIds.size() == 0){
				alert("请选择要删除的市场活动");
				return;
			}
			//弹窗确定删除嘛？
			if( window.confirm("确定删除吗？")){
				//再获取他们的value值（Activity的id值）
				var ids="";
				$.each(checkedIds,function (index, object) {
					ids += "id=" + object.value + "&";
				})
				ids.substr(0, ids.length-1)
				//发送请求
				$.ajax({
					url:"workbench/activity/deleteActivityByIds.do",
					data:ids,
					type:"post",
					dataType:"json",
					success:function (data) {
						if(data.code == "1"){
							//刷新市场活动列表，显示第一页数据，保持每页显示条数不变
							queryActivityByConditionForPage(1,$("#demo_pag1").bs_pagination("getOption","rowsPerPage"));
						}else{
							//提示失败信息
							alert(data.message);
						}
					}
				})
			}
		})

		//修改市场活动
        $("#editActivityBtn").click(function () {
            //收集参数
			//获取列表中选中的checkbox
			var checkedIds = $("#tBody input[type = 'checkbox']:checked");
			if(checkedIds.size() == 0){
				alert("请选择需要修改的市场活动");
				return;
			}else if(checkedIds.size() > 1 ){
				alert("每次只能修改一条数据...")
				return;
			}
			var id = checkedIds.val();

			//发起ajax请求
			$.ajax({
				url:"workbench/activity/queryActivityById.do",
				data:{id:id},
				type:"post",
				dataType:"json",
				success:function (data) {
					//把市场活动信息显示在修改的模态窗口之上
					$("#edit-id").val(data.id);
					$("#edit-marketActivityOwner").val(data.owner);
					$("#edit-marketActivityName").val(data.name);
					$("#edit-startTime").val(data.startDate);
					$("#edit-endTime").val(data.endDate);
					$("#edit-cost").val(data.cost);
                    $("#edit-description").val(data.description);
                    //弹出模态窗口
					$("#editActivityModal").modal("show");
				}
			})
		})

		//用户填写表单
		//用户点击更新
		$("#saveEditActivity").click(function () {
			//收集参数
			var id = $("#edit-id").val();
			var owner = $("#edit-marketActivityOwner").val();
			var name = $.trim($("#edit-marketActivityName").val());
			var startDate = $.trim($("#edit-startTime").val());
			var endDate = $.trim($("#edit-endTime").val());
			var cost = $.trim($("#edit-cost").val());
			var description = $.trim($("#edit-description").val());

			//表单验证
			//表单验证---判断参数是否合法
			if(owner == ""){
				alert("所有者不能为空");
				return;
			}
			if(name == ""){
				alert("名称不能为空");
				return;
			}
			if(startDate != "" && endDate != ""){
				//使用字符串的大小代替日期的大小
				if(endDate < startDate){
					alert("结束日期不能比开始日期小");
					return;
				}
			}
			//成本只能为非负整数-------->正则表达式  ^(([1-9]\d*)|0)$
			var regExp = /^(([1-9]\d*)|0)$/;
			if(!regExp.test(cost)){
				alert("成本只能是非负整数");
			}

			//发起请求
			$.ajax({
				url:"workbench/activity/saveEditActivity.do",
				data:{
					id:id,
					owner:owner,
					name:name,
					startDate:startDate,
					endDate:endDate,
					cost:cost,
					description:description
				},
				type:"post",
				dataType:"json",
				success:function (data) {
					if(data.code == "1"){
						//关闭模态窗口
						$("#editActivityModal").modal("hide");
						//刷新市场 活动页面
						queryActivityByConditionForPage($("#demo_pag1").bs_pagination("getOption","currentPage"),$("#demo_pag1").bs_pagination("getOption","rowsPerPage"));
					}else{
						alert(data.message);
						//模态窗口不关闭
						$("#editActivityModal").modal("show");
					}
				}
			})
		})

		//批量导出市场活动
		$("#exportActivityAllBtn").click(function () {
            //发送下载的同步请求
			window.location.href = "workbench/activity/exportAllActivities.do";
		})

		//给"导入"按钮添加单击事件
		$("#importActivityBtn").click(function () {
			//收集参数----->excel文件
			var activityFileName = $("#activityFile").val();;  //只能获取上传文件的文件名
			//根据文件名---->表单验证
			var suffix = activityFileName.substr(activityFileName.lastIndexOf(".") + 1).toLowerCase();
			if(suffix != "xls"){
				alert("只支持xls文件");
				return;
			}
			var activityFile = $("#activityFile")[0].files[0];  //files是数组
			//表单验证-------->验证文件的大小(不超过5M)
			if(activityFile.size > 1024 * 1024 * 5){
				alert("文件大小不能超过5M");
				return;
			}
			//FormData是ajax提供的接口,可以模拟键值对,向后台提交参数（不但可以提交字符串数据、还可以提交二进制数据）
			var formData = new FormData();
			formData.append("activityFile", activityFile);
            //发起ajax请求
			$.ajax({
				url:"workbench/activity/importActivity.do",
				data:formData,
				type:"post",
				dataType:"json",
				processData:false,    //设置ajax向后台提交参数之前,是否把参数统一转换成字符串,默认是true
				contentType:false,     //设置ajax向后台提交参数之前,是否把所有的参数统一按urlencoded编码,默认是true
				success:function (data) {
					if(data.code == "1"){
						//提示成功导入记录条数
						alert("成功导入" + data.retData + "条记录");
						$("#importActivityModal").modal("hide");
						//刷新列表
						queryActivityByConditionForPage(1,$("#demo_pag1").bs_pagination("getOption","rowsPerPage"));
					}else {
						alert(data.message);
						$("#importActivityModal").modal("show");
					}
				}
			})
		})
	});

	//将查询活动记录的代码封装成函数-------------->代码复用，谁需要用，谁就去调用!!!!
	function queryActivityByConditionForPage(pageNo, pageSize) {
		//收集参数
		var name = $("#query-name").val();
		var owner = $("#query-owner").val();
		var startDate = $("#query-startDate").val();
		var endDate = $("#query-endDate").val();
		//var pageNo = 1;
		//var pageSize = 10;
		//发送请求
		$.ajax({
			url:"workbenach/activity/queryActivityByConditionForPage.do",
			data:{
				name:name,
				owner:owner,
				startDate:startDate,
				endDate:endDate,
				pageNo:pageNo,
				pageSize:pageSize
			},
			type:"post",
			dataType: "json",
			success:function (data) {
				//显示总条数
				//$("#totalRowsB").html(data.totalRows);
				//显示市场活动的列表，遍历activityList，拼接所有行数据
				var htmlStr = "";
				$.each(data.activityList, function (index,object) {
					htmlStr += "<tr class=\"active\">";
					htmlStr += "		<td><input type=\"checkbox\" value=\""+ object.id +"\"/></td>";
					htmlStr += "		<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/activity/detailActivity.do?id="+ object.id +"'\">"+ object.name +"</a></td>";
					htmlStr += " <td>"+ object.owner +"</td>";
					htmlStr += "<td>"+ object.startDate +"</td>";
					htmlStr += "<td>"+ object.endDate +"</td>";
					htmlStr += "</tr>";
				});
				$("#tBody").html(htmlStr);

				//把全选按钮取消
				$("#chechAll").prop("checked", false);

				//计算总页数
				var totalPages = 1;
				if(data.totalRows % pageSize == 0 ){
					totalPages = data.totalRows / pageSize;
				}else{
					totalPages = parseInt(data.totalRows / pageSize) + 1;
				}

				//实现分页查询的功能，调用bs_pagination工具函数，显示翻页信息
				$("#demo_pag1").bs_pagination({
					totalPages:totalPages,       //总页数，必填（必须自己手动算好之后，传过来）剩下的都是可选的，都采用默认值
					currentPage:pageNo,        //默认当前页号

					rowsPerPage:pageSize,       //每页显示的记录条数

					totalRows:data.totalRows,       //总的记录条数

					visiblePageLinks:5,   //最多可以显示的卡片数

					showGoToPage:true,    //是否显示跳转到第几页，默认是true
					showRowsPerpage:true, //是否显示每页的记录条数，默认是true
                    showRowsInfo: true,   //是否显示记录的信息，默认是显示

					//当页号切换之后，执行这个函数，会返回切换之后所在页面的pageNo和pageSize
					onChangePage:function(event,pageObj){
						//当切换页号的时候，执行一些代码
						queryActivityByConditionForPage(pageObj.currentPage, pageObj.rowsPerPage);
					}
				})
			}
		})
	}
</script>
</head>
<body>

	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form" id="createActivityForm" >
					
						<div class="form-group">
							<label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-marketActivityOwner">
                                   <c:forEach items="${userList}" var="u" >
									   <option value="${u.id}">${u.name}</option>
								   </c:forEach>
								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-marketActivityName">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startDate" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control myDate" id="create-startDate" readonly>
							</div>
							<label for="create-endDate" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control myDate" id="create-endDate" readonly>
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveCreateActivityBtn" >保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form">
					    <input type="hidden" id="edit-id">
						<div class="form-group">
							<label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-marketActivityOwner">
									<c:forEach items="${userList}" var="u" >
										<option value="${u.id}">${u.name}</option>
									</c:forEach>
								</select>
							</div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName" value="发传单">
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-startTime" value="2020-10-10">
							</div>
							<label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-endTime" value="2020-10-20">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost" value="5,000">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description">市场活动Marketing，是指品牌主办或参与的展览会议与公关市场活动，包括自行主办的各类研讨会、客户交流会、演示会、新产品发布会、体验会、答谢会、年会和出席参加并布展或演讲的展览会、研讨会、行业交流会、颁奖典礼等</textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveEditActivity">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 导入市场活动的模态窗口 -->
    <div class="modal fade" id="importActivityModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">导入市场活动</h4>
                </div>
                <div class="modal-body" style="height: 350px;">
                    <div style="position: relative;top: 20px; left: 50px;">
                        请选择要上传的文件：<small style="color: gray;">[仅支持.xls]</small>
                    </div>
                    <div style="position: relative;top: 40px; left: 50px;">
                        <input type="file" id="activityFile">
                    </div>
                    <div style="position: relative; width: 400px; height: 320px; left: 45% ; top: -40px;" >
                        <h3>重要提示</h3>
                        <ul>
                            <li>操作仅针对Excel，仅支持后缀名为XLS的文件。</li>
                            <li>给定文件的第一行将视为字段名。</li>
                            <li>请确认您的文件大小不超过5MB。</li>
                            <li>日期值以文本形式保存，必须符合yyyy-MM-dd格式。</li>
                            <li>日期时间以文本形式保存，必须符合yyyy-MM-dd HH:mm:ss的格式。</li>
                            <li>默认情况下，字符编码是UTF-8 (统一码)，请确保您导入的文件使用的是正确的字符编码方式。</li>
                            <li>建议您在导入真实数据之前用测试文件测试文件导入功能。</li>
                        </ul>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button id="importActivityBtn" type="button" class="btn btn-primary">导入</button>
                </div>
            </div>
        </div>
    </div>
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="query-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="query-owner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control" type="text" id="query-startDate" />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control" type="text" id="query-endDate">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="queryActivityBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createActivityBtn" ><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editActivityBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteActivityBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				<div class="btn-group" style="position: relative; top: 18%;">
                    <button type="button" class="btn btn-default" data-toggle="modal" data-target="#importActivityModal" ><span class="glyphicon glyphicon-import"></span> 上传列表数据（导入）</button>
                    <button id="exportActivityAllBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（批量导出）</button>
                    <button id="exportActivityXzBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（选择导出）</button>
                </div>
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="chechAll"/></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="tBody">
<%--						<tr class="active">
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
                            <td>2020-10-10</td>
                            <td>2020-10-20</td>
                        </tr>--%>
					</tbody>
				</table>
				<div id="demo_pag1"></div>
			</div>

			<%--<div style="height: 50px; position: relative;top: 30px;">
				<div>
					<button type="button" class="btn btn-default" style="cursor: default;">共<b id="totalRowsB">50</b>条记录</button>
				</div>
				<div class="btn-group" style="position: relative;top: -34px; left: 110px;">
					<button type="button" class="btn btn-default" style="cursor: default;">显示</button>
					<div class="btn-group">
						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
							10
							<span class="caret"></span>
						</button>
						<ul class="dropdown-menu" role="menu">
							<li><a href="#">20</a></li>
							<li><a href="#">30</a></li>
						</ul>
					</div>
					<button type="button" class="btn btn-default" style="cursor: default;">条/页</button>
				</div>
				<div style="position: relative;top: -88px; left: 285px;">
					<nav>
						<ul class="pagination">
							<li class="disabled"><a href="#">首页</a></li>
							<li class="disabled"><a href="#">上一页</a></li>
							<li class="active"><a href="#">1</a></li>
							<li><a href="#">2</a></li>
							<li><a href="#">3</a></li>
							<li><a href="#">4</a></li>
							<li><a href="#">5</a></li>
							<li><a href="#">下一页</a></li>
							<li class="disabled"><a href="#">末页</a></li>
						</ul>
					</nav>
				</div>
			</div>--%>
			
		</div>
	</div>
</body>
</html>