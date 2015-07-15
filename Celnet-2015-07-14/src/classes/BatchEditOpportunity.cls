public with sharing class BatchEditOpportunity 
{
	public list<Id> List_OppId;
	public list<Opportunity> List_Opp{get;set;} 
	string OppIds;
	public BatchEditOpportunity()
	{
		OppIds = ApexPages.currentPage().getParameters().get('Id');
		List_OppId = new list<Id>();
		List_OppId = OppIds.split(',');
		Init();
	}
	
	public void Init()
	{
		 List_Opp = [select Id, Name, Lictype__c, Licnumber__c, Boss_interview__c, decisiontitle__c, isquotation__c,
		 Interview_boss_stage__c, facetoface__c 
		 from Opportunity where Id IN: List_OppId];
	}
	
	public PageReference MySave()
	{
		update List_Opp;
		PageReference pr = new PageReference('/006/o');
	  	pr.setRedirect(true);
	  	return pr;				
	}
	
	public PageReference MyCancel()
	{
		PageReference pr = new PageReference('/006/o');
	  	pr.setRedirect(true);
	  	return pr;			
	}

	public void change()
	{
	
	}

}