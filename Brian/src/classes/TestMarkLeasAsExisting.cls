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
private class TestMarkLeasAsExisting {

    static testMethod void myUnitTest() {
        
        Account a = new Account(Name= 'ABC, Inc.', Status__c = 'Active', Type='Customer', BillingCountry = 'Ireland', Category__c = 'Key Account');
        insert a;
        Lead l = new Lead(LastName = 'Randomname1', Company = 'ABC, Inc.', Email='test1@test.com');
        insert l;
        List <Lead> savedLead = [select Existing_Customer__c, Category__c from Lead where LastName = 'Randomname1' and Email = 'test1@test.com'];
        System.assertEquals(true, savedLead[0].Existing_Customer__c);
        System.assertEquals('Key Account', savedLead[0].Category__c);
        
        Lead l2 = new Lead(LastName = 'Randomname1', Company = 'ABC, Inc.1234', Email='test2@test.com');
        insert l2;
        savedLead = [select Existing_Customer__c from Lead where LastName = 'Randomname1' and Email = 'test2@test.com'];
        System.assertEquals(false, savedLead[0].Existing_Customer__c);
        
        Account a1 = new Account(Name= 'ABC, Inc2.', Status__c = 'Pending', Type='Customer', BillingCountry = 'Ireland');
        insert a1;
        Lead l23 = new Lead(LastName = 'Randomname1', Company = 'ABC, Inc2.', Email='test3@test.com');
        insert l23;
        savedLead = [select Existing_Customer__c from Lead where LastName = 'Randomname1' and Email = 'test3@test.com'];
        System.assertEquals(false, savedLead[0].Existing_Customer__c);
    }
}