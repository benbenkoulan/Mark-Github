/*
*Author:Tommy at 2013-12-27
*Function1: 检查是否为老客户并设置合同为老客户，规则：检查当前的客户是否已经存在启用的合同，如果存，则当前合同为老客户，如果没有则为新客户
*/
trigger SetContractOldAccont on Contract (before insert) 
{
    set<Id> set_AccountId = new set<Id>();
    for(Contract con : trigger.new)
    {
        set_AccountId.add(con.AccountId);
    }
    list<Contract> list_OldContract = [select Id, AccountId From Contract Where AccountId IN:set_AccountId];//找到已经存在的合同
    for(Contract con : trigger.new)
    {
        if(isHasContract(con.AccountID, list_OldContract))
        {
            con.Existingcustomers__c = true;
        }
        else
        {
            con.Existingcustomers__c = false;
        }
        
    }
    private Boolean isHasContract(ID accountID, list<Contract> list_Contract)
    {
        Boolean isHas = false;
        for(Contract oldCon: list_Contract)
        {
            if (oldCon.AccountID == accountID)
            {
                isHas = true;
                break;
            }
        }
        return isHas;
    }
}