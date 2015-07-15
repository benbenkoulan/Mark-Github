global class CampaignHotActivityHandler extends wlink.WEMPCallinMsgHandler 
{
    private wlink.WEMPCallinMsgPipelineContext Context;
    private string beijingMediaId = 'xOgjvCOeXbzK5IF_44wg_zOE81n85gPCPzC7n-pmCbE';
    private string shanghaiMediaId = 'Rx1KLjir7KloKWaT5pjmWM-P2fsPMc_IwShcxbvTd90';
    private string sourceId = 'gh_f65c9364c9ad';
    global override void Handle(wlink.WEMPCallinMsgPipelineContext Context)
    {
      	if(Context.InMsg.MsgType != wlink.WEMPEntity.MESSAGE_TYPE_EVENT)
        {
            return ;
        }
        this.Context = Context;
        List<Wlink__Wechat_Account__c> waList = [select Wlink__Access_Token__c from Wlink__Wechat_Account__c where Wlink__Source_ID__c = :sourceId];
        MediaItem beijingItem = RetrieveMediaItem(beijingMediaId , waList[0].Wlink__Access_Token__c);
        MediaItem shanghaiItem = RetrieveMediaItem(shanghaiMediaId , waList[0].Wlink__Access_Token__c);
        wlink.WEMPEntity.InEventMsg eventMsg = (wlink.WEMPEntity.InEventMsg)Context.InMsg;
        wlink.WEMPEntity.OutRichMediaMsg outRichMedia = new wlink.WEMPEntity.OutRichMediaMsg();
        List<wlink.WEMPEntity.Article> articleList = new List<wlink.WEMPEntity.Article>();
        wlink.WEMPEntity.GetBaseMsgAtrributes(eventMsg ,outRichMedia);
        outRichMedia.MsgType = wlink.WEMPEntity.MESSAGE_TYPE_NEWS;
        outRichMedia.Articles = articleList;
        wlink.WEMPEntity.Article art = new wlink.WEMPEntity.Article();
        art.title = '社交CRM时代 Salesforce邀您走进成功企业经验分享会（北京站）';
        art.description = 'Salesforce + Celnet + You = Success';
        art.url = beijingItem.url;
        art.picURL = 'https://c.ap1.content.force.com/servlet/servlet.ImageServer?id=01590000009fZqI&oid=00D900000011gkK&lastMod=1436431342000';
        wlink.WEMPEntity.Article art2 = new wlink.WEMPEntity.Article();
        art2.title = '“移动+社交”专属云服务 助力中小企业降低成本、增加收益（上海站）';
        art2.description = 'Salesforce + Celnet + You = Success';
        art2.url = shanghaiItem.url;
        art2.picURL = 'https://c.ap1.content.force.com/servlet/servlet.ImageServer?id=01590000009fZqD&oid=00D900000011gkK&lastMod=1436431305000';
        outRichMedia.Articles.add(art);
        outRichMedia.Articles.add(art2);
        Context.OutMsg = outRichMedia;
     }

     public MediaItem RetrieveMediaItem(string mediaId , string accessToken)
     {
        MediaItem mi = null;
        try
        {
            Http h = new Http();
            httprequest req = new httprequest();
            req.setMethod('POST');
            req.setTimeout(60000);
            req.setbody('{"media_id":' + mediaId + '}');
            req.setEndPoint('https://api.weixin.qq.com/cgi-bin/material/get_material?access_token=' + accessToken);
            httpresponse res = h.send(req);
            MediaSource ms = (MediaSource)JSON.deserialize(res.getbody() , MediaSource.class);
            if(ms != null && !ms.news_item.isempty())
            {
                mi = ms.news_item[0];
            }
        }
        catch(Exception e)
        {
            system.debug('*************' + e.getMessage());
            return mi;
        }
        return mi;
     }

     global class MediaSource
     {
        public List<MediaItem> news_item;
     } 

     global class MediaItem
     {
        public string title;
        public string thumb_media_id;
        public integer show_cover_pic;
        public string author;
        public string digest;
        public string content;
        public string url;
        public string content_source_url;
     }
}