/*
*Author: Tommy Liu 
*Created on: 2014/1/21 
*Function:转换周日期转换方法
*/ 
public class DateHelper 
{
    public class Week
    {
        public String No{get; set;}
        public Integer Year{get; set;}
        public Integer Order{get; set;}
        public Date WeekStartDate{get; set;}
        public Week LastWeek {get; set;}//紧接着的上衣周，支持双向链表
        public Week NextWeek {get; set;}//紧接着的下一周
        public Date WeekEndDate
        {
            get
            {
                if(this.WeekStartDate != null)
                {
                    return WeekStartDate.addDays(6);
                }
                return null;
            }
        }
        //当前周的标准工作人天
        public Integer StandardWorkDays
        {
            get
            {
                //TODO:需要处理年头和年尾的标准人天
                //TODO: 将来根据节假日数据库来算标准人天
                return 5;
            }
        }
    } 
    
    //获取当前日期所处在的周和上一周列表，下标0表示上周，1为本周
    public static List<Week> WeekThisAndLastFYWeeks()
    {
        Week thisWeek = GetThisFYWeek();
        return new Week[] {thisWeek.LastWeek, thisWeek};
    }
    
    //获取当前日期所处在的周，结果返回this Week, 引用Week.LastWeek表示上周， 引用Week.NextWeek表示下周
    public static Week GetThisFYWeek()
    {
        Week thisWeek = GetFYWeekByDate(Date.today());
        return thisWeek;
    }
    
    //获取指定日期所处的周，例如：2014-1-3， 返回FY2014W1， 2014-1-7，返回FY2014W2， 2013-12-30返回FY2013W53, 引用Week.LastWeek表示上周， 引用Week.NextWeek表示下周
    public static Week GetFYWeekByDate(Date day)
    {
        Integer year = day.year();
        List<Week> weeks = GetFYWeeks(year);
        Week theWeek;
        for(Week w : Weeks)
        {
            if(day <= w.WeekEndDate && day >= w.WeekStartDate)
            {
                theWeek= w;
                break;
            }
        }
        if(theWeek.LastWeek == null)//本周是本年度第一周,找到去年最后一周并将去年的链表尾与今年的链表头关联
        {
        	//system.debug('上一周为空');
            List<Week> lastYearWeeks = GetFYWeeks(year - 1);
            Week lastWeek = lastYearWeeks[lastYearWeeks.size() - 1 ];
            theWeek.LastWeek = lastWeek ;
            lastWeek.NextWeek = theWeek;
        }
        if(theWeek.LastWeek.LastWeek== null)
        {
        	//system.debug('上上周为空');
             List<Week> LastYearWeeks = GetFYWeeks(year - 1);
            Week LastWeek = LastYearWeeks[lastYearWeeks.size() - 2 ];
            theWeek.LastWeek.LastWeek=LastWeek ;
        }
        System.debug(theWeek.LastWeek+'theWeek.LastWeek***********************');
        if(theWeek.NextWeek == null)//本周是本年度最后一周,找到明年第一周并将今年的链表尾与明年的链表头相关联
        {
            List<Week> nextYearWeeks = GetFYWeeks(year + 1);
            Week nexWeek = nextYearWeeks[0];
            theWeek.NextWeek = nexWeek;
            nexWeek.LastWeek= theWeek;
        }
        if(theWeek.NextWeek.NextWeek== null)
        {
        	//system.debug('上上周为空');
             List<Week> nextYearWeeks = GetFYWeeks(year + 1);
            Week nexWeek = nextYearWeeks[1];
            theWeek.NextWeek.NextWeek=nexWeek ;
        }
        
        System.debug(theWeek.NextWeek.NextWeek+'theWeek.NextWeek.NextWeek***********************');
        return theWeek;
    }
    
    //获取指定财年的周列表
    public static List<Week> GetFYWeeks(Integer year)
    {
        List<Week> weekList = new List<Week>();
        Date firstDayOfYear = Date.newInstance(year, 1, 1);
        Date startDayOfWeek = ToStartOfWeek(firstDayOfYear);
        Date endDayOfWeek = startDayOfWeek.addDays(6);
        Integer weekOrder = 1;
        Week lastWeek = null;
        /*
        Week lastWeek2 = new Week();
        lastWeek2.Year=2014;
        lastWeek2.Order = 53;
        lastWeek2.WeekStartDate=date.valueOf('2014-12-29');
        //lastWeek2.WeekEndDate=date.valueOf('2015-01-05');
        lastWeek2.No='FY2014W53';
        */
        while (startDayOfWeek.year() == year || endDayOfWeek.year() == year)
        {
            Week w = new Week();
            w.Year = year;
            w.Order = weekOrder;
            w.WeekStartDate = startDayOfWeek;
            /*修改人：Leo
             *修改内容：将周编号的所属周统一设置为两位数，即FY2014W1改为FY2014W01
             *修改时间：2014-04-16
             */
            string NoOrder = String.valueOf(weekOrder);
            if(NoOrder.length() == 1) NoOrder = '0' + NoOrder;
            w.No = 'FY' + Year + 'W' + NoOrder;
            /****************修改截止****************/
            /*
            if(lastWeek==null)
            {
            	w.LastWeek = lastWeek2;
            }
            else
            {
            
            	w.LastWeek = lastWeek;
            }
            */
            w.LastWeek = lastWeek;
            
            if(lastWeek != null)
            {
                LastWeek.NextWeek = w;
            }
            weekList.add(w);
            startDayOfWeek = startDayOfWeek.addDays(7);
            endDayOfWeek = startDayOfWeek.addDays(6);
            weekOrder ++;
            lastWeek = w;
        }
        System.debug(weekList+'weekList****************');
        return weekList;
    }
    
    //根据指定日期返回周起始日期，我们的文化以周一做为一周的起始天，SFDC标准以周日作为周起始日期，所以需要转化
    //在这个方法返回的结果中addDays(6)即可得到周结束日期
    public static Date ToStartOfWeek(Date day)
    {
        Date startDay = day.addDays(-1);
        startDay = startDay.toStartOfWeek();
        startDay = startDay.addDays(1);
        return startDay;
    }

     /*Author；Leo
     *Date:2015-04-16
     *Description:接收周编号参数，返回Week对象。参数形式FY2015W01
     *Warnning:此方法只作为项目人天中周起始和结束日期赋值方法，不建议通用。
     *         该类中链表的指针链接逻辑需要修改，修改完成后，可将此方法作为通用方法
     *         此方法尚未添加参数验证
     */
    public static Week GetFYWeekByNo(String weekNo)
    {
        if(weekNo.length() != 9) return null;
        Integer weekIndex = Integer.valueOf(weekNo.subString(7));
        Integer year = Integer.valueOf(weekNo.subString(2,6));
        List<Week> weeks = GetFYWeeks(year);
        Week thisWeek = weeks[weekIndex - 1];
        return thisWeek;
    }
}