/*
*author:mark
*date:2015-02-28
*function:定时提醒填写周计划
*System.schedule('Wechat Confirm ProjectManday And Remind To Write WeekPlan','0 00 20 ? * FRI-SUN', new CW_RemindToWriteWeekPlanScheduler());
**/
global class CW_RemindToWriteWeekPlanScheduler implements Schedulable 
{
    public static string CorpId = 'wxecd61a327f09efc9';
    public static final string GroupName = 'Salesforce';
    public static final string UserIDs = '@all';
    
    global void execute(SchedulableContext sc)
    { 
        ProjectManDayConfirm();
        RemindWeekPlan();   
    }
    
    //触发项目经理人天提醒标志
    @future(callout=true)
    global static void ProjectManDayConfirm()
    {
        wlink.WEQYCalloutService wcs = new wlink.WEQYCalloutService (CorpId);
        map<Id , string> projectManagerMap = new map<Id , string>();
        for(SFDC_Projects__c pro :[Select id , Name , Projectmanager__c , Projectmanager__r.Temp_QY_ID__c From SFDC_Projects__c where Projectmanager__c <> '' and Project_Imp_Stage__c <> '已完成' and Project_Imp_Stage__c <> '暂停' and State__c <> '关闭'])
        {
            if(!projectManagerMap.containskey(pro.Projectmanager__c))
            {
                projectManagerMap.put(pro.Projectmanager__c , pro.Name);
            }
        }
        
        //获取企业号Wechat User
        List<Wlink__Wechat_User__c> userList = [select Id , Project_Confirm__c , Wlink__User_ID__c from Wlink__Wechat_User__c 
                                         where Wlink__Active__c = true
                                         and RecordType.DeveloperName = 'Internal'
                                         and ownerId in :projectManagerMap.keyset()];
        string text =  '您好，请点击以下链接确认人天：<a href="https://www.welinkcloud.com/Wechat2SFDC/SSO/SSOInit.aspx?SourceID=wxecd61a327f09efc9&AgentID=3&TartgetUrl=/apex/CW_ProjectManDayConfirm">点击确认人天</a>，快乐工作棒棒哒！';
        wlink.WEQYEntity.SendTextMsgRequest req = GetSendTextMsgRequest(userList , text ,'3');
        wcs.SendMsg(req);
        /*
            if(userList.isempty())
            {
                return;    
            }
            update userList;
            for(Wlink__Wechat_User__c wwu : userList)
            {
                wwu.Project_Confirm__c =false;
            }
            update userList;
        */
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
        req.touser = touser.substring(0 , touser.length() - 1);
        req.msgtype = 'text';
        req.agentid = agetId;
        wlink.WEQYEntity.Text t= new wlink.WEQYEntity.Text();
        t.content = text;
        req.text = t;
        return req;
    }
    
    //触发周计划填写提醒标志
    @future(callout=true)
    global static void RemindWeekPlan()
    {
        wlink.WEQYCalloutService wcs = new wlink.WEQYCalloutService (CorpId);
        //获取企业号Wechat User
        //List<Wlink__Wechat_User__c> userList = [select Id , Weekly_Plan__c , Wlink__User_ID__c from Wlink__Wechat_User__c 
                                        // where Wlink__Active__c = true
                                        // and RecordType.DeveloperName = 'Internal'];
        map<Id, string> userMap = new map<Id , string>();
        for(User u :[select id , Name from User where  IsActive = true])
        {
            userMap.put(u.Id , u.Name);
        }
        // 筛选出未填写周计划的用户，获取对应的企业号Id
        DateHelper.Week currentWeek = DateHelper.GetFYWeekByDate(Date.today());
        for(weekly_report_for_work__c wplan : [Select Id, Ownerid
                                            from weekly_report_for_work__c where Belongs_Week__c =:currentWeek.No+1])
        {
            if(userMap.containsKey(wplan.OwnerId)){
                userMap.remove(wplan.OwnerId);
            }
        }
        //获取企业号Wechat User
        List<Wlink__Wechat_User__c> userList = new List<Wlink__Wechat_User__c>();
        for(Wlink__Wechat_User__c wwu : [select Id , Weekly_Plan__c , Wlink__User_ID__c from Wlink__Wechat_User__c 
                                         where Wlink__Active__c = true
                                         and RecordType.DeveloperName = 'Internal'
                                         and ownerId in :userMap.keyset()])
        {
            //wwu.Project_Man_Day__c = true;
            userList.add(wwu);
        }
       string text = '您好,请点击以下链接填写周计划：<a href="https://www.welinkcloud.com/Wechat2SFDC/SSO/SSOInit.aspx?SourceID=wxecd61a327f09efc9&AgentID=4&TartgetUrl=/apex/CW_WeekPlan">点击填写周计划</a>，快乐工作棒棒哒！';
       wlink.WEQYEntity.SendTextMsgRequest req = GetSendTextMsgRequest(userList , text, '4');
       wcs.SendMsg(req);
        /*for(Wlink__Wechat_User__c wwu : [select Id , Weekly_Plan__c from Wlink__Wechat_User__c 
                                         where Wlink__Active__c = true
                                         and RecordType.DeveloperName = 'Internal'])
        {
            wwu.Weekly_Plan__c = true;
            userList.add(wwu);
        }
        if(userList.isempty())
        {
            return;    
        }
        update userList;
        for(Wlink__Wechat_User__c wwu : userList)
        {
            wwu.Weekly_Plan__c =false;
        }
        update userList;*/
    }
}