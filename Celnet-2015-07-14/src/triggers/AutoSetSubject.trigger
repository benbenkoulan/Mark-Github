/*
Author:Crazy
*Date:2014-1-16
*Remark:将没有填写主题的销售任务自动将主题内容写为任务类型的内容

*/
trigger AutoSetSubject on Evaluation_Plan__c (before insert)
{
    list<Evaluation_Plan__c> epNoSubjectIdList = new list<Evaluation_Plan__c>();
    for(Evaluation_Plan__c ep:trigger.new)
    {
        if(ep.subject__c==null)
        {
            epNoSubjectIdList.add(ep);
        }   
    }
    for(Evaluation_Plan__c ep:epNoSubjectIdList)
    {
        ep.subject__c = ep.tasktype__c;
    }
}