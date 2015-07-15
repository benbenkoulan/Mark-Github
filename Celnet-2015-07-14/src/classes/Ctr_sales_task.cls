public with sharing class Ctr_sales_task {
    public List<Evaluation_Plan__c> List_Plan{get;set;}
    public Ctr_sales_task(ApexPages.StandardController stdController)
    {
        List_Plan = new List<Evaluation_Plan__c>();
        Opportunity opp = (Opportunity)stdController.getRecord();
        for(Evaluation_Plan__c ep:[select endate__c,Deliverables__c,Owner__c,status__c,tasktype__c 
                                    from Evaluation_Plan__c where opportunity__c =:opp.id order by endate__c ASC])
        {
            List_Plan.add(ep);
        }
    }
}