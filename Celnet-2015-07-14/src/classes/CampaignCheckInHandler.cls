global class CampaignCheckInHandler extends wlink.WEMPCallinMsgHandler 
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
        if(eventMsg.Event == wlink.WEMPEntity.EVENT_TYPE_SUBSCRIBE)
        {
            ID external = Schema.SObjectType.wlink__Wechat_User__c.getRecordTypeInfosByName().get('External').getRecordTypeId();
            wlink__Wechat_Account__c wa = new wlink__Wechat_Account__c();
            wa.wlink__Source_ID__c = Context.SourceID;
            
            wlink__Wechat_User__c wu = new wlink__Wechat_User__c();
            wu.RecordTypeId = external;
            wu.wlink__Open_Id__c = eventMsg.FromUserName;
            wu.wlink__Subscribe_Time__c = datetime.now();
            wu.wlink__Status__c = 'Subscribe';
            wu.wlink__Active__c = true;
            wu.wlink__Wechat_Account__r = wa;
            upsert wu wlink__Open_Id__c;
            
            wlink__Wechat_Async_Task__c userInfoQueue = new wlink__Wechat_Async_Task__c();
            userInfoQueue.wlink__Wechat_Account__r = wa;
            userInfoQueue.wlink__Parameter__c = eventMsg.FromUserName;
            userInfoQueue.wlink__Processor_Name__c = 'WEMPCalloutGetUserInfoProcessor';
            wlink.WEMPCalloutQueueManager.EnQueue(userInfoQueue);  
            string outMsgText;
            if(eventMsg.ticket != null)
            {
                //扫二维码关注，推送输入手机号图文消息。
                Campaign c = GetCampaginByTicket(eventMsg.ticket);
                if(c == null)
                {
                    wlink.WEMPEntity.OutTextMsg outMsg = wlink.WEMPEntity.GenerateOutMsg(eventMsg, '二维码已失效，请联系管理员重新生成二维码签到。');
                    Context.OutMsg = outMsg;
                }
                else
                {
                    wlink.WEMPEntity.OutRichMediaMsg outRichMedia = GenerateEnterPhoneNews(c.Id , eventMsg , c.Wechat_Account__r.Wlink__App_ID__c);
                    Context.OutMsg = outRichMedia;
                }
            }
            else
            {
                outMsgText = '欢迎关注';
                wlink.WEMPEntity.OutTextMsg outMsg = wlink.WEMPEntity.GenerateOutMsg(eventMsg, outMsgText);
                Context.OutMsg = outMsg;
            }
        }
        else if(eventMsg.Event ==  wlink.WEMPEntity.EVENT_TYPE_SCAN)
        {
            //已关注，通过扫描二维码进入。
            //先通过Wechat User上的Lead和Contact以及Ticket查询本次Campaign的Campaign Member
            //如果存在则签到，如果不存在发送图文消息填写手机号
            Campaign c = GetCampaginByTicket(eventMsg.ticket);
            if(c == null)
            {
                wlink.WEMPEntity.OutTextMsg outMsg = wlink.WEMPEntity.GenerateOutMsg(eventMsg, '二维码已失效，请联系管理员重新生成二维码签到。');
                Context.OutMsg = outMsg;
            }
            else
            {
                string checkInMsg = CampaignAdminHelper.CheckInCampaign(eventMsg.FromUserName , c.Id);
                system.debug('******************' + checkInMsg);
                if(checkInMsg == 'OK')
                {
                    wlink.WEMPEntity.OutTextMsg outMsg = wlink.WEMPEntity.GenerateOutMsg(eventMsg, '恭喜，您已签到成功。');
                    Context.OutMsg = outMsg;
                }
                else
                {
                    wlink.WEMPEntity.OutRichMediaMsg outRichMedia = GenerateEnterPhoneNews(c.Id , eventMsg , c.Wechat_Account__r.Wlink__App_ID__c);
                    Context.OutMsg = outRichMedia;
                }
            }            
        }
        else if(eventMsg.Event == wlink.WEMPEntity.EVENT_TYPE_UNSUBSCRIBE)
        {
            List<wlink__Wechat_User__c> wuList = [Select id From wlink__Wechat_User__c where wlink__Open_Id__c = :eventMsg.FromUserName];
            if(!wuList.isempty())
            {
                wlink__Wechat_User__c wu = new wlink__Wechat_User__c(ID=wuList[0].id);
                wu.wlink__Status__c = 'Unsubscribe';
                wu.wlink__UnSubscribe_Time__c = datetime.now();
                wu.wlink__Active__c = false;
                update wu;
            }
        }
    }
    
    public wlink.WEMPEntity.OutRichMediaMsg GenerateEnterPhoneNews(Id campaignId , wlink.WEMPEntity.InEventMsg eventMsg , string appId)
    {
        wlink.WEMPEntity.OutRichMediaMsg outRichMedia = new wlink.WEMPEntity.OutRichMediaMsg();
        List<wlink.WEMPEntity.Article> articleList = new List<wlink.WEMPEntity.Article>();
        wlink.WEMPEntity.GetBaseMsgAtrributes(eventMsg ,outRichMedia);
        outRichMedia.MsgType = wlink.WEMPEntity.MESSAGE_TYPE_NEWS;
        outRichMedia.Articles = articleList;
        wlink.WEMPEntity.Article art = new wlink.WEMPEntity.Article();
        art.title = '请输入手机号。';
        art.description = 'Salesforce + Celnet + You = Success';
        art.url = 'https://open.weixin.qq.com/connect/oauth2/authorize?appid=' + appId + '&redirect_uri=http://celnetwelink.force.com/Wechat/CampaignEnterPhone&response_type=code&scope=snsapi_base&state=' + campaignId + '#wechat_redirect';
        art.picURL = 'https://c.ap1.content.force.com/servlet/servlet.ImageServer?id=01590000009fD54&oid=00D900000011gkK&lastMod=1435565070000';
        outRichMedia.Articles.add(art);
        return outRichMedia;
    }
    
    public Campaign GetCampaginByTicket(string ticket)
    {
        Campaign c = null;
        List<Campaign> cList = [select Wechat_Account__r.Wlink__App_ID__c , id from Campaign where WeChat_Ticket__c = :ticket];
        if(!cList.isempty())
        {
            c = cList[0];
        }
        return c;
    }
}