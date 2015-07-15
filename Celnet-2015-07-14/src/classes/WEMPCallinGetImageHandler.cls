global class WEMPCallinGetImageHandler extends wlink.WEMPCallinMsgHandler 
{
    private wlink.WEMPCallinMsgPipelineContext Context;
    global override void Handle(wlink.WEMPCallinMsgPipelineContext Context)
    {
        if(Context.InMsg.MsgType != wlink.WEMPEntity.MESSAGE_TYPE_IMAGE)
        {
            return ;
        }
        this.Context = Context;
        wlink.WEMPEntity.InImageMsg imageMsg = (wlink.WEMPEntity.InImageMsg)Context.InMsg;
        system.debug('*******************'+ imageMsg.mediaId);
    }
}