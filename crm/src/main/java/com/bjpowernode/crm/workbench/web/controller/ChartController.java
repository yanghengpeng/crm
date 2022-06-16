package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.workbench.domain.FunnelVO;
import com.bjpowernode.crm.workbench.service.TranService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

@Controller
public class ChartController {

    @Autowired
    private TranService tranService;

    @RequestMapping("/workbench/chart/transaction/index.do")
    public String index(){
        return "workbench/chart/transaction/index";
    }

    @ResponseBody
    @RequestMapping("/workbench/chart/transaction/queryCountOfTranGroupByStage.do")
    public Object queryCountOfTranGroupByStage(){
        //调用service层方法，查询数据
        List<FunnelVO> funnelVOList = tranService.queryCountOfTranGroupByStage();
        return funnelVOList;
    }
}
