/*
*功能：统计统计上收款付款金额
*作者：denny dai
*日期：2012年2月21日
*/
trigger Collection_AIUDUN_StatsAmount on Collection__c (after delete, after insert, after undelete, 
after update) {
    set<Id> setSFDC_ProjectsID = new set<Id>();
    List<SFDC_Projects__c> listSFDC_Projects = new List<SFDC_Projects__c>();
    if(Trigger.isDelete){
        for(Collection__c coll : trigger.old)
        {
            if(coll.projectrelated__c !=null)
            {
                setSFDC_ProjectsID.add(coll.projectrelated__c );
            }
        }
    }else{
        for(Collection__c coll : trigger.new)
        {
            if(coll.projectrelated__c!=null)
            {
                setSFDC_ProjectsID.add(coll.projectrelated__c);
            }
        }
    }
    
    AggregateResult[] sumManday = [select projectrelated__c ,sum(Amount__c) Amount__c from Collection__c 
                                   where projectrelated__c IN: setSFDC_ProjectsID AND collectionstatus__c = '已收' 
                                   group by projectrelated__c];
    for(AggregateResult ar : sumManday)
    {
        SFDC_Projects__c sp = new SFDC_Projects__c(
                              id=id.valueOf(String.valueof(ar.get('projectrelated__c')))
                              ,paymoney__c = Integer.valueOf(ar.get('Amount__c')));
        listSFDC_Projects.add(sp);
    }
    update listSFDC_Projects;
}