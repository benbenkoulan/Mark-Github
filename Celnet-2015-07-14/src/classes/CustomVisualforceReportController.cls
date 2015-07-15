/*Author:Leo
 *Date:2015-02-11
 *Function:按钮跳转Visualforce Page
 */
public class CustomVisualforceReportController
{
	public CustomVisualforceReportController()
	{
		
	}

	public PageReference salesPerformanceReport()
	{
    	return new PageReference('/apex/SalesPerformanceReport');
    }
}