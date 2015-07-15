/*
 * 功能：收款历史数据创建
 * 作者：子越
 * 时间：2013-11-14
*/
global class BatchAutoCollectionHistory implements Database.Batchable<sObject>
{
	global database.Querylocator start(Database.BatchableContext BC) 
	{
		list<CollectionHistory__c> chs = [select id from CollectionHistory__c where isDeleted=false];
		delete chs;
		return database.getQueryLocator([Select id,(Select Id, ParentId, CreatedDate,CreatedById, Field, OldValue, NewValue From Histories where Field = 'expectedcollectiondate__c') From Collection__c ]);
	}
	global void execute(Database.BatchableContext BC, list<sObject> scope)
	{
		//获取所有中间表字段API:label
    	map<string,string> APItoLabel = new map<string,string>();
    	
		map<string,Schema.SobjectField> fields=Schema.SobjectType.Collection__c.fields.getMap();
        list<Schema.SobjectField> field=fields.values();
        for (String s: fields.keySet()) 
        {
           if (fields.get(s).getDescribe().isAccessible()) 
           {
               Schema.SobjectField sObjField = fields.get(s);
               APItoLabel.put(s,sObjField.getDescribe().getLabel());
           }
        }
        list<CollectionHistory__c> inch = new list<CollectionHistory__c>();
        for(sObject obj:scope)
        {
        	Collection__c col = (Collection__c)obj;
        	if(col.Histories != null && col.Histories.size() > 0)
        	{
        		for(Collection__History chs:col.Histories)
        		{
        			CollectionHistory__c ch = new CollectionHistory__c();
		        	ch.Collection__c = col.id;
		        	ch.Modifications__c = APItoLabel.get(chs.Field);
		        	ch.Modified__c = Date.valueOf(chs.CreatedDate);
		        	if(chs.OldValue != null)
		        	{
		        		ch.BeforeModification__c = Date.valueOf(chs.OldValue).year()+'-'+Date.valueOf(chs.OldValue).month()+'-'+Date.valueOf(chs.OldValue).day();
		        	}
		        	if(chs.NewValue != null)
		        	{
		        		ch.AfterModification__c = Date.valueOf(chs.NewValue).year()+'-'+Date.valueOf(chs.NewValue).month()+'-'+Date.valueOf(chs.NewValue).day();
		        	}
		        	ch.ModifiedBy__c = chs.CreatedById;
		        	ch.year__c = string.valueOf(ch.Modified__c.year());
		        	ch.Month__c = string.valueOf(ch.Modified__c.month());
		        	inch.add(ch);
        		}
        	}
        }
        if(inch.size() > 0)
        {
        	insert inch;
        }
	}
	global void finish(Database.BatchableContext BC)
	{
	
	}
}