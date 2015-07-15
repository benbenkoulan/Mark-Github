trigger AgreementSumContract on Contract (before update) 
{
	Id AgId = [select Id from RecordType where DeveloperName='Agreement'][0].Id;
	for(Contract C : trigger.new)
	{
		if(C.recordtypeId==AgId)
		{
			AggregateResult result = [select SUM(Amount__c) AM
		                from Contract where Agreement__c =: C.Id];
			object AM = result.get('AM');
			if(AM!=null)C.ContractSum__c = double.valueOf(AM);
		}
	}

}