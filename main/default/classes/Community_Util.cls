global with sharing class Community_Util {
    
    global static String baseURL    {get;set;}
    global static String commValue  {get;set;}
    global static String splitURL   {get;set;}
    global static String commAppend {get;set;}            
    
    global Community_Util() {}
    
    global static string communityValue() {        
      try{                     
        commAppend = ''; 
        baseURL = ApexPages.currentPage().getHeaders().get('referer');
        if(baseURL != null && baseURL !=''){
            splitURL = baseURL.split('https://')[1];
            commValue = splitURL.substringBetween('/', '/');
                
            ConnectApi.CommunityPage coms = ConnectApi.Communities.getCommunities();
            List<ConnectApi.Community> allCommunities = coms.communities;
              
            if(allCommunities.size() > 0) {           
                for(ConnectApi.Community conCom : allCommunities) {        
                    if(commValue == conCom.urlPathPrefix) {  commAppend = conCom.urlPathPrefix;    break;
                    } 
                }            
            }                
        } 
        return commAppend;  } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }     return null;      
    }   
}