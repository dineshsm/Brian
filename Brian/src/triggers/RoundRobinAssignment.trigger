trigger RoundRobinAssignment on Lead (before insert, before update) {

  	if(Trigger.new.size() == 1){ //SINGLE UPDDATE  	  
		assignToNextInRoundRobinQueue();		
  	}else{ //BATCH ASSIGN LEADS
  		assignLeadsInBatch();
  	}

	/*
	This method is fro Round robin 1 off leads from the web - It takes into account who is next in line to get a lead. 
	*/
	public void assignToNextInRoundRobinQueue(){
		for (Lead newLead : Trigger.new) {
			if(newLead.OwnerId == '00G20000001d62uEAA'){ //This is the Id of the Round RobinGroup.--LIST<Group> groups = [SELECT Id FROM Group WHERE Name = 'RoundRobin']; - Removed this to cut down on queries.
				LIST<User> mRRUsers = [select id, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid = '00G20000001d62uEAA')];	
				boolean isset = false;
			    for (User u : mRRUsers){                    
			        if(u.received_RR_Lead__c == false){
			            newLead.OwnerId = u.Id;
			            u.received_RR_Lead__c = true;
			            isset = true;
			            update u;
			            sendMail(u, newLead.Id);
			            break;
			        }
			    }
		    	if(isset == false){ // everybody has a lead so start again..
			        //loop through again and set them all to false
			        for (User u : mRRUsers){
			            //set the first one to true
			            u.received_RR_Lead__c = false;
			            update u;
			        }
			        //set the first one to true
			        mRRUsers[0].received_RR_Lead__c = true;
			        newLead.OwnerId = mRRUsers[0].Id;
			        update mRRUsers[0];
			        sendMail(mRRUsers[0], newLead.Id);
		    	}
			}
		}
	}
	
	/*
		Send notification email - Only if a once off lead.
	*/
	public void sendMail(User u, id leadId){		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<Messaging.SendEmailResult> results = new list<Messaging.SendEmailResult>();
	    mail.setTargetObjectId(u.id);	    
	    mail.setTemplateId('00X20000001ZWtlEAG');
	    mail.setSaveAsActivity(false);
	    mail.setWhatId(leadId);	    
	    results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
	
	/*
		This method is used for bulk updates - It only updates the lead it does not send and email or change the status of the lead owner as this is not safe in bulk mode..
		It does not affect the order of the web lead distribution.
	*/
	public void assignLeadsInBatch(){

		LIST<User> mRRUsers = [select id, received_RR_Lead__c from user where id in (select UserOrGroupId from GroupMember where groupid = '00G20000001d62uEAA')];
		Integer i = 0;
		Integer numberOfRRUSers = mRRUsers.size();
		for (Lead l : Trigger.new) {		
			if(l.OwnerId == '00G20000001d62uEAA'){ //This is the Id of the Round RobinGroup.--LIST<Group> groups = [SELECT Id FROM Group WHERE Name = 'RoundRobin']; - Removed this to cut down on queries.
				if(i == (numberOfRRUSers)){
					i=0;
				}
				l.ownerId = mRRUsers[i].id;
				i++;
			}
		}
	}  
}