import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;

import java.io.FileInputStream;

import static com.bjpowernode.crm.commons.utils.HSSFUtils.getCellValueForString;


/**
    使用Apache-poi解析Excel文件
 */
public class ParseExcelTest {
    public static void main(String[] args) throws Exception {
        //根据指定的excel文件,生成HSSFWorkbook对象,封装了excel文件的所有信息
        FileInputStream fileInputStream = new FileInputStream("D:\\Java学习资料\\SSM框架项目\\课堂笔记\\createExcel\\activityList.xls");
        //读这个输入流,生成对应的文件
        HSSFWorkbook hssfWorkbook = new HSSFWorkbook(fileInputStream);
        //根据hssfWorkbook获取HSSFSheet对象,封装了一页的所有信息
        HSSFSheet sheet = hssfWorkbook.getSheetAt(0);
        //根据HSSFSheet获取HSSFRow对象,封装了一行的所有信息
        HSSFRow row = null;
        HSSFCell cell = null;
        for (int i = 0; i <= sheet.getLastRowNum(); i++) {
            row = sheet.getRow(i);
            //根据HSSFRow获取HSSFCell对象,封装了该行中列的信息
            for (int j = 0; j < row.getLastCellNum(); j++) {
                cell = row.getCell(j);

                System.out.print(getCellValueForString(cell) + " ");
            }
            System.out.println();
        }
    }
}
