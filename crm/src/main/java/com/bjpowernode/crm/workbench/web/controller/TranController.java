package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.constants.Constants;
import com.bjpowernode.crm.commons.domain.ReturnObject;
import com.bjpowernode.crm.settings.domain.DicValue;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.mapper.DicValueMapper;
import com.bjpowernode.crm.settings.service.DicValueService;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.workbench.domain.Tran;
import com.bjpowernode.crm.workbench.domain.TranHistory;
import com.bjpowernode.crm.workbench.domain.TranRemark;
import com.bjpowernode.crm.workbench.mapper.TranHistoryMapper;
import com.bjpowernode.crm.workbench.mapper.TranRemarkMapper;
import com.bjpowernode.crm.workbench.service.CustomerService;
import com.bjpowernode.crm.workbench.service.TranHistoryService;
import com.bjpowernode.crm.workbench.service.TranRemarkService;
import com.bjpowernode.crm.workbench.service.TranService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.List;
import java.util.Map;
import java.util.ResourceBundle;

@Controller
public class TranController {

    @Autowired
    private DicValueService dicValueService;

    @Autowired
    private UserService userService;

    @Autowired
    private CustomerService customerService;

    @Autowired
    private TranService tranService;

    @Autowired
    private TranRemarkService tranRemarkService;

    @Autowired
    private TranHistoryService tranHistoryService;

    @RequestMapping("/workbench/transaction/index.do")
    public String index(HttpServletRequest request){
        //调用service层方法，查询动态数据  交易类型和交易来源
        List<DicValue> transactionTypeList = dicValueService.queryDicValueByTypeCode("transactionType");
        List<DicValue> transactionSourceList = dicValueService.queryDicValueByTypeCode("source");
        List<DicValue> transactionStageList = dicValueService.queryDicValueByTypeCode("stage");
        request.setAttribute("transactionTypeList",transactionTypeList);
        request.setAttribute("transactionSourceList",transactionSourceList);
        request.setAttribute("transactionStageList",transactionStageList);
        return "workbench/transaction/index";
    }

    @RequestMapping("/workbench/transaction/toSave.do")
    public String toSave(HttpServletRequest request){
        //调用service层方法,查询动态数据
        List<User> userList = userService.queryAllUsers();
        List<DicValue> transactionTypeList = dicValueService.queryDicValueByTypeCode("transactionType");
        List<DicValue> transactionSourceList = dicValueService.queryDicValueByTypeCode("source");
        List<DicValue> transactionStageList = dicValueService.queryDicValueByTypeCode("stage");
        request.setAttribute("userList",userList);
        request.setAttribute("transactionTypeList",transactionTypeList);
        request.setAttribute("transactionSourceList",transactionSourceList);
        request.setAttribute("transactionStageList",transactionStageList);

        return "workbench/transaction/save";
    }

    @ResponseBody
    @RequestMapping("/workbench/transaction/getPossibilityByStage.do")
    public Object getPossibilityByStage(String stageValue){
        //解析properties配置文件，根据阶段获取可能性
        ResourceBundle bundle = ResourceBundle.getBundle("possibility");
        String possibility = bundle.getString(stageValue);
        //直接返回响应信息
        return possibility;
    }

    @ResponseBody
    @RequestMapping("/workbench/transaction/queryCustomerNameByName.do")
    public Object queryCustomerNameByName(String customerName){
        //调用service层方法，查询所有客户名称
        List<String> customerNameList = customerService.queryCustomerNameByName(customerName);
        //根据查询结果，返回响应信息
        return customerNameList;   //['xxxxx','xxxx','xxxx',........]
    }

    @ResponseBody
    @RequestMapping("/workbench/transaction/saveCreateTran.do")
    public Object saveCreateTran(@RequestParam Map<String, Object> map, HttpSession session){
        ReturnObject returnObject = new ReturnObject();
        //把前端传过来的参数，自动封装为map集合，参数名做key，参数值做value
        map.put(Constants.SESSION_USER, session.getAttribute(Constants.SESSION_USER));
        try{
            //调用service层方法，保存创建的交易
            tranService.saveCreateTran(map);
            //不报异常就表示处理成功了
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("当前系统忙，请稍后再试.....");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/transaction/detailTran.do")
    public String detailTran(String id, HttpServletRequest request){
        //调用service层方法，查询数据
        Tran tran = tranService.queryTranForDeatilById(id);
        List<TranRemark> tranRemarkList = tranRemarkService.queryTranRemarkForDetailByTranId(id);
        List<TranHistory> tranHistoryList = tranHistoryService.queryTranHistoryForDetailByTranId(id);

        //根据交易阶段的名称查询可能性
        String stage = tran.getStage();
        ResourceBundle bundle = ResourceBundle.getBundle("possibility");
        String possibility = bundle.getString(stage);

        //将查询的数据保存到request作用域中
        request.setAttribute("tran",tran);
        request.setAttribute("tranRemarkList",tranRemarkList);
        request.setAttribute("tranHistoryList",tranHistoryList);
        request.setAttribute("possibility",possibility);

        //调用service层方法，查询交易所有的阶段
        List<DicValue> stageValueList = dicValueService.queryDicValueByTypeCode("stage");
        request.setAttribute("stageValueList",stageValueList);

        //请求转发
        return "workbench/transaction/detail";
    }
}
