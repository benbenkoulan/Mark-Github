/*
*功能:CtrlBatchUpsertEvaluationPlan测试类
*作者:Denny
*日期:2012-02-02
*/
@isTest
private class CtrlBatchUpsertEvaluationPlan_test {

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
        
        Evaluation_Plan__c eplan = new Evaluation_Plan__c();
        insert eplan;
        
        ApexPages.StandardController ass = new ApexPages.StandardController(new Evaluation_Plan__c(opportunity__c=opp.id));
        CtrlBatchUpsertEvaluationPlan ccep = new CtrlBatchUpsertEvaluationPlan(ass);
        List<CtrlBatchUpsertEvaluationPlan.EvaluationPlan> listEvaluat = ccep.getListEvaluationPlan();
        for(CtrlBatchUpsertEvaluationPlan.EvaluationPlan ep: listEvaluat)
        {
            ep.IsDelete = true;
            ep.epc.tasktype__c = 'test';
        }
        ccep.DeleteEvaluationPlan();
        ccep.AddEvaluationPlan();
        ccep.SaveEvaluationPlan();
        ccep.getFlag();
        
        ApexPages.StandardController asss = new ApexPages.StandardController(new Evaluation_Plan__c(opportunity__c=opp.id));
        CtrlBatchUpsertEvaluationPlan ccep2 = new CtrlBatchUpsertEvaluationPlan(asss);
        List<CtrlBatchUpsertEvaluationPlan.EvaluationPlan> listEvaluat2 = ccep2.getListEvaluationPlan();
        for(CtrlBatchUpsertEvaluationPlan.EvaluationPlan ep: listEvaluat2)
        {
            ep.epc.tasktype__c = 'test';
        }
        ccep2.setListEvaluationPlan(listEvaluat2);
        ccep2.AddEvaluationPlan();
        ccep2.SaveEvaluationPlan();
        ccep2.getFlag();
        
        ApexPages.StandardController asss3 = new ApexPages.StandardController(new Evaluation_Plan__c(opportunity__c=opp.id));
        CtrlBatchUpsertEvaluationPlan ccep3 = new CtrlBatchUpsertEvaluationPlan(asss3);
        List<CtrlBatchUpsertEvaluationPlan.EvaluationPlan> listEvaluat3 = ccep3.getListEvaluationPlan();
        for(CtrlBatchUpsertEvaluationPlan.EvaluationPlan ep: listEvaluat3)
        {
            ep.epc.tasktype__c = 'test';
            ep.epc.Deliverables__c = 'test';
            ep.epc.endate__c = date.valueOf('2012-2-1');
            ep.epc.status__c = 'test';
            ep.epc.Owner__c = Userinfo.getUserId();
        }
        ccep3.setListEvaluationPlan(listEvaluat3);
        ccep3.AddEvaluationPlan();
        ccep3.SaveEvaluationPlan();      
        ccep3.getFlag();
             
        
    }
}