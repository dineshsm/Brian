trigger Create_CampaignMember_For_New_Leads on Lead (after update) {
 
    try {  
 
        if (Trigger.new.size() == 1 ) {
            
            // Only run this trigger if there has beena change to the lead source or the ad Campaign or the adWord...
            if(Trigger.isUpdate && ((Trigger.old[0].searchTerm__c == Trigger.new[0].searchTerm__c) && (Trigger.old[0].adcampaign__c == Trigger.new[0].adcampaign__c) && (Trigger.old[0].LeadSource == Trigger.new[0].LeadSource) && (Trigger.old[0].adword__c == Trigger.new[0].adword__c)) ){
            	return;
            }
            String cname = ''; 
            
            CampaignMember cml = new CampaignMember();
            
            for(Lead L : Trigger.new) {            	
            	Lead leadBeforeUpdate = System.Trigger.oldMap.get(L.Id);
				//If the searchTerm has changed from null to Newsweaver (Search term is only changed by sfga)           	
            	if(leadBeforeUpdate.searchTerm__c == null && (L.searchTerm__c != null && (L.searchTerm__c.contains('Newsweaver') || L.searchTerm__c.contains('newsweaver')))){
            		//remove the previously assigned campaign
            		List<CampaignMember> cm = [Select id from CampaignMember where leadId = :L.id];
            		if(cm.size() >= 1){
            			delete cm;	
            		}            		 
            		// Assign direct visit.
            		cname = 'Direct Website Visit 2011';            		 
           		}else{
	           		if(L.adword__c == 'Newsweaver' || L.adword__c == 'newsweaver'){
	            		cname = 'Direct Website Visit 2011';
	            	}else if(L.adcampaign__c == 'Client_newsletter'){
	                    cname = 'Client Newsletter 2011';
	                }else if(L.adcampaign__c == 'Ireland-1-Sept-09'){                                                               
	                       cname = 'Google Adwords IE';
	                }else if(L.adcampaign__c == 'UK-1-Sept-09'){                                                                
	                       cname = 'Google Adwords UK';
	                }else if(L.adcampaign__c == 'online_banner_ad' && L.adword__c == 'dmablog'){
	                  cname = 'DMA-Banner-Ad';
	                }else if(L.adcampaign__c == 'ebulletins' && L.adword__c == 'edispatch'){
	                  cname = 'eDispatch-Banner-Ad-2010';
	                }else if(L.adcampaign__c == 'ENN' && L.adword__c == 'email_newsletter_template'){
	                  cname = 'ENN-Email-Newsletter-Banner-Ad-20xx';
	                }else if(L.adcampaign__c == 'IAA' && L.adword__c == 'IIA_Advertorial'){
	                  cname = 'IIA-Email-Newsletter';
	                }else if(L.adcampaign__c == 'Advertising' && L.adword__c == 'imjad'){
	                  cname = 'IMJ-PrintAd';
	                }else if(L.adcampaign__c == 'online_banner_ad' && L.adword__c == 'mixingdigital'){
	                  cname = 'Mixing-Digital-2011';
	                }else if((L.adcampaign__c == 'undefined' || L.adcampaign__c == 'Direct_visit_website' || L.adcampaign__c == '' || L.adcampaign__c == null) && L.LeadSource.contains('Organic')){
	                    cname = 'Natural Search';
	                }else if((L.adcampaign__c == 'undefined' || L.adcampaign__c == 'Direct_visit_website' || L.adcampaign__c == '' || L.adcampaign__c == null) && L.LeadSource.contains('Web Referral')){
	                    cname = 'Website Referrals';
	                }else if((L.adcampaign__c == 'undefined' || L.adcampaign__c == 'Direct_visit_website' || L.adcampaign__c == '' || L.adcampaign__c == null)&& L.LeadSource.contains('Web Direct')){
	                    cname = 'Direct Website Visit 2011';
	                }else{
	                    cname = L.adcampaign__c;
	                }
            	}
                if(cname != ''){
                    List <Campaign> c = [select id, name from Campaign where name = :cname limit 1];
                    if(!c.isEmpty()){           
                        cml.campaignid = c[0].id;
                        cml.leadid = l.id;
                    }else{
                        System.debug('No Campaign exists');
                }
            }
            
       }
       if(cml.CampaignId != null){          
        insert cml;
       }
        }
 
    } catch(Exception e) {
        system.debug ('error: ' + e.getMessage() );
    }
}