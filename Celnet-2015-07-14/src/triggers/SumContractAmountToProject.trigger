/*
*Author:Tommy at 2013-12-30
*Function1: 汇总合同上的合同金额（Amount__c）到项目上的合同金额（Amount__c）
*/
trigger SumContractAmountToProject on Contract (after insert, after update)
{
    set<ID> projIdSet = new set<ID>();
    if(Trigger.isInsert)
    {
        for(Contract newCon : trigger.new)
        {
            if(newCon.Amount__c != null && newCon.Amount__c != 0)
            {
                if(newCon.projectcontract__c != null)
                {
                    projIdSet.add(newCon.projectcontract__c);
                }
            }
        }
    }
    if(Trigger.isUpdate)
    {
        for(Contract newCon : trigger.new)
        {
            Contract oldCon = trigger.oldMap.get(newCon.ID);
            if(newCon.projectcontract__c != oldCon.projectcontract__c)
            {
                if(newCon.projectcontract__c != null)
                {
                    projIdSet.add(newCon.projectcontract__c);
                }
                if(oldCon.projectcontract__c != null)
                {
                    projIdSet.add(oldCon.projectcontract__c);
                }
            }
            if(newCon.Amount__c != oldCon.Amount__c)
            {
                if(newCon.projectcontract__c != null)
                {
                    projIdSet.add(newCon.projectcontract__c);
                }
            }
        }
    }
    List<SFDC_Projects__c> projList = [Select Id, Amount__c, (Select Amount__c From projectcontract__r) From SFDC_Projects__c Where ID In: projIdSet];
    for(SFDC_Projects__c proj : projList)
    {
        Decimal sumAmount = 0;
        if(proj.projectcontract__r != null)
        {
            for(Contract con: proj.projectcontract__r)
            {
            	if(con.Amount__c!=null)
            	{
               	 sumAmount += con.Amount__c;
            	}
            }
        }
        proj.Amount__c = sumAmount;
    }
    update projList;
}