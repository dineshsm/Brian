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
private class TestLeadCampaignAssignment {

    static testMethod void testCreateNewEmailLead() {
        // create the campaign
        String cname = 'Google Adwords IE';
	    List <Campaign> c = [select id, name from Campaign where name = :cname limit 1];
        //create the lead with subject= in the description
        Lead myLead = new Lead (FirstName='firstName', 
	                                         LastName='lastName',
	                                         Company='sdfsdf',
	                                         Country='Ireland',
	                                         email = 'test@test.com',
	                                         leadSource = 'Web',
	                                         description='something',
	                                         adcampaign__c ='Ireland-1-Sept-09');                                        
	    insert myLead ;
	    myLead.LeadSource = 'Google AdWords';
	    update myLead;
        //assert the lead is a member of the campaign
        final List <CampaignMember> campaignmembers = [select id from CampaignMember where campaignid = :c[0].id and leadid = :myLead.id];
        
        System.assertEquals(1, campaignmembers.size());

    }
    
    static testMethod void testGoogleAdLeadFromNewsweaverSearch() {
        //create the lead with subject= in the description
        Lead myLead = new Lead (FirstName='firstName', 
	                                         LastName='lastName',
	                                         Company='sdfsdf',
	                                         Country='Ireland',
	                                         email = 'test@test.com',
	                                         leadSource = 'Web',
	                                         description='something',
	                                         adcampaign__c ='Ireland-1-Sept-09');  
	                                         
	                                                                              
	    insert myLead ;	    
	    myLead.LeadSource = 'Google AdWords';
	    update myLead;
        //assert the lead is a member of the campaign        
        SFGA__Search_Phrase__c sfgasp  = new SFGA__Search_Phrase__c(SFGA__Lead__c = myLead.id, name='newsweaver email');
		insert sfgasp;
        
        final List <CampaignMember> campaignmembers = [select CampaignId from CampaignMember where leadid = :myLead.id];        
        System.assertEquals(1, campaignmembers.size());

        final List <Campaign> campaign = [select name from Campaign where id = :campaignmembers[0].CampaignId];        
        System.assertEquals('Direct Website Visit 2011', campaign[0].name);              
    }
    
    static testMethod void testCreateNewEmailLead2() {
        // create the campaign
        String cname = 'Google Adwords UK';
	    List <Campaign> c = [select id, name from Campaign where name = :cname limit 1];
        //create the lead with subject= in the description
        Lead myLead = new Lead (FirstName='firstName', 
	                                         LastName='lastName',
	                                         Company='sdfsdf',
	                                         Country='Ireland',
	                                         email = 'test@test.com',
	                                         leadSource = 'Web',
	                                         description='something',
	                                         adcampaign__c ='UK-1-Sept-09');                                        
	    insert myLead ;
	    myLead.LeadSource = 'Google AdWords';
	    update myLead;
        //assert the lead is a member of the campaign
        final List <CampaignMember> campaignmembers = [select id from CampaignMember where campaignid = :c[0].id and leadid = :myLead.id];
        
        System.assertEquals(1, campaignmembers.size());

    }
    static testMethod void testCreateNewRegularLead() {
                // create the campaign
        String cname = 'Natural Search';
	    List <Campaign> c = [select id, name from Campaign where name = :cname limit 1];
        //create the lead with regular description
        Lead myLead = new Lead (FirstName='firstName', 
	                                         LastName='lastName',
	                                         Company='sdfsdf',
	                                         Country='Ireland',
	                                         email = 'test@test.com',
	                                         leadSource = 'Web',
	                                         description='normal description');                                        
	    insert myLead ;
	    myLead.LeadSource = 'Organic google';
	    update myLead;
	   	
	   	SFGA__Search_Phrase__c sfgasp  = new SFGA__Search_Phrase__c(SFGA__Lead__c = myLead.id, name='SearchPhrase');
		insert sfgasp;
	    
        //assert the lead is not a member of the campaign
        final List <CampaignMember> campaignmembers = [select id, CampaignId from CampaignMember where campaignid = :c[0].id and leadid = :myLead.id];
        System.assertEquals(1, campaignmembers.size());
        final List <Campaign> campaign = [select name from Campaign where Id = :campaignmembers[0].CampaignId];
        System.assertEquals('Natural Search', campaign[0].Name);
    }
    
        static testMethod void testBannerAdLead() {
                // create the campaign
        String cname = 'DMA-Banner-Ad';
	    List <Campaign> c = [select id, name from Campaign where name = :cname limit 1];
        //create the lead with regular description
        Lead myLead = new Lead (FirstName='firstName', 
	                                         LastName='lastName',
	                                         Company='sdfsdf',
	                                         Country='Ireland',
	                                         email = 'test@test.com',
	                                         leadSource = 'Web',
	                                         description='normal description',
	                                         adcampaign__c ='online_banner_ad',
	                                         adword__c ='dmablog');                                        
	    insert myLead ;
	    myLead.LeadSource = 'Organic google';
	    update myLead;
        //assert the lead is not a member of the campaign
        final List <CampaignMember> campaignmembers = [select id, CampaignId from CampaignMember where campaignid = :c[0].id and leadid = :myLead.id];
        System.assertEquals(1, campaignmembers.size());
        final List <Campaign> campaign = [select name from Campaign where Id = :campaignmembers[0].CampaignId];
        System.assertEquals('DMA-Banner-Ad', campaign[0].Name);
    }
    
        static testMethod void testBannerAdLead2() {
                // create the campaign
        String cname = 'eDispatch-Banner-Ad-2010';
	    List <Campaign> c = [select id, name from Campaign where name = :cname limit 1];
        //create the lead with regular description
        Lead myLead = new Lead (FirstName='firstName', 
	                                         LastName='lastName',
	                                         Company='sdfsdf',
	                                         Country='Ireland',
	                                         email = 'test@test.com',
	                                         leadSource = 'Web',
	                                         description='normal description',
	                                         adcampaign__c ='ebulletins',
	                                         adword__c ='edispatch');                                        
	    insert myLead ;
	    myLead.LeadSource = 'Web Referral';
	    update myLead;
        //assert the lead is not a member of the campaign
        final List <CampaignMember> campaignmembers = [select id, CampaignId from CampaignMember where campaignid = :c[0].id and leadid = :myLead.id];
        System.assertEquals(1, campaignmembers.size());
        final List <Campaign> campaign = [select name from Campaign where Id = :campaignmembers[0].CampaignId];
        System.assertEquals('eDispatch-Banner-Ad-2010', campaign[0].Name);
    }
    
    /*
    
    */
    static testMethod void testBannerAdLead3() {
                // create the campaign
        String cname = 'ENN-Email-Newsletter-Banner-Ad-20xx';
	    List <Campaign> c = [select id, name from Campaign where name = :cname limit 1];
        //create the lead with regular description
        Lead myLead = new Lead (FirstName='firstName', 
	                                         LastName='lastName',
	                                         Company='sdfsdf',
	                                         Country='Ireland',
	                                         email = 'test@test.com',
	                                         leadSource = 'Web',
	                                         description='normal description',
	                                         adcampaign__c ='ENN',
	                                         adword__c ='email_newsletter_template');                                        
	    insert myLead ;
	    myLead.LeadSource = 'Web Referral';
	    update myLead;
        //assert the lead is not a member of the campaign
        final List <CampaignMember> campaignmembers = [select id, CampaignId from CampaignMember where campaignid = :c[0].id and leadid = :myLead.id];
        System.assertEquals(1, campaignmembers.size());
        final List <Campaign> campaign = [select name from Campaign where Id = :campaignmembers[0].CampaignId];
        System.assertEquals('ENN-Email-Newsletter-Banner-Ad-20xx', campaign[0].Name);
    }
    
    static testMethod void testBannerAdLead4() {
                // create the campaign
        String cname = 'Mixing-Digital-2011';
	    List <Campaign> c = [select id, name from Campaign where name = :cname limit 1];
        //create the lead with regular description
        Lead myLead = new Lead (FirstName='firstName', 
	                                         LastName='lastName',
	                                         Company='sdfsdf',
	                                         Country='Ireland',
	                                         email = 'test@test.com',
	                                         leadSource = 'Web',
	                                         description='normal description',
	                                         adcampaign__c ='online_banner_ad',
	                                         adword__c ='mixingdigital');                                        
	    insert myLead ;
	    myLead.LeadSource = 'Web Referral';
	    update myLead;
        //assert the lead is not a member of the campaign
        final List <CampaignMember> campaignmembers = [select id, CampaignId from CampaignMember where campaignid = :c[0].id and leadid = :myLead.id];
        System.assertEquals(1, campaignmembers.size());
        final List <Campaign> campaign = [select name from Campaign where Id = :campaignmembers[0].CampaignId];
        System.assertEquals('Mixing-Digital-2011', campaign[0].Name);
    }
    
    static testMethod void testBannerAdLead5() {
                // create the campaign
        String cname = 'IMJ-PrintAd';
	    List <Campaign> c = [select id, name from Campaign where name = :cname limit 1];
        //create the lead with regular description
        Lead myLead = new Lead (FirstName='firstName', 
	                                         LastName='lastName',
	                                         Company='sdfsdf',
	                                         Country='Ireland',
	                                         email = 'test@test.com',
	                                         leadSource = 'Web',
	                                         description='normal description',
	                                         adcampaign__c ='Advertising',
	                                         adword__c ='imjad');                                        
	    insert myLead;
	    myLead.LeadSource = 'Web Referral';
	    update myLead;
        //assert the lead is not a member of the campaign
        final List <CampaignMember> campaignmembers = [select id, CampaignId from CampaignMember where campaignid = :c[0].id and leadid = :myLead.id];
        System.assertEquals(1, campaignmembers.size());
        final List <Campaign> campaign = [select name from Campaign where Id = :campaignmembers[0].CampaignId];
        System.assertEquals('IMJ-PrintAd', campaign[0].Name);
    }    
    
        static testMethod void testBannerAdLead6() {
                // create the campaign
        String cname = 'Direct Website Visit 2011';
	    List <Campaign> c = [select id, name from Campaign where name = :cname limit 1];
        //create the lead with regular description
        Lead myLead = new Lead (FirstName='firstName', 
	                                         LastName='lastName',
	                                         Company='sdfsdf',
	                                         Country='Ireland',
	                                         email = 'test@test.com',
	                                         leadSource = 'Web',
	                                         description='normal description',
	                                         adcampaign__c ='Direct_visit_website');                                        
	    insert myLead ;
	    myLead.LeadSource = 'Web Direct';
	    update myLead;
        //assert the lead is not a member of the campaign
        final List <CampaignMember> campaignmembers = [select id, CampaignId from CampaignMember where campaignid = :c[0].id and leadid = :myLead.id];
        System.assertEquals(1, campaignmembers.size());
        final List <Campaign> campaign = [select name from Campaign where Id = :campaignmembers[0].CampaignId];
        System.assertEquals('Direct Website Visit 2011', campaign[0].Name);
    }    
    
    static testMethod void testLeadWithNewsweaverSearchTerm() {

        //create the lead with regular description
        Lead myLead = new Lead (FirstName='firstName', 
	                                         LastName='lastName',
	                                         Company='sdfsdf',
	                                         Country='Ireland',
	                                         email = 'test@test.com',
	                                         leadSource = 'Web',
	                                         description='normal description');                                        
	    insert myLead ;
	   	myLead.LeadSource = 'Organic google';
	    update myLead;
	   	SFGA__Search_Phrase__c sfgasp  = new SFGA__Search_Phrase__c(SFGA__Lead__c = myLead.id, name='Newsweaver');
		insert sfgasp;
	    
        //assert the lead is not a member of the campaign
        final List <CampaignMember> campaignmembers = [select id, CampaignId from CampaignMember where leadid = :myLead.id];
        System.assertEquals(1, campaignmembers.size());
        final List <Campaign> campaign = [select name from Campaign where Id = :campaignmembers[0].CampaignId];
        System.assertEquals('Direct Website Visit 2011', campaign[0].Name);
    }
    
    
	static testMethod void testLeadWithOtherSearchTerm() {
        //create the lead with regular description
        Lead myLead = new Lead (FirstName='firstName', 
	                                         LastName='lastName',
	                                         Company='sdfsdf',
	                                         Country='Ireland',
	                                         email = 'test@test.com',
	                                         leadSource = 'Web',
	                                         description='normal description');                                        
	    insert myLead ;
	   	myLead.LeadSource = 'Organic google';
	    update myLead;	   	
	   	SFGA__Search_Phrase__c sfgasp  = new SFGA__Search_Phrase__c(SFGA__Lead__c = myLead.id, name='SearchPhrase');
		insert sfgasp;
	    
        //assert the lead is not a member of the campaign
        final List <CampaignMember> campaignmembers = [select id, CampaignId from CampaignMember where leadid = :myLead.id];
        System.assertEquals(1, campaignmembers.size());
        final List <Campaign> campaign = [select name from Campaign where Id = :campaignmembers[0].CampaignId];
        System.assertEquals('Natural Search', campaign[0].Name);
    }    
    
}