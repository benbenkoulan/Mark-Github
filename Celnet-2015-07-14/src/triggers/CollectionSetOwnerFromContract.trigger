/*
*功能：拷贝合同的所有人到收款，未来让Welink能够发送微信通知给合同的所有人
*作者：Tommy Liu
*日期：2015-6-2
*/
trigger CollectionSetOwnerFromContract on Collection__c (before insert)
{
	Set<ID> contractIdSet = new Set<ID>();
	for(Collection__c coll : trigger.new)
    {
    	if(coll.Contract__c != null)
    	{
    		contractIdSet.add(coll.Contract__c);
    	}
    }
    
	Map<Id, Contract> contractMap = new Map<Id, Contract>();
	for(Contract contr : [Select Id, 
								Name,
								OwnerId
							From Contract
							Where Id In: contractIdSet])
	{
		contractMap.put(contr.Id, contr);
	}
	
	for(Collection__c coll : trigger.new)
    {
    	if(coll.Contract__c == null)
    	{
    		continue;
    	}
    	Contract contr = contractMap.get(coll.Contract__c);
    	if(contr == null)
    	{
    		continue;
    	}
    	coll.Contract_Owner__c = contr.OwnerId;
    }
}