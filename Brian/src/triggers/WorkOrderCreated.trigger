/*
	When a Work Order is created set the status on the associated Change Request to Creating.
*/
trigger WorkOrderCreated on SFDC_Projects__c (after insert) {
    try {
        if (Trigger.new.size() == 1){
            for(SFDC_Projects__c p : Trigger.new) {
				 List <Change_Request__c> c = [select id, name from Change_Request__c where id = :p.Change_Request__c limit 1];
				 if(!c.isEmpty()){
				 	c[0].Status__c = 'Creating';
				 	update c[0];
				 }
           	} 
        }
    } catch(Exception e) {
        system.debug ('error: ' + e.getMessage() );
    }
}