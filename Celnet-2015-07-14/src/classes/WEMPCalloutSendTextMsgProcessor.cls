global class WEMPCalloutSendTextMsgProcessor extends wlink.WEMPCalloutProcessor
{
    global override void DoCallout(Wlink__Wechat_Async_Task__c WechatTask)
    {
        wlink.WEMPCalloutService wcs = new wlink.WEMPCalloutService(WechatTask.wlink__Wechat_Account__r.wlink__Source_ID__c);
        wcs.SendMsg(WechatTask.Wlink__Parameter__c);
    }
}