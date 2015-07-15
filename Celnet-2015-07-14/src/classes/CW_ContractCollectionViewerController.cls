/**
 * Author: Steven Ke
 * Date: 2015-3-10
 * Description: 收款信息展示 用于移动端（微信和Salesforce1）
 */
public class CW_ContractCollectionViewerController{
    public CW_ContractCollectionViewerController(){
        
    }
    
    @RemoteAction
    public static List<ContractWrapper> initializeContracts(){
        List<ContractWrapper> allCwList = new List<ContractWrapper>();
        
        List<Contract> contractList = [Select Id,
                                            Name,
                                            ContractNumber,
                                            Account.Name,
                                            ContractType__c,
                                            Contract_Status_Yu1__c,
                                            ContractSignDate__c,
                                            projectcontract__r.Name,
                                            Paid_Amount__c,
                                            No_Paid_Amount__c,
                                            SignedCompany__c,
                                            Segmentation__c,
                                            Field2__c,
                                            Field14__c,
                                            ContractRegion__c,
                                            SalesForce_salesmember__r.Name,
                                            Amount__c,
                                            Lictype__c,
                                            Field12__c,
                                            ProductAmount__c,
                                            ServerPay__c,
                                            OwnerId,
                                            (Select Id, 
                                                contract__r.Name,
                                                contract__r.OwnerId,
                                                Account__r.Name,
                                                projectrelated__r.Name,
                                                receiptype__c,
                                                Name,
                                                Amount__c,
                                                Obtain__c,
                                                ReceiveCompany__c,
                                                Expectedinvoicedate__c,
                                                invoicestatus__c,
                                                Invoiceno__c,
                                                Expectedcollectiondate__c,
                                                collectionstatus__c,
                                                CollectionQuarter__c
                                               From contractname__r)
                                         From Contract
                                         Where ContractSignDate__c >=: Date.today().addMonths(-3)
                                         And ContractSignDate__c <=: Date.today().addMonths(3)
                                         And ( Contract_Status_Yu1__c = '批准过程中' Or Contract_Status_Yu1__c = '已启用')
                                         Order by ContractSignDate__c desc ];
        
        for(Contract con : contractList){
            allCwList.add(new ContractWrapper(con));
        }
        
        return allCwList;
    }
    
    @RemoteAction
    public static CollectionViewerWrapper initializeCollections(){
        List<CollectionWrapper> allCwList = new List<CollectionWrapper>();
        List<CollectionWrapper> myCwList = new List<CollectionWrapper>();
        
        List<Collection__c> cList = [Select Id, 
                                        contract__r.Name,
                                        contract__r.OwnerId,
                                        Account__r.Name,
                                        projectrelated__r.Name,
                                        receiptype__c,
                                        Name,
                                        Amount__c,
                                        Obtain__c,
                                        ReceiveCompany__c,
                                        Expectedinvoicedate__c,
                                        invoicestatus__c,
                                        Invoiceno__c,
                                        Expectedcollectiondate__c,
                                        collectionstatus__c,
                                        CollectionQuarter__c
                                       From Collection__c
                                       Where Expectedcollectiondate__c >: Date.today().addMonths(-3)
                                       And Expectedcollectiondate__c <: Date.today().addMonths(3) 
                                       Order by Expectedcollectiondate__c desc ];
        
        String currentUserId = UserInfo.getUserId();
        
        for(Collection__c cc : cList){
            CollectionWrapper cw = new CollectionWrapper(cc);
            allCwList.add(cw);
            if(cc.contract__r.OwnerId == currentUserId){
                myCwList.add(cw);
            }
        }
        
        CollectionViewerWrapper cvw = new CollectionViewerWrapper();
        cvw.mycollections = myCwList;
        cvw.allcollections = allCwList;
        
        return cvw;
    }
    
    class ContractViewerWrapper{
        public List<ContractWrapper> mycontracts{get;set;}
        public List<ContractWrapper> allcontracts{get;set;}
    }
    
    class ContractWrapper{
        public Contract sfcontract{get;set;}
        public String contractsigndate{get;set;}
        public List<CollectionWrapper> collections{get;set;}
        
        public ContractWrapper(Contract con){
            this.sfcontract = con;
            this.contractsigndate = convertApexDate(con.ContractSignDate__c);
            this.collections = new List<CollectionWrapper>();
            
            for(Collection__c c : con.contractname__r){
                this.collections.add(new CollectionWrapper(c));
            }
        }
        
        public String convertApexDate(Date apexDate){
            if(apexDate == null){
                return '';
            } else {
                return apexDate.year() + '-' + apexDate.month() + '-' + apexDate.day();
            }
        }
    }
    
    class CollectionViewerWrapper{
        public List<CollectionWrapper> mycollections{get;set;}
        public List<CollectionWrapper> allcollections{get;set;}
    }
    
    class CollectionWrapper{
        public Collection__c collection{get;set;}
        public String expectedcollectiondate{get;set;}
        public String expectedinvoicedate{get;set;}
        public CollectionWrapper(Collection__c co){
            this.collection = co;
            this.expectedcollectiondate = convertApexDate(co.Expectedcollectiondate__c);
            this.expectedinvoicedate = convertApexDate(co.Expectedinvoicedate__c);
        }
        
        public String convertApexDate(Date apexDate){
            if(apexDate == null){
                return '';
            } else {
                return apexDate.year() + '-' + apexDate.month() + '-' + apexDate.day();
            }
        }
    }
}