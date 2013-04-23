trigger DeDupeLead on Lead (before insert, after insert) {
	List <Lead> dupeLeads = new List<Lead>();
	// no bulk processing; will only run from the UI
 	for (Lead newLead : Trigger.new) {
	  if (Trigger.new.size() == 1) {
	  	if(newLead.Email != '' && newLead.Email != null){
		  	dupeLeads = [Select l.Id, l.OwnerId, l.Email From Lead l Where l.Email = :newLead.Email]; //Email Match
		  	if(dupeLeads.size() >= 1){
		  		doDeDupeActions(dupeLeads[0], newLead);
		  	}	
	  	}
	  	if(dupeLeads.size() == 0){ // If there are no matches after email check.
	  	 	dupeLeads = [Select l.Id, l.OwnerId, l.Email From Lead l Where  (l.company = :newLead.Company and l.Phone = :newLead.Phone)]; //Company & Phone Match
	  	 	if(dupeLeads.size() >= 1){
	  	 		doDeDupeActions(dupeLeads[0], newLead);
	  	 	}else{	  	 		
	  	 		dupeLeads = [Select l.Id, l.OwnerId, l.Email From Lead l Where  (l.company = :newLead.Company and l.Name = :newLead.Name)]; //Company & Name Match
	  	 		if(dupeLeads.size() >= 1){
	  	 			doDeDupeActions(dupeLeads[0], newLead);
	  	 		}	  	 		
	  	 	}
	  	 }	  	 
	  }
  }
  
  private void doDeDupeActions(Lead dupeLead, Lead newLead){
	if(Trigger.isBefore){  		
  	 	newLead.OwnerId = dupeLead.OwnerId;
  	 	newLead.doNotRoundRobin__c = true;
  	}else if (Trigger.isAfter && newLead.doNotRoundRobin__c == true){
  		sendMail(newLead.OwnerId, newLead.Id);
  	}
  }
  
  public void sendMail(Id uId, id leadId){
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<Messaging.SendEmailResult> results = new list<Messaging.SendEmailResult>();
	    mail.setTargetObjectId(uId);	    
	    mail.setTemplateId('00X20000001ZZycEAG');
	    mail.setSaveAsActivity(false);
	    mail.setWhatId(leadId);	 
	    System.debug('Sending Email');
	    results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }
}