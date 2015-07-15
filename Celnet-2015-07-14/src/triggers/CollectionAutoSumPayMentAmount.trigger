trigger CollectionAutoSumPayMentAmount on Collection__c (after delete, after insert, after undelete, after update) 
{
    Set<ID> ProjectIds = new Set<ID>();
    Set<ID> projectNoPayIds = new Set<ID>();
    if(trigger.isDelete)
    {
        for(Collection__c col : trigger.old)
        {
            if(col.projectrelated__c == null)
            {
                continue;
            }
            if(col.collectionstatus__c == '未收' && col.invoicestatus__c != null)
            {
                projectNoPayIds.add(col.projectrelated__c);
            }
            if(col.collectionstatus__c == '已收' && col.Amount__c != null && col.Amount__c != 0)
            {
                ProjectIds.add(col.projectrelated__c);
            }
        }
    }
    else
    {
        for(Collection__c col : trigger.new)
        {
            if(trigger.isUpdate)
            {
                Collection__c old = trigger.oldMap.get(col.id);
                //if((old.projectrelated__c != col.projectrelated__c || col.Amount__c != old.Amount__c) && (old.collectionstatus__c != col.collectionstatus__c && (old.collectionstatus__c == '已收' || col.collectionstatus__c == '已收')))
                {
                    if(old.projectrelated__c != null)
                    {
                        ProjectIds.add(old.projectrelated__c);
                        projectNoPayIds.add(old.projectrelated__c);
                    }
                    if(col.projectrelated__c != null)
                    {
                        ProjectIds.add(col.projectrelated__c);
                        projectNoPayIds.add(old.projectrelated__c);
                    }
                }
            }
            else
            {
                if(col.projectrelated__c == null)
                {
                    continue;
                }
                if(col.collectionstatus__c == '未收' && col.invoicestatus__c != null)
                {
                    projectNoPayIds.add(col.projectrelated__c);
                }
                if(col.collectionstatus__c == '已收' && col.Amount__c != null && col.Amount__c != 0)
                {
                    ProjectIds.add(col.projectrelated__c);
                }
            }
        }
    }
    if(projectNoPayIds.size() > 0)
    {
        list<SFDC_Projects__c> projs = [Select paymoney__c,OpenNoPayment__c,CloseNoPayment__c,(Select Amount__c, collectionstatus__c,invoicestatus__c, projectrelated__c From projectrelated__r 
                                       where collectionstatus__c = '未收' and Amount__c != null and invoicestatus__c != null) 
                                       From SFDC_Projects__c where id in:ProjectIds];
        if(projs != null && projs.size() > 0)     
        {
            for(SFDC_Projects__c proj : projs)
            {
                proj.OpenNoPayment__c = 0;
                proj.CloseNoPayment__c = 0;
                if(proj.projectrelated__r == null)
                {
                    continue;
                }
                for(Collection__c col : proj.projectrelated__r)
                {
                    if(col.invoicestatus__c == '已开')
                    {
                        proj.OpenNoPayment__c += col.Amount__c;
                    }
                    else
                    {
                        proj.CloseNoPayment__c += col.Amount__c;
                    }
                }
            }
            update projs;  
        }                  
    }
    if(ProjectIds.size() > 0)
    {
        list<SFDC_Projects__c> projs = new list<SFDC_Projects__c>();
        for(SFDC_Projects__c proj : [Select paymoney__c, (Select Amount__c, collectionstatus__c, projectrelated__c From projectrelated__r where collectionstatus__c='已收' and Amount__c!=null) From SFDC_Projects__c where id in:ProjectIds])
        {
            proj.paymoney__c = 0;
            if(proj.projectrelated__r != null)
            {
                for(Collection__c col : proj.projectrelated__r)
                {
                    proj.paymoney__c += col.Amount__c;
                }
            }
            projs.add(proj);
        }
        if(projs.size() > 0)
        {
            update projs;
        }
    }
    
}