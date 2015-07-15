/**
 * 开发人：Sunny
 * 时间：2012-3-13
 * 功能：按钮页面
 * 隐患：使用中文选项列表的值，可能存在翻译隐患
**/
public class ForecastCollection_Con 
{
    private date CurrentStartDate ;
    private date NextDate ;
    private date ThirdDate ;
    private date EndDate ;
    private CollectionForecastHis__c FirstCFH{get;set;}
    private CollectionForecastHis__c SecondCFH{get;set;}
    private CollectionForecastHis__c ThirdCFH{get;set;}
    public List<CollectionForecastHis__c> list_CFH{get;set;}
    public ForecastCollection_Con(ApexPages.StandardController controller)
    {
        list_CFH = new List<CollectionForecastHis__c>() ;
        this.initDate() ;
        this.initCollectionForecastHis() ;
        this.SelectCollectionData() ;
    }
    public ForecastCollection_Con(ApexPages.StandardSetController controller)
    {
        list_CFH = new List<CollectionForecastHis__c>() ;
        this.initDate() ;
        this.initCollectionForecastHis() ;
        this.SelectCollectionData() ;
    }
    //初始化所需日期参数
    private void initDate()
    {
        Date dateNow = date.today() ;
        CurrentStartDate = date.valueOf(dateNow.year()+'-'+dateNow.month()+'-1') ;
        NextDate = CurrentStartDate.addMonths(1) ;
        ThirdDate = NextDate.addMonths(1) ;
        EndDate = ThirdDate.addMonths(1) ; 
        system.debug('FIRST DATE '+CurrentStartDate+'=='+NextDate+'=='+ThirdDate+'=='+EndDate) ;
    }
    //初始化收款预测历史,三条记录(当前月、下一月、下下月)
    private void initCollectionForecastHis()
    {
        FirstCFH = new CollectionForecastHis__c() ;
        FirstCFH.CollectionYear__c = String.valueOf(CurrentStartDate.year()) ;
        FirstCFH.CollectionMonth__c = String.valueOf(CurrentStartDate.month()) ;
        FirstCFH.PredictionUser__c = UserInfo.getUserId() ;
        SecondCFH = new CollectionForecastHis__c() ;
        SecondCFH.CollectionYear__c = String.valueOf(NextDate.year()) ;
        SecondCFH.CollectionMonth__c = String.valueOf(NextDate.month()) ;
        SecondCFH.PredictionUser__c = UserInfo.getUserId() ;
        ThirdCFH = new CollectionForecastHis__c() ;
        ThirdCFH.CollectionYear__c = String.valueOf(ThirdDate.year()) ;
        ThirdCFH.CollectionMonth__c = String.valueOf(ThirdDate.month()) ;
        ThirdCFH.PredictionUser__c = UserInfo.getUserId() ;
    }
    //查询收款数据并计算
    private void SelectCollectionData()
    {
        if(CurrentStartDate == null)return ;
        for(Collection__c objColl : [Select c.invoicestatus__c, c.Expectedcollectiondate__c, Collectiondate__c, c.collectionstatus__c, c.Amount__c From Collection__c c Where Expectedcollectiondate__c >=: CurrentStartDate And Expectedcollectiondate__c <: EndDate])
        {
            if(objColl.Expectedcollectiondate__c == null) continue ;
            if(objColl.Expectedcollectiondate__c < NextDate && objColl.Expectedcollectiondate__c >= CurrentStartDate)
            {//当前月
                this.SumData(FirstCFH, objColl) ;
            }else if(objColl.Expectedcollectiondate__c < ThirdDate && objColl.Expectedcollectiondate__c >= NextDate)
            {//下一月
                this.SumData(SecondCFH, objColl) ;
            }else if(objColl.Expectedcollectiondate__c < EndDate && objColl.Expectedcollectiondate__c >= ThirdDate)
            {//下下月
                this.SumData(ThirdCFH, objColl) ;
            }
        }
        if(FirstCFH.Amount__c != null)list_CFH.add(FirstCFH) ;
        if(SecondCFH.Amount__c != null)list_CFH.add(SecondCFH) ;
        if(ThirdCFH.Amount__c != null)list_CFH.add(ThirdCFH) ;
    }
    private void SumData(CollectionForecastHis__c objCFH , Collection__c objColl)
    {
        system.debug('####');
        system.debug(objCFH);
         system.debug('####2');
        system.debug(objColl);
        if(objColl.Amount__c == null)
        {
            objColl.Amount__c = 0;
        }
        if(objCFH.Amount__c == null){objCFH.Amount__c = objColl.Amount__c;}else{objCFH.Amount__c += objColl.Amount__c;}
        if(objColl.collectionstatus__c == '已收')
        {
            if(objCFH.Collected__c == null){objCFH.Collected__c = objColl.Amount__c;}else{objCFH.Collected__c += objColl.Amount__c;}
        }else if(objColl.collectionstatus__c == '未收')
        {
            if(objCFH.unCollected__c == null){objCFH.unCollected__c = objColl.Amount__c;}else{objCFH.unCollected__c += objColl.Amount__c;}
            if(objColl.invoicestatus__c == '未开')
            {
                if(objCFH.NoInvoice__c == null){objCFH.NoInvoice__c = objColl.Amount__c;}else{objCFH.NoInvoice__c += objColl.Amount__c;}
            }
        }
    }
    public PageReference SaveDate()
    {
        /*
        List<CollectionForecastHis__c> list_CFHSave = new List<CollectionForecastHis__c>() ;
        if(FirstCFH.Amount__c != null)list_CFHSave.add(FirstCFH) ;
        if(SecondCFH.Amount__c != null)list_CFHSave.add(SecondCFH) ;
        if(ThirdCFH.Amount__c != null)list_CFHSave.add(ThirdCFH) ;
        */
        if(list_CFH.size() != 0) insert list_CFH ;
        return new PageReference('/a0K/o') ;
    }
    public PageReference doCancel()
    {
        return new PageReference('/a0K/o') ;
    }
    
    static testMethod void TestPage() {
        //--------------------------New Collection------------------------------
        List<Collection__c> list_Coll = new List<Collection__c>() ;
        Collection__c objColl1 = new Collection__c() ;
        objColl1.Amount__c = 100 ;
        objColl1.Name = 'wef' ;
        objColl1.Collectiondate__c = date.today() ;
        objColl1.collectionstatus__c = '已收' ;
        objColl1.invoicestatus__c = '已开' ;
        objColl1.changdescription__c = 'wer' ;
        objColl1.changreason__c = '开发实施' ;
        objColl1.Invoicedate__c = date.today() ;
        objColl1.Expectedcollectiondate__c = date.today() ;
        objColl1.Expectedinvoicedate__c = date.today() ;
        list_Coll.add(objColl1) ;
        Collection__c objColl2 = new Collection__c() ;
        objColl2.Amount__c = 100 ;
        objColl2.Name = 'wef' ;
        objColl2.Collectiondate__c = date.today() ;
        objColl2.collectionstatus__c = '未收' ;
        objColl2.invoicestatus__c = '已开' ;
        objColl2.changdescription__c = 'wer' ;
        objColl2.changreason__c = '开发实施' ;
        objColl2.Invoicedate__c = date.today() ;
        objColl2.Expectedcollectiondate__c = date.today() ;
        objColl2.Expectedinvoicedate__c = date.today() ;
        list_Coll.add(objColl2) ;
        Collection__c objColl3 = new Collection__c() ;
        objColl3.Amount__c = 100 ;
        objColl3.Name = 'wef' ;
        objColl3.Collectiondate__c = date.today().addMonths(1) ;
        objColl3.collectionstatus__c = '已收' ;
        objColl3.invoicestatus__c = '已开' ;
        objColl3.changdescription__c = 'wer' ;
        objColl3.changreason__c = '开发实施' ;
        objColl3.Invoicedate__c = date.today().addMonths(1) ;
        objColl3.Expectedcollectiondate__c = date.today().addMonths(1) ;
        objColl3.Expectedinvoicedate__c = date.today().addMonths(1) ;
        list_Coll.add(objColl3) ;
        Collection__c objColl4 = new Collection__c() ;
        objColl4.Amount__c = 100 ;
        objColl4.Name = 'wef' ;
        objColl4.Collectiondate__c = date.today().addMonths(1) ;
        objColl4.collectionstatus__c = '未收' ;
        objColl4.invoicestatus__c = '未开' ;
        objColl4.changdescription__c = 'wer' ;
        objColl4.changreason__c = '开发实施' ;
        objColl4.Invoicedate__c = date.today().addMonths(1) ;
        objColl4.Expectedcollectiondate__c = date.today().addMonths(1) ;
        objColl4.Expectedinvoicedate__c = date.today().addMonths(1) ;
        list_Coll.add(objColl4) ;
        Collection__c objColl5 = new Collection__c() ;
        objColl5.Amount__c = 100 ;
        objColl5.Name = 'wef' ;
        objColl5.Collectiondate__c = date.today().addMonths(2) ;
        objColl5.collectionstatus__c = '未收' ;
        objColl5.invoicestatus__c = '未开' ;
        objColl5.changdescription__c = 'wer' ;
        objColl5.changreason__c = '开发实施' ;
        objColl5.Invoicedate__c = date.today().addMonths(2) ;
        objColl5.Expectedcollectiondate__c = date.today().addMonths(2) ;
        objColl5.Expectedinvoicedate__c = date.today().addMonths(2) ;
        list_Coll.add(objColl5) ;
        Collection__c objColl6 = new Collection__c() ;
        objColl6.Amount__c = 100 ;
        objColl6.Name = 'wef' ;
        objColl6.Collectiondate__c = date.today().addMonths(2) ;
        objColl6.collectionstatus__c = '已收' ;
        objColl6.invoicestatus__c = '已开' ;
        objColl6.changdescription__c = 'wer' ;
        objColl6.changreason__c = '开发实施' ;
        objColl6.Invoicedate__c = date.today().addMonths(2) ;
        objColl6.Expectedcollectiondate__c = date.today().addMonths(2) ;
        objColl6.Expectedinvoicedate__c = date.today().addMonths(2) ;
        list_Coll.add(objColl6) ;
        insert list_Coll ;
        
        system.test.startTest() ;
        ApexPages.StandardSetController STController = new ApexPages.StandardSetController(New List<Collection__c>());
        ApexPages.StandardController STController2 = new ApexPages.StandardController(New Collection__c());
        ForecastCollection_Con FC = new ForecastCollection_Con(STController) ;
        ForecastCollection_Con FC2 = new ForecastCollection_Con(STController2) ;
        FC.SaveDate() ;
        FC.doCancel() ;
        system.test.stopTest() ;
        
    }
}