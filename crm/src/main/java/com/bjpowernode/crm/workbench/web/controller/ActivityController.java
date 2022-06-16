package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.constants.Constants;
import com.bjpowernode.crm.commons.domain.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.HSSFUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.ActivityRemark;
import com.bjpowernode.crm.workbench.service.ActivityRemarkService;
import com.bjpowernode.crm.workbench.service.ActivityService;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.util.*;

@Controller
public class ActivityController {
    @Autowired
    private UserService userService;

    @Autowired
    private ActivityService activityService;

    @Autowired
    private ActivityRemarkService activityRemarkService;

    @RequestMapping("/workbench/activity/index.do")
    public String index(HttpServletRequest request){
        //调用servuce层方法，查询所有的用户
        List<User> userList = userService.queryAllUsers();
        //把数据保存到request作用域中
        request.setAttribute("userList", userList);
        //请求转发，跳转到市场活动的主页面
        return "workbench/activity/index";
    }

    @ResponseBody
    @RequestMapping("/workbench/activity/saveCreateActivity.do")
    public Object saveCreateActivity(Activity activity, HttpSession session){
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        activity.setId(UUIDUtils.getUUID());
        activity.setCreateTime(DateUtils.formateDateTime(new Date()));
        activity.setCreateBy(user.getId());

        ReturnObject returnObject = new ReturnObject();
        try{
           //调用service层方法
           int ret = activityService.saveCreateActivity(activity);
           if(ret > 0){
               returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
           }else{
               returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
               returnObject.setMessage("系统忙，请稍后再试....");
           }
        }catch(Exception e){
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统忙，请稍后再试....");
        }
        return returnObject;
    }

    @ResponseBody
    @RequestMapping("/workbenach/activity/queryActivityByConditionForPage.do")
    public Object queryActivityByConditionForPage(String name, String owner, String startDate,
                                                  String endDate, int pageNo, int pageSize){
        //封装参数
        Map<String,Object> map = new HashMap<>();
        map.put("name",name);
        map.put("owner",owner);
        map.put("startDate",startDate);
        map.put("endDate",endDate);
        map.put("beginNo",(pageNo-1)*pageSize);
        map.put("pageSize",pageSize);

        //调用service层方法，查询数据
        List<Activity> activityList = activityService.queryActivityByConditionForPage(map);
        int totalRows = activityService.queryCountOfActivityByCondition(map);

        //根据查询结果，生成响应信息------>把查询结果封装到一个map集合中
        Map<String,Object> retMap = new HashMap<>();
        retMap.put("activityList", activityList);
        retMap.put("totalRows", totalRows);
        return retMap;
    }

    @ResponseBody
    @RequestMapping("/workbench/activity/deleteActivityByIds.do")
    public Object deleteActivityByIds(String[] id){
        ReturnObject returnObject = new ReturnObject();
        //调用service层方法，删除市场活动
        try{
            int ret = activityService.deleteActivityByIds(id);
            if(ret > 0){
               returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统忙，请稍后再试.....");
            }
        }catch (Exception e){
          e.printStackTrace();
        }
        return  returnObject;
    }

    @ResponseBody
    @RequestMapping("/workbench/activity/queryActivityById.do")
    public Object queryActivityById(String id){
        //调用service层方法，查询市场活动
        Activity activity = activityService.queryActivityById(id);
        return activity;
    }

    @ResponseBody
    @RequestMapping("/workbench/activity/saveEditActivity.do")
    public Object saveEditActivity(Activity activity, HttpSession session){
        ReturnObject returnObject = new ReturnObject();
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        //封装参数
        activity.setEditTime(DateUtils.formateDateTime(new Date()));
        activity.setEditBy(user.getId());
        //调用service层方法，保存修改的市场活动
        try{
            int ret = activityService.saveEditActivity(activity);
            if(ret > 0){
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统忙，请稍后再试...");
            }
        }catch (Exception e){
            e.printStackTrace();
        }
        return  returnObject;
    }

    @RequestMapping("/workbench/activity/fileDownload.do")
    public void fileDownload(HttpServletResponse response) throws IOException {
        //读磁盘上的文件，以流的形式返回
        //1、设置响应类型
        response.setContentType("application/octet-stream;charset=UTF-8");
        //2、获取输出流
        OutputStream outputStream = response.getOutputStream();

        //浏览器接收到响应信息之后，默认情况下，会直接在显示窗口中打开，即使打不开，也会调用电脑的相应的软件打开，只有实在打不开，才会激活文件下载窗口
        //设置响应头信息，使浏览器接收到响应信息之后，直接激活文件下载窗口，即使能打开也不会打开
        response.addHeader("Content-Disposition","attachment;filename=mystudentList.xls");

        //3、读取需要下载的文件
        FileInputStream fileInputStream = new FileInputStream("D:\\Java学习资料\\SSM框架项目\\课堂笔记\\createExcel\\studentList.xls");
        byte[] buff = new byte[256];
        int len = 0;
        while ((len = fileInputStream.read(buff)) != -1) {
            outputStream.write(buff, 0, len);
        }
        fileInputStream.close();
        outputStream.flush();
    }

    @RequestMapping("/workbench/activity/exportAllActivities.do")
    public void exportAllActivities(HttpServletResponse response) throws IOException {
        //查出所有的市场活动信息
        List<Activity> activityList = activityService.queryAllActivities();

        //用Apache-poi插件，创建excel文件
        //创建一个excel文件
        HSSFWorkbook hssfWorkbook = new HSSFWorkbook();
        //创建页
        HSSFSheet sheet = hssfWorkbook.createSheet("市场活动列表");
        //创建行，第一行
        HSSFRow row = sheet.createRow(0);
        //创建列
        HSSFCell cell = row.createCell(0);
        cell.setCellValue("Id");   //第一列,市场活动的id
        cell = row.createCell(1);
        cell.setCellValue("所有者");
        cell = row.createCell(2);
        cell.setCellValue("市场活动名称");
        cell = row.createCell(3);
        cell.setCellValue("开始日期");
        cell = row.createCell(4);
        cell.setCellValue("结束日期");
        cell = row.createCell(5);
        cell.setCellValue("成本");
        cell = row.createCell(6);
        cell.setCellValue("描述");
        cell = row.createCell(7);
        cell.setCellValue("创建时间");
        cell = row.createCell(8);
        cell.setCellValue("创建者");
        cell = row.createCell(9);
        cell.setCellValue("修改时间");
        cell = row.createCell(10);
        cell.setCellValue("修改者");

        //遍历activityList，创建HSSFRow对象，生成所有的数据行
        if(activityList != null && activityList.size() > 0){
            Activity activity =null;
            for(int i = 0; i < activityList.size(); i++){
                activity = activityList.get(i);  //每次拿出来一个市场活动

                //每个市场活动对应一行数据
                row = sheet.createRow(i+1);
                //每一行有11列
                cell = row.createCell(0);
                cell.setCellValue(activity.getId());
                cell = row.createCell(1);
                cell.setCellValue(activity.getOwner());
                cell = row.createCell(2);
                cell.setCellValue(activity.getName());
                cell = row.createCell(3);
                cell.setCellValue(activity.getStartDate());
                cell = row.createCell(4);
                cell.setCellValue(activity.getEndDate());
                cell = row.createCell(5);
                cell.setCellValue(activity.getCost());
                cell = row.createCell(6);
                cell.setCellValue(activity.getDescription());
                cell = row.createCell(7);
                cell.setCellValue(activity.getCreateTime());
                cell = row.createCell(8);
                cell.setCellValue(activity.getCreateBy());
                cell = row.createCell(9);
                cell.setCellValue(activity.getEditTime());
                cell = row.createCell(10);
                cell.setCellValue(activity.getEditBy());
            }
        }

/*        //根据hssfWorkbook对象，生成excel文件，这个文件是生成到服务器的！！！！！
        FileOutputStream fileOutputStream = new FileOutputStream("D:\\Java学习资料\\SSM框架项目\\课堂笔记\\createExcel\\activityList.xls");
        hssfWorkbook.write(fileOutputStream);
        //关闭资源
        fileOutputStream.close();
        hssfWorkbook.close();*/

        //再将这个保存在服务器的文件下载给用户的客户端电脑上
        //1、设置响应类型
        response.setContentType("application/octet-stream;charset=utf-8");
        //设置响应头信息，使浏览器接收到响应信息之后，直接激活文件下载窗口，即使能打开也不会打开
        response.addHeader("Content-Disposition","attachment;filename=activityList.xls");
        //2、获取输出流
        OutputStream out = response.getOutputStream();
/*        //3、读文件
        InputStream in = new FileInputStream("D:\\Java学习资料\\SSM框架项目\\课堂笔记\\createExcel\\studentList.xls");
        byte[] buff = new byte[256];
        int len = 0;
        while((len = in.read(buff)) != -1){
            out.write(buff, 0, len);
        }
        //4、关闭资源，自己创建的流自己关闭，out是Tomcat服务器创建的，我们不需要关
        in.close();*/
        hssfWorkbook.write(out);
        out.flush();
    }

    /**
       必须在springmvc的配置文件中配置springmvc中的那个工具类(文件上传解析器)
     */
    @ResponseBody
    @RequestMapping("/workbench/activity/fileUpload.do")
    public Object fileUpload(String userName, MultipartFile myFile) throws IOException {
        //把文本数据打印到控制台
        System.out.println("用户名字:" + userName);

        //把文件在服务器指定的目录中生成一个同样的文件
        File file = new File("D:\\Java学习资料\\SSM框架项目\\课堂笔记\\createExcel\\" + myFile.getOriginalFilename()); //路径必须手动创建好，文件如果不存在，会自动创建

        myFile.transferTo(file);

        //返回响应信息
        ReturnObject returnObject = new ReturnObject();
        returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        returnObject.setMessage("文件上传成功");
        return  returnObject;
    }

    /**
        批量导入市场活动
     */
    @ResponseBody
    @RequestMapping("/workbench/activity/importActivity.do")
    public Object importActivity(MultipartFile activityFile, HttpSession session){
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        ReturnObject returnObject = new ReturnObject();
        try {
            System.out.println("测试这里");

/*            //把接收到的excel文件写到磁盘目录中
            String fileName = activityFile.getOriginalFilename();
            File file = new File("D:\\Java学习资料\\SSM框架项目\\课堂笔记",fileName);
            //MultipartFile类中的transferTo()方法,可以把上传的文件,在服务器中指定路径生成一个一样的文件
            activityFile.transferTo(file);
            //读这个文件,生成HSSFWorkbook对象
            InputStream fileInputStream = new FileInputStream("D:\\Java学习资料\\SSM框架项目\\课堂笔记\\" + fileName);
            //读这个输入流,生成对应的HSSFWorkbook文件*/

            HSSFWorkbook hssfWorkbook = new HSSFWorkbook(activityFile.getInputStream());
            //根据hssfWorkbook获取HSSFSheet对象,封装了一页的所有信息
            HSSFSheet sheet = hssfWorkbook.getSheetAt(0);
            //根据HSSFSheet对象获取row对象,封装了每行的数据
            HSSFRow row = null;
            HSSFCell cell = null;
            Activity activity = null;
            List<Activity> activityList = new ArrayList<>();
            for(int i = 1; i <= sheet.getLastRowNum(); i++){
                row = sheet.getRow(i);
                activity = new Activity();
                activity.setId(UUIDUtils.getUUID());
                activity.setOwner(user.getId());
                activity.setCreateTime(DateUtils.formateDateTime(new Date()));
                activity.setCreateBy(user.getId());
                for(int j = 0; j < row.getLastCellNum(); j++){
                    cell = row.getCell(j);
                    String value = HSSFUtils.getCellValueForString(cell);
                    //根据列的位置,把数据插入
                    if(j == 0){
                        activity.setName(value);
                    }else if(j == 1){
                        activity.setStartDate(value);
                    }else if(j == 2){
                        activity.setEndDate(value);
                    }else if(j == 3){
                        activity.setCost(value);
                    }else if(j == 4){
                        activity.setDescription(value);
                    }
                }
                //每一行中所有列都封装完成之后,把activity保存到list中
                activityList.add(activity);
            }
            //调用service层方法,保存市场活动
            int ret = activityService.saveCreateActivityByList(activityList);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            returnObject.setRetData(ret);

        } catch (IOException e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统忙，请稍后再试....");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/activity/detailActivity.do")
    public String detailActivity(String id, HttpServletRequest request){
        //调用service层方法,查询数据
        Activity activity = activityService.queryActivityForDetailById(id);
        List<ActivityRemark> remarkList = activityRemarkService.queryActivityRemarkForDetailByActivityByActivityId(id);
        //把查询到的数据保存到request作用域中
        request.setAttribute("activity", activity);
        request.setAttribute("remarkList", remarkList);
        //请求转发
        return "workbench/activity/detail";
    }

}

















