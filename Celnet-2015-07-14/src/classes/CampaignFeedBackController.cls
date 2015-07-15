public class CampaignFeedBackController {
    public string questionJson{get;set;}
    public string answerJson{get;set;}
    public string campaignId;
    public CampaignAdminHelper.OauthUser ou;
    public CampaignFeedBack__c campaignFeedBack;
    public Wlink__Wechat_User__c wu; 
    public string msg{get;set;}
    public CampaignFeedBackController()
    {
        string code = Apexpages.currentPage().getParameters().get('code');
        campaignId = Apexpages.currentPage().getParameters().get('state');
        if(code != null)
            ou = CampaignAdminHelper.GetOauthUser(code);
        else
        {
            ou = new CampaignAdminHelper.OauthUser();
            ou.openid = 'oEw3Utw5CbK2LB43RyuL9fNd4kLotest';
            campaignId  = '70190000000X8Z0';
        }
        List<wlink__Wechat_User__c> wuList = [select id ,wlink__Wechat_Account__r.Wlink__App_Id__c from wlink__Wechat_User__c where Wlink__Open_ID__c = :ou.openid];
        if(!wuList.isempty())
            wu = wuList[0];
        else
        {
            msg = '您的微信用户信息不存在，请联系Celnet市场部。';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.WARNING, msg);
            ApexPages.addMessage(myMsg);
            return;
        }
        List<CampaignFeedBack__c> cfbList = [select Evaluate__c ,StaffCount__c ,Challenge__c ,
                                                    Strategy__c ,Plan__c ,Business__c ,
                                                    Solution__c ,Campaign__c ,Wechat_User__c
                                            from CampaignFeedBack__c
                                            where Campaign__c = :campaignId and Wechat_User__r.Wlink__Open_ID__c = :ou.openid];
        if(cfbList.isEmpty() && ou.openid != null)
            questionJson = RetrieveQuestionJson(null);
        else
        {
            campaignFeedBack = cfbList[0];
            questionJson = RetrieveQuestionJson(campaignFeedBack);
        }
    }

    public string RetrieveQuestionJson(CampaignFeedBack__c cfb)
    {
        List<Question> questionList = new List<Question>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('CampaignFeedBack__c').getDescribe().fields.getMap();
        for(string fieldName : fieldMap.keyset())
        {
            Schema.SObjectField sfField = fieldMap.get(fieldName);
            Schema.Describefieldresult fieldDes = sfField.getDescribe();
            if(fieldDes.getPicklistValues().isempty() || fieldDes.getName() == 'CurrencyIsoCode')continue;
            List<Schema.PicklistEntry> picklistValues = fieldDes.getPicklistValues();
            Question q = new Question();
            q.questionName = fieldDes.getName();
            q.questionLabel = fieldDes.getLabel();
            if(cfb != null)
                q.questionValue = (string)cfb.get(q.questionName);
            q.questionValues = new List<string>();
            for(Schema.PicklistEntry v : picklistValues)
                q.questionValues.add(v.getvalue());
            questionList.add(q);
        }
        return JSON.serialize(questionList);
    }

    public PageReference FeedBack()
    {
        if(campaignFeedBack == null)
        {
            campaignFeedBack = (CampaignFeedBack__c)Schema.getGlobalDescribe().get('CampaignFeedBack__c').newSObject();
            campaignFeedBack.put('Campaign__c' , campaignId);
        }
        for(Answer a : (List<Answer>)JSON.deserialize(answerJson , List<Answer>.class))
            campaignFeedBack.put(a.name , a.value);
        campaignFeedBack.put('Wechat_User__c' , wu.id);
        if(campaignFeedBack.id == null)
            insert campaignFeedBack;
        else
            update campaignFeedBack;
        SendMsg(wu.id , campaignId);
        Pagereference redirect_page = new Pagereference('https://open.weixin.qq.com/connect/oauth2/authorize?appid=' + wu.wlink__Wechat_Account__r.Wlink__App_Id__c + '&redirect_uri=http://celnetwelink.force.com/Wechat/CampaignFeedBack&response_type=code&scope=snsapi_base&state=' + campaignId + '#wechat_redirect');
        redirect_page.setRedirect(true);
        return redirect_page;
    }
    
    public void SendMsg(string wuId, string campaignId)
    {
        List<Wlink__Wechat_User__c> wuList = [select id , Wlink__Wechat_Account__c from Wlink__Wechat_User__c where id = :wuId];
        if(wuList.isempty())
        {
           return; 
        }
        List<Campaign> cList = [select Id , Name from Campaign where id = :campaignId];
        if(cList.isempty())
        {
            return;
        }
        Wlink__Wechat_Async_Task__c task = new Wlink__Wechat_Async_Task__c();
        task.Wlink__Processor_Name__c = 'WEMPCalloutSendTextMsgProcessor';
        task.Wlink__Wechat_Account__c = wuList[0].Wlink__Wechat_Account__c;
        string msgText = wlink.WEMPEntity.GenerateSvcTextMsg(ou.openid , '感谢您参与' + cList[0].Name + '反馈调查，祝您工作愉快！');
        task.Wlink__Parameter__c = msgText;
        wlink.WEMPCalloutQueueManager.EnQueue(task); 
    }
    
    public class Answer
    {
        public string name;
        public string value;
    }
    
    public class Question
    {
        public string questionName{get;set;}
        public string questionLabel{get;set;}
        public string questionValue{get;set;}
        public List<string> questionValues{get;set;}
    }
}