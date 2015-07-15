/*
 *作者：team
 *时间：2014-02-24
 *描述：在创建合同的时候自动创建合同分割
*/
trigger AutoCreateConstractSpilt on Contract (after insert) {
    List<ConstractSpilt__c> List_ConstractSpilt = new List<ConstractSpilt__c>();
    for(Contract con : trigger.new)
    {
        ConstractSpilt__c constract=new ConstractSpilt__c();
        constract.percentage_split__c=100;
        constract.Alloter__c=con.OwnerId;
        constract.constract__c=con.Id;
        List_ConstractSpilt.add(constract);
    }
    insert List_ConstractSpilt;
}