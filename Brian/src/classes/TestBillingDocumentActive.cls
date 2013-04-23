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
private class TestBillingDocumentActive {

    static testMethod void myUnitTest() {
    	
    	//Test update
    	Account newAccount = new Account (name='XYZ Organization');
        newAccount.BillingCountry = 'Ireland';
        newAccount.Status__c = 'Pending';
        newAccount.OwnerId = '00520000001dGSCAA2';
        insert newAccount;
        
        Account a = [Select status__c from Account where name = 'XYZ Organization'];
        Financial_Object__c fo = new Financial_Object__c(account__c = newAccount.id, sageid__c = 'd4455332', status__c = 'Pending');
    	insert fo;
    	
    	Financial_Object__c savedFO = [Select account__c from Financial_Object__c where sageid__c = 'd4455332'];
    	a = [Select status__c from Account where id = :savedFO.Account__c];    	 
    	System.assertEquals('Pending', a.status__c);
    	
    	fo.status__c = 'Active';
    	update fo;
    	a = [Select status__c from Account where id = :savedFO.Account__c];
    	System.assertEquals('Active', a.status__c);
    	
    	//Test insert    	
    	Account newAccount2 = new Account (name='XYZ2 Organization');
        newAccount2.BillingCountry = 'Ireland';
        newAccount2.Status__c = 'Pending';
        newAccount2.OwnerId = '00520000001dGSCAA2';
        insert newAccount2;
        
        Financial_Object__c fo2 = new Financial_Object__c(account__c = newAccount2.id,
        sageid__c = 'd4455332', status__c = 'Active');
    	insert fo2;
    	
    	Account a2 = [Select status__c from Account where name = 'XYZ2 Organization'];	 
    	System.assertEquals('Active', a2.status__c);
    	
    }
}