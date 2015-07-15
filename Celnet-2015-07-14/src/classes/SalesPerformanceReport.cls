/*Author:Leo Bi
 *Date:2014-02-09
 *Function:根据销售目标完成情况对象生成销售业绩报表
 */
 
public class SalesPerformanceReport 
{
    public string reportYear{get;set;} //当前年份
	public string reportMonth {get;set;}//当前月份
	public integer reportQuarter;//当前季度
    public string quarterLabel{get;set;}//当前季度,用于页面显示
	public string reportLastyear = String.valueOf(Date.today().addYears(-1).year());//去年
	public Map<Id,SalesPerformance> map_Sales_Performance_Now;//封装今年销售业绩
	public Map<Id,LastYearPerformance> map_Sales_Performance_Last;//封装去年销售年度业绩
    public List<SalesPerformance> list_SalesPerformance{get;set;}
    public string FirstMonth{set;get;}
    public string SecondMonth{set;get;}
    public string ThirdMonth{set;get;}
    public SalesPerformance AllSalesSummary{get;set;}
	
	public SalesPerformanceReport() 
	{
        try
        {
            this.loadData();
        }
        catch(Exception e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Warning , e.getMessage() + '*'  +e.getLineNumber() + '*' + e.getStackTraceString() + '*' + e.getTypeName());
			ApexPages.addMessage(msg);
  	 		return;
        }	
	}
    
	
	public void loadData()
	{
		this.reportYear = String.valueOf(Date.today().year());
        this.reportMonth = String.valueOf(Date.today().month());
        list_SalesPerformance = new List<SalesPerformance>();
        AllSalesSummary = new SalesPerformance();
        this.initNowQuarter();//初始化季度信息
        this.map_Sales_Performance_Last = this.distributeLastYearToSales();//封装去年销售年度业绩
        this.map_Sales_Performance_Now = this.distributeNowYearToSales();//封装今年销售年度业绩
        this.calculateNowYearInfo();
        if(map_Sales_Performance_Now.isEmpty()) this.list_SalesPerformance = new List<SalesPerformance>();
		else
        {
            this.list_SalesPerformance = this.map_Sales_Performance_Now.values();
            this.list_SalesPerformance = this.OrderSalesByRollingTarget(this.list_SalesPerformance);
            this.summaryAll();
            this.formatCurrrency(this.list_SalesPerformance); 
        }
	}

	private void summaryAll()
	{
		for(SalesPerformance sp : this.list_SalesPerformance)
		{
			this.AllSalesSummary.FirstMonth.Target += sp.FirstMonth.Target;
			this.AllSalesSummary.FirstMonth.CompletedAmount += sp.FirstMonth.CompletedAmount;
			this.AllSalesSummary.FirstMonth.CommitAmount += sp.FirstMonth.CommitAmount;
			this.AllSalesSummary.FirstMonth.SamePeriodAmount += sp.FirstMonth.SamePeriodAmount;

			this.AllSalesSummary.SecondMonth.Target += sp.SecondMonth.Target;
			this.AllSalesSummary.SecondMonth.CompletedAmount += sp.SecondMonth.CompletedAmount;
			this.AllSalesSummary.SecondMonth.CommitAmount += sp.SecondMonth.CommitAmount;
			this.AllSalesSummary.SecondMonth.SamePeriodAmount += sp.SecondMonth.SamePeriodAmount;

			this.AllSalesSummary.ThirdMonth.Target += sp.ThirdMonth.Target;
			this.AllSalesSummary.ThirdMonth.CompletedAmount += sp.ThirdMonth.CompletedAmount;
			this.AllSalesSummary.ThirdMonth.CommitAmount += sp.ThirdMonth.CommitAmount;
			this.AllSalesSummary.ThirdMonth.SamePeriodAmount += sp.ThirdMonth.SamePeriodAmount;

			this.AllSalesSummary.Quarter.Target += sp.Quarter.Target;
			this.AllSalesSummary.Quarter.CompletedAmount += sp.Quarter.CompletedAmount;
			this.AllSalesSummary.Quarter.CommitAmount += sp.Quarter.CommitAmount;
			this.AllSalesSummary.Quarter.SamePeriodAmount += sp.Quarter.SamePeriodAmount;

			this.AllSalesSummary.yearInfo.rollingTarget += sp.yearInfo.rollingTarget;
			this.AllSalesSummary.yearInfo.act += sp.yearInfo.act;
			this.AllSalesSummary.yearInfo.samePeriod += sp.yearInfo.samePeriod;//
		}
		this.AllSalesSummary.SalesName = '总计';
		this.AllSalesSummary.FirstMonth.calculate();
		this.AllSalesSummary.SecondMonth.calculate();
		this.AllSalesSummary.ThirdMonth.calculate();
		this.AllSalesSummary.Quarter.calculate();
		this.AllSalesSummary.yearInfo.calculate();
		this.list_SalesPerformance.add(this.AllSalesSummary);
	}

    public void refresh()
    {
    	String nowYear = String.valueOf(Date.today().year());
    	String nowMonth = String.valueOf(Date.today().month());
    	String result = SalesTargetCompletedScheduler.RunFresh(nowYear,nowMonth);
    	if(result == 'TRUE')
    	{
    		this.loadData();
    	}
    	else
    	{
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'ErrorInfo :'+ result);
    		ApexPages.addMessage(msg);
    	}
    }
	
	//初始化季度信息
	private void initNowQuarter()
	{
		integer nowMonth = Integer.valueOf(this.reportMonth);
		if(nowMonth <= 3) 
        {
            this.reportQuarter = 1;
            this.FirstMonth = '一月';
            this.SecondMonth = '二月';
            this.ThirdMonth = '三月';
            this.quarterLabel = '第一季度';
        }
		else if(nowMonth <= 6)
        {
            this.reportQuarter = 2;
            this.FirstMonth = '四月';
            this.SecondMonth = '五月';
            this.ThirdMonth = '六月';
            this.quarterLabel = '第二季度';
        }
		else if(nowMonth <= 9)
        {
            this.reportQuarter = 3;
            this.FirstMonth = '七月';
            this.SecondMonth = '八月';
            this.ThirdMonth = '九月';
            this.quarterLabel = '第三季度';
        }
		else 
        {
            this.reportQuarter = 4;
            this.FirstMonth = '十月';
            this.SecondMonth = '十一月';
            this.ThirdMonth = '十二月';
            this.quarterLabel = '第四季度';
        }
	}
	
	//封装到销售(今年销售业绩)
	private Map<Id,SalesPerformance> distributeNowYearToSales()
	{
		Map<Id,SalesPerformance> temp_Map = new Map<Id,SalesPerformance>();
		for(SalesTargetCompleteStatus__c stcs : [select Year__c, Target__c, SamePeriodRate__c, Quarter__c, SamePeriodAmount__c, Sales__c, Sales__r.Name, RestAmount__c,
												 Month__c, Id, HighestFinishRate__c, CompletedAmount__c, CompletedRate__c, CommitAmount__c 
												 from SalesTargetCompleteStatus__c
												 where Year__c = :this.reportYear])
		{
			SalesPerformance temp_SPF = new SalesPerformance();
			if(temp_Map.containsKey(stcs.Sales__c)) temp_SPF = temp_Map.get(stcs.Sales__c);
			temp_SPF.addSalesTargetCompleteStatus(stcs, this.reportQuarter, this.reportMonth);
			temp_SPF.SalesName = stcs.Sales__r.Name;
			temp_Map.put(stcs.Sales__c,temp_SPF);
		}
		return temp_Map;
	} 
	
	//计算今年信息
	private void calculateNowYearInfo()
	{
		for(Id salesId : this.map_Sales_Performance_Now.keySet())
		{
			SalesPerformance spf =  this.map_Sales_Performance_Now.get(salesId);
			if(this.map_Sales_Performance_Last.containsKey(salesId))
			{
				LastYearPerformance lyf = this.map_Sales_Performance_Last.get(salesId);
				spf.Quarter.SamePeriodAmount = lyf.QuarterAmount;//季度同期
				spf.yearInfo.samePeriod = lyf.YearAmount;//年同期
			}
			spf.calculateMonth();
			spf.calculateQuarter();
			spf.calculateYear();
		}
	}
	
	//封装到销售(去年销售业绩)
	private Map<Id,LastYearPerformance> distributeLastYearToSales() 
	{
		Map<Id,LastYearPerformance> temp_Map = new Map<Id,LastYearPerformance>();
		for(SalesTargetCompleteStatus__c stcs : [select Year__c,  Quarter__c, Sales__c, Month__c, Id, CompletedAmount__c 
				  								 from SalesTargetCompleteStatus__c 
			  								     where Year__c = :this.reportLastyear])
  		{
			LastYearPerformance temp_LYP = new LastYearPerformance();
			if(temp_Map.containsKey(stcs.Sales__c)) temp_LYP = temp_Map.get(stcs.Sales__c);
			if(stcs.Quarter__c == this.reportQuarter) temp_LYP.QuarterAmount += stcs.CompletedAmount__c;//去年本季度同期完成
			if(Integer.valueOf(stcs.Month__c) <= Integer.valueOf(this.reportMonth)) temp_LYP.YearAmount += stcs.CompletedAmount__c;//去年同期完成
			temp_Map.put(stcs.Sales__c,temp_LYP);  
		}
		return temp_Map;
	}
	
	class LastYearPerformance
	{
		public Decimal QuarterAmount;
		public Decimal YearAmount;
		
		LastYearPerformance()
		{
			this.QuarterAmount = 0;
			this.YearAmount = 0;
		}
	}
	
	//今年销售业绩
	class SalesPerformance
	{
		public QuarterPerformance FirstMonth{get;set;}
		public QuarterPerformance SecondMonth{get;set;}
		public QuarterPerformance ThirdMonth{get;set;}
		public QuarterPerformance Quarter{get;set;}
		public List<QuarterPerformance> OtherMonth;
		public YearPerformance yearInfo{get;set;}
		public String SalesName{get;set;}
		public Integer Index{get;set;}
		
		SalesPerformance()
		{
			this.FirstMonth = new QuarterPerformance();
			this.SecondMonth = new QuarterPerformance();
			this.ThirdMonth = new QuarterPerformance();
			this.Quarter = new QuarterPerformance(); 
			this.otherMonth = new List<QuarterPerformance>();
            this.yearInfo = new YearPerformance();
            this.Index = 0;
		}

		void addSalesTargetCompleteStatus(SalesTargetCompleteStatus__c stcs, integer reportQuarter, String reportMonth)
        {
        	if(stcs.Quarter__c == reportQuarter)
			{//本季度
				integer mod = math.mod(Integer.valueOf(stcs.Month__c), 3);
				if(mod == 0) this.ThirdMonth.addSingleMonth(stcs);
				else if(mod == 1) this.FirstMonth.addSingleMonth(stcs);
				else if(mod == 2) this.SecondMonth.addSingleMonth(stcs);
			}
			if(Integer.valueOf(stcs.Month__c) <= Integer.valueOf(reportMonth))
			{//小于当前月--------------------------------
				QuarterPerformance qf = new QuarterPerformance();
				qf.addSingleMonth(stcs);
				this.otherMonth.add(qf);
			}
        }

        void calculateMonth()
        {
        	this.FirstMonth.calculate();
        	this.SecondMonth.calculate();
        	this.ThirdMonth.calculate();
        }

		void calculateQuarter()
		{
			this.Quarter.Target = this.FirstMonth.Target + this.SecondMonth.Target + this.ThirdMonth.Target - this.FirstMonth.RestAmount - this.SecondMonth.RestAmount;//目标
			this.Quarter.CompletedAmount = this.FirstMonth.CompletedAmount + this.SecondMonth.CompletedAmount + this.ThirdMonth.CompletedAmount;//完成
			this.Quarter.CommitAmount = this.FirstMonth.CommitAmount + this.SecondMonth.CommitAmount + this.ThirdMonth.CommitAmount;//确认
			Quarter.calculate();
		}
		
		void calculateYear()
		{
			Integer i = 1;
			for(QuarterPerformance qp : this.OtherMonth)
			{
				//rolling target
				if(i == this.OtherMonth.size())
				this.yearInfo.rollingTarget += qp.Target;
				else
				this.yearInfo.rollingTarget = this.yearInfo.rollingTarget + qp.Target - qp.RestAmount;
				this.yearInfo.act += qp.CompletedAmount;//act
				i++;
			}
            this.yearInfo.calculate(); 
		}
		
	}

	class QuarterPerformance
    {
        public Decimal Target{get;set;}
		public Decimal CommitAmount{get;set;}
		public Decimal CompletedAmount{get;set;}
        public Decimal CompletedRate{get;set;}
		public Decimal HighestFinishRate{get;set;}
		public Decimal SamePeriodAmount{get;set;}
        public Decimal SamePeriodRate{get;set;}
        public Decimal RestAmount{get;set;}
        
        QuarterPerformance()
        {
			this.Target = 0;
            this.CommitAmount = 0;
            this.CompletedAmount = 0;
            this.CompletedRate = 0;
            this.HighestFinishRate = 0;
            this.SamePeriodAmount = 0;
            this.SamePeriodRate = 0;
            this.RestAmount = 0;
        }

        void addSingleMonth(SalesTargetCompleteStatus__c stcs)
        {
        	if(stcs.Target__c != null)
        	this.Target = stcs.Target__c;
        	if(stcs.CommitAmount__c != null)
        	this.CommitAmount = stcs.CommitAmount__c;
        	if(stcs.CompletedAmount__c != null)
        	this.CompletedAmount = stcs.CompletedAmount__c;
        	if(stcs.SamePeriodAmount__c != null)
        	this.SamePeriodAmount = stcs.SamePeriodAmount__c;
        	if(stcs.RestAmount__c != null)
        	this.RestAmount = stcs.RestAmount__c;
        	if(this.Target != 0)
        	{
        		this.CompletedRate = this.CompletedAmount / this.Target;
            	this.HighestFinishRate =  (this.CompletedAmount + this.CommitAmount) / this.Target;
        	}
        	if(this.SamePeriodAmount != 0)
        	{
        		this.SamePeriodRate = this.CompletedAmount / this.SamePeriodAmount;
        	}

        }

        public void calculate()
        {
            if(this.Target == 0) 
            {
                this.CompletedRate = 0;
                this.HighestFinishRate = 0;
            }
            else
            {
                this.CompletedRate = this.CompletedAmount/this.Target * 100;
                this.HighestFinishRate = (this.CompletedAmount + this.CommitAmount)/this.Target * 100;
            }
			//同比
			if(this.SamePeriodAmount == 0) this.SamePeriodRate = 0;
            else this.SamePeriodRate = this.CompletedAmount/this.SamePeriodAmount * 100;
        }
    }
	//年度销售业绩
	class YearPerformance
	{
		public Decimal rollingTarget{get;set;}
		public Decimal act{get;set;}
		public Decimal attain{get;set;}
		public Decimal samePeriod{get;set;}
		public Decimal yoy{get;set;}
		
		YearPerformance()
		{
			this.rollingTarget = 0;
			this.act = 0;
			this.attain = 0;
			this.samePeriod = 0;
			this.yoy = 0;
		}
		
		public void calculate()
		{//计算yoy
			if(this.samePeriod == 0) this.yoy = 0;
			else this.yoy = (this.act - this.samePeriod)/this.samePeriod;
            //计算Attain
            if(this.rollingTarget == 0) this.attain = 0;
            else this.attain = this.act/this.rollingTarget;
            this.yoy = this.yoy * 100;
            this.attain = this.attain * 100;
		}
	}
    
	private List<SalesPerformance> OrderSalesByRollingTarget(List<SalesPerformance> list_Para)
	{
		//对数据进行排序
		List<SalesPerformance> result = new List<SalesPerformance>();
		for(Integer i = 0; i < list_Para.size(); i++)
		{
			SalesPerformance spi = list_Para[i];
			for(Integer j = i+1; j< list_Para.size(); j++)
			{
				SalesPerformance spj = list_Para[j];
				if(spi.yearInfo.rollingTarget < spj.yearInfo.rollingTarget)
				{
					spi.Index += 1;
				}
				else
				{
					spj.Index += 1;
				}
			}
		}
		while(result.size() != list_Para.size())
		{
			for(SalesPerformance sp : list_Para)
			{
				if(result.size() == sp.Index)
				result.add(sp);
			}
		}
		return result;
	}

    public void formatCurrrency(List<SalesPerformance> list_Para)
    {
    	for(SalesPerformance sp : list_Para)
        {
            sp.FirstMonth.Target /= 10000;
            sp.FirstMonth.CompletedAmount /= 10000;
            sp.FirstMonth.CommitAmount /= 10000;
            sp.FirstMonth.SamePeriodAmount /= 10000;
            sp.SecondMonth.Target /= 10000;
            sp.SecondMonth.CompletedAmount /= 10000;
            sp.SecondMonth.CommitAmount /= 10000;
            sp.SecondMonth.SamePeriodAmount /= 10000;
            sp.ThirdMonth.Target /= 10000;
            sp.ThirdMonth.CompletedAmount /= 10000;
            sp.ThirdMonth.CommitAmount /= 10000;
            sp.ThirdMonth.SamePeriodAmount /= 10000;
            sp.Quarter.Target /= 10000;
            sp.Quarter.CompletedAmount /= 10000;
            sp.Quarter.CommitAmount /= 10000;
            sp.Quarter.SamePeriodAmount /= 10000;
            sp.yearInfo.rollingTarget /= 10000;
            sp.yearInfo.act /= 10000;
            sp.yearInfo.samePeriod /= 10000;
            Integer index = sp.SalesName.indexOf(' ');//截取销售的名字
            if(index > -1)
            sp.SalesName = sp.SalesName.subString(0, index);
        }
    }
}