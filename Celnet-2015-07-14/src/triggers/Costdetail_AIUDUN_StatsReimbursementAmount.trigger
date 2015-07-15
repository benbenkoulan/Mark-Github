/*
*功能：统计统计费用报销明细上报销金额
*作者：denny dai
*日期：2012年2月22日
*/
trigger Costdetail_AIUDUN_StatsReimbursementAmount on costdetail__c (after delete, after insert, after undelete, 
after update) {
    set<Id> setSFDC_ProjectsID = new set<Id>();
    List<SFDC_Projects__c> listSFDC_Projects = new List<SFDC_Projects__c>();
    if(Trigger.isDelete){
        for(costdetail__c cos : trigger.old)
        {
            if(cos.projectName__c !=null)
            {
                setSFDC_ProjectsID.add(cos.projectName__c );
            }
        }
    }else{
        for(costdetail__c cos : trigger.new)
        {
            if(cos.projectName__c!=null)
            {
                setSFDC_ProjectsID.add(cos.projectName__c);
            }
        }
    }
    
    AggregateResult[] sumreimbursementAmount = [Select projectName__c, sum(reimbursementAmount__c) reimbursementAmount From costdetail__c  
                                   where projectName__c IN: setSFDC_ProjectsID 
                                   group by projectName__c];
    for(AggregateResult ar : sumreimbursementAmount)
    {
        SFDC_Projects__c sp = new SFDC_Projects__c(
                               id=id.valueOf(String.valueof(ar.get('projectName__c')))
                               ,Costex__c = Integer.valueOf(ar.get('reimbursementAmount')));
        listSFDC_Projects.add(sp);
    }
    update listSFDC_Projects;
}