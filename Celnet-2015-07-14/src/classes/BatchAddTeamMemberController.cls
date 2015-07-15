public class BatchAddTeamMemberController{
    public List<TeamMember> teamMemberList{set;get;}//永远用户选择
    public SFDC_Projects__c projectInfo{set;get;}//用于显示项目信息 
    public Boolean isLocked{set;get;}//用于锁定输入框部分的字段和按钮
    public Boolean showUserInfo{set;get;}//用于锁定输入框部分的字段和按钮
    public Boolean showProcessPart{set;get;}//用于锁定输入框部分的字段和按钮
    Id proId = null; //项目ID，在保存和查询项目信息时使用
    public string inputName{set;get;}//输入的名字，根据输入名字进行模糊查询
    public string inputRole{set;get;}//输入的角色，根据输入的角色进行模糊查询
    public string inputPosition{set;get;}//输入的职位，根据输入的职位进行模糊查询
    public list<SelectOption>   nitemroleOptions;// 项目角色  选项列表 
    public list<SelectOption>   nMemberTypeOptions;// 成员类型  选项列表 
    public List<ItemTeamMemberCls> teamMList{set;get;}
    
    //构造方法，当点击按钮后，页面加载时会执行
    public BatchAddTeamMemberController(ApexPages.StandardController controller) {
         proId = ApexPages.currentPage().getParameters().get('proId');
         init();
    }
    //初始化
    private void init(){
       projectInfo =[Select id,name, project_StartDate__c,SFDCforecast__c,ProjectProperties__c,Project_Estimate_EndDate__c,Project_Actual_EndDate__c,TimePlan__c,State__c,TotalExpense__c,Project_Type__c,Account__c,Contact__c,DeveloperInvolveDate__c,DMprice__c,DCprice__c, Amount__c  from SFDC_Projects__c where id =:proId];
        getTeamMemberList();
        showUserInfo = true;
        showProcessPart = false;       
        isLocked = false;
    
    }
    //此方法用来查询用户，并且支持根据用户输入的内容来进行模糊查询
    private void getTeamMemberList(){
          teamMemberList = new List<TeamMember>();  
          List<User> userList = new List<User>();
          Boolean inputNull = true;
             String SQL = 'select id,name,Title,UserRole.name,Department,MobilePhone,Email from User ';
             inputName =  LRTrim(inputName);
             inputRole = LRTrim(inputRole);
             inputPosition = LRTrim(inputPosition );
              if(inputName!=null && inputName != ''){
                    inputNull =false;
                    SQL += ' where name like \'%' + inputName + '%\'';
              }
              else if(inputRole!=null && inputRole!= ''){          
                  if(inputNull ){
                       SQL += ' where UserRole.name like \'%' + inputRole+ '%\'';
                    }else{
                       SQL += ' AND UserRole.name like \'%' + inputRole+ '%\'';
                    }                 
                inputNull = false;
              }
               else if(inputPosition!=null && inputPosition!= ''){          
                  if(inputNull ){
                       SQL += ' where Title like \'%' + inputPosition+ '%\'';
                    }else{
                       SQL += ' AND  Title like \'%' + inputPosition+ '%\'';
                    }                 
              }
              SQL += ' order by Name ASC';
           System.debug('SQL =====================================' + SQL);                 
           userList = Database.query(SQL);    
          for(User un : userList){
              TeamMember tm= new TeamMember();
              tm.isSelected =false;
              tm.member = un;
              teamMemberList.add(tm);
          }  
     }
    //当点击下一步的时候，把已经选择的用户 封装到list里，然后锁定上面的页面输入框，如果所选用户为空，则返回错误消息
    public PageReference nextSetp(){   
       isLocked = true;
       Boolean isChoosed = false;      
       showProcessPart = true;
       showUserInfo= false;
       //getNitemroleOptions();
       teamMList= new List<ItemTeamMemberCls>();  
      // getNitemroleOptions();    
       System.debug('teamMemberList size =====' +teamMemberList.size());
       for(TeamMember tm: teamMemberList){
            if(tm.isSelected){
                System.debug('tm.isSelected =====' +tm.isSelected);
                isChoosed  = true;
                ObjectItemTeamMember__c TMobj = new  ObjectItemTeamMember__c();
                ItemTeamMemberCls ITMCls= new ItemTeamMemberCls();
                TMobj.Nitemmenber__c= tm.member.id; 
                TMobj.Nitem__c = proId;
                ITMCls.userName =  tm.member.name;
                ITMCls.itemMember = TMobj;                        
                teamMList.add(ITMCls);
            }
       }

      if(isChoosed ==false){
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, '请至少选中一个之后再进行下一步操作！');  
            ApexPages.addMessage(msg);
             isLocked = false;
              showUserInfo= true;
             // showProcessPart = false;
            return null;
      }else{
        isLocked = true;
         
        return null;
       //return new ApexPages.PageReference('/Apex/ProcessTeamMember');
    }
    }
    //上一步，当点击上一步后，返回到上一步
     public PageReference lastSetp(){  
       isLocked = false;    
       showProcessPart = false;
       showUserInfo= true;
      return null;
     }
    
    //当点击保存按钮后将调用如下方法保存数据
    public PageReference saveRecord(){
      if(teamMList.size()>0){
         try {
         List<ObjectItemTeamMember__c> insertOITMList= new  List<ObjectItemTeamMember__c>();
         for(ItemTeamMemberCls tempIMCls:teamMList){
         insertOITMList.add(tempIMCls.itemMember);        
         }
            if(insertOITMList.size()>0) insert insertOITMList;
           return new ApexPages.PageReference('/'+proId );
        }catch(DMLException e){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, '保存数据发生错误，请联系系统管理人员！具体信息');  
            ApexPages.addMessage(msg);
            return null;
        }     
      }else{
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, '没有添加任何项目成员！');  
            ApexPages.addMessage(msg);
            return null;
      }
    
    
    }
    
    //当用户点击搜索按钮后，调用此方法进行用户过滤
      public PageReference searchUser(){
       getTeamMemberList();
      // showUserInfo= false;
       return null;
      }
      
     //此方法永远去掉字符串的前后空格
     private string LRTrim(string str){
        if(str == null)
        return null;
       for(integer i = 0;i <str.length();i++ ){
          if(str.startsWith(' ')){
              str=str.removeStart(' '); 
           }else{
           break;
           }        
       }     
      if(str.trim()!= null) return str.trim();
      return null;
     } 
     //获取 成员类型( NMemberType__c) 选项列表值   
       public  list<SelectOption> getNMemberTypeOptions(){
          list<SelectOption> options = new list<SelectOption>();

         Schema.DescribeFieldResult ObjectItemTeamMember= ObjectItemTeamMember__c.NMemberType__c.getDescribe();
          List<Schema.PicklistEntry> tempValues = ObjectItemTeamMember.getPicklistValues();
          
          for (Schema.PicklistEntry a : tempValues )
          { 
             options.add(new SelectOption(a.getLabel(), a.getValue())); 
          }
          return options;
         }
   
   // 获取项目角色选项列表
   
       public  list<SelectOption> getNitemroleOptions(){
          list<SelectOption> options = new list<SelectOption>();
         Schema.DescribeFieldResult ObjectItemTeamMember= ObjectItemTeamMember__c.Nitemrole__c.getDescribe();
          List<Schema.PicklistEntry> tempValues = ObjectItemTeamMember.getPicklistValues();
          
          for (Schema.PicklistEntry a : tempValues )
          { 
             options.add(new SelectOption(a.getLabel(), a.getValue())); 
          }
          return options;
         }
     
     
    //封装class 为第一步选择User list 使用。
    class TeamMember{
        public Boolean isSelected{set;get;}
        public User member {set;get;}
    }
    class ItemTeamMemberCls{
        public String userName{set;get;}
        public ObjectItemTeamMember__c itemMember{set;get;}
    }

}