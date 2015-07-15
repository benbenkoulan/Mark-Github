global class CelnetMailServerInboundEmailHandler implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        //system.debug('Email info:'+email);
        //system.debug('Email envelope:'+envelope);
        String mailTextBody = email.plainTextBody;
        String mailHtmlBody = email.htmlBody;
        String mailFromAddress = email.replyTo;
        String mailSubject = '电子邮件：'+email.subject;
        List<String> list_mailToAddress = email.toAddresses;
        system.debug('Text Body:'+mailTextBody);
        system.debug('Html Body:'+mailHtmlBody );
//        Contact co = new Contact();
//        co.lastname='s';
//        co.firstname='d';
//        co.Sunnytest1__c = mailHtmlBody ;
//        co.Sunnytest2__c = mailHtmlBody ;
//        insert co;
        system.debug('From Address:'+mailFromAddress);
        system.debug('Subject:'+mailSubject);
        system.debug('To Address:'+list_mailToAddress);
        List<Messaging.InboundEmail.BinaryAttachment> lba = email.binaryAttachments;
        
        //发件人为联系人，找到联系人
        List<Contact> list_Contact = [Select Id,Name From Contact Where Email =: mailFromAddress];
        if(list_Contact == null || list_Contact.size() == 0) return result;
        //找到收件人对应的系统用户
        Map<String,User> map_User = new Map<String,User>();
        for(User U : [Select Id,Name,Email From User Where Email in: list_mailToAddress])
        {
            map_User.put(U.Email , U);
        }
        List<Task> list_task = new List<Task>();
        for(String toAddress : list_mailToAddress)
        {
            Task iTask = new Task();
            iTask.Subject = mailSubject;
            iTask.WhoId = list_Contact[0].Id;
            iTask.ActivityDate = date.today();
            iTask.Description = mailTextBody;
            if(map_User.containsKey(toAddress))
            iTask.OwnerId = map_User.get(toAddress).Id;
            iTask.Status = '已完成';
            list_task.add(iTask);
        }
        insert list_task;
        List<Attachment> listatt = new List<Attachment>();
        for(Task tt:list_task)
        {
            if(lba != null && lba.size() > 0)
            {
                for(Messaging.InboundEmail.BinaryAttachment ba : lba)
                {
                    Attachment att = new Attachment();
                    att.body = ba.body;
                    att.ParentId = tt.Id;
                    att.Name = '邮件附件：'+ba.fileName;
                    if(tt.OwnerId != null)
                    att.OwnerId = tt.OwnerId;
                    else
                    att.OwnerId = UserInfo.getUserId();
                    listatt.add(att);
                } 
            }
        }
        insert listatt;
        return result;
    }
}