/*
 *差旅费结算表
 *Jilly
*/
public class TravelExpense {
	ReplaceStr rs = new ReplaceStr();
	public User user{get;set;}          //报销人信息
	private String ExpenseID;						//费用报销Id
	private List<costdetail__c> accommodationList;	//住宿费
	private List<costdetail__c> carFareList;		//交通费
	private List<costdetail__c> cityCarFareList;	//市内交通费
	private List<costdetail__c> otherFeeList;		//其他补助
	costreport__c baseInfo;
	costdetail__c details=new costdetail__c();
	private double accommodationpay = 0;//住宿费小计
	private double carfarepay=0;		//交通费小计
	private double citycarfarepay=0;	//市内交通费小计
	private double otherfeepay=0;		//其他费用小计
	private double allpay=0;			//报销总计
	private String carFareListTableStyle ;//交通费表格样式
	private String citycarFareListTableStyle ;//市内交通费表格样式
	private String accommodationListTableStyle ;//住宿费表格样式
	private String otherFeeListTableStyle ;//其他费用表格样式
	private double expectedpay=0;			//预支金额
	private double travelpay=0;				//实报金额
	public double gettravelpay(){
		return travelpay;
	}
	public double getexpectedpay(){
		return expectedpay; 
	}
	public String getcarFareListTableStyle(){
		return carFareListTableStyle;
	}
	public String getcitycarFareListTableStyle(){
		return citycarFareListTableStyle;
	}
	public String getaccommodationListTableStyle(){
		return accommodationListTableStyle;
	}
	public String getotherFeeListTableStyle(){
		return otherFeeListTableStyle;
	}
	public double getaccommodationpay(){
		return accommodationpay;
	}
	public double getcarfarepay(){
		return carfarepay;
	}
	public double getcitycarfarepay(){
		return citycarfarepay;
	}
	public double getotherfeepay(){
		return otherfeepay;
	}
	public double getallpay(){
		return allpay;
	}
	public List<costdetail__c> getAccommodationList(){
		return accommodationList;
	}
	public List<costdetail__c> getCarFareList(){
		return carFareList;
	}
	public List<costdetail__c> getCityCarFareList(){
		return cityCarFareList;
	}
	
	public List<costdetail__c> getOtherFeeList(){
		return otherFeeList;
	}
	public costreport__c getBaseInfo(){
		return baseInfo;
	}
	public TravelExpense(ApexPages.StandardController controller){
		String ExpenseID = ApexPages.currentPage().getParameters().get('id');
		//取出记录名为差旅报销信息的记录类型ID
		List<RecordType> recordType=[SELECT Id FROM RecordType where Name='差旅费月结算表'];
		String recordTypeID;
		if(recordType.size()>0){
		    recordTypeID=recordType[0].Id;
		}
		baseInfo=[select OwnerId, Name , CreatedBy.Area__c,CreatedBy.name,CreatedBy.EmployeeNumber,
		 			CreatedBy.Department,reimbursementMonth__c 
		 			from costreport__c  
		 			where id =: ExpenseID];
	    user = [Select u.Name, u.EmployeeNumber, u.Department, u.Area__c From User u where id =:baseInfo.OwnerId];
		if(details.costreport__r.expectedAccount__c!=null){
				expectedpay=details.costreport__r.expectedAccount__c;
		}
		//住宿费信息集合
		accommodationList=[select StartDate__c,Name,EndTime__c,EveryDaymoney__c,reimbursementAmount__c,
							projectName__r.Name,trafficEndAddress_del__c,hotleName__c
		  					from costdetail__c where RecordTypeId=:recordTypeID and reimbursementStyle__c='住宿费'
		  					and costreport__c=:ExpenseID
		  					order by StartDate__c];
			for(costdetail__c detail : accommodationList){
			if(detail.reimbursementAmount__c != null){
		 		accommodationpay += detail.reimbursementAmount__c;
			}
			if(detail.hotleName__c!=null){
                detail.hotleName__c = rs.repla(detail.hotleName__c,12);
			}
			if(detail.projectName__r.Name!=null){
			    detail.projectName__r.Name = rs.repla(detail.projectName__r.Name,8);
			}
		}
		 //交通费信息集合
		carFareList=[select invoiceDate__c,Name,trafficStartAddress_del__c,trafficEndAddress_del__c,
							reimbursementAmount__c,projectName__r.Name from costdetail__c 
							where RecordTypeId=:recordTypeID and reimbursementStyle__c='交通费'
							and costreport__c=:ExpenseID
							order by invoiceDate__c];
		for(costdetail__c detail : carFareList){		
			if(detail.reimbursementAmount__c != null){
				carfarepay+=detail.reimbursementAmount__c;
			}
			if(detail.trafficStartAddress_del__c!=null){
                detail.trafficStartAddress_del__c = rs.repla(detail.trafficStartAddress_del__c, 13);
            }
            if(detail.trafficEndAddress_del__c!=null){
                detail.trafficEndAddress_del__c = rs.repla(detail.trafficEndAddress_del__c, 13);
            }
            if(detail.projectName__r.Name!=null){
                detail.projectName__r.Name = rs.repla(detail.projectName__r.Name, 8);
            }
		}
		//市内交通费信息集合
		cityCarFareList=[select invoiceDate__c,Name,EndAddress__c,StartAddress__c, reimbursementAmount__c,
						projectName__r.Name,Because__c
						from costdetail__c 	where RecordTypeId=:recordTypeID and reimbursementStyle__c='市内交通费'
						and costreport__c=:ExpenseID
						order by invoiceDate__c];
		for(costdetail__c detail : cityCarFareList){		
			if(detail.reimbursementAmount__c != null){
				citycarfarepay+=detail.reimbursementAmount__c;
			}
			if(detail.StartAddress__c!=null){
                detail.StartAddress__c = rs.repla(detail.StartAddress__c, 8);
            }
            if(detail.EndAddress__c!=null){
                detail.EndAddress__c = rs.repla(detail.EndAddress__c, 8);
            }
            if(detail.projectName__r.Name!=null){
                detail.projectName__r.Name = rs.repla(detail.projectName__r.Name, 8);
            }
            if(detail.Because__c!=null){
                detail.Because__c = rs.repla(detail.Because__c, 13);
            }
		}
		//其他费用信息集合
		otherFeeList=[select invoiceDate__c,Name,OtheUser__c, reimbursementAmount__c,projectName__r.Name
						from costdetail__c 	where RecordTypeId=:recordTypeID and reimbursementStyle__c='其他费用'
						and costreport__c=:ExpenseID
						order by invoiceDate__c];
		for(costdetail__c detail : otherFeeList){		
			if(detail.reimbursementAmount__c != null){
				otherfeepay+=detail.reimbursementAmount__c;
			}
			if(detail.OtheUser__c!=null){
                detail.OtheUser__c = rs.repla(detail.OtheUser__c, 8);
            }
            if(detail.projectName__r.Name!=null){
                detail.projectName__r.Name = rs.repla(detail.projectName__r.Name, 8);
            }
		}
		allpay=	accommodationpay+carfarepay+citycarfarepay+otherfeepay;//所有费用总计
		travelpay=allpay-expectedpay;
		//控制各费用列表是否为空，如果为空，表格不显示
		if(carFareList.size()>0){
			carFareListTableStyle = 'display:block;font-size: 14px;';
		}else{
			carFareListTableStyle = 'display:none;';
		}
		if(otherFeeList.size()>0){
			otherFeeListTableStyle= 'display:block;font-size: 14px;';
		}else{
			otherFeeListTableStyle = 'display:none;';
		}
		if(accommodationList.size()>0){
			accommodationListTableStyle= 'display:block; font-size: 14px;';
		}else{
			accommodationListTableStyle = 'display:none;';
		}
		if(citycarFareList.size()>0){
			citycarFareListTableStyle= 'display:block; font-size: 14px;';
		}else{
			citycarFareListTableStyle = 'display:none;';
		}
	}
}