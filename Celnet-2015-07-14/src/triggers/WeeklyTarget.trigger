/**
 * Author: Steven
 * Date: 2015-4-3
 * Description: 周计划工作目标生成任务
 */
trigger WeeklyTarget on WeeklyTarget__c (after insert) {
    List<String> wtIds = new List<String>();
    
    for(WeeklyTarget__c wt : trigger.new){
        wtIds.add(wt.Id);
    }
    
    WeeklyTargetTaskGenerator.generateTasks(wtIds);
}