/*
 * 作者：Ziyue
 * 时间：2013-8-5
 * 功能：一些公用方法
 */
public class UtilityClasses 
{ 
	/*
	 *描述：根据日期获取周
	 *参数dat:日期
	 *返回值：dat所在年周，格式：W10
	*/
    public static String getWeekName(Date dat)
    {
        //输入日期 -1 ，为防止周日的情况
        Date dat2 = dat.addDays(-1);
        //输入日期的周一，来计算是本年第几周
        dat2 = dat.toStartOfWeek().addDays(1);
        Integer i = dat2.dayOfYear();
        double dbl = double.valueOf(i)/7;
        Integer j = Integer.valueOf(dbl);
        //跨年情况
        if(dat2.year() != dat.year())
        {
        	return 'W01';
        }
        if((dbl - j) > 0)
        {
            Integer h = j+1;
            if(h<10)
            {
                return 'W0'+(j+1) ;
            }
            else
            {
                return 'W'+(j+1) ;
            }
            
        }
        else
        {
            if(j<10)
            {
                return 'W0'+j ;
            }
            else
            {
                return 'W'+j ;
            }
        } 
    }
}