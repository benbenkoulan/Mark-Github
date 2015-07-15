/*
wendy   
2015-2-9
销售目标完成情况，每一个月run  
*/ 
global class SalesTargetCompletedScheduler implements Schedulable     
{
	public static Map<Id,SalesTargetCompleteStatus__c> map_STCS = new Map<Id,SalesTargetCompleteStatus__c>();//本月信息
	public static String Error='';
	
	public void execute(SchedulableContext sc)
	{
		String year = String.valueOf(Date.today().year()); 
		String month = String.valueOf(Date.today().month()); 
		allMethods(year,month);
	}
	
	//按钮调用方法，进行刷新
	webService static String RunFresh(String year, String month)
	{
		try
		{
			allMethods(year,month);
			
			if(Error!=null && Error!='')
			{
				return Error;
			}
			return 'TRUE';
		}
		catch(Exception e)
		{
			return 'ERROR:'+e;
		}
	}
	private static void allMethods(String year,String month)
	{
		Integer mon = Integer.valueOf(month);
		if(mon>=1 && mon<=3)
		{
			for(Integer i=1;i<=3;i++)
			{
				innerMethod(year,i+'');
			}
		}else if(mon>=4 && mon<=6)
		{
			for(Integer i=4;i<=6;i++)
			{
				innerMethod(year,i+'');
			}
		}else if(mon>=7 && mon<=9)
		{
			for(Integer i=7;i<=9;i++)
			{
				innerMethod(year,i+'');
			}
		}else if(mon>=10 && mon<=12)
		{
			for(Integer i=10;i<=12;i++)
			{
				innerMethod(year,i+'');
			}
		}
	}
	
	private static void innerMethod(String year,String month)
	{
		//从基础表中取出信息：年，月，当前年月的目标，同期，ID 
		getSalesInformation(year,month);  
		//取合同上对应的完成金额,并将map_STCS赋值
		getCompletedAmount(year,month);
		//取得业务机会上对应的确认金额
		getCommitAmount( month, year);
		upsert map_STCS.values() External_ID__c;
	}
	
	//从基础表中取出信息：年，月，当前年月的目标，同期，E ID，
	private static void getSalesInformation(String year,String month)//参数是年月，由合同来的‘完成金额’
	{
		String lastYear = String.valueOf(Integer.valueOf(year)-1);//去年 
		Integer i=0;
		for(SalesTarget__c st :[ Select s.Year__c, s.Sales__c, Target__c,Month__c
								  From SalesTarget__c s where s.Year__c =:year or s.Year__c =:lastYear order by s.Year__c desc])
		{
			if(st.Year__c == year && st.Month__c == month)
			{
				if(st.Target__c != null)
				{
					getThisMap(st.Target__c,st.Sales__c,year,month);
				}
			}
			i++;
		}
		if(i==0)//说明基础表没有数据
		{
			Error+='找不到基础表数据!';
		}
	}
	//将本月信息存到map中
	private static void getThisMap(Decimal target,Id salesId,String year,String month)//目标，销售id，年，月
	{
		String lastYear = String.valueOf(Integer.valueOf(year)-1);//去年
		Integer monthInt = Integer.valueOf(month);//当前月
		SalesTargetCompleteStatus__c stcs = new SalesTargetCompleteStatus__c();
		stcs.Sales__c = salesId;//销售
		stcs.Target__c = target;
		stcs.CommitAmount__c = 0;
		stcs.CompletedAmount__c = 0; 
		stcs.SamePeriodAmount__c = 0; 
		for(SalesTargetCompleteStatus__c s : [ select RestAmount__c,Year__c,Month__c,Target__c,Sales__c,CompletedAmount__c from SalesTargetCompleteStatus__c
								where Year__c =:year or Year__c =:lastYear order by Year__c desc]) 
		{
			if(s.Sales__c == salesId && s.Year__c == year && s.Month__c == String.valueOf((Integer.valueOf(month)-1)))
			{
				if(monthInt!=1 && monthInt!=4 && monthInt!=7 && monthInt!=10)//季度清0，上一季度未完成的，不算到下一季度
				{
					stcs.Target__c += s.RestAmount__c;//本月目标+上月差值，**************上月差值为负时，+0  **********
				}
			}
			if(s.Sales__c == salesId && s.Month__c == month && s.Year__c == String.valueOf((Integer.valueOf(year)-1)))
			{
				stcs.SamePeriodAmount__c = s.CompletedAmount__c;//同期  
			}
		}
		stcs.Year__c = year;//年
		stcs.Month__c =month;//月 
		stcs.External_ID__c = year+month+salesId;//年月+销售Id
		map_STCS.put(salesId,stcs);
	}
	
	//从业务机会上获得信息：确认金额
	private static void getCommitAmount(String month,String year)
	{
		Integer monthInt = Integer.valueOf(month);
		Integer yearInt = Integer.valueOf(year);
		Date startDate =  Date.newInstance(yearInt, monthInt, 1);//起始日期
		Date endDate = startDate.addMonths(1);//结束日期，相差1个月
		for(Opportunity opp :  [ select id,Amount,CloseDate,ForecastCategoryName,OwnerId from Opportunity where ForecastCategoryName ='提交' 
								 and CloseDate >= :startDate and CloseDate < :endDate and OwnerId in :map_STCS.keySet()])
		{
			SalesTargetCompleteStatus__c stcs = map_STCS.get(opp.OwnerId);
			if(stcs == null)
			continue;
			if(opp.Amount != null)
			{
				stcs.CommitAmount__c += opp.Amount;
			}
			stcs.CommitAmount__c += 0;
		}
	}
	//从合同分割上获得相关信息：完成金额
	private static void getCompletedAmount(String year,String month)
	{
		Integer monthInt = Integer.valueOf(month);
		Integer yearInt = Integer.valueOf(year);
		Date startDate =  Date.newInstance(yearInt, monthInt, 1);//起始日期
		Date endDate = startDate.addMonths(1);//结束日期，相差1个月
		for(ConstractSpilt__c contractS : [ select id,SplitAmount__c,constract__c,constract__r.Contract_Status_Yu1__c,constract__r.ContractType__c,Alloter__c,constract__r.ContractSignDate__c from ConstractSpilt__c 
									where (constract__r.Contract_Status_Yu1__c = '已启用' or constract__r.Contract_Status_Yu1__c='批准过程中') 
									and constract__r.ContractType__c !='产品' and constract__r.ContractType__c !='代付'
									and constract__r.ContractType__c !='SFDC市场费' and constract__r.ContractType__c !='采购合同'
									and constract__r.ContractSignDate__c >= :startDate and constract__r.ContractSignDate__c < :endDate
									and Alloter__c in:map_STCS.keySet()])
		{
			SalesTargetCompleteStatus__c stcs = map_STCS.get(contractS.Alloter__c);
			if(stcs == null)
			continue;
			if(contractS.SplitAmount__c != null)
			{
				stcs.CompletedAmount__c += contractS.SplitAmount__c;
			}
		}
		
	}
}