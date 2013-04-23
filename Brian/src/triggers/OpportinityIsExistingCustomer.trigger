trigger OpportinityIsExistingCustomer on Opportunity (before insert) {	
	for (Opportunity o : Trigger.new) {
		System.debug(o.AccountId);
		if(o.AccountId != null){
			List<Account> account = [Select Category__c, Type, Status__c from Account where id = :o.AccountId];
			if(account[0].Type != 'Prospect' && account[0].Status__c == 'Active'){	//This should stop the trigger acting on newly converted Opps.
				o.Existing_Customer__c = true;
				o.Category__c = account[0].Category__c;					
			}
		}
	}
}