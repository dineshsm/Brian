/**

Last update 2010-07-15
labs@salesforce.com

* with sharing added
* squashed bugs around single / multiple updates
* added limits to SOQL -- 100 for Campaigns 1000 for Campaign Members
* fixed custom settings manager
* updated Static Resources 

*/
global class CampaignCallDownController implements ObjectPaginatorListener{
	
	//setup appropriate variables
	private Boolean 			hasCampaignID = false;
	private string 				thisCampaign;
  	//private Lead[] 				lead; 
  	private Contact[] 			contact;
	private CampaignMember[] 	members; //the members for that campaign
	private Lead[] 				relevantLeads; 
	private List<leadPlusTaskPlusContact> 	leadPlusTasks;
	private List<leadPlusTaskPlusContact> 	totalList;
	private Map<String, Boolean> 			callDownColumns;
	private List<Campaign> 		activeCampaigns;
	public String 				camp { get;set; } //campaign ID
	public String 				campcat { get;set; } //campaign Category
	public String 				status{ get;set; } //status ID
	private Map<String, String> cStatusMap;
	private Map<String, String> cCategoryMap;	
	private Map<String, String> cCategoryMapIsSet;	
	private boolean 			cStatusMapIsSet;
	public string 				campBackup;
	public string 				backRef{ get; set; }
	public list<SelectOption> 	owners;
	public List<SelectOption> rejectionReasonValue;
	public List<SelectOption> campaignCategoryValue;	
	public List<SelectOption> taskSubjectValue;
	global ObjectPaginator paginator {get;private set;}
	
	public List<leadPlusTaskPlusContact> getTotalList() {
		if(totalList == null){
			totalList = new List<leadPlusTaskPlusContact>(); 			
		}
		return totalList;
	}
	
	
	global void handlePageChange(List<Object> newPage){
		leadPlusTasks.clear();
		if(newPage != null){
			for(Object lpt2 : newPage){
				leadPlusTasks.add((leadPlusTaskPlusContact)lpt2);
			}
		}
	}
	
	private void campaignUpdatePage() {
        paginator.page = null;
        if(paginator.all != null && paginator.all.size() > 0){
            paginator.page = new List<Object>();
            for (Integer i = paginator.pageStartPosition; i <= paginator.pageEndPosition; i++) {
                paginator.page.add(paginator.all.get(i));
            }
        }
    }
	
	//Instantiate the StandardSetController - For Paging  
    public ApexPages.StandardSetController con{get; set;}
		
	public string ownerId{
		 get{
		 	//if (ownerId == null || ownerId == '')
		 	 //return UserInfo.getUserId();
		 	return ownerId; 
		 	}
		 set; 
	}
	
	/**
	*Constructor
	*/
	public CampaignCallDownController(){
		relevantLeads = new Lead[ 0 ];
		leadPlusTasks = new leadPlusTaskPlusContact[]{};
		callDownColumns = new Map<String, Boolean>();

		//get columns settings and set to Map
		if( ApexPages.currentPage().getUrl() != null ){
		  	camp = ApexPages.currentPage().getUrl().substring( 1 );
		}
		campBackup = camp;
		backRef = '/apex/CampaignCallDownSettings?var=/' + camp;
		cStatusMap = new Map<String, String>();
		cStatusMapIsSet = false;
		owners = new list<SelectOption>();
	}
    
		/**
		*Return a list of rejection reason values
		*/
	    public List<SelectOption> getrejectionReasonValue(){
	    	if(rejectionReasonValue == null){
	    		Schema.DescribeFieldResult fieldResult = Lead.Rejection_Reason__c.getDescribe();
		    	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		        List<SelectOption> options = new List<SelectOption>();
		        options.add(new SelectOption('', ''));
		        for( Schema.PicklistEntry f : ple)
	   			{
	      			options.add(new SelectOption(f.getLabel(), f.getValue()));
	   			}       
	   			rejectionReasonValue = options;
	    	}
	    	return rejectionReasonValue;
  		}
  		
  		/**
		*Return a list of rejection reason values
		*/
	    public List<SelectOption> gettaskSubjectValue(){
	    	if(taskSubjectValue == null){
		    	Schema.DescribeFieldResult fieldResult = Task.Subject.getDescribe();
		    	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		        List<SelectOption> options = new List<SelectOption>();
		        options.add(new SelectOption('', ''));
		        for( Schema.PicklistEntry f : ple)
	   			{
	      			options.add(new SelectOption(f.getLabel(), f.getValue()));
	   			}       
	   			taskSubjectValue = options;
	    	}
	    	return taskSubjectValue;
	    	
  		}
	
	/**
	*Return if has campaign id
	*@return hasCampaignID boolean flag
	*/
	public Boolean gethasCampaignID(){
		return hasCampaignID;
	}
	
	/**
	*Return the list of owners
	*@return owners
	*/
	public List<SelectOption> getowners(){		
		return owners;
	}
	
	public void setowners( List<SelectOption> l ){
		owners = l;
	}
	
	/**
	*Update all status and log , retuen page reference for redirection
	*@return null
	*/
	public PageReference updateAll(){

		List<leadPlusTaskPlusContact> cleanRecords = new List<leadPlusTaskPlusContact>();
	 	 for( leadPlusTaskPlusContact current :leadPlusTasks ){
	 	 	current.setTaskErrorMessage('');
		 	current.setErrorMessage('');
  	 	 	//status
	 	 	boolean updated = false;
	 	  	boolean rejected = false;
		  
			  //If another call has been scheduled save it..
			  System.debug('scheduleCallDate = ' +current.scheduleCallDate);
			  if(current.scheduleCallDate != null && current.scheduleCallDate != ''){
			  	Task nextCall = new Task();
			    try{			    	
			    	String formattedDate = current.scheduleCallDate.replace('-','/');
            		nextCall.ActivityDate = date.parse(formattedDate);
            		nextCall.WhoId = current.ID;
					nextCall.Status = 'Not Started';
					nextCall.Subject = 'Followup call';
					nextCall.Description = '';
					insert nextCall;
					updated = true;
			    } catch (Exception e){
			    	updated = false;
			    	current.errorMessage = e.getMessage();	
			    }

			  }



	 	  if(current.statusUpdate != null && current.statusUpdate != current.memStatus){	    
		    CampaignMember cm = [Select Id, Status From CampaignMember Where id = :current.MemberId limit 1];

		    cm.status = current.statusUpdate;
		    
		    if(current.cORl == 'lead'){		    			    
			    // update the status of the lead 
			    Lead l = [Select Id, Status From Lead Where id = :current.ID limit 1];	
			    
			    if(current.statusUpdate.contains('Connected')){
			    	l.Status = 'Working';
			    }else if(current.statusUpdate == 'Remarket'){
			    	rejected = true;
			    	l.Status = 'Remarket';	
			    }else if (current.statusUpdate == 'Invalid'){
			    	rejected = true;
			    	l.Status = 'Invalid';    	
			    }else if (current.statusUpdate == 'Dead'){
			    	rejected = true;
			    	current.REJECTIONREASON = 'No interest';
			    	l.Status = 'Dead';
			    }
			    //current.errorMessage = current.REJECTIONREASON+' Error saving Lead status, you must provide a Rejection Reason.';
			    //updated = false;
			    if(rejected == true && current.REJECTIONREASON == null){		    	
					current.errorMessage = 'Error: you must provide a Rejection Reason.';
					updated = false;
			    }else{
				    if(rejected = true){				    	
				    	l.Rejection_Reason__c = current.REJECTIONREASON;
				    }
				    try{
				    	update l;
				    	update cm;
				    	updated= true;	
				    }catch(Exception e){
				    	updated = false;
				    	current.errorMessage = e.getMessage();				    	
				    }			    					    
			    }
		    }else{
		    	update cm;
		    	updated= true;
		    }	    
		  }
		  if (updated || (current.t.Description != '' && current.t.Description != null)) {
		  //log a call
		    if(current.selectedSubject == ''|| current.selectedSubject == null){
		    	current.setTaskErrorMessage('Error: you must provide a Task Subject.');		    	
		    	updated = false;		    	
		    }else{
				current.t.Subject = current.selectedSubject + ' - ' +this.getCampaignName();
				insert current.t;
				updated = true;
		    }
		  }

		  		  
		  if (!updated) {
		  	cleanRecords.add(current);
		  }
		 }
		 leadPlusTasks = cleanRecords;
	 	return null;
	}
	
	/**
	*Filter Owners for leads
	*/
	private void filterOwner(){
		System.debug('ownerId = ' +ownerId);
		if(leadPlusTasks.size() < 1 || ownerId == '--ALL--' || ownerId == null){
			return;
		}else{
			list<leadPlusTaskPlusContact> newLptList = new list<leadPlusTaskPlusContact>();
			for( leadPlusTaskPlusContact lpt : leadPlusTasks ){
				if( lpt.ownerId == ownerId )
				  newLptList.add(lpt);
			}
			leadPlusTasks = newLptList;
		}
	}	
	
	
	public PageReference campaignRefresh1(){
		//ownerId = UserInfo.getUserId();
		return campaignRefresh();
	}
	
	public PageReference campaignRefresh2(){
		getCampaignItems();
		if(campcat == 'Inbound'){
			campaignRefresh();
		}
		return null;
	}
	
	/**
	*Refresh campaign list
	*@return page reference
	*/
	public PageReference campaignRefresh(){
		Map<String, String>ownerMap = new Map<String, String>();
		relevantLeads.clear(); leadPlusTasks.clear(); 
		cStatusMapIsSet = false;
		//if ( camp != null && camp.length( ) >3 ){
			//set some variable values
	   		hasCampaignID = true; 
	   		try{
		   		if(campcat == 'Inbound'  && (camp == '1' || camp == null || camp.length( ) <=1)){
		   			members = [select Id, ContactId, LeadId, Status, CampaignId, Campaign.Name,
			   			Lead.Id, Lead.IsConverted, Lead.Salutation, Lead.Title, Lead.Name, Lead.Company, Lead.Phone, 
			   			Lead.Street, Lead.State, Lead.PostalCode, Lead.Country, Lead.City, Lead.Fax, 
			   			Lead.Email, Lead.Status, Lead.Rejection_Reason__c, Lead.OwnerId, Lead.Owner.FirstName, Lead.Owner.LastName, Lead.Owner.Id,
			   			Contact.ID, Contact.AccountId, Contact.Salutation, Contact.Title, Contact.Name, 
			   			Contact.Phone, Contact.MailingStreet, Contact.MailingState, Contact.MailingPostalCode, 
			   			Contact.MailingCountry, Contact.MailingCity, Contact.Fax, Contact.Email, Contact.OwnerId,
			   			Contact.Owner.FirstName, Contact.Owner.LastName, Contact.Owner.Id, Contact.Account.name
			   			from CampaignMember where CampaignMember.Campaign.Campaign_Category__c = 'Inbound' order by CampaignMember.LastModifiedDate desc LIMIT 50];			   			
		   		}else{		   		
			   		if( status == null || status == '--ALL--' )
			   			members = [select Id, ContactId, LeadId, Status, CampaignId, Campaign.Name,
			   			Lead.Id, Lead.IsConverted, Lead.Salutation, Lead.Title, Lead.Name, Lead.Company, Lead.Phone, 
			   			Lead.Street, Lead.State, Lead.PostalCode, Lead.Country, Lead.City, Lead.Fax, 
			   			Lead.Email, Lead.Status, Lead.Rejection_Reason__c, Lead.OwnerId, Lead.Owner.FirstName, Lead.Owner.LastName, Lead.Owner.Id,
			   			Contact.ID, Contact.AccountId, Contact.Salutation, Contact.Title, Contact.Name, 
			   			Contact.Phone, Contact.MailingStreet, Contact.MailingState, Contact.MailingPostalCode, 
			   			Contact.MailingCountry, Contact.MailingCity, Contact.Fax, Contact.Email, Contact.OwnerId,
			   			Contact.Owner.FirstName, Contact.Owner.LastName, Contact.Owner.Id, Contact.Account.name
			   			from CampaignMember where CampaignId = :camp order by CampaignMember.LastModifiedDate desc LIMIT 100];
		 		    else
		 		      members = [ select Id, ContactId, LeadId, Status, CampaignId, Campaign.Name,
		 		      Lead.Id, Lead.IsConverted, Lead.Salutation, Lead.Title, Lead.Name, Lead.Company, Lead.Phone, 
		 		      Lead.Street, Lead.State, Lead.PostalCode, Lead.Country, Lead.City, Lead.Fax, 
		 		      Lead.Email, Lead.Status, Lead.Rejection_Reason__c, Lead.OwnerId, Lead.Owner.FirstName, Lead.Owner.LastName, Lead.Owner.Id,
		        	  Contact.ID, Contact.AccountId, Contact.Salutation, Contact.Title, Contact.Name, 
		          	  Contact.Phone, Contact.MailingStreet, Contact.MailingState, Contact.MailingPostalCode,
		           	  Contact.MailingCountry, Contact.MailingCity, Contact.Fax, Contact.Email, Contact.OwnerId,
		              Contact.Owner.FirstName, Contact.Owner.LastName, Contact.Owner.Id, Contact.Account.name
		              from CampaignMember where CampaignId = :camp and Status = :status order by CampaignMember.LastModifiedDate desc LIMIT 100];
		   		}
		   		
	   		}catch( Exception e ){
	   			ApexPages.addMessages( e );
	   		}
	        if( members.size() > 0 )
	 			thisCampaign = members[ 0 ].Campaign.Name;
	 		else
	 			thisCampaign ='';
	 			    
	 		//loop through all leads, add relevent leads and their status
	 		for ( CampaignMember m : members ){
	 			if((m.Lead.id != null) && (!m.Lead.IsConverted)){
	 				addLPT(m, camp, ownerMap, leadPlusTasks);
	 			}else if(m.Contact.id != null && m.Lead.id == null){
					addLPT(m, camp, ownerMap, leadPlusTasks);
	 			}
	 		}
	 		System.debug('ownerMap = ' + ownerMap);
			//set owners
	 		owners = ownerMapToSelectOption( ownerMap );
	     	//filter for owner
	     	filterOwner();
	     	getTotalList().clear();
			for (leadPlusTaskPlusContact lpt2 :leadPlusTasks ){
				totalList.add(lpt2);
			}
			paginator = new ObjectPaginator(5, this);
			paginator.setRecords(totalList);
			
			//System.debug('record count = ' + paginator.all.size());
	 		//if( leadPlusTasks.size() > 1 )
	    		//quickSort( 'NAME',0, leadPlusTasks.size()-1 );
 		//}else{ 
 		//	hasCampaignID=false;
 		//	camp=this.campBackup;
 		//}
 		return null;
	}
	
	private void addLPT(CampaignMember m, String camp, Map<String, String> ownerMap, List<leadPlusTaskPlusContact> leadPlusTasks){
 		leadPlusTaskPlusContact lpt = new leadPlusTaskPlusContact( m, getcStatusMap( camp ), camp );
	    leadPlusTasks.add( lpt );
	    ownerMap.put( lpt.ownerId, lpt.ownerFirstName + ' ' + lpt.ownerLastName );
	}
	
	/**
	*With a map of owners and return a list of select option
	*@param ownerMap
	*@return returnVal
	*/
	private List<SelectOption> ownerMapToSelectOption( Map<String, String> ownerMap ){
		List<SelectOption> returnVal=new List<SelectOption>();
		Set<String> keys = new Set<String>();
		keys = ownerMap.keySet();
		returnVal.add( new SelectOption( '--ALL--', '--ALL--' ));
		for ( String s: keys ){
			returnVal.add( new SelectOption(s, ownerMap.get( s )));
		}
		
		return returnVal;
	}
	
	/**
	*Sort by name
	*@return null
	*/
	public PageReference sortByName(){
		if( getTotalList().size() > 1 ){
			quickSort( 'NAME',0, getTotalList().size()-1 );
			campaignUpdatePage();
			handlePageChange(paginator.page);
		}     		
		return null;
	}
	
	/**
	*Sort by name
	*@return null
	*/
	public PageReference sortByTaskDate(){
		if( getTotalList().size() > 1 ){
			quickSort( 'TaskDate',0,  getTotalList().size()-1  );			
			campaignUpdatePage();
			handlePageChange(paginator.page);
		}     		
		return null;
	}


	/**
	*Sort by title
	*@return null
	*/
	public PageReference sortByTitle(){
	    if( getTotalList().size() > 1 )
	     	quickSort( 'TITLE',0, getTotalList().size()-1 );
	     	campaignUpdatePage();
			handlePageChange(paginator.page);
	    return null;
	}	

	/**
	*Sort by Company
	*@return PageReference = null
	*/
	public PageReference sortByCompany(){
    	if( getTotalList().size() > 1 )
     		quickSort( 'COMPANY',0, getTotalList().size()-1 );
     		campaignUpdatePage();
			handlePageChange(paginator.page);
    	return null;
  	} 
  
	/**
	*Sort by Status
	*@return PageReference = null
	*/
	public PageReference sortByStatus(){
    	if( getTotalList().size() > 1 )
     		quickSort( 'STATUS',0, getTotalList().size()-1 );
     		campaignUpdatePage();
			handlePageChange(paginator.page);
    	return null;
    }
  	
  	/**
  	*Implementation of Quick sort
  	*@param key
  	*@param left
  	*@param right
  	*/
	private void quickSort( String key, integer left, integer right ){
		/*if(((leadPlusTaskPlusContact)paginator.all[left]).nTaskDate == null ){
			((leadPlusTaskPlusContact)paginator.all[left]).setNTaskDate(date.today().addYears(10));
		}
		if(((leadPlusTaskPlusContact)paginator.all[right]).nTaskDate == null){
			((leadPlusTaskPlusContact)paginator.all[right]).setNTaskDate(date.today().addYears(10));
		}*/
			
	      integer index = partition( key, left, right );
	      if ( left < index - 1 )
	        quickSort( key, left, index - 1 );
	      if (index < right )
	        quickSort( key, index, right );
	}	
	
	/**
	*Aux method for implement Quick Sort
  	*@param key
  	*@param left
  	*@param right
	*@return i
	*/
	private integer partition( String key, integer left, integer right ){
      integer i = left, j = right;
      leadPlusTaskPlusContact tmp;
      leadPlusTaskPlusContact tmp2;
      leadPlusTaskPlusContact pivot = (leadPlusTaskPlusContact)paginator.all[( left + right ) / 2 ];
      while ( i <= j ){
        while ( compare( key, (leadPlusTaskPlusContact)paginator.all[ i ], pivot )) // compare left with center
          i++;
        while ( compare( key, pivot,(leadPlusTaskPlusContact)paginator.all[ j ]))
          j--;
        if ( i <= j ){
          tmp = (leadPlusTaskPlusContact)paginator.all[ i ];
          paginator.all[i] = paginator.all[ j ];
          paginator.all[ j ] = tmp;
          i++;
          j--;
        }
      }
      return i;
  }
	
	/**
	*Compare 2 leads
	*@sortKey
	*leadPlusTaskPlusContact
	*leadPlusTaskPlusContact
	*@return Boolean
	*/
	private boolean compare( string sortKey, leadPlusTaskPlusContact r1, leadPlusTaskPlusContact r2 ){
	   if( sortKey=='TITLE' )
	     return r1.TITLE < r2.TITLE;
	   else if( sortKey == 'COMPANY' )
	     return r1.COMPANY < r2.COMPANY;
	   else if( sortKey == 'STATUS')
	     return r1.memStatus < r2.memStatus;
	   else if(sortKey == 'TaskDate')
	   	 return (r1.getNTaskDate() < r2.getNTaskDate());	   
	   else 
	     return r1.NAME < r2.NAME;
	}
	
	/**
	*Return a status map
	*@param cId
	*@return cStatusMap
	*/
	public Map<String,String> getcStatusMap( string cId ){
		if( !cStatusMapIsSet ){
		   	CampaignMemberStatus[] cStatus = [ Select Label From CampaignMemberStatus where campaignId =: cId ]; 
        	cStatusMap.clear();
       	 	for ( CampaignMemberStatus s:cStatus )
        		cStatusMap.put( s.Label, '' );
        	cStatusMapIsSet = true;
		}  
		return cStatusMap;
	}
   
    /**
    *Return campaign items
    *@return options    
    */
    public List<SelectOption> getcampaignItems(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption( '1', 'SELECT' ));
        List<Campaign> cList = getactiveCampaigns();
        if(cList != null && cList.size() >= 1){
        	for( Campaign c:cList){        	
            	options.add( new SelectOption( c.ID, c.Name ));
        	}	
        }                
        return options;
    }
   
   
    /**
    *Return status items option list 
    *@return options
    */
	public List<Selectoption> getstatusItems(){
		List<SelectOption> options = new List<SelectOption>();
		options.add( new SelectOption( '--ALL--', '--ALL--' ));
		if ( camp == null || camp == '1' ){
			return options;
			}
		else	{
			for ( String k : getcStatusMap( camp ).keySet())
				options.add( new SelectOption( k, k ));
			return options;
		}
			 
	}

	/**
	*Return a list of campaigns options
	*@return activeCampaigns
	*/
	public List<Campaign> getactiveCampaigns(){
		//if( activeCampaigns == null && campcat != ''){
			activeCampaigns = [ Select Type, Id, Name From Campaign where isActive = true and Campaign_Category__c = :campcat order by name LIMIT 100];
		//}
		return activeCampaigns;
	}
	
	
	/**
	*Return a list of rejection reason values
	*/
	public List<SelectOption> getCampaignCategoryValue(){
	  	if(campaignCategoryValue == null){	   		
	        List<SelectOption> options = new List<SelectOption>();
	        options.add(new SelectOption('', ''));	        
	  		options.add(new SelectOption('Organic', 'Organic'));
	  		options.add(new SelectOption('Outbound', 'Outbound'));	        
	  		options.add(new SelectOption('Inbound', 'Inbound'));			       
			campaignCategoryValue = options;
	   	}
	   	return campaignCategoryValue;
  	}
	
	/**
	*Return the name
	*@retutn callDownColumns.get('Name')
	*/
	public Boolean getName(){
		return callDownColumns.get( 'Name' );
	}
	
	/**
	*Return the campaign name
	*/
	public String getCampaignName(){
		if ( hasCampaignID ){
			return thisCampaign;
		} else{
			return 'All Leads';
		}	
	}
		
	/**
	*Return lead Plus Task
	*/
	public List<leadPlusTaskPlusContact> getLeadPlusTasks(){
		
		/*List<List<leadPlusTaskPlusContact>> accList = new List<List<leadPlusTaskPlusContact>>();
		for(integer i =0 ;i<100;i++){
            List<leadPlusTaskPlusContact> acc = new List<leadPlusTaskPlusContact>();
            for(integer j = 0;j<100;j++){
            	if(i+j < leadPlusTasks.size()){
            		acc.add(leadPlusTasks[i+j]);	
            	}else{            		
            		break;
            	}
                                
            }
            accList.add(acc);
        }     
		return accList;
		*/
		
		return leadPlusTasks;	
	}
	
	/**
	* Inner class to wrap Lead or Contact sobject.
	*/
	public class leadPlusTaskPlusContact{
		//variable for each piece of the combined record

		public Task t;
		public String memStatus      {get; set;}
		public Map<String, String> localCStatusMap;
		public string ID             {get; set;}
		public string NAME           {get; set;}
		public string TITLE          {get; set;}
		public string SALUTATION     {get; set;}
		public string PHONE          {get; set;}
		public string COMPANY        {get; set;}
		public string REJECTIONREASON {get; set;}
		public boolean isAContact    {get; set;}
		public string cORl           {get; set;}
		public string statusUpdate   {get; set;}
		public string memberID       {get; set;}
		public string ADDRESS        {get; set;}
		public string EMAIL          {get; set;}
		public string FAX            {get; set;}
		public string ownerFirstName {get; set;}
		public string ownerLastName  {get; set;}
		public string ownerId        {get; set;}
	    public string accountName    {get; set;}
	    public string callType       {get; set;}
	    public string errorMessage;
	    public string taskErrorMessage;
	    public Date nTaskDate = null;
	    public string nextTaskDate = null;
	    public string lastThreeTasks = '';
	    public String scheduleCallDate {get;set;}	   	   
  
  		public String getNextTaskDate(){
  			if(nextTaskDate == null){
  				List<Task> nextT = [ Select ActivityDate, id From Task where whoId = :ID and Status = 'Not Started'];
  				if(nextT.size() >= 1){
  					nextTaskDate = '<a href="/'+nextT[0].id+'">'+nextT[0].ActivityDate+'</a>';
  				}
  			}return nextTaskDate;
  		}
  		
  		public Date getNTaskDate(){  			
  			if(nTaskDate == null){
  				List<Task> nextT = [Select ActivityDate, id From Task where whoId = :ID and Status = 'Not Started'];
  				if(nextT.size() >= 1){
  					setNTaskDate(nextT[0].ActivityDate);
  				}else{
  					nTaskDate = date.today().addYears(10);	// This is for sorting to ensure no null values.
  				}  				
  			}
  			return nTaskDate;
  		}
  		
  		public void setNTaskDate(Date taskDate){
  			nTaskDate = taskDate;
  		}
  		  		
  		public String getLastThreeTasks(){
  			if(lastThreeTasks == ''){  				
  				List<Task> lastT = [ Select ActivityDate, id, Subject From Task where whoId = :ID and Status = 'Completed' and ActivityDate != null order by ActivityDate desc limit 3];
  				for( Task t:lastT){  					
  					lastThreeTasks += '<a href="/'+t.id+'">'+t.Subject+'</a> - ' + t.ActivityDate +'<br/>';  					
  				}
  			}return lastThreeTasks;
  		}
  		
  		
	    public String selectedSubject = null;
	    
   		public String getselectedSubject()
    	{
       		if(selectedSubject==null || selectedSubject==''){
       			selectedSubject='Outbound Lead Call';
       			t.subject = selectedSubject;
       			   			 
       		}
       		return selectedSubject;       				
    	}
		
		public void setselectedSubject(String subject){
				selectedSubject = subject;
		}
	    
		/*public Integer activityNumber{
	   		get
	    	{
				List<Task> ts = [ Select Id From Task where whoId = :ID and Status = 'Completed'];
				return ts.size();
				//return 0;
	    	}
			set;
		}*/
	
		/**
		*Constructor
		*@param m is a campaign member
		*@param statusMap a map of atatuses
		*@param camp id of campaign
		*/	
	    public leadPlusTaskPlusContact( CampaignMember m, Map<String, String> statusMap, string camp ){
	       	if ( m.Lead.id != null ){
				cORl = 'lead';
				//l=incomingLead;
				ID = m.Lead.Id;
				NAME = m.Lead.Name;
				TITLE = m.Lead.Title;
				SALUTATION=m.Lead.Salutation;
				PHONE = m.Lead.Phone;
				COMPANY = m.Lead.Company;
				REJECTIONREASON = m.Lead.Rejection_Reason__c;
				if( m.Lead.Street != null ){
					ADDRESS = m.Lead.Street + '<br>';
				 	if(m.Lead.City != null){
				 		ADDRESS += ', ' +m.Lead.City;
				 	}
				 	if(m.Lead.State != null){
				 		ADDRESS += ', ' +m.Lead.State;
				 	}
				 	if(m.Lead.PostalCode != null){
				 		ADDRESS += ', ' +m.Lead.PostalCode;
				 	}
				 	if(m.Lead.Country != null){
				 		ADDRESS += '<br>'+m.Lead.Country;
				 	}
				}	
				else
				  	ADDRESS=' ';
				 
					if(m.Lead.Email != null){
						EMAIL = '<a href="mailto:' + m.Lead.Email+'">' + m.Lead.Email + ' </a>';	
					}else{
						EMAIL =' ';
					}
					FAX=m.Lead.Fax;
					ownerFirstName = m.Lead.Owner.FirstName; ownerLastName = m.Lead.Owner.LastName; 
		       		ownerId = m.Lead.OwnerId; 
			}else{
				cORl = 'contact';
	       
		       	if( m.Contact.MailingStreet != null ){
		       		ADDRESS = m.Contact.MailingStreet + '<br>';
		       		if(m.Contact.MailingCity != null){
		       			ADDRESS += ', '+m.Contact.MailingCity;
		       		}
		       		if(m.Contact.MailingState != null){
		       			ADDRESS += ', '+m.Contact.MailingState;
		       		}
		       		if(m.Contact.mailingPostalCode != null){
		       			ADDRESS += ', '+m.Contact.mailingPostalCode;
		       		}
		       		if(m.Contact.MailingCountry != null){
		       			ADDRESS += '<br>' + m.Contact.MailingCountry;
		       		}
		       }else{
		       		ADDRESS = ' ';
		       }
		        
		       ID 				= m.Contact.Id;
		       NAME 			= m.Contact.Name;
		       TITLE 			= m.Contact.Title;
		       SALUTATION		= m.Contact.Salutation;
		       PHONE 			= m.Contact.Phone;
		       if(m.Contact.Email != null){
		       		EMAIL = '<a href="mailto:' + m.Contact.Email + '">' + m.Contact.Email + '</a>';		
		       }else{
		       		EMAIL = ' ';
		       }
		       
		       FAX				= m.Contact.Fax;
		       ownerFirstName 	= m.Contact.Owner.FirstName; ownerLastName = m.Contact.Owner.LastName; 
		       ownerId 			= m.Contact.OwnerId;
		       if ( m.Contact.Account.name != null )
		        	COMPANY = m.Contact.Account.name;
		       else
		          COMPANY = '';
			}
			t = new Task();
			t.ActivityDate = System.today();
			t.WhoId = ID;
			t.Status = 'Completed';
			t.Subject = '';
			t.Description = '';
			if ( m.Lead.id == null && (camp != null && camp != '1')){
				t.WhatId = camp;
			}
			memberID = m.ID;
			memStatus = m.Status;
			localCStatusMap = statusMap;
		}

		/**
		*Return a task
		*@return t
		*/
	    public Task gett(){
	    	return t;
	    }
	    
		/**
		*Set the task propertie
		*@param tsk
		*/
		public Void sett( Task tsk ){
			t = tsk;
		}
		
		public String getErrorMessage(){
			return errorMessage;
		}
		
		public void setErrorMessage(String errMsg){
			errorMessage = errMsg;
		}
		
		public String getTaskErrorMessage(){
			return taskErrorMessage;
		}
		
		public void setTaskErrorMessage(String errMsg){
			taskErrorMessage = errMsg;
		}
		
		
		/**
		*Return member status
		*@return memStatus
		*/
		public String getmemStatus(){
			return memStatus;
		}

		/**
		*Return a list of members status values
		*/
	    public List<SelectOption> getmemStatusValue(){
	        List<SelectOption> options = new List<SelectOption>();
	        options.add( new SelectOption( memStatus, memStatus )); 
	        for( String k: localCStatusMap.keySet()){
	      		if( k != memStatus )
	      	 		options.add( new SelectOption( k, k ));
	      	}
	    	return options;
  		}  		
  		
  		/**
		*Return a list of members status values
		*/
	    public List<SelectOption> getCampaignCategories(){
	        List<SelectOption> options = new List<SelectOption>();
	        options.add( new SelectOption( memStatus, memStatus )); 
	        for( String k: localCStatusMap.keySet()){
	      		if( k != memStatus )
	      	 		options.add( new SelectOption( k, k ));
	      	}
	    	return options;
  		}  	
   
	}
	

	
}