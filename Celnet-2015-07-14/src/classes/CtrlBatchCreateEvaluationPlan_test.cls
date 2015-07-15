/*
*功能:CtrlBatchCreateEvaluationPlan测试类
*作者:Denny
*日期:2012-02-02
*/
@isTest
private class CtrlBatchCreateEvaluationPlan_test {

    static testMethod void myUnitTest() {
    	
        Account account = new Account();
        account.Name = 'test';
        insert account;

        Opportunity opp = new Opportunity();
        opp.AccountId = account.Id;
        opp.Name = 'test';
        opp.StageName = '项目立项';
        opp.CloseDate = date.today();
        opp.ForecastCategoryName = '流量';
        insert opp;
    	
    	ApexPages.StandardController ass = new ApexPages.StandardController(new Evaluation_Plan__c(opportunity__c=opp.id));
    	CtrlBatchCreateEvaluationPlan ccep = new CtrlBatchCreateEvaluationPlan(ass);
    	List<CtrlBatchCreateEvaluationPlan.EvaluationPlan> listEvaluat = ccep.getListEvaluationPlan();
    	for(CtrlBatchCreateEvaluationPlan.EvaluationPlan ep: listEvaluat)
    	{
    		ep.IsDelete = true;
    		ep.epc.tasktype__c = 'test';
    	}
        ccep.DeleteEvaluationPlan();
    	ccep.AddEvaluationPlan();
    	ccep.SaveEvaluationPlan();
    	ccep.getFlag();
    	
    	ApexPages.StandardController asss = new ApexPages.StandardController(new Evaluation_Plan__c(opportunity__c=opp.id));
        CtrlBatchCreateEvaluationPlan ccep2 = new CtrlBatchCreateEvaluationPlan(asss);
        List<CtrlBatchCreateEvaluationPlan.EvaluationPlan> listEvaluat2 = ccep.getListEvaluationPlan();
        for(CtrlBatchCreateEvaluationPlan.EvaluationPlan ep: listEvaluat)
        {
            ep.epc.tasktype__c = 'test';
        }
        ccep2.setListEvaluationPlan(listEvaluat2);
        ccep2.AddEvaluationPlan();
        ccep2.SaveEvaluationPlan();
        ccep2.getFlag();
    	
    	ApexPages.StandardController asss3 = new ApexPages.StandardController(new Evaluation_Plan__c(opportunity__c=opp.id));
        CtrlBatchCreateEvaluationPlan ccep3 = new CtrlBatchCreateEvaluationPlan(asss3);
        List<CtrlBatchCreateEvaluationPlan.EvaluationPlan> listEvaluat3 = ccep.getListEvaluationPlan();
        for(CtrlBatchCreateEvaluationPlan.EvaluationPlan ep: listEvaluat)
        {
            ep.epc.tasktype__c = 'test';
            ep.epc.Deliverables__c = 'test';
            ep.epc.endate__c = date.valueOf('2012-2-1');
            ep.epc.status__c = 'test';
            ep.epc.Owner__c = Userinfo.getUserId();
        }
        ccep3.setListEvaluationPlan(listEvaluat2);
        ccep3.AddEvaluationPlan();
        ccep3.SaveEvaluationPlan();
        ccep3.getFlag();
    	
    }
}