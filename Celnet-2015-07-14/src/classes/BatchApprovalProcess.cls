/*
 *Author:MichaelMi
 *CreatedDate:2011-11-21
 *Function:batch approval ，涉及到的对象：ProcessInstance,ProcessWorkitemRequest，ProcessInstanceWorkitem
*/
global with sharing class BatchApprovalProcess {
	
	webservice static String SubmitApproval(String ids){
		system.debug('**********ids********'+ids);
		ids = ids.substring(1, ids.length()-1);
		String result = 'ok';
		if(ids == '' || ids == null){
			return 'error';
		}
		//把从视图上勾选的记录的ID字符串分割成List
		List<String> allIds = ids.split(',');
		system.debug('***********allIds**********'+allIds);
		set<String> c = new set<String>();
		for(String s : allIds){
			c.add(s);
		}
		//ProcessInstance每一条待审批的记录都会对应一条ProcessInstance记录，外键TargetObjectId
		Set<ID> piIds = new Set<ID>();
		//通过选中记录的Id查询出对应的ProcessInstance集合，把ProcessInstance的ID添加到集合中。
		for(ProcessInstance pi : [Select p.Id From ProcessInstance p where p.TargetObjectId IN:c]){
			piIds.add(pi.Id);
		}
		system.debug('*************piIds***********'+piIds);
		//待审批的集合
		List<Approval.ProcessWorkitemRequest> piwList = new List<Approval.ProcessWorkitemRequest>();
		//根据ProcessInstanceID集合查询出ProcessInstanceWorkitem
		for(ProcessInstanceWorkitem piw : [Select p.Id From ProcessInstanceWorkitem p where p.ProcessInstanceId IN:piIds]){
			//创建ProcessWorkitemRequest
			Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
			req.setComments('Approving request.');
			//设置Approve
        	req.setAction('Approve');
        	//把workitem的ID
        	req.setWorkitemId(piw.Id);
        	piwList.add(req);
		}
		system.debug('****************piwList*************'+piwList);
		//执行批量审批
		Approval.ProcessResult[] result2 =  Approval.process(piwList);
		system.debug('****************result2*************'+result2);
		for(Approval.ProcessResult pr : result2){
			if(!pr.isSuccess()){
				for(Database.Error e : pr.getErrors()){
					result += e.Message;
				}
			}
		}
		return result;
	}

}