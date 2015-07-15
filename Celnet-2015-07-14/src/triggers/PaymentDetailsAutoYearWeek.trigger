/*
 * 作者：Ziyue
 * 时间：2013-8-5
 * 描述：新建或更新PaymentDetails时，根据付款日期更新年周字段格式：2013W10
*/
trigger PaymentDetailsAutoYearWeek on PaymentDetails__c (before insert, before update) 
{
    if(trigger.isInsert)
    {
        for(PaymentDetails__c pay : trigger.new)
        {
            if(pay.ContractPayDate__c != null)
            {
                pay.YearWeek__c = string.valueOf(pay.ContractPayDate__c.year())+UtilityClasses.getWeekName(pay.ContractPayDate__c);
            }
        }
    }
    if(trigger.isUpdate)
    {
        for(PaymentDetails__c pay : trigger.new)
        {
            PaymentDetails__c old = trigger.oldMap.get(pay.Id);
            if(pay.ContractPayDate__c != old.ContractPayDate__c && pay.ContractPayDate__c != null)
            {
                pay.YearWeek__c = string.valueOf(pay.ContractPayDate__c.year())+UtilityClasses.getWeekName(pay.ContractPayDate__c);
            }
        }
    }
}