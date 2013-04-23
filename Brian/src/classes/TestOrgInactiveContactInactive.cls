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
private class TestOrgInactiveContactInactive {

    static testMethod void myUnitTest() {
        //Create an Active Account
        Account newAccount = new Account (name='XYZ Organization');
        newAccount.BillingCountry = 'Ireland';
        newAccount.Status__c = 'Active';
        insert newAccount;
        
        List <Account> savedAccount = [Select Status__c from Account where name = 'XYZ Organization'];
        
        //TEST FOR STATUS EQUAL TO 'Inactive'
        //Create Active Contacts
        Contact mycontact = new Contact (lastName='XYZ Contact',Contact_Status__c = 'Active', MailingCountry='Ireland');
        mycontact.accountId = savedAccount[0].Id;
        insert mycontact;
        
        //Update to Inactive        
        Account na = savedAccount[0];
        na.Status__c = 'Inactive';
        na.Cease_date__c = date.today();
        System.debug('Calling After Update Trigger...');
        update na;
                        
        //Assert contacts are inactive & reason is set
        List<Contact> savedContact = [Select Contact_status__c, Status_Inactive_Reason__c from Contact where name = 'XYZ Contact'];
        System.assertEquals('Inactive', savedContact[0].Contact_Status__c);
        System.assertEquals('Organisation no longer a client', savedContact[0].Status_Inactive_Reason__c);
        
        //TEST FOR STATUS EQUAL TO 'Sold-written off'
        //Create Active Contacts
        Contact mycontact2 = new Contact (lastName='XYZ Contact',Contact_Status__c = 'Active', MailingCountry='Ireland');
        mycontact2.accountId = savedAccount[0].Id;
        insert mycontact2;
        
        //Update to Sold-written off        
        Account na2 = savedAccount[0];
        na2.Status__c = 'Sold-written off';
        na2.Cease_date__c = date.today();
        System.debug('Calling After Update Trigger...');
        update na2;
                        
        //Assert contacts are inactive & reason is set
        List<Contact> savedContact2 = [Select Contact_status__c from Contact where name = 'XYZ Contact'];
        System.assertEquals('Inactive', savedContact2[0].Contact_Status__c);
        //System.assertEquals('Organisation no longer a client', savedContact[0].Status_Inactive_Reason__c);
    }
}