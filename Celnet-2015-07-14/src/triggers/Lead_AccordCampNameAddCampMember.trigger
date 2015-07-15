/*
*功能：根据潜在客户上的市场活动名称字段查找系统中的市场活动，若有该市场活动，在该潜在客户下添加市场活动历史
*负责人：Alisa
*时间：2014-4-23
*/
trigger Lead_AccordCampNameAddCampMember on Lead (after insert, after update) {
    set<String> setCampName = new set<String>();//存放潜在客户上市场活动名称字段的值
    
    //获取潜在客户上市场活动名称字段的值
    if(trigger.isInsert)
    {
        for(Lead l : trigger.new)
        {
            if(l.markname__c != null)
            {
                setCampName.add(l.markname__c);
            }
        }
    }
    if(trigger.isUpdate)
    {
        for(Lead l : trigger.new) 
        {
            Lead oldLead = trigger.oldMap.get(l.Id);
            if(l.markname__c != null && oldLead.markname__c != l.markname__c)
            { 
                setCampName.add(l.markname__c);
            }
        }
    }
    
    list<Campaign> listCamp = new list<Campaign>();//存放市场活动
    //活动市场活动
    listCamp = [select Id,Name from Campaign where Name IN :setCampName];
    //key-市场活动名称，value-市场活动
    map<String,Campaign> mapCampNameAndCamp = new map<String,Campaign>(); 
    //获取市场活动名称和对应的市场活动的map
    if(listCamp != null && listCamp.size()>0)
    {
        for(Campaign camp : listCamp)
        {
            if(!mapCampNameAndCamp.containsKey(camp.Name))
            {
                mapCampNameAndCamp.put(camp.Name,camp);
            }
        }
    }
    
    list<CampaignMember> listCampMember = new list<CampaignMember>();//要插入的市场活动成员
    //获取市场活动成员
    for(Lead l : trigger.new)
    {
        if(mapCampNameAndCamp.containsKey(l.markname__c))
        {
            CampaignMember campM = new CampaignMember();
            campM.LeadId = l.Id;
            campM.CampaignId = mapCampNameAndCamp.get(l.markname__c).Id;
            listCampMember.add(campM);
        }
    }
    //插入市场活动成员
    if(listCampMember != null && listCampMember.size()>0)
    {
        insert listCampMember;
    }
    
}