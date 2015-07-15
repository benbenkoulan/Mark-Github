/*
*功能:批量添加项目人天
*作者:Hank
*日期:2014-01-24
*/
public with sharing class BatchAddMandayanalysisController 
{
    public mandayanalysis__c mansis{get;set;}
    public string mansisId{get;set;}
    public list<SelectOption> OptionList{get;set;}
    public string selectListValue{get;set;}
    public Date weekStart
    {
        get
        {
            if(selectListValue != null)
            {
                DateHelper.Week selWeek = this.weekMap.get(selectListValue);
                if(selWeek != null)
                {
                    return selWeek.WeekStartDate;
                }else{
                    return selectDate.toStartOfWeek();
                }
            }
            return null;
        }
    }
    public Date weekEnd
    {
        get
        {
            if(selectListValue != null)
            {
                DateHelper.Week selWeek = this.weekMap.get(selectListValue);
                if(selWeek != null)
                {
                    return selWeek.WeekEndDate;
                }else{
                    return selectDate.addDays(7).toStartOfWeek().addDays(-1);
                }
            }
            return null;
        }
    }
    public list<mandayanalysis> mansisList{get;set;}
    public Boolean isupdate;//判断是新建还是编辑保存完毕后页面返回到哪里
    public String URL;
    public String userId;//用来存储工作者的ID
    private map<String, DateHelper.Week> weekMap = new map<String, DateHelper.Week>();
    public BatchAddMandayanalysisController(ApexPages.StandardController controller)
    {
        selectDate = Date.today();
        DateHelper.Week thisWeek = DateHelper.GetFYWeekByDate(selectDate);
        //system.debug(thisWeek+'thisWeek');
        this.weekMap.put(thisWeek.No, thisWeek);
        this.weekMap.put(thisWeek.LastWeek.No, thisWeek.LastWeek);
        this.weekMap.put(thisWeek.LastWeek.LastWeek.No, thisWeek.LastWeek.LastWeek);
        init();
    }
    
    public Date selectDate{get;set;}
    public Date selectedDate{get;set;}    
    //可以多选几周
    public void SelectDateMethod()
    {
        if(selectedDate==null)selectedDate=system.today();
        selectDate = selectedDate;
        system.debug(selectDate+'xuanzheriqi');
        string weekNo = DateHelper.GetFYWeekByDate(selectDate).No;
        string lastweekNo = DateHelper.GetFYWeekByDate(selectDate).LastWeek.No;
        string lastweekNos = DateHelper.GetFYWeekByDate(selectDate).LastWeek.LastWeek.No;       
        OptionList = new List<SelectOption>();
        OptionList.add(new SelectOption(lastweekNos,lastweekNos));
        OptionList.add(new SelectOption(lastweekNo,lastweekNo));
        OptionList.add(new SelectOption(weekNo,weekNo));
    }
    
    //初始状态
    public void init()
    {
         this.mansisId = ApexPages.currentPage().getParameters().get('Id');
         this.mansis = new mandayanalysis__c();
         if(mansisId!=null && mansisId!='')
         {
            //编辑
            list<mandayanalysis__c> mansislists = [SELECT description__c,Project_assisted__c,projectstandardmandy__c,relateuser__c,Collectiontype__c,manday__c,relatedproject__c,NProjectStage__c,NProjectType__c,HolidayStyle__c,Week_No__c FROM mandayanalysis__c where Id=:mansisId];
            if(mansislists.size()!=null && mansislists.size() > 0)
            {
                mandayanalysis mans = new mandayanalysis();
                mans.mansiss = mansislists[0];
                mansis.relateuser__c = mansislists[0].relateuser__c;
                mans.mansiss.Project_assisted__c = mansislists[0].relatedproject__c;
                mans.updateIsTrue = false;
                mans.updateIsFalse = true;
                mansisList = new list<mandayanalysis>();
                mansisList.add(mans);
                selectListValue = mansislists[0].Week_No__c;
                OptionList = new List<SelectOption>();
                OptionList.add(new SelectOption(mansislists[0].Week_No__c,mansislists[0].Week_No__c));
                isupdate = true;
                
            }
            else
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR , '没有该记录的信息') ;
                ApexPages.addMessage(msg);
                return;
            }
         }
         else
         {
            //新建
            string weekNo = DateHelper.GetFYWeekByDate(selectDate).No;
            string lastweekNo = DateHelper.GetFYWeekByDate(selectDate).LastWeek.No;
            string lastweekNos = DateHelper.GetFYWeekByDate(selectDate).LastWeek.LastWeek.No;
            if(selectListValue == null)
            {
                selectListValue = weekNo;
            }
            else
            {
                selectListValue = selectListValue;
            }
            if(userId == null)
            {
                mansis.relateuser__c = userinfo.getUserId();
            }
            else
            {
                mansis.relateuser__c = userId;
            }
            OptionList = new List<SelectOption>();
            OptionList.add(new SelectOption(lastweekNos,lastweekNos));
            OptionList.add(new SelectOption(lastweekNo,lastweekNo));
            OptionList.add(new SelectOption(weekNo,weekNo+(selectDate==Date.today()?'(本周)':'')));
            list<mandayanalysis__c> mansislists = [SELECT description__c,projectstandardmandy__c,relateuser__c,Collectiontype__c,manday__c,relatedproject__c,NProjectStage__c,NProjectType__c,HolidayStyle__c,Week_No__c,Project_assisted__c FROM mandayanalysis__c where relateuser__c=:mansis.relateuser__c and Week_No__c=:selectListValue];
            if(mansislists.size()!=null && mansislists.size() > 0)
            {
                mansisList = new list<mandayanalysis>();
                for(mandayanalysis__c mann:mansislists)
                {
                    mandayanalysis mans = new mandayanalysis();
                    mans.mansiss = mann;
                    mans.mansiss.Project_assisted__c = mann.relatedproject__c;
                    mans.updateIsTrue = false;
                    mans.updateIsFalse = true;
                    mansisList.add(mans);
                }
                
            }
            else
            {
                mansisList = new list<mandayanalysis>();
                Addmandayanalysis();
                Addmandayanalysis();
                Addmandayanalysis();
                Addmandayanalysis();
                Addmandayanalysis();
            }
            isupdate = false;
            
         }
    }
    public class mandayanalysis
    {
        public boolean IsDelete{get;set;}
        public mandayanalysis__c mansiss{get;set;}
        //因为项目人天上面的项目为主详关系的字段，不能进行修改，加上2个字段是新建的时候可以进行赋值，修改的时候不能进行修改
        public Boolean updateIsTrue{get;set;}//新建的时候等于true修改的时候false
        public Boolean updateIsFalse{get;set;}//修改的时候等于true新建的时候false
    }
    //添加行
    public void Addmandayanalysis()
    {
        mandayanalysis__c mansis = new mandayanalysis__c();
        mansis.relateuser__c = UserInfo.getUserId();
        mandayanalysis mans = new mandayanalysis();
        mans.updateIsFalse = false;
        mans.updateIsTrue = true;
        mans.mansiss = mansis;
        mansisList.add(mans);
    }
    //删除行
    public void Deletemandayanalysis()
    {
        list<mandayanalysis__c> listDeletemandayanalysis = new list<mandayanalysis__c>();
        for(Integer i = mansisList.size()-1;i>=0;i--)
        {
            if(mansisList[i].IsDelete)
            {
                if(mansisList[i].mansiss.id!=null)
                {
                    listDeletemandayanalysis.add(mansisList[i].mansiss);
                }
                mansisList.remove(i);
            }
        }
        delete listDeletemandayanalysis;
    }
    //保存
    public Pagereference Save()
    {
        try
        {
            //mandayanalysis__c mansis = new mandayanalysis__c();
            List<mandayanalysis__c> listSavemandayanalysis = new List<mandayanalysis__c>();
            system.debug('&&&&&&&&&&&&&&&&'+mansisList);
            for(Integer i = 0;i<mansisList.size();i++)
            {
                mandayanalysis__c man = mansisList[i].mansiss;
                if(man.Project_assisted__c!=null||man.NProjectType__c!=null||man.NProjectStage__c!=null
                ||man.HolidayStyle__c!=null||man.manday__c!=null||man.description__c!=null)
                {
                    //wtc.Weeklyname__c = wrfw.Id;
                    if(mansisList[i].updateIsFalse==false && mansisList[i].updateIsTrue==true)
                    {
                        man.relatedproject__c = man.Project_assisted__c;
                    }
                    //mansiss.Project_assisted__c = null;
                    man.relateuser__c = mansis.relateuser__c;
                    man.Week_No__c = selectListValue;
                    listSavemandayanalysis.add(man);
                }
            }
            for(Integer i = 0;i<listSavemandayanalysis.size();i++)
            {
                mandayanalysis__c man = listSavemandayanalysis[i];
                if(evaluateCountDays()){
                    return null;
                }
                if(man.relatedproject__c==null)
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '第'+(i+1)+'行项目不能为空');         
                    ApexPages.addMessage(msg);
                    return null;
                }
                if(man.manday__c==null)
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '第'+(i+1)+'行人天不能为空');         
                    ApexPages.addMessage(msg);
                    return null;
                }
                if(man.NProjectType__c=='销售' && man.NProjectStage__c!=null)
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '第'+(i+1)+'行类型为销售时，阶段必须为无');         
                    ApexPages.addMessage(msg);
                    return null;
                }
                if((man.NProjectType__c=='实施' || man.NProjectType__c=='维护')&& man.NProjectStage__c==null)
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '第'+(i+1)+'行类型为实施或维护时，阶段必填');         
                    ApexPages.addMessage(msg);
                    return null;
                }
                if(man.manday__c>5)
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '第'+(i+1)+'行项目人天超过5天');         
                    ApexPages.addMessage(msg);
                    return null;
                }
                //if(man.relatedproject__c=='a0G90000007XQRb' && man.NProjectStage__c!=null && man.NProjectType__c!=null && man.HolidayStyle__c==null)
                //{
                    //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '第'+(i+1)+'行项目为内部管理时，类型和阶段不能填写');         
                    //ApexPages.addMessage(msg);
                    //return null;
                //}
            }
            if(listSavemandayanalysis.size()>0)
            {
                upsert listSavemandayanalysis;
            }
        }
        catch(system.Dmlexception e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR , '错误提示：'+e) ;
            ApexPages.addMessage(msg);
            return null;
        }
        if(isupdate)
        {
            URL= '/' + mansisId;
        }
        else
        {
            URL= '/a0d/o';
        }
        return new Pagereference(URL);
        
    }
    //切换工作者
    public void ChangeUser()
    {
        userId = mansis.relateuser__c;
        init();
    }
    
    public Decimal countDays{get;set;}
    public void miniUpdate(){
        Integer i=0;
        countDays=0;
        for(mandayanalysis man:mansisList){
            if(man.mansiss.Project_assisted__c!=null ||man.mansiss.Project_assisted__c!=''){
                list<SFDC_Projects__c> list_sp=[select id,Project_Imp_Stage__c,Project_Type__c from SFDC_Projects__c where id=:man.mansiss.Project_assisted__c];
                if(list_sp.size()==1){
                    man.mansiss.NProjectType__c=list_sp[0].Project_Type__c;
                    man.mansiss.NProjectStage__c=list_sp[0].Project_Imp_Stage__c;
                    mansisList[i]=man;                                              
                }                           
            }
            i++;  
        }
        evaluateCountDays();
    }
    public Boolean evaluateCountDays(){
        countDays=0;
        for(mandayanalysis man:mansisList){
            if(man.mansiss.manday__c!=null){
                countDays+=man.mansiss.manday__c;
            }
        }
        if(countDays>7){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'总人天不能大于5');
            ApexPages.addMessage(msg);
            return true;
        }else{
            return false;
        }
    }
}