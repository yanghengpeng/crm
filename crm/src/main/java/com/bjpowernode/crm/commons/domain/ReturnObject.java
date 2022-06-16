package com.bjpowernode.crm.commons.domain;

public class ReturnObject {
    private String code;      //处理成功或者失败的标记：0失败、1成功
    private String message;   //提示信息
    private Object retData;   //返回的其它数据

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Object getRetData() {
        return retData;
    }

    public void setRetData(Object retData) {
        this.retData = retData;
    }
}
