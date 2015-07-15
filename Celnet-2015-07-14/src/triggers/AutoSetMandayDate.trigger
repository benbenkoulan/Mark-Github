/*Author:Leo
 *Date:2015-04-16
 *Description:添加修改项目人天时自动将周起始和周结束时间赋值
 */
trigger AutoSetMandayDate on mandayanalysis__c (before insert, before update)
{
	for(mandayanalysis__c md : trigger.new)
	{
		if(trigger.isInsert && (md.Week_No__c == null || md.Week_No__c == '')) continue;//插入时周编号为空
		//if(trigger.isUpdate && (((mandayanalysis__c)trigger.oldMap.get(md.Id)).Week_No__c == md.Week_No__c)) continue;//更新时周编号未变
		if(md.Week_No__c != null || md.Week_No__c != '')
		{
			DateHelper.Week belongWeek = DateHelper.GetFYWeekByNo(md.Week_No__c);
			md.WeekStartDate__c = belongWeek.WeekStartDate;
			md.WeekEndDate__c = belongWeek.WeekEndDate;
		}
		else
		{//更新时周编号变为空
			md.WeekStartDate__c = null;
			md.WeekEndDate__c = null;
		}
	}
}