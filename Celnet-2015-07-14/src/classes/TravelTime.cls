/*
 *差旅费月结算表
 *Jilly
*/
public  class TravelTime {
	public User user{get;set;}          //报销人信息
	ReplaceStr rs = new ReplaceStr();
	String ExpenseID;					//报销费用ID
	List<costdetail__c> travelPayList;	//出差补助
	double travelpay=0;					//小计
	costreport__c baseInfo;

	public List<costdetail__c> getTravelPayList(){
		return travelPayList;
	}
	public double gettravelpay(){
		return travelpay;
	}
	public costreport__c getbaseInfo(){
		return baseInfo;
	}
	
	public TravelTime(ApexPages.StandardController controller){
	    ExpenseID = ApexPages.currentPage().getParameters().get('id');
	    //取出记录名等于出差时间信息的记录类型ID
		List<RecordType> recordType=[SELECT Id FROM RecordType where Name='差旅补助月结算表'];
		String recordTypeID;
		if(recordType.size()>0){
		    recordTypeID=recordType[0].Id;
		}
		//用户的基本信息
		baseInfo=[select OwnerId, Name , CreatedBy.Area__c,CreatedBy.name,CreatedBy.EmployeeNumber,
		 			CreatedBy.Department,reimbursementMonth__c 
		 			from costreport__c 
		 			where id =: ExpenseID];
		user = [Select u.Name, u.EmployeeNumber, u.Department, u.Area__c From User u where id =:baseInfo.OwnerId];
		//出差补助信息
		travelPayList=[select travelStartDate__c,travleEndDate__c,travelDay__c,subsidies__c
						,reimbursementAmount__c,projectName__r.Name,Account_Sum__c
						from costdetail__c 	where RecordTypeId=:recordTypeID
						and costreport__c=:ExpenseID
						order by travelStartDate__c];
		for(costdetail__c detail : travelPayList){		
			if(detail.Account_Sum__c!= null){
				travelpay+=detail.Account_Sum__c;
			}
			if(detail.projectName__r.Name!=null){
			    detail.projectName__r.Name = rs.repla(detail.projectName__r.Name,8);
			}
		}
	
	}
}