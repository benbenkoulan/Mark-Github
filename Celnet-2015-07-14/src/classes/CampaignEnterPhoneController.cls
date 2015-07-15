public class CampaignEnterPhoneController
{
    public string phone{get;set;}
    public string campaignId{get;set;}
    public CampaignAdminHelper.OauthUser ou;
    
    public CampaignEnterPhoneController()
    {
         string code = Apexpages.currentPage().getParameters().get('code');
         campaignId = Apexpages.currentPage().getParameters().get('state');
         ou = CampaignAdminHelper.GetOauthUser(code);
    }
    
    public PageReference register()
    {
        List<Wlink__Wechat_User__c> userList = [select id , Contact__c , Lead__c from Wlink__Wechat_User__c where Wlink__Open_ID__c = :ou.openid];
        Wlink__Wechat_User__c wu;
        if(!userList.isempty())
            wu= userList[0];
        else
        {
            wu = CampaignAdminHelper.GenerateWechatUser(campaignId , ou.openid);
            insert wu;            
        }
        CampaignAdminHelper.Member m = new CampaignAdminHelper.Member();
        m.phone = phone;
        CampaignMember cm = CampaignAdminHelper.IsExistsCampaignMember(m.phone , campaignId);
        cm.Status__c = '已出席';
        string url = '/CampaignRegister?checkin=true';
        if(cm.Id != null)
        {
            //已经存在市场活动成员
            if(cm.contactId != null)
                wu.contact__c = cm.contactId;
            if(cm.leadId != null)
                wu.lead__c = cm.leadId;
            update cm;
        }
        else if(cm.contactId != null)
        {           
            //存在联系人
            wu.contact__c = cm.contactId;
            insert cm;
        }
        else if(cm.leadId != null)
        {
            //存在潜在客户
            wu.lead__c = cm.leadId;
            insert cm;
        }
        else
        {
            //既没有联系人，也没有潜在客户
            url = 'https://open.weixin.qq.com/connect/oauth2/authorize?appid=wx98908d372b119c48&redirect_uri=http://celnetwelink.force.com/Wechat/CampaignRegister&response_type=code&scope=snsapi_base&state=' + campaignId + ',No_CampaignMember#wechat_redirect';
        }
        update wu;
        PageReference redirect_page = new PageReference(url);
        redirect_page.setRedirect(true);
        return redirect_page;

    }
}