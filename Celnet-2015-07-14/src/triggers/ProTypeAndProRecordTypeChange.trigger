/*
wendy
2015-4-3
项目类型改变时，更新记录类型；
记录类型改变时，更新项目类型
*/
trigger ProTypeAndProRecordTypeChange on SFDC_Projects__c (before insert, before update) 
{
    //key:Id value:Project_Type
    Map<Id,String>Map_RtPt = new Map<Id,String>();
    //key:Project_Type value:Id
    Map<String,Id>Map_PtRt = new Map<String,Id>();
    
    for(RecordType rt:[select Id,DeveloperName from RecordType where SobjectType='SFDC_Projects__c'])
    {
        if(rt.DeveloperName == 'InternalProject')////内部项目
        {
            Map_RtPt.put(rt.Id,'内部');
            Map_PtRt.put('内部',rt.Id);
        }
        else if(rt.DeveloperName == 'PresalesProject')//售前项目
        {
            Map_RtPt.put(rt.Id,'销售');
            Map_PtRt.put('销售',rt.Id);
        }
        else if(rt.DeveloperName == 'OutsourcingProject')//外包项目
        {
            Map_RtPt.put(rt.Id,'外包');
            Map_PtRt.put('外包',rt.Id);
        }
        else if(rt.DeveloperName == 'ImplementationProject')//实施项目
        {
            Map_RtPt.put(rt.Id,'实施');
            Map_PtRt.put('实施',rt.Id);
        }
        else if(rt.DeveloperName == 'OnGoingSupportProject')//维护项目
        {
            Map_RtPt.put(rt.Id,'维护');
            Map_PtRt.put('维护',rt.Id);
        }
        else if(rt.DeveloperName == 'ProductProject')//产品项目
        {
            Map_RtPt.put(rt.Id,'产品');
            Map_PtRt.put('产品',rt.Id);
        }
    }
    
    
    if(trigger.isInsert)
    {
        for(SFDC_Projects__c sp : trigger.new)
        {
            if(!Map_RtPt.containskey(sp.RecordTypeId))
            {
                sp.addError('记录类型匹配项目类型失败！');return;
            }
            sp.Project_Type__c=Map_RtPt.get(sp.RecordTypeId);
        }
    }
    if(trigger.isUpdate)
    {
        for(SFDC_Projects__c spNew : trigger.new)
        {
            SFDC_Projects__c spOld = trigger.oldMap.get(spNew.Id);
            //记录类型更改
            if(spOld.RecordTypeId != spNew.RecordTypeId)
            {
                if(!Map_RtPt.containskey(spNew.RecordTypeId))
                {
                    spNew.addError('记录类型匹配项目类型失败！');return;
                }
                spNew.Project_Type__c=Map_RtPt.get(spNew.RecordTypeId);
            }
            //项目类型更改
            else if(spOld.Project_Type__c != spNew.Project_Type__c)
            {
                
                if(!Map_PtRt.containskey(spNew.Project_Type__c))
                {
                    spNew.addError('项目类型匹配记录类型失败！');return;
                }
                spNew.RecordTypeId = Map_PtRt.get(spNew.Project_Type__c);
            }
        }
    }
}