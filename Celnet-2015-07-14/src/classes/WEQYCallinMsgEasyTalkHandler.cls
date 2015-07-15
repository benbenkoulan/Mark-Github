global class WEQYCallinMsgEasyTalkHandler extends wlink.WEQYCallinMsgHandler 
{
    global override void Handle(wlink.WEQYCallinMsgPipelineContext Context)
    {
        system.debug('*********************' + context);
        if(Context.InMsg.MsgType != Wlink.WEQYEntity.MESSAGE_TYPE_TEXT)
        {
            return ;
        }
        Wlink.WEQYEntity.InTextMsg inMsg = (Wlink.WEQYEntity.InTextMsg)Context.InMsg;
        
        Wlink__Wechat_Async_Task__c task = new Wlink__Wechat_Async_Task__c();
        Wlink__Wechat_Account__c wa = new Wlink__Wechat_Account__c();
        wa.Wlink__Source_ID__c = Context.CorpID;
        task.Wlink__Wechat_Account__r = wa; 
        
        task.Wlink__Wechat_Agent__c = [select id from Wlink__Wechat_Agent__c 
                        where Wlink__Wechat_Account__r.Wlink__Source_ID__c= :Context.CorpID
                        and Wlink__Agent_ID__c = :Context.AgentID].Id;
        task.Wlink__Processor_Name__c = 'WEQYCalloutSendTextMsgProcessor';      
        task.Wlink__Parameter__c = inMsg.FromUserName + ':' + inMsg.Content;
        Wlink.WEQYCalloutQueueManager.EnQueue(task);
    }
}