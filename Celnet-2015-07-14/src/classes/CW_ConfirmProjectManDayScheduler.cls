/*
*author:markli
*date:2015-02-26
*function:定时向项目经理发消息确认人天 
*System.schedule('Wechat Confirm ProjectManday','0 00 20 ? * FRI-SUN', new CW_ConfirmProjectManDayScheduler());
**/
global class CW_ConfirmProjectManDayScheduler implements Schedulable 
{
	public static final string CorpId = 'wxecd61a327f09efc9';
	public static final string GroupName = 'Salesforce';
	public static final string UserIds = 'Mark|Scott|Sunny|Jack|kevin|Mars|Bill|Denny|David|Michael'; 
	
	global void execute(SchedulableContext sc)
	{ 
		confirm();	
	}
	
	@Future(callout=true)
	global static void confirm()
	{
		WEQYCalloutService wcs = new WEQYCalloutService(CorpId , GroupName);
		
		WEQYEntity.SendNewsMsgRequest msg = new WEQYEntity.SendNewsMsgRequest();
		msg.touser = UserIds;
		msg.msgtype = 'news';
		msg.agentid = '3';

		WEQYEntity.News news = new WEQYEntity.News();
		List<WEQYEntity.NewsArticle> articles = new List<WEQYEntity.NewsArticle>();
		WEQYEntity.NewsArticle art = new WEQYEntity.NewsArticle();
		art.description = '快乐工作棒棒哒!';
		art.title ='亲!请确认下项目人天!';
		art.url = 'http://www.celnet.com.cn/CelnetWelink/SSOInitPage.aspx?CorpID=wxecd61a327f09efc9&AgentID=3&Resource=/apex/CW_ProjectManDayConfirm';
		art.picurl = 'https://c.ap1.content.force.com/servlet/servlet.ImageServer?id=01590000008GaBK&oid=00D900000011gkK&lastMod=1424946591000';
		articles.add(art);
		news.articles = articles;
		msg.news = news;

		wcs.SendMsg(msg);	
	}
}