public  class Collection_PaymentDetails_Report 
{
	
	class Collection_PaymentDetails
	{
		public string WeekName{get;set;}
		public Integer Colspan_Col{get{ if(Collections.size()==0) return 1;else return Collections.size();}}
		public Integer ColsPan_Pay{get{ if(PayDetails.size()==0) return 1;else return PayDetails.size();}}
		public Integer ColsPanWeek{get{ return Colspan_Col+ColsPan_Pay+3;}}
		public list<Collection__c> Collections{get;set;}//收款
		public list<PaymentDetails__c> PayDetails{get;set;}//付款
		public Decimal CollSumAmount{get;set;}//收款汇总
		public Decimal PaySumAmount{get;set;}//付款汇总
		public Decimal Remain{get;set;}//上周余额
		public Decimal Rema
		{
			get
			{ 
				Decimal amount=0;
				if(Remain!=null)
				{
					amount+=Remain;
			    }
			    if(CollSumAmount!=null)
			    {
			    	amount+=CollSumAmount;
			    }
			    if(PaySumAmount!=null)
			    {
			    	amount-=PaySumAmount;
			    }
			    return amount;
			}
		}
		public Collection_PaymentDetails()
		{
			Collections=new list<Collection__c>();
			PayDetails=new list<PaymentDetails__c>();
		}
	}
	public string StartWeek{get;set;}
	public string EndWeek{get;set;}
	public Date StartDate{get;set;}//起始时间   StartDate
	public Date EndDate{get;set;}//结束时间  EndDate
	public string Invoicestatus{get;set;}//发票状态
	public Decimal StartRemain{get;set;}//起始余额
	public string status{get;set;}
	public list<Collection_PaymentDetails> list_Collection_PaymentDetails{get;set;}
	
	public Collection_PaymentDetails_Report(ApexPages.StandardController controller)
	{
		list_Collection_PaymentDetails=new list<Collection_PaymentDetails>();
	}
	public PageReference returnHome()
    {
    	PageReference pageRef=new PageReference('https://'+ApexPages.currentPage().getHeaders().get('Host')+'/home/home.jsp');
    	return pageRef;  	
    }
	public void query()
	{
		status = null;
		list_Collection_PaymentDetails=new list<Collection_PaymentDetails>();
		list<Collection__c> list_Colls;
		list<PaymentDetails__c> list_PayDetail;
		//起始时间   StartDate
	//结束时间  EndDate
	    try
	    {
	    	if(StartWeek != null && StartWeek != '')
	    	{
				StartDate = Date.valueOf(StartWeek);
	    	}
	    	if(EndWeek != null && EndWeek != '')
	    	{
				EndDate = Date.valueOf(EndWeek);
	    	}
	    }
	    catch(Exception exc)
	    {
	    	status = '请输入正确的日期格式。';
	    }
		if( StartDate==null)
		{
			 StartDate=Date.today();
		}
		if(EndDate==null)
		{
			list_PayDetail=[select id,Name,	Invoice__c,	PaymentType__c,PaymentAmount__c,Week__c,YearWeek__c from PaymentDetails__c where ContractPayDate__c>=:StartDate and PayStatus__c!='已付' order by YearWeek__c Asc];
			if(Invoicestatus=='已开')
			{
				list_Colls=[select Expectedcollectiondate__c,Expectedinvoicedate__c,id,Name,Collectiondate__c,invoicestatus__c,projectrelated__c,collectionstatus__c,Invoicedate__c,Amount__c,Week__c,YearWeek__c from Collection__c where Expectedcollectiondate__c>=:StartDate and invoicestatus__c=:Invoicestatus and collectionstatus__c != '已收' order by YearWeek__c Asc];
			}
			else
			{
				list_Colls=[select Expectedcollectiondate__c,Expectedinvoicedate__c,id,Name,Collectiondate__c,collectionstatus__c,invoicestatus__c,projectrelated__c,Invoicedate__c,Amount__c,Week__c,YearWeek__c from Collection__c where Expectedcollectiondate__c>=:StartDate and collectionstatus__c != '已收' order by YearWeek__c Asc];
			}
		}
		else
		{
			list_PayDetail=[select id,Name,	Invoice__c,	PaymentType__c,PaymentAmount__c,Week__c,YearWeek__c from PaymentDetails__c where ContractPayDate__c>=:StartDate and ContractPayDate__c<=:EndDate and PayStatus__c!='已付'];
			if(Invoicestatus=='已开')
			{
				list_Colls=[select Expectedcollectiondate__c,Expectedinvoicedate__c,id,Name,Collectiondate__c,invoicestatus__c,projectrelated__c,collectionstatus__c,Invoicedate__c,Amount__c,Week__c,YearWeek__c from Collection__c where Expectedcollectiondate__c>=:StartDate and Expectedcollectiondate__c<=:EndDate and invoicestatus__c=:Invoicestatus and collectionstatus__c != '已收' order by YearWeek__c Asc];
			}
			else
			{
				list_Colls=[select Expectedcollectiondate__c,Expectedinvoicedate__c,id,Name,Collectiondate__c,invoicestatus__c,projectrelated__c,collectionstatus__c,Invoicedate__c,Amount__c,Week__c,YearWeek__c from Collection__c where Expectedcollectiondate__c>=:StartDate and Expectedcollectiondate__c<=:EndDate and collectionstatus__c != '已收' order by YearWeek__c Asc];
			}
		}
		//周：收款支出集合
		map<string,Collection_PaymentDetails> map_Collection_PaymentDetails=new map<string,Collection_PaymentDetails>();
		if(list_Colls!=null&&list_Colls.size()>0)
		{
			for(Collection__c col:list_Colls)
			{
				if(map_Collection_PaymentDetails.containsKey(col.YearWeek__c))
				{
					Collection_PaymentDetails cp=map_Collection_PaymentDetails.get(col.YearWeek__c);
					if(cp.Collections==null)
					{
						cp.Collections=new list<Collection__c>();
						cp.Collections.add(col);
						cp.CollSumAmount=col.Amount__c;
					}
					else
					{
						cp.Collections.add(col);
						if(col.Amount__c!=null)
						{
							if(cp.CollSumAmount==null)
							{
								cp.CollSumAmount=col.Amount__c;
							}
							else
							{
								cp.CollSumAmount+=col.Amount__c;
							}
						}
					}
					
				}
				else
				{
					Collection_PaymentDetails cp=new Collection_PaymentDetails();
					cp.WeekName=col.YearWeek__c;
					cp.Collections=new list<Collection__c>();
					cp.Collections.add(col);
					cp.CollSumAmount=col.Amount__c;
					map_Collection_PaymentDetails.put(col.YearWeek__c,cp);
				}
			}
		}
		if(list_PayDetail!=null&&list_PayDetail.size()>0)
		{
			for(PaymentDetails__c col:list_PayDetail)
			{
				if(map_Collection_PaymentDetails.containsKey(col.YearWeek__c))
				{
					Collection_PaymentDetails cp=map_Collection_PaymentDetails.get(col.YearWeek__c);
					if(cp.PayDetails==null)
					{
						cp.PayDetails=new list<PaymentDetails__c>();
						cp.PayDetails.add(col);
						cp.PaySumAmount=col.PaymentAmount__c;
					}
					else
					{
						cp.PayDetails.add(col);
						if(col.PaymentAmount__c!=null)
						{
							if(cp.PaySumAmount==null)
							{
								cp.PaySumAmount=col.PaymentAmount__c;
							}
							else
							{
								cp.PaySumAmount+=col.PaymentAmount__c;
							}
						}
					}
					
				}
				else
				{
					Collection_PaymentDetails cp=new Collection_PaymentDetails();
					cp.WeekName=col.YearWeek__c;
					cp.PayDetails=new list<PaymentDetails__c>();
					cp.PayDetails.add(col);
					cp.PaySumAmount=col.PaymentAmount__c;
					map_Collection_PaymentDetails.put(col.YearWeek__c,cp);
				}
			}
		}
		//map<Decimal,Collection_PaymentDetails> map_Collection_PaymentDetails
		if(map_Collection_PaymentDetails!=null&&map_Collection_PaymentDetails.size()>0)
		{
			list<string> Keys=new list<string>();
			Keys.addAll(map_Collection_PaymentDetails.keySet());
			Keys.sort();
			Decimal StartAmount=StartRemain;
			for(string key:Keys)
			{
				Collection_PaymentDetails cp=map_Collection_PaymentDetails.get(key);
				cp.Remain=StartAmount;
				StartAmount=0;
				if(cp.Remain!=null)
				{
					StartAmount+=cp.Remain;
				}
				if(cp.CollSumAmount!=null)
				{
					StartAmount+=cp.CollSumAmount;
				}
				if(cp.PaySumAmount!=null)
				{
					StartAmount-=cp.PaySumAmount;
				}
				list_Collection_PaymentDetails.add(cp);
			}
		}
	}
}