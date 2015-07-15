//业务费用月结算表
//scott
public with sharing class BusinesscostinformationPdf {
   public costreport__c expense{get;set;}          //费用报销
   public User user{get;set;}          //报销人信息
   public List<costdetail__c> citytrafficlist{get;set;}//市内交通费
   public List<costdetail__c> communicationslist{get;set;}//通讯费
   public List<costdetail__c> otherlist{get;set;}//其他
   public double csummoney {get;set;}//市内交通费
   public double cosummoney {get;set;}//通讯费
   public double osummoney {get;set;}//其他
   public double allmoney {get;set;}//报销金额总计    
    //表格样式
   public String citytrafficlistTableStyle {get;set;}
   public String communicationslistTableStyle{get;set;}
   public String otherlistTableStyle{get;set;}
    /*public String getCitytrafficlistTableStyle(){
        return citytrafficlistTableStyle;
    } 
    public String getCommunicationslistTableStyle(){
        return communicationslistTableStyle;
    } 
    public String getOtherlistTableStyle(){
        return otherlistTableStyle;
    } 
     
    public costreport__c getExpense(){
        return expense;
    }
    public List<costdetail__c> getCitytrafficlist(){
        return citytrafficlist;
    }
    public List<costdetail__c> getCommunicationslist(){
        return Communicationslist;
    }
    public List<costdetail__c> getOtherlist(){
        return otherlist;
    }
    public double getCsummoney(){
        return csummoney;
    }
    public double getCosummoney(){
        return cosummoney;
    }
    public double getOsummoney(){
        return osummoney;
    }
    public double getAllmoney(){
        return allmoney;
    }*/
    public BusinesscostinformationPdf(ApexPages.StandardController controller){
    	csummoney =0;//市内交通费
	    cosummoney =0;//通讯费
	    osummoney =0;//其他
	    allmoney = 0;//报销金额总计
        String ExpenseID = ApexPages.currentPage().getParameters().get('id');
        RecordType recordtype = [select id from RecordType where Name='业务费用月结算表'];
         expense = [select OwnerId,CreatedBy.Area__c,CreatedBy.name,CreatedBy.EmployeeNumber,CreatedBy.Department,reimbursementMonth__c 
                    from costreport__c 
                    where id =: ExpenseID];
        user = [Select u.Name, u.EmployeeNumber, u.Department, u.Area__c From User u where id =:expense.OwnerId];        
        citytrafficlist =[select invoiceDate__c,StartAddress__c,EndAddress__c,Because__c,
                          reimbursementAmount__c,projectName__r.Name
                          from costdetail__c
                          where costreport__c =:ExpenseID
                          and recordtypeid =:recordtype.Id
                          and reimbursementStyle__c='市内交通费'
                          order by invoiceDate__c];
        
        communicationslist  = [select invoiceDate__c,reimbursementAmount__c,projectName__r.Name
                          from costdetail__c
                          where costreport__c =:ExpenseID
                          and recordtypeid =:recordtype.Id
                          and reimbursementStyle__c='通讯费'
                          order by invoiceDate__c];
        otherlist = [select Name, invoiceDate__c,Other__c,reimbursementAmount__c,projectName__r.Name
                          from costdetail__c
                          where costreport__c =:ExpenseID
                          and recordtypeid =:recordtype.Id
                          and reimbursementStyle__c='其他费用'
                          order by invoiceDate__c];
        for(costdetail__c citytraffic:citytrafficlist){
            if(citytraffic.reimbursementAmount__c != null){
                csummoney+=citytraffic.reimbursementAmount__c;
            }
            if(citytraffic.StartAddress__c!=null && citytraffic.StartAddress__c.length()>10){
            	 citytraffic.StartAddress__c = repla(citytraffic.StartAddress__c,10);
            }
            
            if(citytraffic.EndAddress__c!=null && citytraffic.EndAddress__c.length()>10){
            	citytraffic.EndAddress__c = repla(citytraffic.EndAddress__c,10);
            }
            if(citytraffic.Because__c!=null && citytraffic.Because__c.length()>12){
                citytraffic.Because__c = repla(citytraffic.Because__c,12);
            }
            if(citytraffic.projectName__r!=null && citytraffic.projectName__r.name.length()>10){
                citytraffic.projectName__r.name = repla(citytraffic.projectName__r.name,10);
            }
        }
        for(costdetail__c communications:communicationslist){
            if(communications.reimbursementAmount__c != null){
                cosummoney+=communications.reimbursementAmount__c;
            }
            if(communications.projectName__r.name!=null && communications.projectName__r.name.length()>20){
               communications.projectName__r.name = repla(communications.projectName__r.name,20);
            }
        }
        for(costdetail__c other:otherlist){
            if(other.reimbursementAmount__c != null){
                osummoney+=other.reimbursementAmount__c;
            }
            if(other.Other__c!=null && other.Other__c.length()>30){
                other.Other__c = repla(other.Other__c, 30);
            }
            if(other.projectName__r.name!=null && other.projectName__r.name.length()>20){
                other.projectName__r.name = repla(other.projectName__r.name,20);
            }
        }
        allmoney =csummoney+cosummoney+osummoney;
         //判断费用记录是否为空，如果为空，表格不显示
          if(citytrafficlist.size()>0){   
               citytrafficlistTableStyle = 'display:block;font-size: 14px;';   
           }else{     
                    citytrafficlistTableStyle = 'display:none;';  
                }
          if(communicationslist.size()>0){   
               communicationslistTableStyle = 'display:block;font-size: 14px;';   
           }else{     
                    communicationslistTableStyle = 'display:none;';  
                }
          if(otherlist.size()>0){   
               otherlistTableStyle = 'display:block;font-size: 14px;';   
           }else{     
                    otherlistTableStyle = 'display:none;';  
                }                               
    }
    //格式化字符来进行显示数据
	
     public String repla(String str,Integer size){
        String tempStr = '';
        Integer startSize =0;
        Integer endSize = size;
        for(Integer i = 0;i <= str.length()/size ;i++)
        {
        	if(endSize>=str.length()){
                endSize=str.length();
            }
            tempStr=tempStr+'\n'+str.substring(startSize,endSize);
            startSize = startSize+size;
            endSize = endSize+size;
            
        }
        return tempStr;
    }
}