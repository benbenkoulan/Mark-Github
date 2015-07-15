global class CampaignFeedBackHandler extends wlink.WEMPCallinMsgHandler 
{
  private wlink.WEMPCallinMsgPipelineContext Context;
    global override void Handle(wlink.WEMPCallinMsgPipelineContext Context)
    {
        if(Context.InMsg.MsgType != wlink.WEMPEntity.MESSAGE_TYPE_EVENT)
        {
            return ;
        }
        this.Context = Context;
        wlink.WEMPEntity.InEventMsg eventMsg = (wlink.WEMPEntity.InEventMsg)Context.InMsg;
        set<Id> campaignIdSet = new set<Id>();
        set<Id> leadIdSet = new set<Id>();
        set<Id> contactIdSet = new set<Id>();
        for(Wlink__Wechat_User__c wu : [select id , Lead__c , Contact__c from Wlink__Wechat_User__c where Wlink__Open_Id__c = :eventMsg.FromUserName])
        {
            if(wu.Lead__c != null)
                leadIdSet.add(wu.Lead__c);
            if(wu.Contact__c != null)
                contactIdSet.add(wu.Contact__c);
        }
        for(Campaign c : [select id from Campaign where EndDate = TODAY])
            campaignIdSet.add(c.Id);
        if(campaignIdSet.isempty())
        {
            wlink.WEMPEntity.OutTextMsg outMsg = wlink.WEMPEntity.GenerateOutMsg(eventMsg, '抱歉，市场活动时间不在今天。');
            Context.OutMsg = outMsg;
            return;
        }
        
        List<CampaignMember> cmList = [select id , CampaignId from CampaignMember where ((LeadId in :leadIdSet and LeadId <> null) 
                                                                or (ContactId in :contactIdSet and ContactId <> null)) and CampaignId in :campaignIdSet];
        if(cmList.isempty())
        {
            wlink.WEMPEntity.OutTextMsg outMsg = wlink.WEMPEntity.GenerateOutMsg(eventMsg, '抱歉，您没有签到，无法填写市场活动反馈。');
            Context.OutMsg = outMsg;
            return;
        }
        wlink.WEMPEntity.OutRichMediaMsg outRichMedia = new wlink.WEMPEntity.OutRichMediaMsg();
        List<wlink.WEMPEntity.Article> articleList = new List<wlink.WEMPEntity.Article>();
        wlink.WEMPEntity.GetBaseMsgAtrributes(eventMsg ,outRichMedia);
        outRichMedia.MsgType = wlink.WEMPEntity.MESSAGE_TYPE_NEWS;
        outRichMedia.Articles = articleList;
        wlink.WEMPEntity.Article art = new wlink.WEMPEntity.Article();
        art.title = '市场活动反馈调查';
        art.description = 'Salesforce + Celnet + You = Success';
        art.url = 'https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxd5b3bd16e3c0665d&redirect_uri=http://celnetwelink.force.com/Wechat/CampaignFeedBack&response_type=code&scope=snsapi_base&state=' + cmList[0].campaignId + '#wechat_redirect';
        art.picURL = 'https://c.ap1.content.force.com/servlet/servlet.ImageServer?id=01590000009fhaS&oid=00D900000011gkK&lastMod=1436783008000';
        outRichMedia.Articles.add(art);
        Context.OutMsg = outRichMedia;
     }
}