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
private class TestOpportunityRedirect {
	
	public static testMethod void testOpportunityRedirect() {
		
    	Opportunity opp=createOpportunity();
        //Instantiate and construct the controller class.
        ApexPages.StandardController sc = new ApexPages.standardController(opp);
		
       PageReference pageRef = new PageReference('/006/e?conId=03945&accId=340975');
       Test.setCurrentPage(pageRef);
      
        OpportunityRedirect controller = new OpportunityRedirect(sc);
        PageReference nextPage = controller.redirect();

        // Verify that page fails without parameters      
        System.assertEquals('/006/e?accid=340975&conid=03945&nooverride=1', nextPage.getUrl());
        
      
    }
    
    public static testMethod void testOpportunityRedirect2() {
		
    	Opportunity opp=createOpportunity();
        //Instantiate and construct the controller class.
        ApexPages.StandardController sc = new ApexPages.standardController(opp);
		
       PageReference pageRef = new PageReference('/006/e');
       Test.setCurrentPage(pageRef);
      
        OpportunityRedirect controller = new OpportunityRedirect(sc);
        PageReference nextPage = controller.redirect();

        // Verify that page fails without parameters      
        System.assertEquals('/apex/createOpportunity2?nooverride=1', nextPage.getUrl());

    }
    
    public static testMethod Opportunity createOpportunity(){
    	//create Account
        Account myAccount = new Account (name='XYZ1 Organization');
        myAccount.BillingCountry = 'Ireland';
        myAccount.Type = 'Prospect';
        myAccount.Status__c = 'Prospect';
        insert myAccount;
                
        Contact mycontact = new Contact (lastName='XYZ Contact',Contact_Status__c = 'Active',MailingCountry='Ireland');
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
                                           StageName='Closed-Won',
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
                                           Solution_Category__c = 'New Account setup');
		return myOpportunity;
    }
}