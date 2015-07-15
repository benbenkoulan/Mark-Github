public class SumCollectionByDateController 
{
	public class Collection
	{
		public Collection__c Coll{get;set;}//收款、金额
		public string Expectedcollectiondate{get;set;}//预计收款时间
		public Integer year{get;set;}
		public Integer month{get;set;}
	}
	public class CollectionsByMonth
	{
		public list<Collection> list_Collection{get;set;}
		public Integer year{get;set;}
		public Integer month{get;set;}
		public Integer getRowspan()
		{
			if(list_Collection == null || list_Collection.size() == 0)
			{
				return 1;
			}
			else
			{
				return list_Collection.size();
			}
		}
	}
	public SumCollectionByDateController(ApexPages.Standardcontroller controller)
	{
		
	}
}