package com.bjpowernode.crm.commons.utils;

import org.apache.poi.hssf.usermodel.HSSFCell;

public class HSSFUtils {
    /**
     从指定的HSSFCell对象中获取列的值,并返回String类型
     */
    public static String getCellValueForString(HSSFCell cell){
        String retValue = "";
        //根据某行某列中的数据类型,调用对应的方法获取数据
        if(cell.getCellType() == HSSFCell.CELL_TYPE_STRING){
            retValue = cell.getStringCellValue();
        }else if(cell.getCellType() == HSSFCell.CELL_TYPE_NUMERIC){
            retValue = cell.getNumericCellValue() + "";
        }else if(cell.getCellType() == HSSFCell.CELL_TYPE_BOOLEAN){
            retValue = cell.getBooleanCellValue() + "";
        }else if(cell.getCellType() == HSSFCell.CELL_TYPE_FORMULA){
            retValue = cell.getCellFormula()+ "";
        }else{
            retValue = "";
        }

        return retValue;
    }
}

