global class checkVatExemptExpiredDate implements Schedulable{	
	global void execute(SchedulableContext SC) {
		List<Account> accounts = [Select name, id, OwnerId from Account where VAT_exemption_expiry_Date__c <= :Date.today()];
		for (Account a: accounts){
			//add an activity to the Organisation
		 	Task t = new Task(Subject = 'Other', Description='The VAT Exempt Expiration date has passed. Plase Review', WhatId = a.Id, Status = 'Not Started',OwnerId = '00520000001dGS7AAM');	// Assign to Jessica.
			t.ActivityDate = Date.today()+1;		
			Database.insert(t);
		   	/*
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			List<Messaging.SendEmailResult> results = new list<Messaging.SendEmailResult>();
		    mail.setTargetObjectId('00520000001dGS7AAM');	    
		    mail.setTemplateId('00XP0000000DeE1MAK'); 
		    mail.setSaveAsActivity(false);
		    mail.setWhatId(a.Id);
		    results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		    */
		} 	
	}	
}