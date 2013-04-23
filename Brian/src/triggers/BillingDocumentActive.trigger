/*
If the Billing Document is set to Active - Set the associated organisation to active.
*/
trigger BillingDocumentActive on Financial_Object__c (after insert, before update) {
	 for (Financial_Object__c bd : Trigger.new) {
	 	System.debug('Account Id = ' + bd.Account__c);	 	
	 	//Financial_Object__c beforeUpdate = System.Trigger.oldMap.get(bd.Id);	 	
	 	if(bd.status__c == 'Active'){
	 		//Status has changed update the organisation status
	 		List<Account> org = [select status__c from Account where id = :bd.Account__c];
	 		if(org.size() == 1 && org[0].Status__c != 'Active'){	 		
		 		org[0].Status__c = 'Actsdfsdfive';
		 		update org;	
	 		}	 		
	 	}
	 }
}