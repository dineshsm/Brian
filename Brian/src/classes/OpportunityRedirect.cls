public with sharing class OpportunityRedirect {
	private ApexPages.StandardController controller;
	public String retURL {get; set;}
	public String saveNewURL {get; set;}
	public String rType {get; set;}
	public String cancelURL {get; set;}
	public String ent {get; set;}
	public String confirmationToken {get; set;}
	public String accountID {get; set;}
	public String contactID {get; set;}
	public String department {get; set;}
	

	public opportunityRedirect(ApexPages.StandardController controller) {	
		this.controller = controller;		
		retURL = ApexPages.currentPage().getParameters().get('retURL');
		rType = ApexPages.currentPage().getParameters().get('RecordType');
		cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
		ent = ApexPages.currentPage().getParameters().get('ent');
		confirmationToken = ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN');
		saveNewURL = ApexPages.currentPage().getParameters().get('save_new_url');
		accountID = ApexPages.currentPage().getParameters().get('accid');
		contactID = ApexPages.currentPage().getParameters().get('conId');
		department = ApexPages.currentPage().getParameters().get('Department');
	}

	public PageReference redirect(){
	
		PageReference returnURL;
		
		// Redirect if Record Type corresponds to custom VisualForce page		
		IF(contactID == null) {		
			returnURL = new PageReference('/apex/createOpportunity2');
		}ELSE {		
			returnURL = new PageReference('/006/e');		
		}
		
		returnURL.getParameters().put('retURL', retURL);
		returnURL.getParameters().put('nooverride', '1');
		returnURL.getParameters().put('cancelURL', cancelURL);
		returnURL.getParameters().put('ent', ent);
		returnURL.getParameters().put('_CONFIRMATIONTOKEN', confirmationToken);
		returnURL.getParameters().put('save_new_url', saveNewURL);
		
		IF (accountID != null){
			returnURL.getParameters().put('accid', accountID);
		}
		
		IF (contactID != null){
			returnURL.getParameters().put('conid', contactID);
		}
		
		IF (department != null){
			returnURL.getParameters().put('00N200000031QPi', department);
		}
		
		returnURL.setRedirect(true);
		return returnURL;
	
	}
}