global class WEQYSendPictureWordHandler extends Wlink.WEQYCallinMsgHandler 
{
    global override void Handle(Wlink.WEQYCallinMsgPipelineContext Context)
    {
        system.debug('*****************************************************');
        if(Context.InMsg.MsgType != Wlink.WEQYEntity.MESSAGE_TYPE_TEXT && Context.InMsg.MsgType != Wlink.WEQYEntity.MESSAGE_TYPE_EVENT)
        {
            return ;
        }
        system.debug('********intMsg************' + Context.InMsg);
        Wlink.WEQYEntity.InEventMsg inMsg = (Wlink.WEQYEntity.InEventMsg)Context.InMsg;
        //构造响应信息
        Wlink.WEQYEntity.OutTextMsg outMsg = new Wlink.WEQYEntity.OutTextMsg();
        outMsg.ToUserName = inMsg.FromUserName;
        outMsg.FromUserName = inMsg.ToUserName;
        outMsg.CreateTime = datetime.now();
        outMsg.MsgType = Wlink.WEQYEntity.MESSAGE_TYPE_TEXT;
        
        outMsg.Content = '公司组织相关信息：'+'\n';
        outMsg.Content += '公司中文名称：北京雨花石科技有限公司'+'\n';
        outMsg.Content += '公司英文名称：Beijing'+'\b'+'Celnet'+'\b'+'Technology'+'\b'+'Co.,Ltd'+'\n';
        outMsg.Content += '公司中文地址：北京市朝阳区高碑店乡半壁店村恵河南街1008-B 四惠大厦4017室'+'\n';
        outMsg.Content += '公司英文地址：No.1008'+'\b'+'South'+'\b'+'Huihe'+'\b'+'Street,Sihui'+'\b'+'Building'+'\b'+'R4017,Chaoyang'+'\b'+'District,Beijing'+'\n';
        outMsg.Content += '公司电话和传真：电话：010-59231558，传真：010-59231532，邮编：100124'+'\n';
        outMsg.Content += '开户行信息：中国农业银行北京英家坟支行，账号：11042901040011727'+'\n';
        outMsg.Content += '开户行国际码：SWIFT'+'\b'+'CODE:'+'\b'+'ABOCCNBJ010';
        outMsg.Content += '开户行英文名：AGRICULTURAL'+'\b'+'BANK'+'\b'+'OF'+'\b'+'CHINA,'+'\b'+'BEIJING'+'\b'+'BRANCH'+'\n'+'\n';
        outMsg.Content += '思略组织相关信息：'+'\n';
        outMsg.Content += '公司中文名称：上海思略网络科技有限公司'+'\n';
        outMsg.Content += '公司中文地址：上海市静安区北京西路1701号静安中华大厦301室'+'\n';
        outMsg.Content += '公司英文地址：No.1701'+'\b'+'West'+'\b'+'Beijing'+'\b'+'Road,'+'\b'+'Jing'+'\b'+'an'+'\b'+'Fortune'+'\b'+'Gate'+'\b'+'Suite'+'\b'+'301,Shanghai'+'\n';
        outMsg.Content += '开户行：上海银行武夷路支行'+'\n';
        outMsg.Content += '账号：315'+'\b'+'820'+'\b'+'0000'+'\b'+'9009'+'\b'+'172'+'\n';
        
        outMsg.AgentID = Context.AgentID;
        Context.OutMsg = outMsg;
        
        
    }
}