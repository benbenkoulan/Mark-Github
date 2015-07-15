/*
 * 作者：Ziyue
 * 时间：2013-8-5
 * 描述：新建或更新Collection时，根据收款日期更新年周字段格式：2013W10
*/
trigger CollectionAutoYearWeek on Collection__c (before insert, before update) 
{
    if(trigger.isInsert)
    {
        for(Collection__c col : trigger.new)
        {
            if(col.Expectedcollectiondate__c != null)
            {
                col.YearWeek__c = string.valueOf(col.Expectedcollectiondate__c.year())+UtilityClasses.getWeekName(col.Expectedcollectiondate__c);
            }
        }
    }
    if(trigger.isUpdate)
    {
        for(Collection__c col : trigger.new)
        {
            Collection__c old = trigger.oldMap.get(col.Id);
            if(col.Expectedcollectiondate__c != old.Expectedcollectiondate__c && col.Expectedcollectiondate__c != null)
            {
                col.YearWeek__c = string.valueOf(col.Expectedcollectiondate__c.year())+UtilityClasses.getWeekName(col.Expectedcollectiondate__c);
            }
        }
    }
}