public class CampaignRegisterController
{
    public string memberinfo{get;set;}
    public string campaignId{get;set;}
    public CampaignAdminHelper.OauthUser ou;
    public boolean formDisplay{get;set;}
    public boolean form2Display{get;set;}
    public boolean form3Display{get;set;}
    public List<string> stateList;
    
    public CampaignRegisterController()
    {
        string code = Apexpages.currentPage().getParameters().get('code');
        if(code == null)
        {
            string checkIn = Apexpages.currentPage().getParameters().get('checkin');
            //签到成功
            if(checkIn != null)
            {
                form3Display = true;
                form2Display = false;
                formDisplay = false;
            }    
            else
            {
                form3Display = false;
                string register = Apexpages.currentPage().getParameters().get('register');
                //注册成功
                if(register != null)
                    form2Display = true;
                else
                    form2Display = false;
                formDisplay = !form2Display;
            }
        }
        else
        {
            form2Display = false;
            form3Display = false;
            formDisplay = true;
            stateList = Apexpages.currentPage().getParameters().get('state').split(',');
            campaignId = stateList[0];           
            ou = CampaignAdminHelper.GetOauthUser(code);
        }
     }
    
    public PageReference register()
    {
        CampaignAdminHelper.Member m = (CampaignAdminHelper.Member)JSON.deserialize(memberinfo , CampaignAdminHelper.Member.class);
        CampaignMember cm = CampaignAdminHelper.GenerateCampaignMember(m, ou.openid , campaignId);
        if(stateList.size() > 1)
        {
            cm.status__c = '已出席';
            update cm;
        }
        else
        {
            //签到成功发送微信提示
            List<Campaign> cList = [select id ,Name , Wechat_Account__c from Campaign where id =:campaignId];
            Wlink__Wechat_Async_Task__c task = new Wlink__Wechat_Async_Task__c();
            task.Wlink__Processor_Name__c = 'WEMPCalloutSendTextMsgProcessor';
            task.Wlink__Wechat_Account__c = cList[0].Wechat_Account__c;
            string msgText = wlink.WEMPEntity.GenerateSvcTextMsg(ou.openid , '您好，您已成功报名市场活动:' + cList[0].Name);
            task.Wlink__Parameter__c = msgText;
            wlink.WEMPCalloutQueueManager.EnQueue(task); 
        }
        PageReference redirect_page = new PageReference('/CampaignRegister?register=true');
        redirect_page.setRedirect(true);
        return redirect_page;
    }
}