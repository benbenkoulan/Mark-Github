/*
*功能:批量添加项目阶段
*作者:Crazy
*日期:2014-01-20 
*/
public with sharing class BatchAddProjectStepController 
{
    public ID projectId {get;set;}
    public SFDC_Projects__c sfdc_Project{get;set;}
    public list<ProjectStep> listProjectStep {get; set;}
    public BatchAddProjectStepController(ApexPages.StandardController controller)
    {
       projectId=ApexPages.currentPage().getParameters().get('id'); 
       init();
    }
    //初始状态
    public void init()
    {
        this.listProjectStep = new list<ProjectStep>();
        sfdc_Project = [select ID,Name from SFDC_Projects__c where id =: this.projectId];
        list<projectstep__c> listProject = new list<projectstep__c>([select 
                                                                        id,
                                                                        NStageName__c, 
                                                                        SSdate__c,
                                                                        SCdate__c,
                                                                        Shoukuan__c,
                                                                        Collectionbysteps__c,
                                                                        NState__c,
                                                                        Startdate__c,
                                                                        Enddate__c,
                                                                        Stagedis__c,
                                                                        NRemarks__c  
                                                                    from projectstep__c 
                                                                    where relatedproject__c  =: projectId]);
        if(listProject.size()==0)
        {
            for(Integer i=0;i<5;i++)
            {
                AddProjectStep();
            }
        }
        for(projectstep__c pro : listProject)
        {
            ProjectStep pros = new ProjectStep();
            if(pro.Collectionbysteps__c!=null)
            {
                pros.ShowStyle='display:block;width:150px;';
            }
            else
            {
                pros.ShowStyle='display:none;width:150px;';
            }
            pros.ssDate = String.valueOf(date.valueOf(pro.SSdate__c));
            pros.scDate = String.valueOf(date.valueOf(pro.SCdate__c));
            pros.startDate = String.valueOf(date.valueOf(pro.Startdate__c));
            pros.endDate = String.valueOf(date.valueOf(pro.Enddate__c));    
            pros.pro = pro;
            listProjectStep.add(pros);
        }
    }
    
     //添加行
    public void AddProjectStep()
    {
        projectstep__c prostep = new projectstep__c();
        prostep.relatedproject__c = projectId;
        ProjectStep pros = new ProjectStep();
        pros.pro = prostep;
        listProjectStep.add(pros);
    }
    //删除行
    public void DeleteProjectStep()
    {
        list<projectstep__c> listDeleteProjectStep = new list<projectstep__c>();
        List<ProjectStep> deleteProjectSteps = new List<ProjectStep>();
        for(Integer i = listProjectStep.size()-1;i>=0;i--)
        {
            if(listProjectStep[i].IsDelete)
            {
                if(listProjectStep[i].pro.id!=null)
                {
                    listDeleteProjectStep.add(listProjectStep[i].pro);
                }
                listProjectStep.remove(i);
            }
        }
        delete listDeleteProjectStep;
    }
    //保存
    public void SaveProjectStep()
    {
            String message = '';
            String dateMessage = '';
            List<projectstep__c> listSaveProjectStep = new List<projectstep__c>();
            for(Integer i = 0;i<listProjectStep.size();i++)
            {
                projectstep__c projs = listProjectStep[i].pro;
                if(projs.NStageName__c==null )
                {
                    message += '"阶段名称"';
                }
                if( listProjectStep[i].ssDate == null || listProjectStep[i].ssDate == '')
                {
                    message += '"计划开始时间"';
                }
                if(listProjectStep[i].scDate == null || listProjectStep[i].scDate == '')
                {
                     message += '"计划结束时间"';
                }
                /*************************leo added on 2015-04-27***************************/
                if( listProjectStep[i].ssDate != null && listProjectStep[i].ssDate != ''
                    && listProjectStep[i].scDate != null && listProjectStep[i].scDate != ''
                    && getDate(listProjectStep[i].ssDate) > getDate(listProjectStep[i].scDate))
                {
                    dateMessage += '"计划开始时间不能大于计划结束时间"';
                }
                if( listProjectStep[i].startDate != null && listProjectStep[i].startDate != ''
                    && listProjectStep[i].endDate != null && listProjectStep[i].endDate != ''
                    && getDate(listProjectStep[i].startDate) > getDate(listProjectStep[i].endDate))
                {
                    dateMessage += '"实际开始时间不能大于实际结束时间"';
                }
                /*************************leo added on 2015-04-27***************************/
                if(projs.Shoukuan__c)
                {
                    if(projs.Collectionbysteps__c==null)
                    {
                        message+='"阶段收款金额"';
                    }
                }
                if(message!=null&&message!='')
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, message+'不能为空' + dateMessage + '保存失败');
                    ApexPages.addMessage(msg);
                    return;
                }
                projs.SSdate__c = getDate(listProjectStep[i].ssDate);
                projs.SCdate__c = getDate(listProjectStep[i].scDate);
                if(listProjectStep[i].startDate !=null && listProjectStep[i].startDate !='')
                {
                    projs.Startdate__c = getDate(listProjectStep[i].startDate);
                }
                if(listProjectStep[i].endDate != null && listProjectStep[i].endDate != '')
                {
                    projs.Enddate__c = getDate(listProjectStep[i].endDate);
                } 
                if(projs.NStageName__c!=null||projs.SSdate__c!=null||projs.SCdate__c!=null
                ||projs.NState__c!=null||projs.Startdate__c!=null||projs.Enddate__c!=null)
                {
                    listSaveProjectStep.add(projs);
                }
            }
            if(listSaveProjectStep.size()>0)
            {
                upsert listSaveProjectStep;
                listProjectStep.clear(); 
                listSaveProjectStep.clear();
                init();
            }
    }
    public Date getDate(String strDate)
    {
        Date dateValue = date.valueOf(strDate);
        return dateValue;   
    }
    public class ProjectStep
    {
        public boolean IsDelete{get;set;}
        public projectstep__c pro{get;set;}
        public String ShowStyle{get;set;}
        public String ssDate{get;set;}
        public String scDate{get;set;}
        public String startDate{get;set;}
        public String endDate{get;set;}
    }

}