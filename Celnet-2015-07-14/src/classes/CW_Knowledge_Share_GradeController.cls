public class CW_Knowledge_Share_GradeController{
    
    public List<KnowGrade> kgList{get;set;}
    public static String sid{get;set;}
    public String id{get;set;}
    public string message{get;set;}
    public CW_Knowledge_Share_GradeController()
    {
               message = ApexPages.currentPage().getParameters().get('message');
               if(message != null)
               {
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.WARNING, '评分成功，感谢您的参与');
                   ApexPages.addMessage(myMsg);
               }
               id = ApexPages.currentPage().getParameters().get('id');
               sid=id;
               kgList =  new List<KnowGrade>();
               for(Knowledge_Share__c ks :[Select Id, 
                                                  Start_Time__c,
                                                  Total_Grade__c,
                                                  Speaker__c,
                                                  Speaker_Name__c,
                                                  
                                                  Name,
                                                  (select id,Grade__c,Suggest__c from Knowledge_Share_Grade__r
                                                          where createdbyid = :userinfo.getUserId() 
                                                  ),
                                                  Category__c,
                                                  Sub_Category__c
                                                  From Knowledge_Share__c 
                                                  where Id=:CW_Knowledge_Share_GradeController.sid])
                 {
                     KnowGrade kg = new KnowGrade();
                     kg.kShare = ks;
                     if(ks.Knowledge_Share_Grade__r.isempty())
                     {
                         Knowledge_Share_Grade__c ksg = new Knowledge_Share_Grade__c();
                         ksg.Knowledge_Share__c = ks.id;
                         kg.ksGrade = ksg;
                     }
                     else
                     {
                         kg.ksGrade = ks.Knowledge_Share_Grade__r[0];
                     }
                     kgList.add(kg);
                 }
                
              
    }
    public Pagereference save()
    {
        List<Knowledge_Share_Grade__c> insertList = new List<Knowledge_Share_Grade__c>();
        List<Knowledge_Share_Grade__c> updateList = new List<Knowledge_Share_Grade__c>();
        for(KnowGrade kkgg : kgList)
        {
            if(kkgg.ksGrade.Id==null)
            {
                insertList.add(kkgg.ksGrade);
            }
            else
            {
                updateList.add(kkgg.ksGrade);
            }
        }
        if(!insertList.isempty())
            {
                insert insertList;
            }
        if(!updateList.isempty())
            {
                update updateList;
            }
            Pagereference redirect_page = new PageReference('/apex/CW_Knowledge_Share_Grade?message=success&Id='+id);
            redirect_page.setRedirect(true);
            return redirect_page;
    }
    public class KnowGrade
   {
       public Knowledge_Share__c kShare{get;set;}
       public Knowledge_Share_Grade__c ksGrade{get;set;}
   } 
}