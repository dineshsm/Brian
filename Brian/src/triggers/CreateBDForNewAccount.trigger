trigger CreateBDForNewAccount on Account (after insert) {
    Financial_Object__c fo = new Financial_Object__c();
    for (Account a : Trigger.new) {
        fo.Account__c = a.id;
        fo.SageId__c = '00000';     
    }
    if(fo.Account__c != null){
        insert fo;
    }
}