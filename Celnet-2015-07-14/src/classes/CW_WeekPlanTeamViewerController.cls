public class CW_WeekPlanTeamViewerController{
    // 所属周描述
    public static String currentWeekRangeDescription{get;set;}
    public static String lastWeekRangeDescription{get;set;}
    public static String nextWeekRangeDescription{get;set;}
    public static String sid{get;set;}
    public static list<User> qq{get;set;}
    public String id{get;set;}
    
    public static List<weekly_report_for_work__c> reports_x{get;set;}
    
    public static List<WeekPlanWrapper> weekPlans{get;set;}
    
    public CW_WeekPlanTeamViewerController(){
        
        id = ApexPages.currentPage().getParameters().get('id');
        sid=id;
        // 周信息
        Date currentDay = Date.today();
        DateHelper.Week currentWeek = DateHelper.GetFYWeekByDate(currentDay);
        DateHelper.Week lastWeek = currentWeek.LastWeek;
        DateHelper.Week nextWeek = currentWeek.NextWeek;
        currentWeekRangeDescription = retrieveWeekRangeDescription(currentWeek);
        lastWeekRangeDescription = retrieveWeekRangeDescription(lastWeek);
        nextWeekRangeDescription = retrieveWeekRangeDescription(nextWeek);
        
        
        list<User>  uu=[select Id,
                               Name 
                               From User 
                               where Id=:CW_WeekPlanTeamViewerController.sid];
        qq=uu;
    } 
    
    
    private static WeekPlanWrapper wrapWeekPlan(weekly_report_for_work__c wrfw){
        WeekPlanWrapper wpw = new WeekPlanWrapper();
        wpw.weekReport = wrfw;
        wpw.id = wrfw.Id;
        
        if(wrfw.plan_do_standards__c != null){
            wpw.thoughts = wrfw.plan_do_standards__c;
        }
        
        if(wrfw.issues__c != null){
            wpw.issues = wrfw.issues__c;
        }
        
        for(WeeklyTarget__c wt : wrfw.Goalweekly__r){
            wpw.targets.add(wrapWeekTarget(wt));
        }
        
        return wpw;
    }
    
    private static WeekTargetWrapper wrapWeekTarget(WeeklyTarget__c wt){
        WeekTargetWrapper wtw = new WeekTargetWrapper();
        wtw.target = wt;
        wtw.id = wt.Id;
        wtw.subject = wt.Name;
        
        if(wt.Enddate__c != null){
            wtw.endtime = String.valueOf(wt.Enddate__c);
        }
        
        if(wt.Goalachievement__c != null){
            wtw.accomplishment_rate = wt.Goalachievement__c == null?'0':String.valueOf(wt.Goalachievement__c);
        }
        
        if(wt.Status__c != null){
            wtw.status = wt.Status__c;
        }
        
        if(wt.Description__c != null){
            wtw.description = wt.Description__c;
        }
        
        return wtw;
    }
    
    @RemoteAction
    public static List<WeekPlanWrapper> initiateWeekPlans(String userid){
        CW_WeekPlanTeamViewerController.sid=userid;
        Date currentDay = Date.today();
        DateHelper.Week currentWeek = DateHelper.GetFYWeekByDate(currentDay);
        DateHelper.Week lastWeek = currentWeek.LastWeek;
        DateHelper.Week nextWeek = currentWeek.NextWeek;
        currentWeekRangeDescription = retrieveWeekRangeDescription(currentWeek);
        lastWeekRangeDescription = retrieveWeekRangeDescription(lastWeek);
        nextWeekRangeDescription = retrieveWeekRangeDescription(nextWeek);

        reports_x = [Select 
                            Id, Name, plan_do_standards__c, others__c, issues__c,
                            Belongs_Week__c, startdate__c, enddate__c,
                            (Select Id, Name, Enddate__c, Description__c, Goalachievement__c, Status__c 
                                From Goalweekly__r) 
                        From weekly_report_for_work__c
                        Where OwnerId =:CW_WeekPlanTeamViewerController.sid
                        And (Belongs_Week__c =: currentWeek.No
                          Or Belongs_Week__c =: nextWeek.No
                          Or Belongs_Week__c =: lastWeek.No)];
        weekPlans = new List<WeekPlanWrapper>();
        
        WeekPlanWrapper currentWeekPlan = new WeekPlanWrapper();
        WeekPlanWrapper lastWeekPlan = new WeekPlanWrapper();
        WeekPlanWrapper nextWeekPlan = new WeekPlanWrapper();
        
        for(weekly_report_for_work__c wrfw : reports_x){
            if(wrfw.Belongs_Week__c == currentWeek.No){
                //currentWeekReport = wrfw;
                currentWeekPlan = wrapWeekPlan(wrfw);
            } else if(wrfw.Belongs_Week__c == lastWeek.No){
                //lastWeekReport = wrfw;
                lastWeekPlan = wrapWeekPlan(wrfw);
            } else if(wrfw.Belongs_Week__c == nextWeek.No){
                //nextWeekReport = wrfw;
                nextWeekPlan = wrapWeekPlan(wrfw);
            }
        }
        
        weekPlans.add(lastWeekPlan);
        weekPlans.add(currentWeekPlan);
        weekPlans.add(nextWeekPlan);
        
        return weekPlans;
    }
    
    // 1. 已有 Week Plan，插入 Week Target
    // 2. 已有 Week Plan，更新 Week Target
    // 3. 没有 Week Plan，插入 Week Target
    @RemoteAction
    public static String saveWeekTarget(String weekPlanId, WeekTargetWrapper wtw){
        
        WeeklyTarget__c save_week_target = new WeeklyTarget__c();
        
        save_week_target.Name = wtw.subject;
        save_week_target.Enddate__c = convertJsDateStringToApexDate(wtw.endtime);
        save_week_target.Description__c = wtw.description;
        save_week_target.Goalachievement__c = Integer.valueOf(wtw.accomplishment_rate);
        save_week_target.Status__c = wtw.status;
        
        
        String weekPlanPrefix = Sobjecttype.weekly_report_for_work__c.getKeyPrefix();
        
        if(!weekPlanId.startsWith(weekPlanPrefix)){ // 没有 Week Plan，插入 Week Target
            weekly_report_for_work__c save_week_plan = new weekly_report_for_work__c();
            
            DateHelper.Week planWeek = DateHelper.GetFYWeekByDate(Date.today());
        
            if(weekPlanId == 'lastweek'){
                planWeek = planWeek.LastWeek;
            } else if(weekPlanId == 'nextweek'){
                planWeek = planWeek.NextWeek;
            }
            
            save_week_plan.Name = planWeek.No + '-' + UserInfo.getName();
            save_week_plan.Belongs_Week__c = planWeek.No; 
            save_week_plan.startdate__c = planWeek.WeekStartDate; 
            
            save_week_plan.InputSource__c = 'Welink';
            
            insert save_week_plan;
            
            weekPlanId = save_week_plan.Id;
            
        } else if(wtw.id == 'new') { // 已有 Week Plan，更新 Week Target
            
        } else { // 已有 Week Plan，插入 Week Target
            save_week_target.Id = wtw.id;
        }
        
        save_week_target.Weeklyname__c = weekPlanId;
        
        save_week_target.InputSource__c = 'Welink';
        
        upsert save_week_target;
        
        // String weekPlanId = '';
        return weekPlanId + '-' + save_week_target.Id;
    }
    
    // js date string 转换为 apex date
    private static Date convertJsDateStringToApexDate(String js_date_string){
        if(js_date_string == null || js_date_string.length() < 10)
        return null;
        
        Integer apex_year = Integer.valueOf(js_date_string.substring(0,4));
        Integer apex_month = Integer.valueOf(js_date_string.substring(5,7));
        Integer apex_date = Integer.valueOf(js_date_string.substring(8,10));
        
        return Date.newInstance(apex_year, apex_month, apex_date);
    }
    
    // 1. 没有 Week Plan，插入 Week Plan
    // 2. 已有 Week Plan，更新 Week Plan
    @RemoteAction
    public static String saveWeekPlan(String week_id, WeekPlanWrapper wpw){
        
        weekly_report_for_work__c save_week_plan = new weekly_report_for_work__c();
        
        save_week_plan.plan_do_standards__c = wpw.thoughts; // 注意null 
        save_week_plan.issues__c = wpw.issues; // 注意null
        
        //save_week_plan.others__c = ''; // 不需要填写
        //save_week_plan.enddate__c = Date.today(); // 公式字段
        //save_week_plan.Belongs_Week__c = 
        
        if(wpw.id == 'new'){ // 没有 Week Plan
            //weekly_report_for_work__c save_week_plan = new weekly_report_for_work__c();
            //save_week_plan
            
            DateHelper.Week planWeek = DateHelper.GetFYWeekByDate(Date.today());
        
            if(week_id == 'lastweek'){
                planWeek = planWeek.LastWeek;
            } else if(week_id == 'nextweek'){
                planWeek = planWeek.NextWeek;
            }
            
            save_week_plan.Name = planWeek.No + '-' + UserInfo.getName();
            save_week_plan.Belongs_Week__c = planWeek.No; 
            save_week_plan.startdate__c = planWeek.WeekStartDate; 
            
            
        } else {    // 已有 Week Plan
            // weekly_report_for_work__c
            save_week_plan.Id = wpw.id; // 更新的需要
        }
        
        try{
            
            save_week_plan.InputSource__c = 'Welink';
        
            upsert save_week_plan;
            
            return save_week_plan.Id;
        } catch(Exception e){
            return e.getMessage();
        }
    }
    
    // 删除 Week Target
    @RemoteAction
    public static String deleteWeekTarget(String targetId){
        try{
            delete new WeeklyTarget__c(Id = targetId);
            return 'success';
        } catch(Exception e) {
            return e.getMessage();
        }
    }
    
    public static String retrieveWeekRangeDescription(DateHelper.Week week){
        String startDay = string.valueOf(week.WeekStartDate.year()) + '-' + string.valueOf(week.WeekStartDate.month()) + '-' + string.valueOf(week.WeekStartDate.day());
        String endDay = string.valueOf(week.WeekEndDate.year()) + '-' + string.valueOf(week.WeekEndDate.month()) + '-' + string.valueOf(week.WeekEndDate.day());
        // String weekRangeDescription = '所属周:' + week.No + '(从' + startDay + '到' + endDay + ')';
        String weekRangeDescription = week.No + ' ( ' + startDay + ' ~ ' + endDay + ' )';
        return weekRangeDescription;
    }
    
    public class WeekPlanWrapper{
        public String id{get;set;}
        public String issues{get;set;}
        public String thoughts{get;set;}
        public List<WeekTargetWrapper> targets{get;set;}
        public weekly_report_for_work__c weekReport{get;set;}
        
        public WeekPlanWrapper(){
            this.id = 'new';
            this.issues = '';
            this.thoughts = '';
            this.weekReport = new weekly_report_for_work__c();
            this.targets = new List<WeekTargetWrapper>();
        }
    }
    
    public class WeekTargetWrapper{
        public String id{get;set;}
        public String subject{get;set;}
        public String endtime{get;set;}
        public String accomplishment_rate{get;set;}
        public String status{get;set;}
        public String description{get;set;}
        public WeeklyTarget__c target{get;set;}
        
        public WeekTargetWrapper(){
            this.target = new WeeklyTarget__c();
            this.id = 'new';
            this.subject = '';
            this.endtime = '';
            this.accomplishment_rate = '0';
            this.status = '';
            this.description = '';
        }
    }
}