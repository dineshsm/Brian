trigger RequireContactForNewOpportunity on Opportunity (before update) {
    /*for (Opportunity opp : Trigger.new) {   
        Map<ID, OpportunityContactRole> ocrMap = new Map<ID, OpportunityContactRole >();
        ocrMap = new Map<ID, OpportunityContactRole >([ SELECT OpportunityId FROM OpportunityContactRole WHERE OpportunityId = :Trigger.newMap.keySet() LIMIT 1 ]);
            if(ocrMap.size() < 1){          
                opp.addError('You must add at least 1 Contact Role.');          
            }   
    
    }*/

}