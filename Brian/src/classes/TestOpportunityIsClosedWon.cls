/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestOpportunityIsClosedWon {
	
	
	static testMethod void myUnitTest() {

    	//create Account
        Account myAccount = new Account (name='XYZ1 Organization');
        myAccount.BillingCountry = 'Ireland';
        myAccount.Type = 'Prospect';
        myAccount.Status__c = 'Prospect';
        insert myAccount;
                
        Contact mycontact = new Contact (lastName='XYZ Contact',Contact_Status__c = 'Pending',MailingCountry='Ireland');
        mycontact.account = myAccount;
        insert mycontact;
        
    	List<Account> savedAccount = [SELECT Status__c, Type FROM Account WHERE name = 'XYZ1 Organization'];
    	
    	//create Campaign
        Campaign myCampaign = new Campaign(name='XYZ Campaign');
        myCampaign.Type = 'Advertisement';
        insert myCampaign;
        
        // create an opportunity
        Opportunity myOpportunity = new Opportunity(name='XYZ Opp', 
                                           AccountId=savedAccount[0].id,
                                           StageName='Open',
                                           Campaign=myCampaign,
                                           CloseDate = date.today(),
                                           Deal_Type__c = 'New Business',
                                           Interest_Driver__c = 'Product replacement',
                                           amount=90.00,
                                           Billing_Method__c = 'Monthly',
                                           Billing_Term__c = 'CC',
                                           No_of_Flyers__c = 2,
                                           No_of_Newsletters__c = 2,
                                           Service_Order_Number__c = '234234',
                                           X1k_emails__c = 2,
                                           Overage_Rate__c = 7.00,
                                           Solution_Category__c = 'New Account setup',
                                           Communication_Type__c = 'Internal Comms'
                                           );
		insert myOpportunity;
		//add contact role
        OpportunityContactRole cr = new OpportunityContactRole(opportunityId=myOpportunity.id,contactId=mycontact.id,role='Business User');
        insert cr;
        
        myOpportunity.StageName = 'Closed-Won';
        update myOpportunity;
		List<Change_Request__c> existingChangeRequest = [SELECT id FROM Change_Request__c WHERE Opportunity__c = :myOpportunity.Id];
		//get the account
		
		List<Account> reSsavedAccount = [SELECT Status__c, Type FROM Account WHERE name = 'XYZ1 Organization'];
		System.assertEquals(1, existingChangeRequest.size());
		System.assertEquals('Pending', reSsavedAccount[0].Status__c);
		System.assertEquals('Customer', reSsavedAccount[0].Type);
		
		List<OpportunityContactRole> contactsIds = ([ SELECT ContactId FROM OpportunityContactRole WHERE opportunityId = :myOpportunity.Id]);
		System.assertNotEquals(null, contactsIds[0].ContactId);
		System.debug('contactsIds[0].ContactId' + contactsIds[0].ContactId);
		
		//get the contact again
		List<Contact> theContacts = ([ SELECT Contact_Status__c FROM Contact WHERE id = :cr.contactId]);
		System.assertEquals('Active', theContacts[0].Contact_Status__c);
		

	}
}