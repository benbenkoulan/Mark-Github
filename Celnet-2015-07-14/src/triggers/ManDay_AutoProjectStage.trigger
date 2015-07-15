/**
 * Author:Sunny
 * Des:
 * 1.创建项目人天或修改项目人天的项目时，自动将项目的阶段赋值到项目人天的项目阶段上
 * 2.当创建、更新、删除项目人天时，汇总项目人天汇总及分析
 **/
trigger ManDay_AutoProjectStage on mandayanalysis__c (before insert,before update,after insert,after update,after delete) {
    //#1
    List<ID> list_ProjectIds = new List<ID>();
    if(trigger.isInsert && trigger.isBefore)
    {
        for(mandayanalysis__c manDayAna : trigger.new)
        {
            if(manDayAna.relatedproject__c != null)
            {
                list_ProjectIds.add(manDayAna.relatedproject__c);
            }
        }
        
    }else if(trigger.isBefore && trigger.isUpdate)
    {
        for(mandayanalysis__c manDayAna : trigger.new)
        {
            mandayanalysis__c oldManDayAna = trigger.oldMap.get(manDayAna.Id);
            if(manDayAna.relatedproject__c != oldManDayAna.relatedproject__c)
            {
                list_ProjectIds.add(manDayAna.relatedproject__c);
            }
        }
    }
    if(list_ProjectIds.size() > 0)
    {
        Map<ID,String> map_ProjectStage = New Map<ID,String>();
        for(SFDC_Projects__c pro : [Select Id,Project_Imp_Stage__c,salesprojectsteps__c From SFDC_Projects__c Where Id in: list_ProjectIds])
        {
            map_ProjectStage.put(pro.Id,pro.Project_Imp_Stage__c);
        }
        System.Debug('****');
        System.Debug(map_ProjectStage);
        for(mandayanalysis__c manDayAna : trigger.new)
        {
            if(map_ProjectStage.containsKey(manDayAna.relatedproject__c))
            {
                if(manDayAna.NProjectStage__c == null)
                {
                    manDayAna.NProjectStage__c = map_ProjectStage.get(manDayAna.relatedproject__c);
                }
            }
        }
    }
    //#2
    List<ID> list_StandDateIds = new List<ID>();
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate))
    {
        for(mandayanalysis__c manDayAna : trigger.new)
        {
            if(manDayAna.projectstandardmandy__c != null)
            {
                list_StandDateIds.add(manDayAna.projectstandardmandy__c);
            }
        }
    }else if(trigger.isAfter && trigger.isDelete)
    {
        for(mandayanalysis__c manDayAna : trigger.old)
        {
            if(manDayAna.projectstandardmandy__c != null)
            {
                list_StandDateIds.add(manDayAna.projectstandardmandy__c);
            }
        }
    }
    if(list_StandDateIds.size() > 0)
    {
        List<projectstandardmanday__c> list_StandManday = new List<projectstandardmanday__c>();
        for(projectstandardmanday__c StandManDay : [Select p.salesmanday__c, p.nofeemanday__c, p.maintenancemanday__c, 
                p.internalmanday__c, p.implementationmanday__c, p.holidaymanday__c, p.feemanday__c, p.Id, 
                (Select HolidayStyle__c, NProjectType__c, Collectiontype__c, manday__c From projectstandardmandy__r) 
                From projectstandardmanday__c p Where Id in: list_StandDateIds])
        {
            Decimal dNoFee = 0;//非收费人天数
            Decimal dFee = 0;//收费人天数
            Decimal dInternal = 0;//内部人天数
            Decimal dImplementation = 0;//实施人天数
            Decimal dMaintenance = 0;//维护人天数
            Decimal dSales = 0;//销售人天数
            Decimal dHoliday = 0;//休假人天数
            for(mandayanalysis__c manDayAna : StandManDay.projectstandardmandy__r)
            {
                if(manDayAna.HolidayStyle__c != null)
                {
                    dHoliday += manDayAna.manday__c;
                }
                if(manDayAna.Collectiontype__c == '收费人天')
                {
                    dFee += manDayAna.manday__c;
                }else
                {
                    dNoFee += manDayAna.manday__c;
                }
                if(manDayAna.NProjectType__c == '销售')
                {
                    dSales += manDayAna.manday__c;
                }else if(manDayAna.NProjectType__c == '实施')
                {
                    dImplementation += manDayAna.manday__c;
                }else if(manDayAna.NProjectType__c == '维护')
                {
                    dMaintenance += manDayAna.manday__c;
                }else if(manDayAna.NProjectType__c == '内部')
                {
                    dInternal += manDayAna.manday__c;
                }
            }
            StandManDay.nofeemanday__c = dNoFee;
            StandManDay.feemanday__c = dFee;
            StandManDay.internalmanday__c = dInternal;
            StandManDay.implementationmanday__c = dImplementation;
            StandManDay.maintenancemanday__c = dMaintenance;
            StandManDay.salesmanday__c = dSales;
            StandManDay.holidaymanday__c = dHoliday;
            list_StandManday.add(StandManDay);
        }
        update list_StandManday;
    }
    
}