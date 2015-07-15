trigger CollectionType on mandayanalysis__c(before insert,before update) {

    Set<Id> setProjectId = new Set<Id>();
    List<mandayanalysis__c>  listManday= new List<mandayanalysis__c>();
    for (mandayanalysis__c my: trigger.new ) {
        setProjectId.add(my.relatedproject__c);
    }

    Map<id,SFDC_Projects__c>  mapProject= new Map<id,SFDC_Projects__c>([select id,Contract_Manday__c,Actual_ManDays__c from SFDC_Projects__c where id in:setProjectId]);
    for (mandayanalysis__c my: trigger.new ) 
    {
        if (my.NProjectType__c== '销售'||my.NProjectType__c== '内部') {
            my.Collectiontype__c= '非收费人天';
        }
        if (my.NProjectType__c== '维护' || my.NProjectType__c== '外包') {
            my.Collectiontype__c= '收费人天';
        }
        if (my.NProjectType__c== '实施') {
            if(mapProject.containsKey(my.relatedproject__c))
            {
                SFDC_Projects__c sfdcPro = mapProject.get(my.relatedproject__c) ;
                if (sfdcPro.Actual_ManDays__c>sfdcPro.Contract_Manday__c) {
                    my.Collectiontype__c= '非收费人天';
                }else
                {
                    my.Collectiontype__c= '收费人天';
                }
            }
        }
    }
}