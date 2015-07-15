/*
*Author:Tommy at 2013-12-30
*Function1: 创建按钮和VF页面实现OPP转化，页面让用户选择是否是新建项目还是关联到已有的项目。
*/
public class ConvertToProjectController 
{
	private ID oppId;
	public Opportunity Opp {get; set;}
	public ID OldProjectId {get; set;}
	public String ConvertType {get; set;}
	public Boolean IsError {get; set;}
	public Boolean IsShowProject 
	{
		get
		{
			if(this.ConvertType == 'AttachToOldProject')
			{
				return true;
			}
			return false;
		}
	}

	public ConvertToProjectController(ApexPages.StandardController controller)
    {
		this.IsError = false;
      	this.oppId = ApexPages.currentPage().getParameters().get('id');
     	this.Opp = [Select ID, Name, TargetProject__c, Type, AccountId From Opportunity Where Id =: this.oppId];
       	if(this.Opp.TargetProject__c != null)
       	{
   	   		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '此业务机会已经被转化，您不能再次进行转化，点击“取消”按钮返回业务机会详细信息表单');         
       		ApexPages.addMessage(msg);
       		this.IsError = true;
       		return;
       	}
       	else
       	{
       		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, '请在下面选择一个转化方式，传化为一个全新的项目或将此业务机会附加到一个已有的项目。');         
       		ApexPages.addMessage(msg);
       		return;
       	}
    }
    
    public void UpdateMessage()
    {
   		if(this.ConvertType == 'NewProject')
	   	{
	   		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, '您已经选择“转化为一个全新的项目”，点击“转化”按钮将产生一个全新的项目。');         
       		ApexPages.addMessage(msg);
	   	}
	   	else if(this.ConvertType == 'AttachToOldProject')
	   	{
	   		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, '您已经选择“附加到已有的项目”，请在选择一个已有的项目后，点击“转化”按钮，系统会将此业务机会附加到您指定的项目。');         
       		ApexPages.addMessage(msg);
	   	}
    }
    
    public PageReference Convert()
    {
    	SFDC_Projects__c proj;
    	try
    	{
	    	if(this.ConvertType == 'NewProject')
	    	{
	    		proj = new SFDC_Projects__c();
	    		proj.Opportunity__c = this.oppId;//最后转化的业务机会
	    		proj.Name = this.Opp.Name;
	    		proj.Account__c = this.Opp.AccountId;
	    		proj.Project_Type__c = '销售';
	    		insert proj;
	    		this.Opp.TargetProject__c = proj.Id;
	    		update this.Opp;
	    	}
	    	else if(this.ConvertType == 'AttachToOldProject')
	    	{
	    		if(this.Opp.TargetProject__c == null)
	    		{
	    			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '您必须指定一个已有的项目才能进行转化');         
       				ApexPages.addMessage(msg);
	    			return null;
	    		}
	    		this.OldProjectId = this.Opp.TargetProject__c;//在页面前端已经由用户选择已存在的Project
	    		proj = new SFDC_Projects__c(ID = this.OldProjectId);
	    		proj.Opportunity__c = this.oppId;//最后转化的业务机会
	    		proj.Project_Type__c = '销售';
	    		update proj;
	    		update this.Opp;
	    	}
	    	else
	    	{
	    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '请选择一个转化类型');         
       			ApexPages.addMessage(msg);
	    		return null;
	    	}
    	}
    	catch (Exception e)
    	{
    		String emsg = e.getMessage();
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '发生未预知的系统错误：' + emsg);         
       		ApexPages.addMessage(msg);
       		this.IsError = true;
       		return null;
    	}
    	//跳转到转化的目的项目
    	PageReference redirectPag = new PageReference('https://ap1.salesforce.com/' + proj.ID);//TODO:调成动态的
        redirectPag.setRedirect(true);
        return redirectPag; 
    }
    
    public PageReference Cancel()
    {
    	PageReference redirectPag = new PageReference('https://ap1.salesforce.com/' + this.oppId);//TODO:调成动态的
        redirectPag.setRedirect(true);
        return redirectPag; 
    }
}