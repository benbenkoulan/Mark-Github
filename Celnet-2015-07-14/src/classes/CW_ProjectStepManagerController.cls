public class CW_ProjectStepManagerController {
    
    public CW_ProjectStepManagerController(){
        
    }
    
    public class ManagerWrapper{
        public List<ProjectWrapper> project_wrapper_list{get;set;}
        public List<String> project_step_name_list{get;set;}
        
        public ProjectStepWrapper project_step_wrapper{get;set;}
        public String dml_status{get;set;}
    }
    
    @RemoteAction
    public static ManagerWrapper initiateProjects(){
        
        List<ProjectWrapper> pwList = new List<ProjectWrapper>();
    
        // 查询出当前用户的项目及项目阶段
        List<SFDC_Projects__c> projects = [Select 
                                            Id,
                                            Name,
                                            OwnerId,
                                            Projectmanager__c,
                                            Project_Imp_Stage__c, // 项目实施阶段 picklist
                                            State__c, // 状态 picklist
                                            Project_Type__c, // 项目类型 picklist
                                            Contract_Manday__c, // 公式 合同人天
                                            Actual_ManDays__c, // 累计汇总 实际人天
                                            MandayRate__c, // 公式 实际人天执行率
                                            maintenancestartday__c, // 维护开始日期
                                            project_StartDate__c, // 项目启动日期
                                            Project_Estimate_EndDate__c, // 项目预计结束日期
                                            stopon__c, // 保修截止期
                                            Project_Actual_EndDate__c, // 验收日期
                                            (Select 
                                                Id, 
                                                Name,
                                                relatedproject__c, // 相关项目
                                                NStageName__c, // 阶段名称 picklist
                                                SSdate__c, // 计划开始时间
                                                SCdate__c, // 计划结束时间
                                                Plan_Duration__c, // 阶段计划时长 公式
                                                Startdate__c, // 实际开始时间
                                                Enddate__c, // 实际结束时间
                                                Shoukuan__c, // 收款阶段 checkbox
                                                Collectionbysteps__c, // 阶段收款金额
                                                Actual_Duration__c, // 阶段实际时长 公式
                                                Stagedis__c // 阶段描述
                                             From relatedproject__r
                                             Order by SSdate__c asc NULLS LAST)
                                           From SFDC_Projects__c 
                                           Where (Projectmanager__c =: UserInfo.getUserId() //'00590000003BwDI'
                                           Or OwnerId =: UserInfo.getUserId())
                                           And Project_Imp_Stage__c != '已完成'
                                           And State__c != '关闭'
                                           Order by Project_Type__c, Project_Imp_Stage__c, CreatedDate desc];
        
        for(SFDC_Projects__c sp : projects){
            pwList.add(new ProjectWrapper(sp));
        }
        
        // 获取项目阶段名称picklist
        List<String> psnList = new List<String>();
                
        Schema.DescribeFieldResult fieldResult = projectstep__c.NStageName__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple){
            psnList.add(f.getValue());
        }
        
        ManagerWrapper mw = new ManagerWrapper();
        mw.project_wrapper_list = pwList;
        mw.project_step_name_list = psnList;
        
        return mw;
    }
    
    // 保存项目阶段
    @RemoteAction
    public static ManagerWrapper saveProjectStep(ProjectStepWrapper psw){
        try{
            projectstep__c ps = new projectstep__c();
            ps.relatedproject__c = psw.project_id; 
            ps.NStageName__c = psw.project_step_name; 
            ps.SSdate__c = convertJsDateStringToApexDate(psw.due_start_date); 
            ps.SCdate__c = convertJsDateStringToApexDate(psw.due_end_date); 
            ps.Startdate__c = convertJsDateStringToApexDate(psw.actual_start_date); 
            ps.Enddate__c = convertJsDateStringToApexDate(psw.actual_end_date); 
            ps.Shoukuan__c = psw.is_remittance_step;
            ps.Stagedis__c = psw.step_description; 
            
            if(psw.remittance_amount != null && psw.remittance_amount > 0){
                ps.Collectionbysteps__c = psw.remittance_amount; 
            }
            
            ps.Stagedis__c = psw.step_description; 
            ps.InputSource__c = 'Welink';
            if(psw.id != ''){
                ps.Id = psw.id;
            }
            
            upsert ps;
            
            projectstep__c upserted_ps = [Select Id, Name, relatedproject__c, NStageName__c, 
                                    SSdate__c, SCdate__c, Plan_Duration__c, Startdate__c, 
                                    Enddate__c, Shoukuan__c, Collectionbysteps__c, 
                                    Actual_Duration__c, Stagedis__c 
                                   From projectstep__c
                                   Where Id =: ps.Id];
            
            ManagerWrapper mw = new ManagerWrapper();
            mw.dml_status = 'success';
            mw.project_step_wrapper = new ProjectStepWrapper(upserted_ps);
            
            return mw;
        } catch(Exception e){
            ManagerWrapper mw = new ManagerWrapper();
            mw.dml_status = e.getMessage();
            
            return mw;
        }
    }
    
    // 删除项目阶段
    @RemoteAction
    public static String deleteProjectStep(String psId){
        try{
            delete new projectstep__c(Id = psId);
            return 'success';
        } catch(Exception e){
            return e.getMessage();
        }
    }
    
    public class ProjectWrapper{
        public SFDC_Projects__c sfProject{get;set;}
        public String project_name{get;set;}
        public String project_imp_step{get;set;}
        public String project_state{get;set;}
        public String project_type{get;set;}
        public String project_type_js{get;set;} // js variable name
        public Decimal contract_manday{get;set;}
        public Decimal actual_manday{get;set;}
        public Decimal manday_rate{get;set;}
        public String maintenance_start_date{get;set;}
        public String project_start_date{get;set;}
        public String estimated_end_date{get;set;}
        public String stopon_date{get;set;}
        public String actual_end_date{get;set;}
        public List<ProjectStepWrapper> project_step_list{get;set;}
        public String id{get;set;}
        
        public ProjectWrapper(SFDC_Projects__c sp){
            this.sfProject = sp;
            this.project_name = sp.Name;
            this.project_imp_step = sp.Project_Imp_Stage__c;
            this.project_state = sp.State__c;
            this.project_type = sp.Project_Type__c;
            this.contract_manday = sp.Contract_ManDay__c;
            this.actual_manday = sp.Actual_ManDays__c;
            this.manday_rate = sp.MandayRate__c;
            this.maintenance_start_date = convertDateToString(sp.maintenancestartday__c);
            this.project_start_date = convertDateToString(sp.project_StartDate__c);
            this.estimated_end_date = convertDateToString(sp.Project_Estimate_EndDate__c);
            this.stopon_date = convertDateToString(sp.stopon__c);
            this.actual_end_date = convertDateToString(sp.Project_Actual_EndDate__c);
            this.id = sp.id;
            
            this.project_step_list = new List<ProjectStepWrapper>();
            for(projectstep__c ps : sp.relatedproject__r){
                this.project_step_list.add(new ProjectStepWrapper(ps));
            }  
        }
        
        private String convertDateToString(Date d){
            return (d!=null?String.valueOf(d):'');
        }
    }
    
    public class ProjectStepWrapper{
        public projectstep__c projectStep{get;set;}
        public String project_id{get;set;}
        public String project_step_name{get;set;}
        public String due_start_date{get;set;}
        public String due_end_date{get;set;}
        public Decimal due_duration{get;set;}
        public String actual_start_date{get;set;}
        public String actual_end_date{get;set;}
        public Decimal actual_duration{get;set;}
        public String step_description{get;set;}
        public boolean is_remittance_step{get;set;}
        public Decimal remittance_amount{get;set;}
        public String id{get;set;}
        
        public ProjectStepWrapper(projectstep__c ps){
            this.projectStep = ps;
            this.project_id = ps.relatedproject__c;
            this.project_step_name = ps.NStageName__c;
            this.due_start_date = convertDateToString(ps.SSdate__c);
            this.due_end_date = convertDateToString(ps.SCdate__c);
            this.due_duration = ps.Plan_Duration__c;
            this.actual_start_date = convertDateToString(ps.Startdate__c);
            this.actual_end_date = convertDateToString(ps.Enddate__c);
            this.actual_duration = ps.Actual_Duration__c;
            this.step_description = ps.Stagedis__c;
            this.is_remittance_step = ps.Shoukuan__c;
            this.remittance_amount = ps.Collectionbysteps__c;
            this.id = ps.Id;
        }
        
        private String convertDateToString(Date d){
            return (d!=null?String.valueOf(d):'');
        }
    }
    
    private static Date convertJsDateStringToApexDate(String js_date_string){
        if(js_date_string == null || js_date_string.length() < 10)
        return null;
        
        Integer apex_year = Integer.valueOf(js_date_string.substring(0,4));
        Integer apex_month = Integer.valueOf(js_date_string.substring(5,7));
        Integer apex_date = Integer.valueOf(js_date_string.substring(8,10));
        
        return Date.newInstance(apex_year, apex_month, apex_date);
    }
}