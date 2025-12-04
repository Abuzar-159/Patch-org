public with sharing class LocationFinder implements LocationMapper{

    public String LatLangs {get;set;}
    public string MarkerXMLFormat {get;set;}
    public String Latitude {get; set;}
    public String Longitude {get; set;}
    public String Radius {get; set;}
    public String objectName {get; set;}
    public Boolean resultDisplay {get; set;}
    public String objectLabel {get; set;}      public String errMsg {get; set;}     
    public String street {get; set;}
    public String city {get; set;}
    public String country {get; set;}
    public String zipCode {get; set;}   public String alphaField {get; set;}   public String navURL {get; set;} public String RecordId {get; set;}
            
        
    public Boolean boolcity {get; set;} public String betaField {get; set;}    
    public Boolean boolcountry {get; set;}
    public Boolean boolzipCode {get; set;}     
    public Boolean boolstreet {get; set;}
    public Boolean boolLatitude {get; set;}  
    public Boolean boolLongitude {get; set;}
    
    public LocationFinder(){
    try{
        MarkerXMLFormat ='';
        LatLangs = '';
        Latitude ='';
        Longitude ='';
        Radius = '20'; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }       
         }
    
    public String sObjectLabel {
   		get {
            if(objectName != null) {   List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objectName}); objectLabel = describeSobjectsResult[0].getLabel();  return objectLabel; } return '';
        }
    }
    
    public LocationFinder(ApexPages.StandardController controller) {
      }
        
    public void grabLatLong(){
    try{
            if (LatLangs != null) {
                LatLangs = LatLangs.trim();
                LatLangs = LatLangs.substring(1, LatLangs.length() - 2).trim();
                String[] reslArry = LatLangs.split(',');
                if (reslArry.size() > 1) {
                    Latitude = reslArry[0];
                    Longitude = reslArry[1];
                }
            }
            Latitude = Latitude.trim();
            Longitude = Longitude.trim();
            if ((Latitude == '') || (Longitude == '')) {
            }
           returnMarkerXMLFormat(Decimal.valueOf(Latitude),Decimal.valueOf(Longitude)); } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
    }
        
    public void returnMarkerXMLFormat(Decimal latitude, Decimal longitude) {
        try {                     
            
            List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objectName}); // this can accept list of strings, we describe only one object here
            objectLabel = describeSobjectsResult[0].getLabel();
             
            resultDisplay = true;              
            String q = 'select '+String.escapeSingleQuotes(UtilClass.selectStarFromSObject(objectName));     
            q += ' from '+String.escapeSingleQuotes(objectName);            
            q += ' where DISTANCE(ERP7__Location__c, GEOLOCATION( ';
            q += String.escapeSingleQuotes(String.valueOf(latitude)) + ', ' + String.escapeSingleQuotes(String.valueOf(longitude));
            q += ' ), \'km\') < 100 ';
            q += 'Order By DISTANCE(ERP7__Location__c, GEOLOCATION( ';
            q += String.escapeSingleQuotes(String.valueOf(latitude)) + ', ' + String.escapeSingleQuotes(String.valueOf(longitude));
            q += ' ), \'km\') asc limit 25';            
            
            boolLatitude = q.contains('location__longitude__s');
            boolLongitude = q.contains('location__latitude__s');
            boolstreet = q.contains(street);
            boolcity = q.contains(city); 
            boolcountry = q.contains(country);
            boolzipCode = q.contains(zipCode);                         
                        
            List <sObject> nearByStore = new List <sObject>();                    
                nearByStore = Database.query(q); 
                                               
            if(boolstreet == true && boolcity == true && boolcountry == true && boolzipCode == true && boolLatitude == true && boolLongitude == true) {                 
                String geoXML = '<markers>';
                    for (sObject sObj: nearByStore) { if(sObj.get(street) != null && sObj.get(city) != null && sObj.get(country) != null && sObj.get(zipCode) != null && sObj.get('Location__Latitude__s') != null && sObj.get('Location__Longitude__s') != null) {                        
                            geoXML += '<marker name="' + String.valueof(sObj.get('Name')).escapeXml() + '"'; geoXML += ' street="' + String.valueof(sObj.get(Street)).escapeXml() + '"'; geoXML += ' city="' + String.valueof(sObj.get(city)).escapeXml() + '"';
                            geoXML += ' country="' + String.valueof(sObj.get(country)).escapeXml() + '"'; geoXML += ' zipCode="' + String.valueof(sObj.get(zipCode)).escapeXml() + '"'; geoXML += ' id="' + String.valueof(sObj.get('Id')).escapeXml() + '"';
                            geoXML += ' lat="' + String.valueof(sObj.get('Location__Latitude__s')).escapeXml() + '"'; geoXML += ' lng="' + String.valueof(sObj.get('Location__Longitude__s')).escapeXml() + '"'; geoXML += ' city="' + String.valueof(sObj.get(city)).escapeXml() + '"';
                            geoXML += ' objLabel="' + String.valueof(objectLabel).escapeXml() + '"'; geoXML += ' /> ';
                        } else {
                            geoXML += '<marker name="' + String.valueof(sObj.get('Name')).escapeXml() + '"'; geoXML += ' address=""'; geoXML += ' id="' + String.valueof(sObj.get('Id')).escapeXml() + '"';
                            geoXML += ' lat="' + String.valueof(sObj.get('Location__Latitude__s')).escapeXml() + '"'; geoXML += ' lng="' + String.valueof(sObj.get('Location__Longitude__s')).escapeXml() + '"';
                            geoXML += ' city=""'; geoXML += ' objLabel="' + String.valueof(objectLabel).escapeXml() + '"'; geoXML += ' /> ';
                        }
                    }
                geoXML += '</markers>';  
                MarkerXMLFormat = geoXML;
            } else if(boolLatitude == true && boolLongitude == true){
                   
                String geoXML = '<markers>';
                    for (sObject sObj: nearByStore) { geoXML += '<marker name="' + String.valueof(sObj.get('Name')).escapeXml() + '"'; geoXML += ' address=""'; geoXML += ' id="' + String.valueof(sObj.get('Id')).escapeXml() + '"';
                        geoXML += ' lat="' + String.valueof(sObj.get('Location__Latitude__s')).escapeXml() + '"'; geoXML += ' lng="' + String.valueof(sObj.get('Location__Longitude__s')).escapeXml() + '"';
                        geoXML += ' city=""'; geoXML += ' objLabel="' + String.valueof(objectLabel).escapeXml() + '"'; geoXML += ' /> ';
                    }
                    geoXML += '</markers>';  
                    MarkerXMLFormat = geoXML;
            } 
        } catch(Exception e) { errMsg = 'There might be some problem with object setup, please contact support'; String geoXML = '<markers'; geoXML += 'errMsg="' + errMsg.escapeXml() + '"'; geoXML += ' objLabel="' + objectLabel.escapeXml() + '"'; geoXML += ' /> '; MarkerXMLFormat = geoXML;
        }
              
    }
               
    public String serviceResults(String lat, String lon){
    try{
        returnMarkerXMLFormat(Decimal.valueOf('51.5182322'),Decimal.valueOf('-0.1196624')); } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }      
}