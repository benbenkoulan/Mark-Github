global class CampaignContactUsHandler extends wlink.WEMPCallinMsgHandler 
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
        string outMsgText = '尊敬的客户您好，\n您可以通过以下方式联系我们：\n业务咨询：400 819 9012\n市场活动报名：010-59231558 ext 207\n联系地址：\n北京总部：北京市朝阳区惠河南街1008号四惠大厦4017室\n上海分公司：上海市长宁区延安西路726号华敏翰尊大厦18K室\n工作时间：9:00-18:00';
        wlink.WEMPEntity.OutTextMsg outMsg = wlink.WEMPEntity.GenerateOutMsg(eventMsg, outMsgText);
        Context.OutMsg = outMsg;
    }
}