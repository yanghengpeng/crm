package com.bjpowernode.crm.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class IndexController {

    @RequestMapping("/")
    public String index(){
        //请求转发
        return "index";
        //return "forward:index.jsp";  //配置了视图解析器，可以使用forward:来忽略视图解析器的存在
    }
}
