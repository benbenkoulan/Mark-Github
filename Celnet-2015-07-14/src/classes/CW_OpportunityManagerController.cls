public class CW_OpportunityManagerController{
    public CW_OpportunityManagerController(){
        
    }
    
    @RemoteAction
    public static ManagerWrapper initializeOpps(){
        ManagerWrapper mw = new ManagerWrapper();
        
        try{
            /*
            业务机会名称 Name (Edit)
            客户名 Account (Name, Read-only)
            业务区隔 Segmentation__c (Read-only)
            Salesforce 销售 SalesForce_salesmember__c (Read-only)
            阶段 StageName (Edit)
            可能性％ Probability (Read-only)
            项目可能性 projectpossiblity__c (Read-only)
            SFDC金额$ SFDC_Amount1__c (Edit)
            金额 Amount (Edit)
            重要性 Important__c (Read-only)
            下一步 NextStep (Edit)
            结束日期 CloseDate (Edit)
            所有人 OwnerId (Read-only)
            */
            List<Opportunity> opps = [Select Id, 
                                            Name, 
                                            OwnerId,
                                            AccountId,
                                            Account.Name,
                                            Segmentation__c,
                                            SalesForce_salesmember__c,
                                            StageName,
                                            Probability,
                                            projectpossiblity__c,
                                            SFDC_Amount1__c,
                                            Amount,
                                            Important__c,
                                            NextStep,
                                            CloseDate
                                        From Opportunity 
                                        Where OwnerId =: UserInfo.getUserId()
                                        And CloseDate >=: Date.today()
                                        And CloseDate <=: Date.today().addMonths(3)];
            
            List<OpportunityWrapper> owList = new List<OpportunityWrapper>();
            
            for(Opportunity opp: opps){
                owList.add(new OpportunityWrapper(opp));
            }
            
            mw.ow_list = owList;
            
            // 获取阶段列表
            List<String> stageList = new List<String>();
            
            Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            for( Schema.PicklistEntry f : ple){
                stageList.add(f.getValue());
            }
            
            mw.opp_stages = stageList;
            mw.status = 'success';
            return mw;
        } catch (Exception e){
            mw.status = e.getMessage();
            return mw;
        }
    }
    
    @RemoteAction
    public static ManagerWrapper saveOpp(OpportunityWrapper ow){
        ManagerWrapper mw = new ManagerWrapper();
        
        try{
            Opportunity save_opp = ow.opp;
            save_opp.CloseDate = convertJsDateStringToApexDate(ow.js_close_date);
            
            update save_opp;
            
            Opportunity renewed_opp = [Select Id, Name, OwnerId, AccountId, Account.Name,
                                          Segmentation__c, SalesForce_salesmember__c, 
                                          StageName, Probability, projectpossiblity__c,
                                          SFDC_Amount1__c, Amount, Important__c, NextStep, 
                                          CloseDate
                                        From Opportunity Where Id =: save_opp.Id];
            
            mw.status = 'success';
            mw.ow_list = new List<OpportunityWrapper>();
            mw.ow_list.add(new OpportunityWrapper(renewed_opp));
            return mw;
        } catch (Exception e){
            mw.status = e.getMessage();
            return mw;
        }
    }
    
    
    
    class ManagerWrapper{
        public String status{get;set;}
        public List<String> opp_stages{get;set;}
        public List<OpportunityWrapper> ow_list{get;set;}
    }
    
    class OpportunityWrapper{
        public Opportunity opp{get;set;}
        public String js_close_date{get;set;}
        
        OpportunityWrapper(Opportunity o){
            this.opp = o;
            this.js_close_date = convertDateToString(o.CloseDate);
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