global class WEQYUserAdoptionHandler extends wlink.WEQYCallinMsgHandler
{
	global override void Handle(wlink.WEQYCallinMsgPipelineContext Context)
    {
    	if(Context.InMsg.MsgType == Wlink.WEQYEntity.MESSAGE_TYPE_TEXT)
        {
            Wlink.WEQYEntity.CallinBaseMsg inMsg = (Wlink.WEQYEntity.CallinBaseMsg)Context.InMsg;
            WEQYUserAdoptionHandler.SaveAdoptionInfo(inMsg.CreateTime,null,null,inMsg.FromUserName,inMsg.MsgType,inMsg.ToUserName,inMsg.AgentID);
        }
        if(Context.InMsg.MsgType == Wlink.WEQYEntity.MESSAGE_TYPE_EVENT)
        {
        	Wlink.WEQYEntity.InEventMsg inMsg = (Wlink.WEQYEntity.InEventMsg)Context.InMsg;
    		WEQYUserAdoptionHandler.SaveAdoptionInfo(inMsg.CreateTime,inMsg.Event,inMsg.EventKey,inMsg.FromUserName,inMsg.MsgType,inMsg.ToUserName,inMsg.AgentID);	
        }
    }
    
    @future
    global static void SaveAdoptionInfo(datetime actionTime,string event,string eventKey,string fromUserID,string msgType,string toUserID,string wechatAgentID)
    {
    	Wechat_User_Adoption__c adoption = new Wechat_User_Adoption__c();
    	adoption.Action_Time__c = actionTime;
    	adoption.Event__c = event;
    	adoption.Event_Key__c = eventKey;
    	adoption.From_User_ID__c = fromUserID;
    	adoption.Msg_Type__c = msgType;
    	adoption.To_User_ID__c = toUserID;
    	adoption.Wechat_Agent_ID__c = wechatAgentID;
    	list<Wlink__Wechat_Account__c> accList = [select id from Wlink__Wechat_Account__c 
    											  where Wlink__Source_ID__c = :toUserID];
    	if(!accList.isempty())
    	{
    		adoption.Wechat_Account__c = accList[0].Id;	
    	}
    	list<Wlink__Wechat_Agent__c> agentList = [select id from Wlink__Wechat_Agent__c 
    											  where Wlink__Agent_ID__c = :wechatAgentID 
    											  and Wlink__Wechat_Account__r.Wlink__Source_ID__c = :toUserID];
    	if(!agentList.isempty())
    	{
    		adoption.Wechat_Agent__c = agentList[0].Id;	
    	}
    	list<Wlink__Wechat_User__c> userList = [select id from Wlink__Wechat_User__c
    											where Wlink__User_ID__c = :fromUserID
    											and Wlink__Wechat_Account__r.Wlink__Source_ID__c = :toUserID];
		if(!userList.isempty())
		{
			adoption.Wechat_User__c = userList[0].Id;	
		}
		insert adoption;
    }
}