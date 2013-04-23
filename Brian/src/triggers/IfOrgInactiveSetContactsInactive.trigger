trigger IfOrgInactiveSetContactsInactive on Account (after update) {	
	if(Trigger.isUpdate){
		List<Contact> contacts;
		 for (Account a : Trigger.new) { 
			 	Account beforeUpdate = System.Trigger.oldMap.get(a.Id);
			 	if(beforeUpdate != null && (a.Status__c == 'Inactive' || a.Status__c == 'Sold-written off') && ((beforeUpdate.Status__c != 'Inactive' || beforeUpdate.Status__c != 'Sold-written off') && beforeUpdate.Status__c != null)){
			 		//Go through the contacts and set to inactive
			 		contacts = [select id, Contact_Status__c from Contact where accountId = :a.Id];
			 		for (Contact c : contacts) {
			 			c.Contact_Status__c = 'Inactive';
			 			c.Status_Inactive_Reason__c = 'Organisation no longer a client';
			 		}
			 	}
		 }	
		 if(contacts != null && contacts.size() >= 1){
		 	update contacts;	 	
		 }
	}
}