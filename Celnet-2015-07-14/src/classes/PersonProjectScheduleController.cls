//(暂时保留)
public with sharing class PersonProjectScheduleController {
    
    public PersonProjectSchedule__c pps{get;set;}
    public string ppsId{get;set;}
    public Boolean isEdit{get;set;}
    public PersonProjectScheduleController(){
        init();
    }
    
    public void init(){
        isEdit = false;
        ID userId = UserInfo.getUserId();
        String ppsId=Apexpages.currentPage().getParameters().get('TaskId');
        String startDate=Apexpages.currentPage().getParameters().get('startDate');
        String endDate=Apexpages.currentPage().getParameters().get('endDate');
        if(ppsId==null||ppsId==''){//当前状态为新建事件
            pps=new PersonProjectSchedule__c();
            pps.startDateTime__c=DateTime.valueOf(startDate);
            pps.endDateTime__c=DateTime.valueOf(endDate);
            pps.developer__c = userId;
        }else{//根据ID查看已存在的事件
            list<PersonProjectSchedule__c> list_pps=[select Name, developer__c,Project__r.ProColor__c,Project__r.Name,type__c,
                        endDateTime__c,startDateTime__c,estimateStaffDay__c from PersonProjectSchedule__c where id=:ppsId];
            if(list_pps != null && list_pps.size()>0)
            {
                pps=list_pps[0];
                pps.developer__c = userId;
                isEdit=true;
            }
        }       
    }
    
    public Pagereference mySave(){
        try{
            if(pps.Id == null)
            {
                insert pps;
            }else{
                update pps;
            }
        }catch(exception e){
        
        }
        return new PageReference('/apex/ProjectDevelopmentTasksPage');
    }
    public void myEdit(){isEdit= false;}
    
    public Pagereference myDelete(){
        try{
            delete pps;
        }catch(Exception e){}
        return new PageReference('/apex/ProjectDevelopmentTasksPage');
    }
    
    
    //返回 项目开发任务 日历 页面
    public Pagereference myCancer(){return new PageReference('/apex/ProjectDevelopmentTasksPage');}
    
}