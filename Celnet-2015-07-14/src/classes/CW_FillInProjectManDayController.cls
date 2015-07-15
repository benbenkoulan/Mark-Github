/**
 * Author:mark.li@celnet.com.cn
 * Date: 2015-3-24
 * Description: 
 */
public class CW_FillInProjectManDayController 
{
    // 用户保存时选择的周
    public String selectedWeek{get;set;}
    
    // 所属周描述
    public string lastStandardWeek{get;set;}
    public string standardWeek{get;set;}
    public string last_lastStandardWeek{get;set;}
 
    // 当前登录的用户名称
    public string UserName{get;set;}
    
    // 无可录人天时的提示语和提示图片
    public string reminderUrl{
        get{
            return 'https://c.ap1.content.force.com/servlet/servlet.ImageServer?id=01590000007rcMR&oid=00D900000011gkK&lastMod=1423729225000';
        }
        set;
    }
    
    public string reminder{
        get{
            return '系统找不到您本周所参加的项目，请到Salesforce系统中，在您所参加的项目下添加项目团队成员以及检查更新进场离场时间。';
        }
        set;
    }
    
    // 可录项目列表
    public List<ManDayWrapper> last_lastWeekMW{get;set;}
    public List<ManDayWrapper> lastWeekMW{get;set;}
    public List<ManDayWrapper> thisWeekMW{get;set;}
    
    // 判断是否有可录的项目
    public boolean hasLastLastWeekMW{get;set;}
    public boolean hasLastWeekMW{get;set;}
    public boolean hasThisWeekMW{get;set;}
    
    // 人天的wrapper class
    public class ManDayWrapper
    {
        public mandayanalysis__c manday{get;set;}
        public String weekNumber{get;set;}
        public Decimal days{get;set;}
        public String projectId{get;set;}
        public String projectName{get;set;}
        public String description{get;set;}
        
        // 用于已经录入的人天
        public ManDayWrapper(mandayanalysis__c mda)
        {
            this.manday = mda;
            this.days = (mda.manday__c == null?0:mda.manday__c);
            this.projectId = mda.project_assisted__c;
            this.projectName = mda.project_assisted__r.Name;
            this.description=mda.description__c;
        }
        
        // 用于可录人天但是尚未录入的项目
        public ManDayWrapper(String weekNo, String pId, String pName)
        {
            this.manday = new mandayanalysis__c();
            this.manday.project_assisted__c = pId;
            this.manday.relatedproject__c =  pId;
            this.manday.Week_No__c = weekNo;
            this.manday.relateuser__c = Userinfo.getUserId();
            this.weekNumber = weekNo;
            this.days = 0;
            this.projectId = pId;
            this.projectName = pName;
        }
    }
    
    public CW_FillInProjectManDayController()
    {
        UserName = UserInfo.getName();
        Date day = system.today();

        DateHelper.Week thisWeek = DateHelper.GetFYWeekByDate(day);
        standardWeek = retrieveWeekDescription(thisWeek);
        
        DateHelper.Week lastWeek = DateHelper.GetFYWeekByDate(day).LastWeek;
        lastStandardWeek = retrieveWeekDescription(lastWeek);
        
        DateHelper.Week last_lastWeek = DateHelper.GetFYWeekByDate(day).LastWeek.LastWeek;
        last_lastStandardWeek = retrieveWeekDescription(last_lastWeek);
    
        lastWeekMW = retrieveExistedManDay(lastWeek.No);
        Map<String, String> lastWeekprojectMap = retrieveProjectMap2(lastWeekMW);
        lastWeekMW.addAll(retrieveNonExistedManDay(lastWeek.WeekStartDate, lastWeek.No, lastWeekprojectMap));
        
        last_lastWeekMW = retrieveExistedManDay(last_lastWeek.No);
        Map<String, String> last_lastWeekprojectMap = retrieveProjectMap2(last_lastWeekMW);
        last_lastWeekMW.addAll(retrieveNonExistedManDay(last_lastWeek.WeekStartDate, last_lastWeek.No, last_lastWeekprojectMap));
        
        thisWeekMW = retrieveExistedManDay(thisWeek.No);
        Map<String, String> thisWeekprojectMap = retrieveProjectMap2(thisWeekMW);
        thisWeekMW.addAll(retrieveNonExistedManDay(thisWeek.WeekStartDate, thisWeek.No, thisWeekprojectMap));
        
        hasLastLastWeekMW = (last_lastWeekMW.size() > 0);
        hasLastWeekMW = (lastWeekMW.size() > 0);
        hasThisWeekMW = (thisWeekMW.size() > 0);
    }
    
    // 可录项目和已录项目之间的查重
    private map<string , string> retrieveProjectMap2(list<ManDayWrapper> projectMandayList)
    {
        map<string , string> projectMap = new map<string , string>();
        for(ManDayWrapper m : projectMandayList)
        {
            if(!projectMap.containsKey(m.projectName))
            {
                projectMap.put(m.projectName , m.manday.project_assisted__r.Id);
            }
        }
        return projectMap;
    }
    
    // 获取已录项目
    public List<ManDayWrapper> retrieveExistedManDay(String weekNo)
    {
        List<ManDayWrapper> existedMWList = new List<ManDayWrapper>();
        
        List<mandayanalysis__c> existedManDayList = [Select Id,
                                                        projectstandardmandy__c,
                                                        relateuser__c,
                                                        manday__c,
                                                        relatedproject__c , 
                                                        project_assisted__c,
                                                        project_assisted__r.Name,
                                                        description__c
                                                      From mandayanalysis__c
                                                      Where Week_No__c =: weekNo
                                                      And relateuser__c =: UserInfo.getUserId()];
        
        for(mandayanalysis__c eMD : existedManDayList)
        {
            if(existedManDayList.size() == 5)
            {
                break;
            }
            existedMWList.add(new ManDayWrapper(eMD));
        }
       
        return existedMWList;
    }

    // 获取可录但是尚未录入人天的项目
    public List<ManDayWrapper> retrieveNonExistedManDay(Date thisStartWeek, String weekNo, Map<String, String> projectMap)
    {
        List<ManDayWrapper> nonExistedMWList = new List<ManDayWrapper>();
        
        List<ObjectItemTeamMember__c> memberList = [Select 
                                                        Nitem__c, 
                                                        Nitem__r.Name 
                                                    From ObjectItemTeamMember__c 
                                                    Where NitemMenber__c =: UserInfo.getUserId()
                                                    And (NLeaveTime__c >: thisStartWeek Or NLeaveTime__c = null)];
        
        for(ObjectItemTeamMember__c oit : memberList)
        {
            if(!projectMap.containsKey(oit.Nitem__r.Name))
            {
                nonExistedMWList.add(new ManDayWrapper(weekNo, oit.Nitem__c, oit.Nitem__r.Name));
            }
        }
        
        return nonExistedMWList;
    }
    
    // 保存项目人天
    public void saveManDay()
    {
        List<mandayanalysis__c> saveManDays = new List<mandayanalysis__c>();
        
        if(selectedWeek == 'thisweek')
        {
            saveManDays = rebuildSaveManDays(thisweekMW);
        } 
        else if (selectedWeek == 'lastweek')
        {
            saveManDays = rebuildSaveManDays(lastweekMW);
        } 
        else if (selectedWeek == 'lastlastweek')
        {
            saveManDays = rebuildSaveManDays(last_lastweekMW);
        }
        
        upsert saveManDays;
    }
    
    // 准备保存数据
    public List<mandayanalysis__c> rebuildSaveManDays(List<ManDayWrapper> mwList)
    {
        List<mandayanalysis__c> saveManDays = new List<mandayanalysis__c>();
        
        for(ManDayWrapper mdw : mwList)
        {
            mandayanalysis__c m = mdw.manday;
            m.manday__c = mdw.days;
            m.InputSource__c = 'Welink';
            m.description__c=mdw.description;
            if(m.Id != null || (m.manday__c != null && m.manday__c > 0)){
                saveManDays.add(m);
            }
        }
        
        return saveManDays;
    }
    
    // 获取标准周
    private string retrieveWeekDescription(DateHelper.Week week)
    {
        string startDay = string.valueOf(week.WeekStartDate.year()) + '-' + string.valueOf(week.WeekStartDate.month()) + '-' + string.valueOf(week.WeekStartDate.day());
        string endDay = string.valueOf(week.WeekEndDate.year()) + '-' + string.valueOf(week.WeekEndDate.month()) + '-' + string.valueOf(week.WeekEndDate.day());
        return '所属周:' + week.No + '(从' + startDay + '到' + endDay + ')';
    }
}