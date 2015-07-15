/*
查询Welink开发路径的控制类

*/
public class CW_WelinkRouteNodeController 
{
 //用于存储系统中所有的welink开发路径信息
 public List<Welink_Route_Node__c> WelinkRNList{get;set;}
 //用于存储当前版本信息
 public Welink_Route_Node__c CurrentVersion {get;set;}

 public CW_WelinkRouteNodeController()
 {
       //查询所有版本信息
        this.WelinkRNList=new List<Welink_Route_Node__c>();
       
        /* this.WelinkRNList=[Select Id,
                                  Name,
                                  Publish__c,
                                  Description__c,
                                  Content__c,
                                  System_Version__c,
                                  NodeColor__c
                                  from Welink_Route_Node__c
                                  order by Order__c desc];*/
        for(Welink_Route_Node__c w:[Select Id,
                                  Name,
                                  Publish__c,
                                  Description__c,
                                  Content__c,
                                  System_Version__c,
                                  ReleaseDate__c,
                                  Tense__c,
                                  NodeColor__c
                                  from Welink_Route_Node__c
                                  Where Publish__c = true
                                  order by Order__c desc]){
             if(w.Tense__c=='现在')
             {
                w.NodeColor__c='#00688B';
             } else if(w.Tense__c=='将来')
             {
                w.NodeColor__c='#ccc';
             }
             this.WelinkRNList.add(w);
        }
         //查询当前版本信息                       
         this.CurrentVersion=new Welink_Route_Node__c();
          List<Welink_Route_Node__c> CurrentWelinkRNList=new List<Welink_Route_Node__c>();
         CurrentWelinkRNList=[Select Id,
                                  Name,
                                  Publish__c,
                                  Description__c,
                                  Content__c,
                                  System_Version__c 
                                  from Welink_Route_Node__c
                                  where Tense__c='现在' 
                                  order by Order__c desc];  
          this.CurrentVersion = CurrentWelinkRNList.get(0);
                                                    
 }
}