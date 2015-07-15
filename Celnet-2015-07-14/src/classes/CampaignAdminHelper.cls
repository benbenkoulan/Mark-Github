global class CampaignAdminHelper
{
    global static Wlink.WEMPCalloutService wcs;
    global static Campaign c;
    global static string executeMsg;
    global static final string appId = 'wxd5b3bd16e3c0665d';
    global static final string appSecret = 'c54fe9824f16b39583a20926cdbe0b78';
    
    //初始化WEMPCalloutService
    global static void InitCalloutService(string campaignId)
    {
        c = [select Id , Media_Id__c ,WeChat_Ticket__c , Wechat_Account__r.Wlink__App_ID__c ,Wechat_Account__r.Wlink__Access_Token__c , Wechat_Account__r.Wlink__Source_ID__c , Wechat_Account__c from Campaign where id = :campaignId];
        wcs =  new Wlink.WEMPCalloutService(c.Wechat_Account__r.Wlink__Source_ID__c);
    }
    
    webservice static string UpdateMPNewsContentUrl(string campaignId)
    {
        try
        {
            InitCalloutService(campaignId);
            string url = 'https://api.weixin.qq.com/cgi-bin/material/get_material?access_token=' + c.Wechat_Account__r.Wlink__Access_Token__c;
            string response = SendRequest(url , 'POST' , '{"media_id":"' + c.Media_Id__c +'"}');  
            GetMediaNewsResponse mmm = (GetMediaNewsResponse)JSON.deserialize(response , GetMediaNewsResponse.class);
            UpdateMPNewsRequest ump = new UpdateMPNewsRequest();
            ump.media_id = c.Media_Id__c;
            ump.index = 0;
            UpdateArticle art = new UpdateArticle();
            art.title = mmm.news_item[0].title;
            art.thumb_media_id = mmm.news_item[0].thumb_media_id;
            art.author = mmm.news_item[0].author;
            art.digest = mmm.news_item[0].digest;
            art.show_cover_pic = mmm.news_item[0].show_cover_pic;
            art.content = mmm.news_item[0].content;
            art.content_source_url = 'https://open.weixin.qq.com/connect/oauth2/authorize?appid=' + c.Wechat_Account__r.wlink__App_id__c + '&redirect_uri=http://celnetwelink.force.com/Wechat/CampaignRegister&response_type=code&scope=snsapi_base&state=' + campaignId +'#wechat_redirect';
            ump.articles = art;
            url = 'https://api.weixin.qq.com/cgi-bin/material/update_news?access_token=' + c.Wechat_Account__r.Wlink__Access_Token__c;
            response = SendRequest(url , 'POST' , JSON.serialize(ump)); 
            system.debug('##################' + response); 
            executemsg = '更新图文消息成功.';
        }
        catch(Exception e)
        {
            executeMsg = '更新图文消息失败，错误信息 :' + e.getMessage() + '，请联系管理员。';
        }
        return executemsg;
    }
    
    webservice static string BulkChangeCampaignMemberStatus(List<Id> cmIds , string status)
    {
        try
        {
            List<CampaignMember> cmList = new List<CampaignMember>();
            for(Id cmId : cmIds)
            {
                CampaignMember cm = new CampaignMember();
                cm.Id = cmId;
                cm.Status__c = status;
                cmList.add(cm);
            }
            if(!cmList.isempty())
            {
                update cmList;
            }
            executeMsg = '批量更新成功。';
        }
        catch(Exception e)
        {
            executeMsg = '批量更新失败.错误信息 :' + e.getMessage() + '，请联系管理员。';
        }
        return executeMsg;
    }
    
    webservice static string GetAllWechatUsers(string campaignId)
    {
        try
        {
            InitCalloutService(campaignId);
            string url = 'https://api.weixin.qq.com/cgi-bin/user/get?access_token=' + c.Wechat_Account__r.Wlink__Access_Token__c;
            string response = SendRequest(url , 'GET' , null);  
            system.debug('******************' + response);
            WechatUserResponse wr = (WechatUserResponse)JSON.deserialize(response , WechatUserResponse.class);
            system.debug('##################' + wr);
            List<Wlink__Wechat_Async_Task__c> taskList = new List<Wlink__Wechat_Async_Task__c>();
            for(string openid : wr.data.openid)
            {
                Wlink__Wechat_Async_Task__c task = new Wlink__Wechat_Async_Task__c();
                task.Wlink__Processor_Name__c = 'WEMPCalloutGetUserInfoProcessor';
                task.Wlink__Parameter__c = openid;
                task.Wlink__Wechat_Account__c = c.Wechat_Account__c;
                taskList.add(task);
            }
            wlink.WEMPCalloutQueueManager.EnQueue(taskList);
            executeMsg = '创建批量更新粉丝列表任务成功，请稍后刷新服务号查看。';
        }
        catch(Exception ex)
        {
            executeMsg = '创建批量更新粉丝列表任务失败.错误信息 :' + ex.getMessage() + '，请联系管理员。';
        }
        return executeMsg;        
    }
    
    //发送市场活动图文
    webservice static string SendCampaignNews(string campaignId)
    {
        try
        {
            InitCalloutService(campaignId);
            List<string> toUserList = new List<string>();
            for(Wlink__Wechat_User__c wu : [select id , Wlink__Open_Id__c from Wlink__Wechat_User__c where Wlink__Wechat_Account__c = :c.Wechat_Account__c])
            {
                toUserList.add(wu.Wlink__Open_Id__c);
            }
            MassSendMPNews mn = new MassSendMPNews();
            mn.touser = toUserList;
            MPNews news = new MPNews();
            news.media_id = c.Media_Id__c;
            mn.mpnews = news;
            mn.msgtype = 'mpnews';
            string newsJson = JSON.serialize(mn);
            string url = 'https://api.weixin.qq.com/cgi-bin/message/mass/send?access_token=' + c.Wechat_Account__r.Wlink__Access_Token__c;
            string response = SendRequest(url , 'POST' , newsJson);  
            system.debug('******************' + response);
            WechatResponse wr = (WechatResponse)JSON.deserialize(response , WechatResponse.class);
            c.SendMPNews__c = true;
            update c;
            executeMsg = '发送成功.';
        }
        catch(Exception e)
        {
            executeMsg = '发送失败.错误信息 :' + e.getMessage() + '，请联系管理员。';
        }
        return executeMsg;
    }
    
    //生产市场活动二维码
    webservice static string CreateCampaignQRCode(string campaignId)
    {
        try
        {
            InitCalloutService(campaignId);
            Wlink.WEMPEntity.QRCodeTemporaryRequest req = Wlink.WEMPEntity.GenerateQRCodeTemporaryRequest(604800 ,1);
            Wlink.WEMPEntity.QRCodeResponse res = wcs.GenerateTemporaryQRCode(req);
            blob qrcode = wcs.GetQRCodeByTicket(res.ticket);
            
            c.WeChat_Ticket__c = res.ticket;
            update c;
            
            List<Attachment> attList = [select id from Attachment where parentId = :campaignId and Description = :('QRCode-' + campaignId)];
            if(!attList.isempty())
            {
                delete attList;
            }
            Attachment att = new Attachment();
            att.Name = 'QRCode.jpg';
            att.body = qrcode;
            att.parentId = campaignId;
            att.description = 'QRCode-' + campaignId;
            insert att;
            executeMsg = '生成二维码成功.';
        }
        catch(Exception e)
        {
            executeMsg = '生成二维码失败.错误信息 :' + e.getMessage() + '，请联系管理员。';   
        }
        return executeMsg;
    }
    
    public static string SendRequest(string url , string method , string body)
    {
        http h = new http();
        httprequest req = new httprequest();
        req.setMethod(method);
        req.setTimeout(60000);
        req.setEndPoint(url);
        if(method == 'POST')
        {
            req.setbody(body);
        }
        httpresponse res = h.send(req);
        return res.getbody();
    }
    
    //根据code获得openid
    public static OauthUser GetOauthUser(string code)
    {
        OauthUser ou;
        string url = 'https://api.weixin.qq.com/sns/oauth2/access_token?appid=' + appId + '&secret=' + appSecret + '&code=' + code + '&grant_type=authorization_code';
        try
        {
            string response = SendRequest(url , 'GET' , null);
            ou = (OauthUser)JSON.deserialize(response , OauthUser.class);
        }
        catch(Exception e)
        {
            ou = new OauthUser();    
        }
        return ou;
    }
    
    
    //根据手机号判断客户在系统中的存在情况
    public static CampaignMember IsExistsCampaignMember(string phone , string campaignId)
    {
        //根据市场活动Id和手机号判断是否存在市场活动成员
        List<CampaignMember> cmList = [select id, Campaign.Name , contactId , leadId from CampaignMember where Phone__c = :phone and CampaignId = :campaignId];
        //已存在市场活动成员
        if(!cmList.isempty())
            return cmList[0];
        //不存在市场活动成员
        CampaignMember cm = new CampaignMember();
        cm.campaignId = campaignId;
        cm.Phone__c = phone;
        //根据手机号判断是否存在联系人
        List<Contact> contactList = [select id from Contact where MobilePhone = :phone or Phone = :phone or Phone__c = :phone or HomePhone = :phone or OtherPhone = :phone];
        //已存在联系人,市场活动成员关联联系人
        if(!contactList.isempty())
        {
            cm.contactId = contactList[0].id;
        }
        else
        {
            //根据手机号判断是否存在潜在客户
            List<Lead> leadList = [select Id from Lead where (Phone = :phone or MobilePhone = :phone) and (markname__c = null or markname__c = :cm.Campaign.Name)];
            //已存在潜在客户，市场活动成员关联
            if(!leadList.isempty())
            {
                cm.leadId = leadList[0].id;
            }
        }
        return cm;
    }
    
    //报名流程，设置签到
    public static CampaignMember GenerateCampaignMember(Member m , string openid , string campaignId)
    {
        //根据openId判断是否存在Wechat User
        List<Wlink__Wechat_User__c> userList = [select id , Contact__c , Lead__c from Wlink__Wechat_User__c where Wlink__Open_ID__c = :openid];
        Wlink__Wechat_User__c wu;
        if(!userList.isempty())
            wu= userList[0];
        else
        {
            wu = GenerateWechatUser(campaignId , openid);
            insert wu;            
        }
        //返回市场活动成员，如果没有则新建
        CampaignMember cm = IsExistsCampaignMember(m.phone , campaignId);
        cm.Last_Name__c = m.lastname;
        cm.First_Name__c = m.firstname;
        cm.Title__c = m.position;
        cm.Company__c = m.company;
        cm.Email__c = m.email;
        //已经存在市场活动成员
        if(cm.Id != null)
        {
            //如果市场活动成员关联联系人，Wechat User关联联系人
            if(cm.contactId != null)
                wu.contact__c = cm.contactId;
            //如果市场活动成员关联潜在客户，Wechat User关联潜在客户
            if(cm.leadId != null)
                wu.lead__c = cm.leadId;
            update wu;
            update cm;
            return cm;
        }
        else if(cm.contactId != null)
        {           
            //存在联系人
            wu.contact__c = cm.contactId;
        }
        else if(cm.leadId != null)
        {
            //存在潜在客户
            wu.lead__c = cm.leadId;
        }
        else
        {
            //既没有联系人，也没有潜在客户
            Lead l = new Lead();
            l.Email = m.email;
            l.FirstName = m.firstname;
            l.LastName = null != m.lastname ? m.lastname : '无';
            l.Company = null != m.company ? m.company : '无';
            l.Phone = m.phone;
            l.Title = m.position;
            insert l;
            wu.lead__c = l.id;
            cm.leadid = l.id;
        }
        update wu;
        insert cm;
        return cm;
    }    
    //签到流程
    public static string CheckInCampaign(string openId , Id campaignId)
    {
        string msg;
        //根据OpenId查询Wechat User
        List<Wlink__Wechat_User__c> wuList = [select id , Lead__c , Contact__c from Wlink__Wechat_User__c where Wlink__Open_Id__c = :openId];
        if(wuList.isempty())
        {
            msg = 'NO Wechat User';
        }
        else
        {
            Wlink__Wechat_User__c wu = wuList[0];
            //根据Wechat User关联的Lead和Contact和市场活动ID查询市场活动成员
            List<CampaignMember> cmList = [select Id , Status__c 
                                           from CampaignMember 
                                           where ((leadId = :wu.Lead__c and leadId <> null) 
                                           or (contactId = :wu.Contact__c and contactId <> null))
                                           and campaignId = :campaignId ];
            //无法查出市场活动成员
            if(cmList.isempty())
            {
                msg = 'NO Campaign Member';
            }
            else
            {
                cmList[0].Status__c = '已出席';
                update cmList[0];
                msg = 'OK';
            }
        }
        return msg;
    }
    
    //生产Wechat User
    public static Wlink__Wechat_User__c GenerateWechatUser(string campaignId , string openId)
    {
        InitCalloutService(campaignId);
        wlink.WEMPEntity.User user = wcs.GetUserInfo(openId);
        Wlink__Wechat_User__c wu = new Wlink__Wechat_User__c();
        wu.Wlink__Status__c = (user.subscribe==0 ? 'Unsubscribe' : 'Subscribe');
        wu.Wlink__Sex__c = (user.sex==1 ? 'Male' : 'Female');
        wu.Wlink__Nick_Name__c = user.nickname;
        wu.Name = user.nickname;
        wu.Wlink__Language__c = user.language;  
        wu.Wlink__City__c = user.city;
        wu.Wlink__Province__c = user.province;
        wu.Wlink__Country__c = user.country;   
        wu.Wlink__Head_Image_Url__c = user.headimgurl;
        wu.Wlink__Union_Id__c = user.unionid;  
        wu.Wlink__Open_Id__c = user.openid;
        return wu;
    }
    
    public class OauthUser
    {
        public string access_token{get;set;}
        public integer expires_in{get;set;}
        public string refresh_token{get;set;}
        public string openid{get;set;}
        public string scope{get;set;}
        public string unionid{get;set;}
    }
    
    public class Member
    {
        public string firstname{get;set;}
        public string lastname{get;set;}
        public string email{get;set;}
        public string company{get;set;}
        public string phone{get;set;}
        public string position{get;set;}
    }
    
    public class MassSendMPNews
    {
        public List<string> touser;
        public MPNews mpnews;
        public string msgtype;
    }
    
    public class MPNews
    {
        public string media_id;
    }
    
    public class WechatUserResponse
    {
        public integer total;
        public integer count;
        public Data data;
        public string next_openid;
    }
    
    public class GetMediaNewsResponse
    {
        public List<GetMediaNews> news_item;
    }
    
    public class GetMediaNews
    {
        public string title;
        public string thumb_media_id;
        public string show_cover_pic;
        public string author;
        public string digest;
        public string content;
        public string url;
        public string content_source_url;
    }
    
    public class UpdateMPNewsRequest
    {
        public string media_id;
        public integer index;
        public UpdateArticle articles;
    }
    
    public class UpdateArticle
    {
        public string title;
        public string thumb_media_id;
        public string author;
        public string digest;
        public string show_cover_pic;
        public string content;
        public string content_source_url;
    }
    
    public class Data
    {
        public List<string> openid;
    }
    public class WechatResponse
    {
        public integer errcode;
        public string errmsg;
        public long msg_id;
    }
}