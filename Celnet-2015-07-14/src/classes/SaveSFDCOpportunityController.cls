/*
 * Author: Steven
 * Date: 2014-1-21
 * Description: 录入业务机会, 联系人和业务机会信息
 */
public class SaveSFDCOpportunityController 
{
    public Account account{get;set;}
    public Contact contact{get;set;}
    public Opportunity opportunity{get;set;}
    
    public SaveSFDCOpportunityController(ApexPages.StandardController controller)
    {
        account = new Account();
        contact = new Contact();
        opportunity = new Opportunity();
    }
    
    public PageReference save()
    {
        try
        {
            this.account.SalesForce_salesmember__c = this.opportunity.SalesForce_salesmember__c;
            insert this.account;
            this.contact.AccountId = this.account.Id;
            this.opportunity.AccountId = this.account.Id;
            insert this.contact;
            insert this.opportunity;
        }
        catch(Exception e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '插入客户出错, 请重试或联系管理员');
            ApexPages.addMessage(msg);
            return null;
        }
        
        PageReference redirectPag = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id);
        redirectPag.setRedirect(true);
        return redirectPag;
    }
    
    public PageReference cancel()
    {
        PageReference redirectPag = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/home/home.jsp');
        redirectPag.setRedirect(true);
        return redirectPag;
    }
}