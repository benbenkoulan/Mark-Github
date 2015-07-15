trigger SFDC_Projects_Project_Type_update_onContractInsert on Contract (after insert) {
      
      set<ID> proImplementIdList = new set<ID>();
      set<ID> proMaintainIdList = new set<ID>();
      
      for(Contract newCon:trigger.new)
      {        
              if(newCon.Contract_Status_Yu1__c == '已启用' && newCon.projectcontract__c!=null)
               {
                   proImplementIdList.add(newCon.projectcontract__c);                  
              }         
      }
      //需要改为实施的项目集合
      list<SFDC_Projects__c> proImplementList = new list<SFDC_Projects__c>();
      
      for(ID proId: proImplementIdList)
      {
        SFDC_Projects__c pro = new  SFDC_Projects__c();
        pro.ID = proId;
        pro.Project_Type__c = '实施';  
        proImplementList.add(pro);
      }
      update proImplementList;
}