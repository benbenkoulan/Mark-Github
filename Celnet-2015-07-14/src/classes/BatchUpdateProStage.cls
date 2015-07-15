/*
wendy
2015-6-11
点击“同步项目阶段”按钮，判断当前时间是否在此项目的项目阶段所对应的时间范围内，如果在，将项目上的“项目实施阶段1”更新为项目阶段上的“阶段名称”，
如果不在，更新为空
*/
global class BatchUpdateProStage 
{
	public static Set<string> set_proIds = new Set<string>();
	public static Date d = Date.today();
	public static string newProStage=null;
	public static Map<Integer,string> stage_Map= new Map<Integer,string>();
	public static List<Integer> List_Stage = new List<Integer>();
	webService static String BatchUpdateProStage(string proIds)
	{
		string[] s = proIds.split(',');
		for(Integer i=0 ;i<s.size(); i++)
		{
			set_proIds.add(s[i]);
		}
		List<SFDC_Projects__c> list_pro = getProList(set_proIds);
		try
		{
			update list_pro;
			return 'OK';
		}catch(Exception e)
		{
			return 'NO:'+e.getMessage();  
		}
		
	}
	public static List<SFDC_Projects__c> getProList(Set<string> setproid)
	{
		//排序的map
		Map<string,Integer> tmpMap = new Map<string,Integer>();
		tmpMap.put('进场准备',1);
		tmpMap.put('需求调研',2);
		tmpMap.put('方案与设计',3);
		tmpMap.put('开发实施',4);
		tmpMap.put('部署培训',5);
		tmpMap.put('测试培训',6);
		tmpMap.put('上线',7);
		tmpMap.put('验收中',8);
		tmpMap.put('售后维护',9);
		tmpMap.put('暂停',10);
		tmpMap.put('已完成',11);
		List<SFDC_Projects__c> pro_List = [ select id,Name,
											Project_Imp_Stage__c,
											(Select SCdate__c, SSdate__c, NStageName__c From relatedproject__r)
											from SFDC_Projects__c where id in:setproid];
		if(pro_List.size()>0)
		{
			for(SFDC_Projects__c sfdcPro :pro_List)
			{
				for(projectstep__c pros : sfdcPro.relatedproject__r)
				{
					if(d>=pros.SSdate__c && d<=pros.SCdate__c)
					{
						newProStage=pros.NStageName__c;
						stage_Map.put(tmpMap.get(pros.NStageName__c),pros.NStageName__c);
						List_Stage.add(tmpMap.get(pros.NStageName__c));
					}
				}
				if(stage_Map.size() == 1)//无交叉时间
				{
					sfdcPro.Project_Imp_Stage__c = newProStage;
				}
				if(stage_Map.size()>1)//说明存在交叉的时间
				{
					sfdcPro.Project_Imp_Stage__c = stage_Map.get(List_Stage[0]);
				}
				List_Stage = new List<Integer>();
			}
		}
		return pro_List;
	}
}