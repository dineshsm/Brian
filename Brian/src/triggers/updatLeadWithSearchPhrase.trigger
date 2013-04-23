trigger updatLeadWithSearchPhrase on SFGA__Search_Phrase__c (before insert) {
 List<Lead> leads = new List<Lead>();
 for (SFGA__Search_Phrase__c sp : Trigger.new) {  
    id leadid = sp.SFGA__Lead__c;
    string namesp = sp.name;
        for (lead l: [select searchTerm__c from lead where Id = :leadid]){    
             l.searchTerm__c = namesp;
             leads.add(l);
        }
    }
    update leads;
}