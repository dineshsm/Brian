trigger OpportunityIsClosedWon on Opportunity (after insert, after update) {
  Map<ID, Account> accMap = new Map<ID, Account >();
  list<Opportunity> opps = new list<Opportunity>();
  // Loop Through Opportunities Being Processed
  for (Opportunity opp : Trigger.new) {
    if((Trigger.isInsert && opp.StageName == 'Closed-Won') || (opp.StageName == 'Closed-Won' && System.Trigger.oldMap.get(opp.Id).StageName != 'Closed-Won')){
      opps.add(opp);
    }          
  }
  doOpportunityTrigger(opps);
  
  public void doOpportunityTrigger(list<Opportunity> oppsToUpdate){  	
    for(Opportunity opp : oppsToUpdate) {    
      List<Change_Request__c> existingChangeRequest = [SELECT id FROM Change_Request__c WHERE Opportunity__c = :opp.Id];
      if(existingChangeRequest.size() == 0){      
        //create a changeRequest
        Change_Request__c newChangeRequest = new Change_Request__c(Solution__C = opp.Solution__c, Type__c = opp.Solution_Category__c, Opportunity__c = opp.Id, Organisation__c = opp.AccountId, Amount__c = opp.Amount, Description__c = opp.Description, Summary__c = 'CR for' + opp.Name, CurrencyIsoCode = opp.CurrencyIsoCode,Service_Amount__c = opp.Services_Fee__c, No_Publications__c = opp.No_of_Publications__c);
        insert newChangeRequest;
        List<Account> accounts = ([ SELECT Status__c, Type FROM Account WHERE Id = :opp.AccountId ]);
        if(accounts.size() == 1){              
          if(accounts[0].Status__c != 'Active' &&  accounts[0].Status__c != 'Pending'){
            accounts[0].Status__c = 'Pending';
            accounts[0].Type = 'Customer';
            update accounts[0];
          }
        }
      }
      List<OpportunityContactRole> contactsIds = ([ SELECT ContactId FROM OpportunityContactRole WHERE opportunityId = :opp.Id]);
      for (OpportunityContactRole oppContact : contactsIds){
      	List<Contact> theContacts = ([ SELECT Contact_Status__c FROM Contact WHERE id = :oppContact.ContactId]);
       	if(theContacts != null && theContacts.size() == 1){
               theContacts[0].Contact_Status__c = 'Active';
           	update theContacts[0];
       	}
      }
	}
}
}