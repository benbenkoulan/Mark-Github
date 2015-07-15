/*Author:Leo
 * Date:2015-02-11
 *Function:汇总付款金额总额到合同上‘销售/采购成本’
 */
trigger PaymentAmountSumToContract on PaymentDetails__c (after delete, after insert, after undelete, 
after update) 
{
    public Set<Id> set_ContractId = new Set<Id>();
	if(trigger.isInsert)
	{
		for(PaymentDetails__c PaymentDetil : trigger.new)
		{//插入无金额或者金额为0的付款，不汇总合同
			if(PaymentDetil.Contract__c != null && PaymentDetil.PaymentAmount__c != null && PaymentDetil.PaymentAmount__c != 0) set_ContractId.add(PaymentDetil.Contract__c);
		}
	}
	if(trigger.isUpdate)
	{
		for(PaymentDetails__c PaymentDetil : trigger.new)
		{
            PaymentDetails__c oldPay = (PaymentDetails__c)(trigger.oldMap.get(PaymentDetil.Id));
			if(PaymentDetil.Contract__c != null && PaymentDetil.Contract__c == oldPay.Contract__c && PaymentDetil.PaymentAmount__c != oldPay.PaymentAmount__c)
            {//付款对象的金额被更新并且关联的合同不为空，且未更改lookup关系，需要重新汇总
            	set_ContractId.add(PaymentDetil.Contract__c);
            }
            else if(PaymentDetil.Contract__c != oldPay.Contract__c) 
            {//如果更改了lookup关系
                if(PaymentDetil.Contract__c != null) set_ContractId.add(PaymentDetil.Contract__c);
                if(oldPay.Contract__c != null) set_ContractId.add(oldPay.Contract__c);
            }
            	
		}
	}
	if(trigger.isDelete)
	{
		for(PaymentDetails__c PaymentDetil : trigger.old)
		{
			if(PaymentDetil.Contract__c != null && PaymentDetil.PaymentAmount__c != null && PaymentDetil.PaymentAmount__c != 0) set_ContractId.add(PaymentDetil.Contract__c);
		}
	}
	if(trigger.isUnDelete)
	{
		for(PaymentDetails__c PaymentDetil : trigger.new)
		{
			if(PaymentDetil.Contract__c != null && PaymentDetil.PaymentAmount__c != null && PaymentDetil.PaymentAmount__c != 0) set_ContractId.add(PaymentDetil.Contract__c);
		}
	}
    if(!set_ContractId.isEmpty()) sumToContract();
        
    private void sumToContract()
    {
        List<Contract> list_Contract = [select Id, SalesPurchaseCost__c, (select Id,PaymentAmount__c from PayDetail__r) from Contract where Id in :set_ContractId];
        List<Contract> list_UpContract = new List<Contract>();
        for(Contract cont : list_Contract)
        {
            Decimal oldAmount = cont.SalesPurchaseCost__c;
            cont.SalesPurchaseCost__c = 0;
            for(PaymentDetails__c pd : cont.PayDetail__r)
            {
                if(pd.PaymentAmount__c != null)
                {
                    cont.SalesPurchaseCost__c += pd.PaymentAmount__c;
                }
            }
			if(oldAmount != cont.SalesPurchaseCost__c)
            {
                list_UpContract.add(cont);
            }
        }
        if(!list_UpContract.isEmpty()) update list_UpContract; 
    }
}