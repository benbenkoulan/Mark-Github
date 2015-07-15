public class WeeklyTargetTaskGenerator{
    
    @future
    public static void generateTasks(List<String> weeklyTargetIds){
        
        List<Task> newTasks = new List<Task>();
        
        List<WeeklyTarget__c> wtList = [Select id,
                                            Name,
                                            OwnerId,
                                            Enddate__c,
                                            Description__c,
                                            Goalachievement__c,
                                            Status__c,
                                            Weeklyname__c,
                                            Weeklyname__r.Belongs_Week__c
                                            From WeeklyTarget__c 
                                            Where Id IN: weeklyTargetIds];
                                            
        for(WeeklyTarget__c wt : wtList){
            if(wt.Status__c == '开启' && wt.Goalachievement__c != 100){
                Date dueDate = (wt.Enddate__c != null?wt.Enddate__c:Date.today().addDays(7).toStartOfWeek().addDays(-1));
                Task t = new Task(
                    OwnerId = wt.OwnerId,
                    Subject = '周计划 ' + wt.Name,
                    ActivityDate = dueDate,
                    WhatId = wt.Weeklyname__c,
                    Status = '未开始',
                    Description = wt.Description__c
                );
                newTasks.add(t);
            }
        }
        
        insert newTasks;
    }
}