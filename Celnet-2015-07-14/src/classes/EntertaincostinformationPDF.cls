//业务招待费申请结算表
//scott
public with sharing class EntertaincostinformationPDF {
	public User user{get;set;}          //报销人信息
	costreport__c expense;  //费用报销
	ReplaceStr rs = new ReplaceStr();
	List<costdetail__c> entertainlist;//招待费
	List<costdetail__c> otherlist;//其他  
	double esummoney = 0;//招待费
	double easummoney = 0;//招待费申请
	double osummoney = 0;//其他
	double oasummoney = 0;//其它申请
	
	double allcostmoney = 0;//报销金额总计
	double allapplicationmoney = 0;//申请金额总计
	
	//表格样式
	String entertainlistTableStyle;
	String otherlistTableStyle;
	
	public String getEntertainlistTableStyle(){
		return entertainlistTableStyle;
	} 
	public String getOtherlistTableStyle(){
		return otherlistTableStyle;
	} 
	
	public costreport__c getExpense(){
		return expense;
	}
	public List<costdetail__c> getEntertainlist(){
		return entertainlist;
	}
	public List<costdetail__c> getOtherlist(){
		return otherlist;
	}
	public double getEsummoney(){
		return esummoney;
	}
	public double getEasummoney(){
		return easummoney;
	}
	public double getOsummoney(){
		return osummoney;
	}
	public double getOasummoney(){
		return oasummoney;
	}
	public double getAllcostmoney(){
		return allcostmoney;
	}
	public double getAllapplicationmoney(){
		return allapplicationmoney;
	}
	public EntertaincostinformationPDF(ApexPages.StandardController controller){
		String ExpenseID = ApexPages.currentPage().getParameters().get('id');
		RecordType recordtype = [select id from RecordType where Name='业务招待费月结算表'];
		expense = [select OwnerId, Name , CreatedBy.Area__c,CreatedBy.name,CreatedBy.EmployeeNumber,
		 			CreatedBy.Department,reimbursementMonth__c 
		 			from costreport__c 
		 			where id =: ExpenseID];
		user = [Select u.Name, u.EmployeeNumber, u.Department, u.Area__c From User u where id =:expense.OwnerId];
		entertainlist = [select reimbursementDate__c,reimbursementStyle__c,CustomerName__r.name,purpose__c,
						 applicationAmount__c,reimbursementAmount__c,projectName__r.Name
						  from costdetail__c
						  where costreport__c =:ExpenseID
						  and recordtypeid =:recordtype.Id
						  and reimbursementStyle__c='招待费'
						  order by reimbursementDate__c];
		
		otherlist = [select reimbursementDate__c,product__c,specifications__c,Number__c,Price__c,
						 applicationAmount__c,reimbursementAmount__c,projectName__r.Name 
						  from costdetail__c
						  where costreport__c =:ExpenseID
						  and recordtypeid =:recordtype.Id
						  and reimbursementStyle__c='其他费用'
						  order by reimbursementDate__c];
						  
		for(costdetail__c entertainlist:entertainlist){
			if(entertainlist.reimbursementAmount__c != null){
				esummoney+=entertainlist.reimbursementAmount__c;
			}
			if(entertainlist.applicationAmount__c !=null){
				easummoney+=entertainlist.applicationAmount__c;
			}
			if(entertainlist.purpose__c!=null){
			    entertainlist.purpose__c = rs.repla(entertainlist.purpose__c,8);
			}
			
			if(entertainlist.projectName__r.Name!=null){
			    entertainlist.projectName__r.Name = rs.repla(entertainlist.projectName__r.Name, 8);
			}
			if(entertainlist.CustomerName__r.name!=null){
			    entertainlist.CustomerName__r.name = rs.repla(entertainlist.CustomerName__r.name, 5);
			}
		}
		
		for(costdetail__c other:otherlist){
			if(other.reimbursementAmount__c != null){
				osummoney+=other.reimbursementAmount__c;
			}
			if(other.applicationAmount__c != null){
				oasummoney+=other.applicationAmount__c;
			}
			if(other.product__c!=null){
			    other.product__c = rs.repla(other.product__c, 7);
			}
			if(other.specifications__c!=null){
			    other.specifications__c = rs.repla(other.specifications__c,7);
			}
			if(other.projectName__r.Name!=null){
			    other.projectName__r.Name = rs.repla(other.projectName__r.Name, 7);
			}
		}
		allcostmoney = esummoney+osummoney; 	
		allapplicationmoney = easummoney+oasummoney;	
		 //判断费用记录是否为空，如果为空，表格不显示
		
		  if(entertainlist.size()>0){   
		  	   entertainlistTableStyle = 'display:block;font-size: 14px;';   
		   }else{     
		  	    	entertainlistTableStyle = 'display:none;';  
		  	    }
		  if(otherlist.size()>0){   
		  	   otherlistTableStyle = 'display:block;font-size: 14px;';   
		   }else{     
		  	    	otherlistTableStyle = 'display:none;';  
		  	    }  	    	    	    	    	
	}
}