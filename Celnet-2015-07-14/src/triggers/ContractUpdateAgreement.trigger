trigger ContractUpdateAgreement on Contract (after delete, after insert, after update) 
{
	list<Contract> List_UpCon = new list<Contract>();
	set<Id> Set_Agreement = new set<Id>();
	if(trigger.isInsert||trigger.isUpdate)
	{
		for(Contract C : trigger.new)
		{
			if(C.Agreement__c!=null)
			{
				Set_Agreement.Add(C.Agreement__c);
			}
		}
	}
	if(trigger.isDelete)
	{
		for(Contract C : trigger.old)
		{
			if(C.Agreement__c!=null)
			{
				Set_Agreement.Add(C.Agreement__c);
			}
		}
	}
	for(Id I : Set_Agreement)
	{
		Contract Con = new Contract();
		Con.Id = I;
		List_UpCon.Add(Con);
	}
	update List_UpCon;
	
}