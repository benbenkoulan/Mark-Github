/*
*Author:crazy at 2013-12-31
*Function1:当合同状态（Contract_Status_Yu1__c）处于“批准过程中时”，
若合同类型（ContractType__c）为“实施服务”或“培训”，则项目类型（Project_Type__c）改为“实施”，
若合同类型为“维护”，则项目类型改为“维护”
*/
trigger UpdateProjectType on Contract (after update) {

    set<ID> proImplementIdList = new set<ID>();
    set<ID> proMaintainIdList = new set<ID>();
    
    for(Contract newCon:trigger.new)
    {
        Contract oldCon = trigger.oldMap.get(newCon.ID);
        if(newCon.Contract_Status_Yu1__c != oldCon.Contract_Status_Yu1__c)
        {
            if(newCon.Contract_Status_Yu1__c =='批准过程中' || newCon.Contract_Status_Yu1__c == '草稿批准' || newCon.Contract_Status_Yu1__c == '已启用')
            {
                if(newCon.ContractType__c =='实施服务'||newCon.ContractType__c =='培训')
                {
                	if(newCon.projectcontract__c != null)
                	{
                		proImplementIdList.add(newCon.projectcontract__c);	
                	}
                }
                else if(newCon.ContractType__c =='维护')
                {
                	if(newCon.projectcontract__c != null)
                	{
                		proMaintainIdList.add(newCon.projectcontract__c);	
                	}
                }
            }
        }
    }
    //需要改为实施的项目集合
    list<SFDC_Projects__c> proImplementList = new list<SFDC_Projects__c>();
    
    //需要改为维护的项目的集合
    list<SFDC_Projects__c> proMaintainList = new list<SFDC_Projects__c>();
    
    for(ID proId: proImplementIdList)
    {
        SFDC_Projects__c pro = new  SFDC_Projects__c();
        pro.ID = proId;
        pro.Project_Type__c = '实施'; 
        proImplementList.add(pro);
    }
    update proImplementList;
    
    for(ID proId :proMaintainIdList)
    {
        SFDC_Projects__c pro = new  SFDC_Projects__c();
        pro.ID = proId;
        pro.Project_Type__c = '维护'; 
        proMaintainList.add(pro);   
    }
    update proMaintainList;
}