global class WEQYCalloutSendTextMsgProcessor extends Wlink.WEQYCalloutProcessor
{
    global override void DoCallout(Wlink__Wechat_Async_Task__c WEQYTask)
    {
      system.debug('*********SendText***********' + WEQYTask);
        Wlink.WEQYCalloutService wcs = new Wlink.WEQYCalloutService(WEQYTask.Wlink__Wechat_Account__r.Wlink__Source_ID__c);
        Wlink.WEQYEntity.Text text = new Wlink.WEQYEntity.Text();
        text.content = WEQYTask.Wlink__Parameter__c;
        Wlink.WEQYEntity.SendTextMsgRequest msgReq = new Wlink.WEQYEntity.SendTextMsgRequest();
        
        list<Wlink__Wechat_User__c> userList = [select Wlink__User_ID__c from Wlink__Wechat_User__c where ownerid != :userinfo.getuserid()];
        
        system.debug('**********userList********' + userList);
        
        string touserIds = '';
        for(Wlink__Wechat_User__c wu : userList)
        {
            touserIds += wu.Wlink__User_ID__c+'|';
        }
        touserIds = touserIds.substring(0,touserIds.length()-1);
                system.debug('**********touserIds********' + touserIds);
        msgReq.touser = touserIds;
        msgReq.msgtype = 'text';
        msgReq.agentid = WEQYTask.Wlink__Wechat_Agent__r.Wlink__Agent_ID__c;
        msgReq.text = text;
        msgReq.safe = '0';
        Wlink.WEQYEntity.SendMsgResponse res = wcs.SendMsg(msgReq);
        system.debug('**********res********' + res);
    }
}