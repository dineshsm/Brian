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
private class TestNextBillingDate {

    static testMethod void myUnitTest() {
        // create Billing Doc            	
    	Account newAccount = new Account (name='XYZ Organization');
        newAccount.BillingCountry = 'Ireland';
        insert newAccount;
        
        Account a = [Select status__c from Account where name = 'XYZ Organization'];
        Financial_Object__c fo = new Financial_Object__c(account__c = newAccount.id, sageid__c = 'd4455332', status__c = 'Pending', Billing_Term__c = '6 months in advance');
    	insert fo;
    	
    	Financial_Object__c savedFO = [Select Next_Billing_Day__c from Financial_Object__c where sageid__c = 'd4455332'];
    	System.assertEquals(Date.today().addMonths(6), savedFO.Next_Billing_Day__c);
    	Date previousBillingDate = savedFO.Next_Billing_Day__c;
    	savedFO.Billing_Term__c = '12 months in advance';
    	update savedFO;
    	
    	savedFO = [Select Next_Billing_Day__c from Financial_Object__c where sageid__c = 'd4455332'];    	    	
    	System.assertEquals(previousBillingDate.addMonths(12), savedFO.Next_Billing_Day__c);
    	
    	
    	previousBillingDate = savedFO.Next_Billing_Day__c;
    	savedFO.Billing_Term__c = 'Monthly in advance';
    	update savedFO;    	
    	savedFO = [Select Next_Billing_Day__c from Financial_Object__c where sageid__c = 'd4455332'];    	    	
    	System.assertEquals(previousBillingDate.addMonths(1), savedFO.Next_Billing_Day__c);
        //Set the Billing Term
        
        previousBillingDate = savedFO.Next_Billing_Day__c;
    	savedFO.Billing_Term__c = 'Quarterly in advance';
    	update savedFO;    	
    	savedFO = [Select Next_Billing_Day__c from Financial_Object__c where sageid__c = 'd4455332'];    	    	
    	System.assertEquals(previousBillingDate.addMonths(3), savedFO.Next_Billing_Day__c);
    }
}