/*
*功能:批量修改销售项目Evaluation Plan
*作者:Denny
*日期:2012-02-02
*/
public with sharing class CtrlBatchUpsertEvaluationPlan {
    public ID opportunityId {get;set;}
    public Boolean flag = false ;
    public Boolean getFlag()
    {
        return flag;
    }
    public list<EvaluationPlan> listEvaluationPlan = new list<EvaluationPlan>();
    public list<EvaluationPlan> getListEvaluationPlan()
    {
        return listEvaluationPlan;
    }
    public void setListEvaluationPlan(list<EvaluationPlan> listEvaluationPlan)
    {
        this.listEvaluationPlan = listEvaluationPlan;
    }
    public CtrlBatchUpsertEvaluationPlan(ApexPages.StandardController controller)
    {
       opportunityId=ApexPages.currentPage().getParameters().get('opportunity__c');
       init();
    }
    //初始状态
    public void init()
    {
    	list<Evaluation_Plan__c> listEvaluation = new list<Evaluation_Plan__c>([select id,tasktype__c
                                                 ,Deliverables__c,endate__c,status__c,Owner__c from 
                                                 Evaluation_Plan__c where opportunity__c =: opportunityId]);
		for(Evaluation_Plan__c ep : listEvaluation)
		{
			EvaluationPlan eps = new EvaluationPlan();
			eps.epc = ep;
			listEvaluationPlan.add(eps);
		}
    }
     //添加行
    public void AddEvaluationPlan()
    {
        Evaluation_Plan__c ep = new Evaluation_Plan__c();
        ep.status__c = '未开始';
        ep.Owner__c = UserInfo.getUserId();
        ep.opportunity__c = opportunityId;
        EvaluationPlan eps = new EvaluationPlan();
        eps.epc = ep;
        listEvaluationPlan.add(eps);
    }
    //删除行
    public void DeleteEvaluationPlan()
    {
    	list<Evaluation_Plan__c> listDeleteEvaluationPlan = new list<Evaluation_Plan__c>();
        List<EvaluationPlan> deleteEvaluationPlans = new List<EvaluationPlan>();
        for(Integer i = listEvaluationPlan.size()-1;i>=0;i--)
        {
            if(listEvaluationPlan[i].IsDelete)
            {
            	if(listEvaluationPlan[i].epc.id!=null)
            	{
            		listDeleteEvaluationPlan.add(listEvaluationPlan[i].epc);
            	}
                listEvaluationPlan.remove(i);
            }
        }
        delete listDeleteEvaluationPlan;
    }
    //保存
    public void SaveEvaluationPlan()
    {
        flag = false;
        String message = '';
        List<Evaluation_Plan__c> listSaveEvaluationPlan = new List<Evaluation_Plan__c>();
        for(Integer i = 0;i<listEvaluationPlan.size();i++)
        {
            Evaluation_Plan__c eplan = listEvaluationPlan[i].epc;
            if(eplan.tasktype__c!=null||eplan.Deliverables__c!=null||eplan.endate__c!=null
            ||eplan.status__c!=null||eplan.Owner__c!=null)
            {
                listSaveEvaluationPlan.add(eplan);
            }
        }
        for(Integer i = 0;i<listSaveEvaluationPlan.size();i++)
        {
            Evaluation_Plan__c eplan = listSaveEvaluationPlan[i];
            if(eplan.tasktype__c==null)
                {
                    message += '"任务类型"';
                }
                if(eplan.Deliverables__c==null)
                {
                    message += '"交付物"';
                }
                if(eplan.endate__c==null)
                {
                    message += '"结束日期"';
                }
                if(eplan.status__c==null)
                {
                    message += '"状态"';
                }
                if(eplan.Owner__c==null)
                {
                    message += '"负责人" ';
                }
                if(message!=null&&message!='')
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, message+'不能为空，保存失败');         
                    ApexPages.addMessage(msg);
                    return;
                }
        }
        if(listSaveEvaluationPlan.size()>0)
        {
            upsert listSaveEvaluationPlan;
            listEvaluationPlan.clear();
            listSaveEvaluationPlan.clear();
            flag = true;
            init();
        }
    }

    public class EvaluationPlan
    {
        public boolean IsDelete{get;set;}
        public Evaluation_Plan__c epc{get;set;}
    }
}