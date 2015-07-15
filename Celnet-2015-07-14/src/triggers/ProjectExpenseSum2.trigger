/*功能:将挂在项目下的费用汇总到项目上
**作者:Ward Zhou
**时间:2014年12月30日
*/
trigger ProjectExpenseSum2 on SFDC_Projects__c (before update) 
{
    set<Id> Set_ProId = new set<Id>();
    for(SFDC_Projects__c SF:trigger.new)
    {
        Set_ProId.Add(SF.Id);
    }
    AggregateResult[] result1 = [select SUM(reimbursementAmount__c) RA, projectName__c  from costdetail__c
                                    where projectName__c IN:Set_ProId 
                                    and reimbursementStyle__c ='交通费' group by projectName__c];
    AggregateResult[] result2 = [select SUM(reimbursementAmount__c) RA, projectName__c  from costdetail__c
                                    where projectName__c IN:Set_ProId
                                    and reimbursementStyle__c ='其他费用' group by projectName__c];
    AggregateResult[] result3 = [select SUM(reimbursementAmount__c) RA, projectName__c  from costdetail__c
                                    where projectName__c IN:Set_ProId 
                                    and reimbursementStyle__c ='通讯费' group by projectName__c];
    AggregateResult[] result4 = [select SUM(reimbursementAmount__c) RA, projectName__c  from costdetail__c
                                    where projectName__c IN:Set_ProId
                                    and reimbursementStyle__c ='住宿费' group by projectName__c];
    AggregateResult[] result5 = [select SUM(reimbursementAmount__c) RA, projectName__c from costdetail__c
                                    where projectName__c IN:Set_ProId 
                                    and reimbursementStyle__c ='招待费' group by projectName__c];
    AggregateResult[] result6 = [select SUM(reimbursementAmount__c) RA, projectName__c from costdetail__c
                                    where projectName__c IN:Set_ProId 
                                    and reimbursementStyle__c ='市内交通费' group by projectName__c];
    map<Id,double> Map_Traffic = new map<Id,double>();
    map<Id,double> Map_Other = new map<Id,double>();
    map<Id,double> Map_Phone = new map<Id,double>();
    map<Id,double> Map_Stay = new map<Id,double>();
    map<Id,double> Map_Entertain = new map<Id,double>();
    map<Id,double> Map_InnerTraffic = new map<Id,double>();
    for(AggregateResult Ar:result1)                             
    {
        Map_Traffic.put(Id.valueOf(string.valueOf(Ar.get('projectName__c'))),double.valueOf(Ar.get('RA')));
    }
    for(AggregateResult Ar:result2)                             
    {
        Map_Other.put(Id.valueOf(string.valueOf(Ar.get('projectName__c'))),double.valueOf(Ar.get('RA')));
    }
    for(AggregateResult Ar:result3)                             
    {
        Map_Phone.put(Id.valueOf(string.valueOf(Ar.get('projectName__c'))),double.valueOf(Ar.get('RA')));
    }
    for(AggregateResult Ar:result4)                             
    {
        Map_Stay.put(Id.valueOf(string.valueOf(Ar.get('projectName__c'))),double.valueOf(Ar.get('RA')));
    }
    for(AggregateResult Ar:result5)                             
    {
        Map_Entertain.put(Id.valueOf(string.valueOf(Ar.get('projectName__c'))),double.valueOf(Ar.get('RA')));
    }
    for(AggregateResult Ar:result6)                             
    {
        Map_InnerTraffic.put(Id.valueOf(string.valueOf(Ar.get('projectName__c'))),double.valueOf(Ar.get('RA')));
    }
    for(SFDC_Projects__c SF:trigger.new)
    {
        SF.TrafficExpense__c = Map_Traffic.get(SF.Id);
        SF.OtherExpense__c = Map_Other.get(SF.Id);
        SF.PhoneExpense__c = Map_Phone.get(SF.Id);
        SF.StayExpense__c = Map_Stay.get(SF.Id);
        SF.EntertainExpense__c = Map_Entertain.get(SF.Id);
        SF.InnerTrafficExpense__c = Map_InnerTraffic.get(SF.Id);
    }
    
    
}