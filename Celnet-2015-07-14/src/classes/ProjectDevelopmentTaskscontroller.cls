//author:bill
//date:2014-6-6
//日历控制类
//(暂时保留)
global class ProjectDevelopmentTaskscontroller 
{
    public PersonProjectSchedule__c user{get;set;}
    public ProjectDevelopmentTaskscontroller()
    {
        user = new PersonProjectSchedule__c();
        user.developer__c = UserInfo.getUserId();
    }
    //bill 获取时间段的总任务
    webservice static String getProidTasks(Datetime startTime,Datetime endTime,String dateType,String userId)
    {
        return getDiffTask(startTime,endTime,dateType,userId);
    }
    
    //查询不同类型的任务
    public static String getDiffTask(Datetime start,Datetime endt,String dateType,String userId)
    {
        Datetime startTime = Datetime.valueOf(start);
        Datetime endTime = Datetime.valueOf(endt);
        String strEvents = '[';
        if(dateType == 'month'){
            //遍历当前用户的任务数据，拼接成JSON类型的字符串
            list<PersonProjectSchedule__c> list_Schedule = [select developer__r.LastName,developer__r.FirstName,Project__r.ProColor__c,Project__r.Name,type__c,
                        endDateTime__c,startDateTime__c from PersonProjectSchedule__c 
                        where Developer__c = : userId and startDateTime__c != null and endDateTime__c != null
                        and ((startDateTime__c >= :startTime and startDateTime__c <: endTime)
                        OR (endDateTime__c >= :startTime and endDateTime__c <: endTime)
                        OR (startDateTime__c < :startTime AND endDateTime__c >: endTime))];
            Integer i = 1;
            for(PersonProjectSchedule__c t : list_Schedule)
            {
                String bg = t.Project__r.ProColor__c == null?'#ffffff':t.Project__r.ProColor__c;//根据项目的颜色
                
                strEvents += '{Id:\''+t.Id+'\',title:\''+t.Project__r.Name+'('+t.type__c+'——'
                        +(t.developer__r.LastName==null?'':t.developer__r.LastName)
                        +(t.developer__r.FirstName==null?'':t.developer__r.FirstName)
                        +')\',start:new Date('
                        +t.startDateTime__c.year()+','
                        +(t.startDateTime__c.month()-1)+','
                        +t.startDateTime__c.day()+','
                        +t.startDateTime__c.hour()+','
                        +t.startDateTime__c.minute()+'),'
                        +'end:new Date('
                        +t.endDateTime__c.year()+','
                        +(t.endDateTime__c.month()-1)+','
                        +t.endDateTime__c.day()+','
                        +t.endDateTime__c.hour()+','
                        +t.endDateTime__c.minute()
                        +'),allDay: false,backgroundColor:\'' + bg + '\',textColor:\'black\'}';
                        
                if(i!=list_Schedule.size())
                {
                    strEvents += ',';
                }
                i++;
            }           
        }else{
            //遍历当前用户的任务数据，拼接成JSON类型的字符串
            list<Project_Development_Task__c> list_tasks = [select Developer__c,Project__r.ProColor__c,Project__r.Name,
                        Task_Status__c,EndDate__c,StartDate__c from Project_Development_Task__c 
                        where Developer__c = :userId and StartDate__c != null and EndDate__c != null
                        and ((StartDate__c >= :startTime and StartDate__c <: endTime)
                        OR (EndDate__c >= :startTime and EndDate__c <: endTime)
                        OR (StartDate__c < :startTime AND EndDate__c >: endTime))];
            Integer i = 1;
            for(Project_Development_Task__c t : list_tasks)
            {
                String bg = t.Project__r.ProColor__c == null?'#ffffff':t.Project__r.ProColor__c;//根据项目的颜色
                
                strEvents += '{Id:\''+t.Id+'\',title:\''+t.Project__r.Name+'('+t.Task_Status__c+')\',start:new Date('
                        +t.StartDate__c.year()+','
                        +(t.StartDate__c.month()-1)+','
                        +t.StartDate__c.day()+','
                        +t.StartDate__c.hour()+','
                        +t.StartDate__c.minute()+'),'
                        +'end:new Date('
                        +t.EndDate__c.year()+','
                        +(t.EndDate__c.month()-1)+','
                        +t.EndDate__c.day()+','
                        +t.EndDate__c.hour()+','
                        +t.EndDate__c.minute()
                        +'),allDay: false,backgroundColor:\'' + bg + '\',textColor:\'black\'}';
                if(i!=list_tasks.size())
                {
                    strEvents += ',';
                }
                i++;
            }
        }
        strEvents += ']';
        return strEvents;
    }
    
    //当一个事件改变大小时，调用，更新对应的任务
    webservice static void updateTaskReSize(String eventId,Integer eventMinute)
    {
        list<Project_Development_Task__c> list_task = [select StartDate__c,EndDate__c from Project_Development_Task__c where Id = :eventId];
        if(list_task != null && list_task.size()>0)
        {
            Project_Development_Task__c task = list_task[0];
            if(task.EndDate__c != null)
            {
                task.EndDate__c = task.EndDate__c.addMinutes(eventMinute);
                update task;
            }
        }else{
            list<PersonProjectSchedule__c> list_Schedule = [select Id, endDateTime__c,startDateTime__c from PersonProjectSchedule__c where Id = :eventId];
            if(list_Schedule != null && list_Schedule.size()>0 && list_Schedule[0].endDateTime__c != null)
            {
                system.debug('偏移的时间'+eventMinute);
                PersonProjectSchedule__c schedule = list_Schedule[0];
                schedule.endDateTime__c = schedule.endDateTime__c.addMinutes(eventMinute);
                update schedule;    
            }   
        }
    }
    //当一个事件移动时，调用，更新对应的任务
    webservice static String updateTaskDrop(String eventId,Integer eventDays,Integer eventMinute)
    {
        
        list<Project_Development_Task__c> list_task = [select StartDate__c,EndDate__c from Project_Development_Task__c where Id = :eventId];
        if(list_task != null && list_task.size()>0)
        {
            Project_Development_Task__c task = list_task[0];            
            if(task.StartDate__c != null && task.EndDate__c != null)
            {
                task.StartDate__c = task.StartDate__c.addDays(eventDays);
                task.StartDate__c = task.StartDate__c.addMinutes(eventMinute);
                task.EndDate__c = task.EndDate__c.addDays(eventDays);
                task.EndDate__c = task.EndDate__c.addMinutes(eventMinute);
                update task;
            }
            return '1';
        }else{
            list<PersonProjectSchedule__c> list_Schedule = [select Id, endDateTime__c,startDateTime__c from PersonProjectSchedule__c where Id = :eventId];
            if(list_Schedule != null && list_Schedule.size()>0)
            {
                PersonProjectSchedule__c schedule = list_Schedule[0];
                schedule.startDateTime__c = schedule.startDateTime__c.addDays(eventDays);
                schedule.startDateTime__c = schedule.startDateTime__c.addMinutes(eventMinute);
                schedule.endDateTime__c = schedule.endDateTime__c.addDays(eventDays);
                schedule.endDateTime__c = schedule.endDateTime__c.addMinutes(eventMinute);
                update schedule;    
            }   
            return '1'; 
        }
    }
}