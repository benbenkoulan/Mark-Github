public class CW_WeekPlanTeamController 
{
  public List<User> team{get;set;}
  public Map<Id, Integer> currentweekmap{get;set;}
  public Map<Id, Integer> lastweekmap{get;set;}
  public Map<Id, Integer> nextweekmap{get;set;}
  
  public CW_WeekPlanTeamController()
  {          
        team=getUserTeam();
        
        Date currentDay = Date.today();
        DateHelper.Week currentWeek = DateHelper.GetFYWeekByDate(currentDay);
        DateHelper.Week lastWeek = currentWeek.LastWeek;
        DateHelper.Week nextWeek = currentWeek.NextWeek;
        system.debug(lastWeek.No);
        List<Id> userIds = new List<Id>();
        for(User ur:team){
            userIds.add(ur.Id);
        }
        List<WeeklyTarget__c>  cWeeklyTargetList = [Select Id, OwnerId From WeeklyTarget__c Where OwnerId IN: userIds and Weeklyname__r.Belongs_Week__c=:currentWeek.No];
        List<WeeklyTarget__c>  lWeeklyTargetList = [Select Id, OwnerId From WeeklyTarget__c Where OwnerId IN: userIds and Weeklyname__r.Belongs_Week__c=:lastWeek.No];
        List<WeeklyTarget__c>  nWeeklyTargetList = [Select Id, OwnerId From WeeklyTarget__c Where OwnerId IN: userIds and Weeklyname__r.Belongs_Week__c=:nextWeek.No];
        lastweekmap = new Map<Id, Integer>();
        currentweekmap = new Map<Id, Integer>();
        nextweekmap = new Map<Id, Integer>();
        
        // 将没有工作目标的用户的工作目标数置为0
         for(User ur:team){
            //userIds.add(ur.Id);
            if(currentweekmap.get(ur.Id) == null){
                currentweekmap.put(ur.Id, 0);
            }
            if(lastweekmap.get(ur.Id) == null){
                lastweekmap.put(ur.Id, 0);
            }
            if(nextweekmap.get(ur.Id) == null){
                nextweekmap.put(ur.Id, 0);
            }
         }
        
        
            for(WeeklyTarget__c ctc : cWeeklyTargetList){ 
                Integer currentUserCount = currentweekmap.get(ctc.OwnerId) == null?1:currentweekmap.get(ctc.OwnerId) + 1;
                currentweekmap.put(ctc.OwnerId,currentUserCount);
            }
        
         
         
            for(WeeklyTarget__c ltc : lWeeklyTargetList){ 
                Integer lastUserCount = lastweekmap.get(ltc.OwnerId) == null?1:lastweekmap.get(ltc.OwnerId) + 1;
                lastweekmap.put(ltc.OwnerId,lastUserCount);
            }
       
            for(WeeklyTarget__c ntc : nWeeklyTargetList){ 
                Integer nextUserCount = nextweekmap.get(ntc.OwnerId) == null?1:nextweekmap.get(ntc.OwnerId) + 1;
                nextweekmap.put(ntc.OwnerId,nextUserCount);
            }
            
       

  } 
  
  public  List<User> getUserTeam()
  {
    User user =new User();
    user.Id = UserInfo.getUserId();
    List<User> usersteam= getUserTeam(user);
    return usersteam;
   
  }
  
  public  List<User> getUserTeam(User user){
        system.debug(user.Id);
                List<User> userteam= [Select Id,
                                   ManagerId,
                                   Name   
                                   From User
                                   Where ManagerId =: user.Id ];
                                   
             if(userteam.size()>0){
              List<User> usersteam2=new List<User>();
                  for(User user2:userteam){
                     
                      usersteam2.addAll(getUserTeam(user2));
                      
                  }
                  userteam.addAll(usersteam2);
             }
             if(userteam.size()<=0){
                 return userteam;
             }
           return userteam;        
  }
  
    
 }