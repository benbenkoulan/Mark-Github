/*功能:将挂在项目下的费用汇总到项目上
**作者:Ward Zhou
**时间:2014年12月30日
*/
trigger ProjectExpenseSum on costdetail__c (after delete, after insert, after update) 
{
    set<Id> Set_ProjectId = new set<Id>();
    list<SFDC_Projects__c> List_Update = new list<SFDC_Projects__c>();
    if(trigger.isDelete)
    {
        for(costdetail__c Cost : trigger.old)
        {
            if(Cost.projectName__c!=null)
            {
                Set_ProjectId.Add(Cost.projectName__c);
            }
            
        }
    }
    else
    {
        for(costdetail__c Cost : trigger.new)
        {
            if(Cost.projectName__c!=null)
            {
                Set_ProjectId.Add(Cost.projectName__c);
            }
            
        }
    }
    for(Id I:Set_ProjectId)
    {
        SFDC_Projects__c P = new SFDC_Projects__c();
        P.Id=I;
        List_Update.Add(P); 
    }
    update List_Update;
    
    
}