/*
*功能:创建周计划批，修改周计划，批量创建工作目标
*作者:Hank
*日期:2014-01-20 
*/
public with sharing class BatchAddWeekPlanController 
{
    public string wrfwId{get;set;}
    public weekly_report_for_work__c wrfw{get;set;}
    public list<weekly_report_for_work__c> queryResult{get;set;}//Tommy:此页面不需要处理多个weekly_report_for_work__c，没有必要定义列表
    public string strname{get;set;}//Tommy:此成员的命名不规范，没有实际意义，通过名称无法知道是干什么用的， 除非你有注释
    private map<String, DateHelper.Week> weekMap = new map<String, DateHelper.Week>();
    public Date weekStart
    {
        get
        {
            if(strname != null)
            {
                DateHelper.Week selWeek = this.weekMap.get(strname);
                if(selWeek != null)
                {
                    return selWeek.WeekStartDate;
                }
            }
            return null;
        }
    }
    public Date weekEnd
    {
        get
        {
            if(strname!= null)
            {
                DateHelper.Week selWeek = this.weekMap.get(strname);
                if(selWeek != null)
                {
                    return selWeek.WeekEndDate;
                }
            }
            return null;
        }
    }
    public Boolean isupdate{get;set;}
    public List<SelectOption> weekstr{get;set;}//Tommy: 此命名不规范可以叫做weekOptionList,weekOptions,或list_weekOption
    public string proId;
    public ID WeeklyTargetId {get;set;}
    public list<WeeklyTarget> listWeeklyTarget {get;set;}
    public BatchAddWeekPlanController(ApexPages.StandardController controller)
    {
        try
        {
        DateHelper.Week thisWeek = DateHelper.GetFYWeekByDate(Date.today());
        this.weekMap.put(thisWeek.NextWeek.No, thisWeek.NextWeek);
        System.debug(thisWeek.NextWeek.NextWeek+'thisWeek.NextWeek.NextWeek************');
        this.weekMap.put(thisWeek.NextWeek.NextWeek.No, thisWeek.NextWeek.NextWeek);
        this.weekMap.put(thisWeek.No, thisWeek);
        this.weekMap.put(thisWeek.LastWeek.No, thisWeek.LastWeek);
        this.weekMap.put(thisWeek.LastWeek.LastWeek.No, thisWeek.LastWeek.LastWeek);
        init();
        }catch(exception e)
        {
            System.debug(e.getmessage()+'************'+e.getLineNumber());
        }
    }
    //初始状态
    public void init()
    {
        wrfwId=ApexPages.currentPage().getParameters().get('id');//Tommy:如果引用成员需要明显加this.关键字：this.wrfwId
        wrfw  = new weekly_report_for_work__c();//
        if(wrfwId!=null && wrfwId!='')
        {
            queryResult = [SELECT Id,Name,OwnerId,plan_do_standards__c,issues__c,startdate__c,Belongs_Week__c FROM weekly_report_for_work__c where id=:wrfwId];
            if(queryResult.size()!=null && queryResult.size() > 0)//Tommy:如果指定ID的weekly_report_for_work__c找不到，需要向用户报出错误信息
            {
                for(weekly_report_for_work__c w:queryResult)//Tommy:以下为累赘代码，应该将下标为0的元素的引用直接付给成员wrfw，不需要为每个属性复制
                {
                    wrfw.Id = w.Id;
                    wrfw.Name = w.Name;
                    wrfw.OwnerId = w.OwnerId;
                    wrfw.plan_do_standards__c = w.plan_do_standards__c;
                    wrfw.issues__c = w.issues__c;
                    //wrfw.startdate__c = w.startdate__c;
                    wrfw.startdate__c = weekStart;
                    wrfw.Belongs_Week__c = w.Belongs_Week__c;
                }
                weekstr = new List<SelectOption>();
                weekstr.add(new SelectOption(wrfw.Belongs_Week__c,wrfw.Belongs_Week__c));
                isupdate = true;
                strname = wrfw.Belongs_Week__c;
                //Tommy: 以下代码：WeeklyTarget__c与其父weekly_report_for_work__c是否可以用关联一次查询出来的。
                list<WeeklyTarget__c> listWeekly = new list<WeeklyTarget__c>([Select Id,Status__c, Name,Goalachievement__c, Enddate__c, Description__c,Weeklyname__c From WeeklyTarget__c where Weeklyname__c =: wrfwId]);
                listWeeklyTarget = new list<WeeklyTarget>();
                for(WeeklyTarget__c wt : listWeekly)
                {
                    WeeklyTarget wts = new WeeklyTarget();
                    wts.wtt = wt;
                    listWeeklyTarget.add(wts);
                }
            }
        }
        else//Tommy：此处应该加注释：如果没有在地址参数中指定‘id’及其值则系统任务用户将要新建记录,其实还用另外一个因素决定是否为更新，考虑这样的情况：地址上id没有被指定，但是用户切换到已经填写过的周，结果是更新
        {
            weekstr = new List<SelectOption>();
            //Tommy: *****非常严重地耗费了系统性能，调用了10次，其实此处只需要需要调用一次DateHelper.GetFYWeekByDate(Date.today()方法即可
            weekstr.add(new SelectOption(DateHelper.GetFYWeekByDate(Date.today()).LastWeek.LastWeek.No,DateHelper.GetFYWeekByDate(Date.today()).LastWeek.LastWeek.No));
            weekstr.add(new SelectOption(DateHelper.GetFYWeekByDate(Date.today()).LastWeek.No,DateHelper.GetFYWeekByDate(Date.today()).LastWeek.No+'(上周)'));
            weekstr.add(new SelectOption(DateHelper.GetFYWeekByDate(Date.today()).No,DateHelper.GetFYWeekByDate(Date.today()).No+'(本周)'));
            weekstr.add(new SelectOption(DateHelper.GetFYWeekByDate(Date.today()).NextWeek.No,DateHelper.GetFYWeekByDate(Date.today()).NextWeek.No+'(下周)'));
            weekstr.add(new SelectOption(DateHelper.GetFYWeekByDate(Date.today()).NextWeek.NextWeek.No,DateHelper.GetFYWeekByDate(Date.today()).NextWeek.NextWeek.No));
            
            isupdate = false;//Tommy：此处应该加注释：不要断然决定此处一定不是更新操作，考虑这样的情况：地址上id没有被指定，但是用户切换到已经填写过的周，结果是更新
            wrfw.OwnerId = userinfo.getUserId();
            //wrfw.startdate__c = DateHelper.ToStartOfWeek(Date.today());
            //Tommy: 此处应该从当前的周获取周开始时间DataHelper.Week.WeekStartDate
            wrfw.startdate__c = weekStart;
            
            if(strname == null)
            {
                wrfw.Name = DateHelper.GetFYWeekByDate(Date.today()).No+'-'+userinfo.getName();
                strname = DateHelper.GetFYWeekByDate(Date.today()).NextWeek.No; //DateHelper.GetFYWeekByDate(Date.today()).No;
                wrfw.Belongs_Week__c = strname;//Tommy：应当直接用wrfw.Belongs_Week__c代替strname，省略复制的复杂度
                //Tommy：需要显示地指定OwnerId为当前用户
            }
            else
            {
                wrfw.Name = strname+'-'+userinfo.getName();
                wrfw.Belongs_Week__c = strname;
            }
            
            listWeeklyTarget = new list<WeeklyTarget>();
            //Tommy：查询不应以Name 的拼装字符串筛选，应该按weekly_report_for_work__c的周编号和OwnerId为筛选条件，因为Name是相对不稳定的
            list<weekly_report_for_work__c> wrfwc = [SELECT Id,Name,OwnerId,plan_do_standards__c,issues__c,startdate__c FROM weekly_report_for_work__c where Belongs_Week__c=:wrfw.Belongs_Week__c and Name=:wrfw.Belongs_Week__c+'-'+userinfo.getName()];
            if(wrfwc.size()!=null && wrfwc.size() > 0)
            {
                isupdate = true;//Tommy: 此处应该加注释：不要断然决定此处一定不是更新操作，考虑这样的情况：地址上id没有被指定，但是用户切换到已经填写过的周，结果是更新
                //Tommy：此处又是累赘的代码
                for(weekly_report_for_work__c w:wrfwc)
                {
                    wrfw.Id = w.Id;
                    wrfw.OwnerId = w.OwnerId;
                    wrfw.plan_do_standards__c = w.plan_do_standards__c;
                    wrfw.issues__c = w.issues__c;
                    wrfw.startdate__c = weekStart;
                }
                //Tommy：此处是累赘的代码，需要考虑与上面查询合并
                list<WeeklyTarget__c> listWeekly = new list<WeeklyTarget__c>([Select Id,Status__c, Name,Goalachievement__c, Enddate__c, Description__c,Weeklyname__c From WeeklyTarget__c where Weeklyname__c =: wrfw.Id]);
                for(WeeklyTarget__c wt : listWeekly)
                {
                    WeeklyTarget wts = new WeeklyTarget();
                    wts.wtt = wt;
                    listWeeklyTarget.add(wts);
                }
            }
            else
            {
                AddWeeklyTarget();
                AddWeeklyTarget();
                AddWeeklyTarget();
                AddWeeklyTarget();
                AddWeeklyTarget();
            }
        }
    }
    public class WeeklyTarget
    {
        public boolean IsDelete{get;set;}
        public WeeklyTarget__c wtt{get;set;}
    }
    //添加行
    public void AddWeeklyTarget()
    {
        WeeklyTarget__c wkt = new WeeklyTarget__c();
        wkt.OwnerId = UserInfo.getUserId();//Tommy: 不能够断然决定当前用户一定是Owner,应该与weekly_report_for_work__c的Owner保持一致
        if(isupdate)
        {
            wkt.Weeklyname__c = wrfwId;
        }
        WeeklyTarget wts = new WeeklyTarget();
        wts.wtt = wkt;
        listWeeklyTarget.add(wts);
        
        system.debug('!!!!!!!!!!!'+listWeeklyTarget);
    }
    //删除行
    public void DeleteWeeklyTarget()
    {
        list<WeeklyTarget__c> listDeleteWeeklyTarget = new list<WeeklyTarget__c>();
        for(Integer i = listWeeklyTarget.size()-1;i>=0;i--)
        {
            if(listWeeklyTarget[i].IsDelete)
            {
                if(listWeeklyTarget[i].wtt.id!=null)
                {
                    listDeleteWeeklyTarget.add(listWeeklyTarget[i].wtt);
                }
                listWeeklyTarget.remove(i);
            }
        }
        delete listDeleteWeeklyTarget;
    }
    //保存
    public Pagereference Save()
    {
        if(isupdate)
        {
            wrfw.startdate__c = weekStart;
            update wrfw;
            List<WeeklyTarget__c> listSaveWeeklyTarget = new List<WeeklyTarget__c>();
            for(Integer i = 0;i<listWeeklyTarget.size();i++)
            {
                WeeklyTarget__c wtc = listWeeklyTarget[i].wtt;
                if(wtc.Name!=null||wtc.Goalachievement__c!=null||wtc.Enddate__c!=null
                ||wtc.Status__c!=null||wtc.Description__c!=null)
                {
                    listSaveWeeklyTarget.add(wtc);
                }
            }
            for(Integer i = 0;i<listSaveWeeklyTarget.size();i++)
            {
                WeeklyTarget__c wtc = listSaveWeeklyTarget[i];
                if(wtc.Name==null)
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '目标主题不能为空，工作目标保存失败');         
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if(listSaveWeeklyTarget.size()>0)
            {
                upsert listSaveWeeklyTarget;
            }
            string URL= '/' + wrfw.Id;
            return new Pagereference(URL);
        }
        else
        {
            try
            {
             wrfw.startdate__c = weekStart;
                upsert wrfw;
                List<WeeklyTarget__c> listSaveWeeklyTarget = new List<WeeklyTarget__c>();
                for(Integer i = 0;i<listWeeklyTarget.size();i++)
                {
                    WeeklyTarget__c wtc = listWeeklyTarget[i].wtt;
                    if(wtc.Name!=null||wtc.Goalachievement__c!=null||wtc.Enddate__c!=null
                    ||wtc.Status__c!=null||wtc.Description__c!=null)
                    {
                        wtc.Weeklyname__c = wrfw.Id;
                        listSaveWeeklyTarget.add(wtc);
                    }
                }
                for(Integer i = 0;i<listSaveWeeklyTarget.size();i++)
                {
                    WeeklyTarget__c wtc = listSaveWeeklyTarget[i];
                    if(wtc.Name==null)
                    {
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '目标主题不能为空，工作目标保存失败');         
                        ApexPages.addMessage(msg);
                        return null;
                    }
                }
                if(listSaveWeeklyTarget.size()>0)
                {
                    upsert listSaveWeeklyTarget;
                }
            }
            catch(system.Dmlexception e)
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR , '所有人不能为空') ;  //Tommy不能断言  Dmlexception 就一定是所有人为空导致的
                ApexPages.addMessage(msg);
                return null;
            }
            string URL= '/' + wrfw.Id;
            return new Pagereference(URL);
        }
    }
}