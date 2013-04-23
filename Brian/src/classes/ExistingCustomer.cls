global class ExistingCustomer implements Database.Batchable<sObject>{
    global String email = 'ssheehan@newsweaver.com';
    global final Map<String, String> name_category = new Map<String, String>();
    global final Map<String, Date> id_startDate = new Map<String, Date>();
    global Set<String> accountIds = new Set<String>();

    global ExistingCustomer (){
        for(Account account: [Select a.Id, a.Category__c, a.Start_Date__c From Account a Where a.Status__c = 'Inactive' and a.Type = 'Customer']){
            accountIds.add(account.Id);
            if(account.Category__c != null){
                name_category.put(account.Id,account.Category__c.trim());
            }
            if(account.Start_Date__c != null){
            	id_startDate.put(account.Id,account.Start_Date__c);            	
            }
        } 
    }
     
    global Database.querylocator start(Database.BatchableContext BC){
    	//return a list of Opportunities associated with an Account of type Customer    	
        return Database.getQueryLocator('select id, accountId, Category__c, Existing_Customer__c, CloseDate from Opportunity where StageName = \'Closed-Won\' and accountId in :accountIds');
       
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
       List<Opportunity> opportunities = new List<Opportunity>();
       for(sObject s : scope){
           Opportunity o = (Opportunity)s;
               //if the Close Date is after the Organisation Activation date. (Organisation is already a customer)
               if(o.CloseDate >  id_startDate.get(o.accountId)){
	               o.Existing_Customer__c = true;             
	               o.Category__c = name_category.get(o.accountId);
	               opportunities.add(o);
               }
        }
        update opportunities;        
    }
    
    global void finish(Database.BatchableContext BC){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        mail.setToAddresses(new String[] {email});
        mail.setReplyTo('ssheehan@newsweaver.com');
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject('Batch Process Completed');
        mail.setPlainTextBody('Batch Process has completed');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}