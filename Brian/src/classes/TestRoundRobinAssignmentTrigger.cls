@isTest
private class TestRoundRobinAssignmentTrigger {
                  
	public static testMethod void testRoundRobinAssignment() {       
      final List<GroupMember> Allmembers = [select UserOrGroupId from GroupMember where groupid = '00G20000001d62uEAA'];
      final Set<ID> userIds = new Set<ID>();
      for(GroupMember member : Allmembers){
        userIds.add(member.UserOrGroupId);
      }
      LIST<User> rrUsers = [select id, received_RR_Lead__c from user where id in :userIds];
      for (User u : rrUsers){
        u.received_RR_Lead__c = false;
        update u;
      } 
        Integer numberOfMembers = Allmembers.size();
        Integer j = 0;
    	while (j <= (Allmembers.size())){
          //create a lead 
          String leadEmail =  'JSchmoe' + j +'@test.com';
          String firstName = 'Joe'+ j;
          String lastName = 'Schmoe'+ j;
          String company='random'+ j;
          Lead myLead = new Lead (FirstName=firstName, 
                                           LastName=lastName,
                                           leadSource='Web',
                                           Company=company,
                                           Country='Ireland',
                                           email = leadEmail);                                        
          insert myLead ; 
          
          myLead.OwnerId = '00G20000001d62uEAA'; // assignment rule will assign to Queue and update
        update myLead; // call trigger
         //if(j == 0){ // Only do the asserts fr the first lead..
        //retrieve the lead
            List<Lead> savedLead = [SELECT OwnerId FROM Lead WHERE FirstName = :firstName and LastName= :lastName and Company = :company and email = :leadEmail];
            if(savedLead.size() != 1){
              System.debug('PROBLEM HERE.........');
            }
            //Assert the assigned Owner is not the Round Robin Queue 
            ID userId = savedLead[0].OwnerId;       
            System.assertNotEquals('00G20000001d62uEAA', userId);
            //Assert the newly assigned Owner is a Member of the RR Queue
            final List<GroupMember> members = [select UserOrGroupId from GroupMember where groupid = '00G20000001d62uEAA' and UserOrGroupId = :userId];
            System.assertEquals(1, members.size());           
         //}  
           j++;
    }
    //each member has now received a lead so Create 1 more lead and test that all members except for the lead owner have the received Lead flag set to false.
    String leadEmail =  'JSchmoe2ndRound@test.com';
      Lead myLead = new Lead (FirstName='Joe2ndRound', 
                                       LastName='Schmoe2ndRound',
                                        leadSource='Web',
                                        Company='random2ndRound',
                                        Country='Ireland',
                                        email = leadEmail);                                        
      insert myLead;        
      myLead.OwnerId ='00G20000001d62uEAA'; // assignment rule will assign to Queue and update     
    update myLead; // call trigger     
      //retrieve the lead
      List<Lead> savedLeadJoe2ndRound = [SELECT OwnerId FROM Lead WHERE FirstName = 'Joe2ndRound' and LastName='Schmoe2ndRound' and Company = 'random2ndRound' and email = :leadEmail];
            
      for (User u : rrUsers){
        if(u.id != savedLeadJoe2ndRound[0].OwnerId){

          System.assertEquals(false, u.received_RR_Lead__c);
        }
      }    
     }
     
     public static testMethod void testBulkRoundRobinAssignment() {
          
        Profile p = [select id from profile where name='Custom - Marketing User'];
        // create a user to run the test as
		User u = new User(alias = 'test123', email='test12345@noemail.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id, country='United States',
            timezonesidkey='America/Los_Angeles', username='test12354@noemail.com');

        insert u;
        List<Lead> leads = new List<Lead>();          
        for (Integer i=0;i<100;i++) {	 
	    	//create 200 lead 
	        String leadEmail =  'JSchmoeBulk@test.com';
	        String firstName = 'Joe'+i;
	        String lastName = 'Schmoe'+i;
	        String company='random'+i;
	        Lead myLead = new Lead (FirstName=firstName, 
	                                         LastName=lastName,
	                                         Company=company,
	                                         Country='Ireland',
	                                         email = leadEmail,
	                                         ownerId = '00G20000001d62uEAA');    
	        leads.add(myLead);
        }
        Test.startTest();
    	System.runAs(u) {
       		insert leads;
    	}
    	Test.stopTest();
    	for (Lead l : [Select OwnerId from Lead Where email = 'JSchmoe@test.com']){
    		System.assertNotEquals(l.OwnerId,'00G20000001d62uEAA');
    	}    	

   		
	}
     
}