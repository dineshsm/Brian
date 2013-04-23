trigger NextBillingDate on Financial_Object__c (before insert, before update) {
	for (Financial_Object__c fo : Trigger.new) {
			Integer noMonths = 0;
			if(fo.Billing_Term__c != null){							
				if(fo.Billing_Term__c.contains('6')){
					noMonths = 6;
				}else if(fo.Billing_Term__c.contains('12')){
					noMonths = 12;
				}else if(fo.Billing_Term__c.contains('4')){
					noMonths = 4;
				}else if (fo.Billing_Term__c.contains('Monthly')){
					noMonths = 1;
				}else if(fo.Billing_Term__c.contains('Quarterly')){
					noMonths = 3;
				}else if(fo.Billing_Term__c.contains('10')){
					noMonths = 10;
				}		
			 	if(Trigger.isInsert ){		 			
			 		fo.Next_Billing_Day__c = date.today().addMonths(noMonths);
			 	}else if(Trigger.isUpdate){		 					 		
					 Financial_Object__c beforeUpdate = System.Trigger.oldMap.get(fo.Id);
					 if((fo.Billing_Term__c != beforeUpdate.Billing_Term__c) || (fo.Billing_Complete__c == true && beforeUpdate.Billing_Complete__c == false) ){
					 	if(fo.Next_Billing_Day__c != null){
							fo.Next_Billing_Day__c = fo.Next_Billing_Day__c.addMonths(noMonths);
					 	}else{			
							fo.Next_Billing_Day__c = (fo.CreatedDate.date()).addMonths(noMonths);
					 	}
						fo.Billing_Complete__c = false;
					 }
			 	}
			}
	}
}