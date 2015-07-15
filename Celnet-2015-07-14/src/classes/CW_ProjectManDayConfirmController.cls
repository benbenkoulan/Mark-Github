public class CW_ProjectManDayConfirmController 
{
	public string managerId;
	
	public string last_lastStandardWeek{get;set;}
	public string lastStandardWeek{get;set;}
	public string standardWeek{get;set;}
	public string UserName{get;set;}
	
	public List<ManagerProject> last_lastWeekManagerProject{get;set;}
	public List<ManagerProject> lastWeekManagerProject{get;set;}
	public List<ManagerProject> thisWeekManagerProject{get;set;}
	
	public CW_ProjectManDayConfirmController()
	{
		managerId = Userinfo.getUserId();//'00590000003Bw9w';//'00590000003Bpig';
		UserName = UserInfo.getName();
		Date day = system.today();
        DateHelper.Week thisWeek = DateHelper.GetFYWeekByDate(day);
        standardWeek = RetrieveStandaraWeek(thisWeek);
        lastStandardWeek = RetrieveStandaraWeek(thisWeek.LastWeek);
        last_lastStandardWeek = RetrieveStandaraWeek(thisWeek.LastWeek.LastWeek);
        
        map<string , string> last_lastWeekManDay = new map<string , string>();        
		last_lastWeekManDay = RetrieveProjectManDayMap(thisWeek.LastWeek.LastWeek.No);
        last_lastWeekManagerProject = RetrieveManagerProjectManDay(thisWeek.LastWeek.LastWeek , managerId , last_lastWeekManDay);
        
        map<string , string> lastWeekManDay = new map<string , string>();        
		lastWeekManDay = RetrieveProjectManDayMap(thisWeek.LastWeek.No);
        lastWeekManagerProject = RetrieveManagerProjectManDay(thisWeek.LastWeek , managerId , lastWeekManDay);
        
		map<string , string> thisWeekManDay = new map<string , string>();        
		thisWeekManDay = RetrieveProjectManDayMap(thisWeek.No);
        thisWeekManagerProject = RetrieveManagerProjectManDay(thisWeek , managerId , thisWeekManDay);
        
	}
	
	//获取项目经理所负责项目的指定周的项目人天
	public List<ManagerProject> RetrieveManagerProjectManDay(DateHelper.Week theWeek , string managerId , map<string , string> weekManDayMap)
	{
		List<ManagerProject> managerProjectList = new List<ManagerProject>();
		List<ManagerProject> tempProjectList = new List<ManagerProject>();
		for(SFDC_Projects__c pro :[Select id , Name , (Select Id , Nitemmenber__c , Nitemmenber__r.Name From item_itemmenber_relation__r where NLeaveTime__c > :theWeek.WeekStartDate) From SFDC_Projects__c where (Projectmanager__c = :managerId or ownerId = :managerId) and Project_Imp_Stage__c <> '已完成' and Project_Imp_Stage__c <> '暂停' and State__c <> '关闭'])
		{
			ManagerProject mp = new ManagerProject();
			List<ProjectMember> mList = new List<ProjectMember>();
			decimal currentManday = 0.0;
			for(ObjectItemTeamMember__c ot : pro.item_itemmenber_relation__r)
			{
				string key = string.valueOf(pro.Id) + string.valueOf(ot.Nitemmenber__c);
				if(weekManDayMap.containsKey(key))
				{
					ProjectMember member = new ProjectMember();
					member.projectMember = ot.Nitemmenber__r.Name;
					member.manDay = weekManDayMap.get(key);
					currentManday = currentManday + decimal.valueOf(weekManDayMap.get(key));
					mList.add(member);
				} 
			}
			mp.currentManDay = currentManday;
			mp.memberList = mList;
			if(mp.memberList.isempty())
			{
				mp.nullDisplay = '';
			}
			else
			{
				mp.nullDisplay = 'none';
			}
			if(pro.Name.length() > 25)
			{
				mp.projectName = pro.Name.substring(0,25) + '...';
			}
			else
			{
				mp.projectName = pro.Name;
			}
			if(currentManday == 0.0)
			{
				tempProjectList.add(mp);
			}
			else
			{
				managerProjectList.add(mp);
			}
		}
		managerProjectList.addAll(tempProjectList);
		return managerProjectList;
	}
	
	//获取指定周的项目人天映射
	public map<string , string> RetrieveProjectManDayMap(string weekNo)
	{
		map<string , string> weekManDay = new map<string , string>();        
        for(mandayanalysis__c m : [Select relateuser__c , relatedproject__c , manday__c From mandayanalysis__c where Week_No__c = :weekNo])
		{
			weekManDay.put(string.valueOf(m.relatedproject__c) + string.valueOf(m.relateuser__c) , string.valueOf(m.manday__c));
		}
		return weekManDay;
	}
	
	 // 获取标准周
    public string RetrieveStandaraWeek(DateHelper.Week week)
    {
        string startDay = string.valueOf(week.WeekStartDate.year()) + '-' + string.valueOf(week.WeekStartDate.month()) + '-' + string.valueOf(week.WeekStartDate.day());
        string endDay = string.valueOf(week.WeekEndDate.year()) + '-' + string.valueOf(week.WeekEndDate.month()) + '-' + string.valueOf(week.WeekEndDate.day());
        string standardWeek = '所属周:' + week.No + '(从' + startDay + '到' + endDay + ')';
        return standardWeek;
    }
	
	class ManagerProject
	{
		public List<ProjectMember> memberList{get;set;}
		public string projectName{get;set;}
		public decimal currentManDay{get;set;}
		public string nullDisplay{get;set;}
	}
	
	class ProjectMember
	{
		public string projectMember{get;set;}
		public string manDay{get;set;}
	}
}