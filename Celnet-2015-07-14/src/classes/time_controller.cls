public without Sharing class time_controller
{
    public String sTime{get;set;}
    public time_controller()
    {
        Date dToday = date.today();
        String sToday = 'Volume'+dToday.day()+', ';
        List<String> list_Months = new List<String>{'January','February','March','April','May','June','July','August',
         'September','October','November','December'};
        sToday += list_Months[dToday.month()-1];
        sToday += ' ';
        sToday += dToday.year();
        sTime = sToday;
    }
}