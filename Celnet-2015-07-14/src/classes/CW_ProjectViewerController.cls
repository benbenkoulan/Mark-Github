public class CW_ProjectViewerController{
    public CW_ProjectViewerController(){
        
    }
    
    @RemoteAction
    public static ProjectViewerWrapper initializeProjects(){
        List<ProjectWrapper> pwList = new List<ProjectWrapper>();
       
        
        List<SFDC_Projects__c> projects = [Select 
                                            Id,
                                            Name,
                                            OwnerId,
                                            RecordTypeId,//记录类型
                                            Projectmanager__c,//项目经理
                                            Project_Imp_Stage__c, // 项目实施阶段 picklist
                                            State__c, // 状态 picklist
                                            Project_Type__c, // 项目类型 picklist
                                            maintenancestartday__c,//维护起始日期
                                            Contract_Manday__c, // 公式 合同人天
                                            Actual_ManDays__c, // 累计汇总 实际人天
                                            MandayRate__c, // 公式 实际人天执行率
                                            project_StartDate__c, // 项目启动日期
                                            Project_Estimate_EndDate__c, // 项目预计结束日期
                                            stopon__c, // 保修截止期
                                            Opportunity__c,//最近来源业务机会
                                            Amount__c,//合同金额
                                            Account__c,//客户
                                            ProColor__c,//项目颜色
                                            Project_Actual_EndDate__c, // 验收日期
                                            Contact__c//联系人
                                           From SFDC_Projects__c 
                                           Where (Projectmanager__c =: UserInfo.getUserId() //'00590000003BwDI'
                                           Or OwnerId =: UserInfo.getUserId())
                                           And Project_Type__c='实施'
                                           Order by Project_Type__c, Project_Imp_Stage__c, CreatedDate desc];
        
        String currentUserId = UserInfo.getUserId();
        
        for(SFDC_Projects__c sp : projects){
        
            pwList.add(new ProjectWrapper(sp));
        }
        
        ProjectViewerWrapper pvw = new ProjectViewerWrapper();
        pvw.allProjects = pwList;
        
        return pvw;
    }
    
    class ProjectViewerWrapper{
        public List<ProjectWrapper> allProjects{get;set;}
    }
    
    class ProjectWrapper{
        public SFDC_Projects__c project{get;set;}
        //public String expectedprojectdate{get;set;}
        //public String expectedinvoicedate{get;set;}
        public ProjectWrapper(SFDC_Projects__c co){
            this.project = co;
            //this.expectedprojectdate = convertApexDate(co.Expectedprojectdate__c);
            //this.expectedinvoicedate = convertApexDate(co.Expectedinvoicedate__c);
        }
        
        public String convertApexDate(Date apexDate){
            if(apexDate == null){
                return '';
            } else {
                return apexDate.year() + '-' + apexDate.month() + '-' + apexDate.day();
            }
        }
    }
}