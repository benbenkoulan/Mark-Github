/*
*author:markli
*date:2015-02-11
*function:定时发消息提示填报人天 
*System.schedule('Wechat Remind ProjectManday','0 00 17 ? * FRI-SUN', new CW_RemindProjectManDayScheduler());
* modified by Steven, 优化选择提醒，而不是全部提醒
**/
global class CW_RemindeProjectManDayScheduler implements Schedulable 
{   
    
    public static string CorpId = 'wxecd61a327f09efc9';
    /*
    public static final string GroupName = 'Salesforce';
    public static final string DepartmentIds = '9|8';
    */
    global void execute(SchedulableContext sc)
    { 
        ProjectManDay();
        /*
        if(userList.isempty())
        {
            return;    
        }
        update userList;
        for(Wlink__Wechat_User__c wwu : userList)
        {
            wwu.Project_Man_Day__c =false;
        }
        update userList;*/
    }
    
    @future(callout=true)
    global static void ProjectManDay()
    {
        wlink.WEQYCalloutService wcs = new wlink.WEQYCalloutService (CorpId);
        //获取需要填人天的用户
        List<string> userRoleList = GetUserRoles();
        map<Id, string> userMap = new map<Id , string>();
        for(User u :[select id , Name from User where UserRoleId in : userRoleList and IsActive = true])
        {
            userMap.put(u.Id , u.Name);
        }
        // 筛选出未填写人天的用户，获取对应的企业号Id
        DateHelper.Week currentWeek = DateHelper.GetFYWeekByDate(Date.today());
        for(mandayanalysis__c ma : [Select Id, relateuser__c
                                            From mandayanalysis__c 
                                            Where Week_No__c =: currentWeek.No])
        {
            if(userMap.containsKey(ma.relateuser__c)){
                userMap.remove(ma.relateuser__c);
            }
        }
        //获取企业号Wechat User
        List<Wlink__Wechat_User__c> userList = new List<Wlink__Wechat_User__c>();
        for(Wlink__Wechat_User__c wwu : [select Id , Project_Man_Day__c , Wlink__User_ID__c from Wlink__Wechat_User__c 
                                         where Wlink__Active__c = true
                                         and RecordType.DeveloperName = 'Internal'
                                         and ownerId in :userMap.keyset()])
        {
            //wwu.Project_Man_Day__c = true;
            userList.add(wwu);
        }
        string text = '您好,请点击以下链接填写项目人天：<a href="https://www.welinkcloud.com/Wechat2SFDC/SSO/SSOInit.aspx?SourceID=wxecd61a327f09efc9&AgentID=3&TartgetUrl=/apex/CW_FillInProjectManDay">点击填写人天</a>，快乐工作棒棒哒！';
        wlink.WEQYEntity.SendTextMsgRequest req = GetSendTextMsgRequest(userList , text ,'3');
        wcs.SendMsg(req);
    }
    
     //获取需要填人天的角色
    global static List<string> GetUserRoles()
    {
        List<string> roleIds = new List<string>();
        for(UserRole ur :[select Id , Name from UserRole where DeveloperName in ('CustomerServiceDirector','ProductDirector' , 'Developer_HD' , 'DevelopManager_HD' , 'ProjectManager_HD' , 'AssistantConsultant_HD')])
        {
            roleIds.add(ur.Id);
        }
        List<string> userRoleList = new List<string>();
        //递归获取角色以及所子角色
        GetRoleSubordinates(userRoleList , roleIds);
        return userRoleList;
    }
    
    //递归获取角色及其下属角色
    global static void GetRoleSubordinates(List<string> userRoleList , List<string> roleIds)
    {
        userRoleList.addAll(roleIds);
        List<string> subRoleList = new List<string>();
        //获得所选角色以及下属角色
        for(UserRole ur : [select id from UserRole where ParentRoleId in :roleIds])
            subRoleList.add(ur.id);
        if(!subRoleList.isEmpty())
            GetRoleSubordinates(userRoleList , subRoleList);
    }
    
    global static wlink.WEQYEntity.SendTextMsgRequest GetSendTextMsgRequest(List<Wlink__Wechat_User__c> userList , string text , string agetId)
    {
        string touser = '';
        for(Wlink__Wechat_User__c wwu : userList )
        {
            //wwu.Project_Confirm__c = true;
            //userList.add(wwu);
            touser +=  wwu.Wlink__User_ID__c+ '|';
        }
        wlink.WEQYEntity.SendTextMsgRequest req = new wlink.WEQYEntity.SendTextMsgRequest();
        req.touser = touser.length() > 0 ? touser.substring(0 , touser.length() - 1) : '';
        req.msgtype = 'text';
        req.agentid = agetId;
        wlink.WEQYEntity.Text t= new wlink.WEQYEntity.Text();
        t.content = text;
        req.text = t;
        return req;
    }
    
    
    /*
    @Future(callout=true)
    global static void UpdateUsers()
    {
        Wlink.WEQYCalloutService wcs = new Wlink.WEQYCalloutService(CorpId);
        list<Wlink__Wechat_Account__c> enterpriseList= [Select Wlink__Access_Token__c from Wlink__Wechat_Account__c where Wlink__Source_ID__c = :CorpId];
        Wlink__Wechat_Account__c wa = enterpriseList[0];
        String tousers = retrieveReminderUserIds(wa.Wlink__Access_Token__c );
        Wlink.WEQYEntity.SendNewsMsgRequest msg = new Wlink.WEQYEntity.SendNewsMsgRequest();
        //msg.toparty = DepartmentIds;
        msg.touser = tousers;
        msg.msgtype = 'news';
        msg.agentid = '3';

        Wlink.WEQYEntity.News news = new Wlink.WEQYEntity.News();
        List<Wlink.WEQYEntity.NewsArticle> articles = new List<Wlink.WEQYEntity.NewsArticle>();
        Wlink.WEQYEntity.NewsArticle art = new Wlink.WEQYEntity.NewsArticle();
        art.description = '快乐工作棒棒哒!';
        art.title ='亲！请别忘记填报项目人天!';
        art.url = 'http://www.celnet.com.cn/CelnetWelink/SSOInitPage.aspx?CorpID=wxecd61a327f09efc9&AgentID=3&Resource=/apex/CW_FillInProjectManDay';
        art.picurl = 'https://c.ap1.content.force.com/servlet/servlet.ImageServer?id=01590000007rYkA&oid=00D900000011gkK&lastMod=1423720973000';
        articles.add(art);
        news.articles = articles;
        msg.news = news;
        wcs.SendMsg(msg);
    }
    
    
    public static String retrieveReminderUserIds(string accessToken){
        
        // 获取部门为 8,9 的所有用户的企业号Id
        List<DepartmentUser> duList = new List<DepartmentUser>();
        duList.addAll(retrieveDepartmentUsers(accessToken , '8'));
        duList.addAll(retrieveDepartmentUsers(accessToken , '9'));
        
        List<String> QYUserIdList = new List<String>();
        
        for(DepartmentUser du : duList){
            QYUserIdList.add(du.userid);
        }
        
        // 获取对应的SF用户Id
        Map<String, String> sfQYIdMap = new Map<String, String>();
        
        for(User u : [Select Id, Temp_QY_ID__c From User Where Temp_QY_ID__c IN: QYUserIdList And IsActive = true]){
           sfQYIdMap.put(u.Id, u.Temp_QY_ID__c); 
        }
        
        
        // 筛选出未填写人天的用户，获取对应的企业号Id
        DateHelper.Week currentWeek = DateHelper.GetFYWeekByDate(Date.today());
        
        List<mandayanalysis__c> maList = [Select Id, relateuser__c
                                            From mandayanalysis__c 
                                            Where Week_No__c =: currentWeek.No];
        
        for(mandayanalysis__c ma : maList){
            System.debug(ma.relateuser__c);
            if(sfQYIdMap.containsKey(ma.relateuser__c)){
                sfQYIdMap.remove(ma.relateuser__c);
            }
        }
        
        List<String> qyUserIds = sfQYIdMap.values();
        
        if(qyUserIds.isEmpty())
        return '';
        
        String touser = '';
        
        for(String qyId : qyUserIds){
            touser += qyId;
            touser += '|';
        }
        
        touser = touser.substring(0, touser.length() - 1);
        
        return touser;
    }
    
    private static List<DepartmentUser> retrieveDepartmentUsers(String accessToken , string dId){
        // 获取部门的用户
        List<DepartmentUser> userlist = new List<DepartmentUser>();
        try
        {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            String endpoint = 'https://qyapi.weixin.qq.com/cgi-bin/user/simplelist?access_token=';
            endpoint += accessToken;
            endpoint += '&department_id=';
            endpoint += dId;
            endpoint += '&fetch_child=0&status=0';
            req.setEndpoint(endpoint);
            HttpResponse res = h.send(req);
            String resbody = res.getBody();
            DepartmentUserResponse dur = (DepartmentUserResponse)JSON.deserialize(res.getBody(), DepartmentUserResponse.class);
            userlist = dur.userList;
        }
        catch(Exception e)
        {
        
        }
        return userlist;
    }
    
    class DepartmentUserResponse{
        public String errcode;
        public String errmsg;
        public List<DepartmentUser> userlist;
    }
    
    class DepartmentUser{
        public String userid;
        public String name;
    }
    */
}