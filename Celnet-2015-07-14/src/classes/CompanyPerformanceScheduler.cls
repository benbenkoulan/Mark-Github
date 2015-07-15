/*
wendy
2015-2-11
公司业绩Log汇总 
*/  
global class CompanyPerformanceScheduler implements Schedulable {  
	public static CompanyPerformanceLog__c cpfl = new CompanyPerformanceLog__c();//公司业绩Log
	public static Integer year= Date.today().year();
	public static Integer month=Date.today().month(); 
	global void execute(SchedulableContext sc) 
	{
		//月度收款
		getMonthMoney();
		//月度开票  
		getMonthBill();
		//发票应收款
		getBillMoney();
		//合同应收款
		getContractMoney();
		//预计本月签单，预计本月签单金额（加权）
		getMonthSignBillAndSum();
		//月度OPP数量
		getMonthOppNumber();
		//Open Opp 数量 
		getOpenOppNumber();
		
		cpfl.Year__c=String.valueOf(year);
		cpfl.Month__c=String.valueOf(month);
		cpfl.External_ID__c=year+''+month+DateHelper.GetThisFYWeek().No;//20152FY2015W7
		system.debug('---------------------cpfl.External_ID__c:'+cpfl.External_ID__c);
		upsert cpfl External_ID__c; 
	}
	
	//按钮调用方法，进行刷新
	webService static String RunFresh(String yearStr, String monthStr)
	{
		try
		{
			cpfl.Year__c=String.valueOf(year);
			cpfl.Month__c=String.valueOf(month);
			cpfl.External_ID__c=year+''+month; 
			year = Integer.valueOf(yearStr);
			month = Integer.valueOf(monthStr);
			//月度收款
			getMonthMoney();
			//月度开票
			getMonthBill();
			//发票应收款
			getBillMoney();
			//合同应收款
			getContractMoney();
			//预计本月签单，预计本月签单金额（加权）
			getMonthSignBillAndSum();
			//月度OPP数量
			getMonthOppNumber();
			//Open Opp 数量 
			getOpenOppNumber();
			
			cpfl.Year__c=yearStr;
			cpfl.Month__c=monthStr;
			cpfl.External_ID__c=year+''+month+DateHelper.GetThisFYWeek().No;//20152FY2015W7
			cpfl.DateHelp__c=cpfl.External_ID__c;//辅助字段，用来刷新按钮使用
			upsert cpfl External_ID__c; 
			return 'TRUE';
		}
		catch(Exception e)
		{
			return 'ERROR:'+e;
		}
	}
	
	webService static String getWeek(String d)
	{
		try
		{
			Integer y = Integer.valueOf(d.split('-')[0]);
			Integer m = Integer.valueOf(d.split('-')[1]);
			Integer day = Integer.valueOf(d.split('-')[2]);
			Date ddd = Date.newInstance(y, m, day);
			String noStr = DateHelper.GetFYWeekByDate(ddd).No;
			return noStr;
		}catch(Exception e)
		{
			return 'ERROR'+e;
		}
	}
	
	//月度收款-预计本月收款的金额（实施服务、返点、市场合同（SFDC市场费）)
	private static void getMonthMoney()
	{
		cpfl.MonthlyPayment__c = 0;//月度收款
		Date startDate = Date.newInstance(year, month, 1);
		Date endDate = startDate.addMonths(1);
		for(Collection__c col : [ select Amount__c,Expectedcollectiondate__c,contract__c,contract__r.ContractType__c,collectionstatus__c
								 from Collection__c where Expectedcollectiondate__c>= :startDate and  Expectedcollectiondate__c < :endDate
								and (contract__r.ContractType__c='实施服务' or contract__r.ContractType__c='返点' or contract__r.ContractType__c='SFDC市场费')
								and collectionstatus__c = '已收'])
		{
			if(col.Amount__c != null) 
			{
				cpfl.MonthlyPayment__c += col.Amount__c;
			}
		}
	}
	//月度开票-预计本月开票的金额（服务、返点、市场合同）
	private static void getMonthBill()
	{
		cpfl.MonthlyBilling__c = 0;//月度开票
		Date startDate = Date.newInstance(year, month, 1);
		Date endDate = startDate.addMonths(1);
		for(Collection__c col : [select Amount__c,Expectedinvoicedate__c,invoicestatus__c,collectionstatus__c,contract__c,contract__r.ContractType__c from Collection__c 
								where Expectedinvoicedate__c>= :startDate and  Expectedinvoicedate__c < :endDate
								and (contract__r.ContractType__c='实施服务' or contract__r.ContractType__c='返点' or contract__r.ContractType__c='SFDC市场费')])
		{
			if(col.invoicestatus__c == '已开' && col.Amount__c != null)
			{
				cpfl.MonthlyBilling__c += col.Amount__c;
			}else if(col.invoicestatus__c == '未开' && col.collectionstatus__c=='已收' && col.Amount__c != null)
			{
				cpfl.MonthlyBilling__c += col.Amount__c;
			}
		}
	}
	//发票应收款-预计收款时间六个月内已开票未收款（服务、返点、市场合同）
	private static void getBillMoney()
	{
		cpfl.InvoiceReceivable__c = 0;//发票应收款
		Date startDate = Date.newInstance(year,month,1);//本月第一天
		Date endDate  = startDate.addMonths(6);//+6个月
		for(Collection__c col : [select Amount__c,Expectedcollectiondate__c, contract__c,contract__r.ContractType__c,
											collectionstatus__c,invoicestatus__c from Collection__c where Expectedcollectiondate__c>= :startDate 
											and  Expectedcollectiondate__c < :endDate and (contract__r.ContractType__c='实施服务' 
											or contract__r.ContractType__c='返点' or contract__r.ContractType__c='SFDC市场费')
											and invoicestatus__c='已开' and collectionstatus__c='未收' ])
		{
			if(col.Amount__c != null)
			{
				cpfl.InvoiceReceivable__c += col.Amount__c;
			}
		}
	}
	//合同应收款-预计收款时间12个月内所有未收款（服务、返点、市场合同）
	private static void getContractMoney()
	{
		cpfl.ContractReceivables__c = 0;//合同应收款
		Date startDate = Date.newInstance(year,month,1);//本月第一天
		Date endDate  = startDate.addYears(1);//+1年
		for(Collection__c col : [select Amount__c,Expectedcollectiondate__c, contract__c,contract__r.ContractType__c,
											collectionstatus__c from Collection__c where Expectedcollectiondate__c>= :startDate 
											and  Expectedcollectiondate__c < :endDate and (contract__r.ContractType__c='实施服务' 
											or contract__r.ContractType__c='返点' or contract__r.ContractType__c='SFDC市场费')
											and collectionstatus__c='未收'])
		{
			if(col.Amount__c != null)
			{
				cpfl.ContractReceivables__c += col.Amount__c;
			}
		}
		
	}
	//预计本月签单-结束日期在本月内的未暂停或者未丢单的业务机会金额汇总
	//预计本月签单金额（加权）-预计本月签单乘以业务机会可能性
	private static void getMonthSignBillAndSum()
	{
		cpfl.AnticipatedOrder__c=0;//预计本月签单
		cpfl.AnticipatedOrderSum__c=0;//预计本月签单金额（加权）
		Date startDate = Date.newInstance(year, month, 1);
		Date endDate = startDate.addMonths(1);
		for(Opportunity opp : [ select StageName,Amount,Probability,CloseDate from Opportunity
								where StageName!='暂停' and StageName!='已结束但失去客户' 
								and CloseDate>= :startDate and CloseDate< :endDate])
		{
			if(opp.Amount != null)
			{
				cpfl.AnticipatedOrder__c += opp.Amount;
				
				
				
				
				cpfl.AnticipatedOrderSum__c += (opp.Amount * opp.Probability*0.01);
			}
		}
	}
	//月度OPP数量-获得业务机会时间在本月的业务机会数量
	private static void getMonthOppNumber()
	{
		cpfl.OppNum__c=0;
		Date startDate = Date.newInstance(year, month, 1);
		Date endDate = startDate.addMonths(1);
		List<Opportunity> list_MonthOppNum = [ select id,Field1_GetOppTime__c from Opportunity
												where Field1_GetOppTime__c>= :startDate 
												and Field1_GetOppTime__c< :endDate];
		if(list_MonthOppNum.size()== null)
		return;
		cpfl.OppNum__c=list_MonthOppNum.size();
	}
	//Open Opp 数量  - 预计结束时间在六个月内的未暂停未丢单的业务机会数量
	private static void getOpenOppNumber()
	{
		cpfl.Open_OppNum__c=0;//Open Opp 数量 
		Date startDate = Date.newInstance(year,month,1);//本月第一天
		Date endDate  = startDate.addMonths(6);//+6个月
		List<Opportunity> list_Opp = [ select id,Name,StageName,Amount,Probability,CloseDate from Opportunity
												where StageName!='暂停' and StageName!='已结束但失去客户' 
												and CloseDate>= :startDate and CloseDate< :endDate];
		if(list_Opp.size()== null)
		return;
		cpfl.Open_OppNum__c=list_Opp.size();
	}
}