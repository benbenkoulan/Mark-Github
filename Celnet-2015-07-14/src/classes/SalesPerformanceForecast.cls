/*Author:Leo
 *Date:2014-02-12
 *Function:将系统标准的Forcast修改为周的模式
 */
public class SalesPerformanceForecast
{
	public String StartWeek{get;set;}//预测开始周
	public String EndWeek {get;set;}//预测结束周
	private Date StartDate;//开始日期
	private Date EndDate;//结束日期
	private Integer WeeiListSize;//标准祝选项列表长度
	public List<SelectOption> List_WeekLisk {get;set;}//标准周列表
	private Map<String,DateHelper.Week> map_No_Week;//根据标准周编号获取标准周
	public static Set<String> set_OppFinish = new Set<String>{'已结束/赢得客户'};
	public static Set<String> set_OppHighest = new Set<String>{'方案制定', '方案确认', '报价', '商务谈判'};
	public static Set<String> set_OppFlow = new Set<String>{'销售线索', '项目立项', '需求分析', '需求调研'};
	public static Set<String> set_OppCommit = new Set<String>{'提交'};
	public Map<String,WeekLine> map_Week_Opp {get;set;}
	public List<WeekLine> list_WeekLine{get;set;}//周列表

	public SalesPerformanceForecast()
	{
		this.map_Week_Opp= new Map<String,WeekLine>();
		this.List_WeekLisk = new List<SelectOption>();
		this.list_WeekLine = new List<WeekLine>();
		this.map_No_Week = new Map<String,DateHelper.Week>();
		this.WeeiListSize = 12;//设置标准周列表有12个选项值
		this.initStandardWeek();//初始化标准周
		if(this.List_WeekLisk.size() >= 4)
		{//设置开始周结束周默认值
			this.StartWeek = List_WeekLisk[0].getValue();
			this.EndWeek = List_WeekLisk[5].getValue();
		}
		this.loadData();
	}

	//加载数据
	private void loadData()
	{
		
		this.formatStandardWeekSectionDate();//格式化所选标准周区间的日期
		this.packageWeekLine();
		this.list_WeekLine = this.map_Week_Opp.values();
	}

	//初始化标准周
	private void initStandardWeek()
	{
		Date NowYear = Date.today();
		DateHelper.Week ThisWeek = DateHelper.GetThisFYWeek();//当前标准周
		List<DateHelper.Week> List_ThisYearStandardWeek = DateHelper.GetFYWeeks(NowYear.year());//获取当前财年标准周列表
		List<DateHelper.Week> List_LastYearStandardWeek = DateHelper.GetFYWeeks(NowYear.addYears(1).year());//获取明年标准周列表
		//TODO处理标准周出错问题
		//封装周列表
		Integer i = 0, j = 0;
		while(this.List_WeekLisk.size() < this.WeeiListSize)
		{//标准周列表未装满时进入循环
			DateHelper.Week Temp_Week = new DateHelper.Week();
			if(i < List_ThisYearStandardWeek.size())
			{//先装今年标准周
				Temp_Week = List_ThisYearStandardWeek[i];
				if(Temp_Week.WeekStartDate >= ThisWeek.WeekStartDate)
			    {//只装当前周和以后的周
		   			this.List_WeekLisk.add(new SelectOption(Temp_Week.No, Temp_Week.No));
		   			this.map_No_Week.put(Temp_Week.No, Temp_Week);
			    }
			}
			else
			{//如果今年标准周装完，装明年标准周
				Temp_Week = List_ThisYearStandardWeek[j];
	   			this.List_WeekLisk.add(new SelectOption(Temp_Week.No, Temp_Week.No));
	   			this.map_No_Week.put(Temp_Week.No, Temp_Week);
	   			j++;
			}
		    i++;
		}
	}

	//格式化所选标准周区间的日期
	private void formatStandardWeekSectionDate()
	{
		this.StartDate = this.map_No_Week.get(this.StartWeek).WeekStartDate;
		this.EndDate = this.map_No_Week.get(this.EndWeek).NextWeek.WeekStartDate;
	}

	private void packageWeekLine()
	{
		
		for(Opportunity opp : [select Id, Name, AccountId, Amount, SFDC_Amount1__c, Probability, CloseDate, OwnerId,
							   Field1_GetOppTime__c, StageName, Important__c, OppSource__c, SalesForce_salesmember__c, ForecastCategoryName
							   from Opportunity where CloseDate >= :this.StartDate and CloseDate <= :this.StartDate]
		    )
		{
			String weekNo = DateHelper.GetFYWeekByDate(opp.CloseDate).No;
			WeekLine tempWeekLine;
			if(map_Week_Opp.containsKey(weekNo))
			{
				tempWeekLine = 	map_Week_Opp.get(weekNo);
				tempWeekLine.addOpportunity(opp);//将业务机会放入周
			}
			else
			{
				tempWeekLine = new WeekLine(weekNo);//所属周赋值
				tempWeekLine.addOpportunity(opp);
				map_Week_Opp.put(weekNo, tempWeekLine);//将业务机会放入周
			}
			
		}
	}

	public void pageValid()
	{}

	public void refreshForecast()
	{}

	class Cell
	{
		public Decimal Amount {get;set;}//单元格金额
		public List<Opportunity> List_CellOpp {get;set;}//每个单元格包含的业务机会List

		public Cell()
		{//初始化成员，避免空指针
			this.Amount = 0;
			this.List_CellOpp = new List<Opportunity>();
		}

		//将业务机会装到单元格中
		void addOpportunity(Opportunity opp)
		{
			this.List_CellOpp.add(opp);
			if(opp.Amount != null)
			{
				this.Amount += opp.Amount;
			}
		}
	}

	class SalesLine
	{
		public Id Sales {get;set;}
		public Cell Finished {get;set;}
		public Cell Highest {get;set;}
		public Cell Flow {get;set;}
		public Cell Commited {get;set;}
		public String BelongWeek {set;get;}

		public SalesLine(String BelongWeek, Id u)
		{
			this.Finished = new Cell();
			this.Highest  = new Cell();
			this.Flow  = new Cell();
			this.Commited  = new Cell();
			this.BelongWeek = BelongWeek;
			this.Sales = u;
		}

		//将业务机会装到销售列中
		void addOpportunity(Opportunity opp)
		{
			if(SalesPerformanceForecast.set_OppFinish.contains(opp.StageName))
			{
				this.Finished.addOpportunity(opp);
			}
			else if(SalesPerformanceForecast.set_OppCommit.contains(opp.ForecastCategoryName))
			{
				this.Commited.addOpportunity(opp);
			}
			else if(SalesPerformanceForecast.set_OppHighest.contains(opp.StageName))
			{
				this.Highest.addOpportunity(opp);
			}
			else if(SalesPerformanceForecast.set_OppFlow.contains(opp.StageName))
			{
				this.Flow.addOpportunity(opp);
			}
		}
	}

	class WeekLine
	{
		public String WeekLabel{get;set;}
		public Cell Finished {get;set;}
		public Cell Highest {get;set;}
		public Cell Flow {get;set;}
		public Cell Commited {get;set;}
		private Map<Id,SalesLine> map_Id_SalesLine;
		public List<SalesLine> Lit_SalesLine
		{
			get
			{
				return map_Id_SalesLine.values();
			}
			set;
		}

		public WeekLine(String WeekLabel)
		{
			this.WeekLabel = WeekLabel;
			this.Finished = new Cell();
			this.Highest  = new Cell();
			this.Flow  = new Cell();
			this.Commited  = new Cell();
			this.Lit_SalesLine = new List<SalesLine>();
			this.map_Id_SalesLine = new Map<Id,SalesLine>();
		}

		void addOpportunity(Opportunity opp)
		{
			if(SalesPerformanceForecast.set_OppFinish.contains(opp.StageName))
			{
				system.debug('----------set_OppFinish-----------');
				this.Finished.addOpportunity(opp);
			}
			else if(SalesPerformanceForecast.set_OppCommit.contains(opp.ForecastCategoryName))
			{
				system.debug('----------set_OppCommit-----------');
				this.Commited.addOpportunity(opp);
			}
			else if(SalesPerformanceForecast.set_OppHighest.contains(opp.StageName))
			{
				system.debug('----------set_OppHighest-----------');
				this.Highest.addOpportunity(opp);
			}
			else if(SalesPerformanceForecast.set_OppFlow.contains(opp.StageName))
			{
				system.debug('----------set_OppFlow-----------');
				this.Flow.addOpportunity(opp);
			}
			SalesLine temp_SL;
			if(map_Id_SalesLine.containsKey(opp.OwnerId))
			{
				temp_SL = map_Id_SalesLine.get(opp.OwnerId);
				temp_SL.addOpportunity(opp);
			}
			else
			{
				temp_SL = new SalesLine( DateHelper.GetFYWeekByDate(opp.CloseDate).No, opp.OwnerId);
				temp_SL.addOpportunity(opp);
				map_Id_SalesLine.put(opp.OwnerId, temp_SL);
			}
		}
		
	}
}