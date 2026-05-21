public class GoogleDriveController {
    public static String code { get; set; } public static String AuthError { get; set; }
    @AuraEnabled public static String response_1 { get; set; }
    public static Blob Clientkey;
    public static Blob secret;
    public static string redirect_uri;
    public static string authUrl = 'https://accounts.google.com/o/oauth2/v2/auth';
    public static string scope = 'https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/drive.metadata.readonly';
    public static Integer expiresIn;
    public static String tokentype;
    public static String DRIVE_UPLOAD_ENDPOINT = 'https://www.googleapis.com/upload/drive/v3/files';
    public static String DRIVE_FOLDER_ENDPOINT = 'https://www.googleapis.com/drive/v3/files'; public static String CurrentUrl { get; set; }    
    public static String mimeTypeJSON = '{"aac": "audio/aac","abw": "application/x-abiword","apng": "image/apng","arc": "application/x-freearc","avif": "image/avif","avi": "video/x-msvideo","azw": "application/vnd.amazon.ebook","bin": "application/octet-stream","bmp": "image/bmp","bz": "application/x-bzip","bz2": "application/x-bzip2","cda": "application/x-cdf","csh": "application/x-csh","css": "text/css","csv": "text/csv","doc": "application/msword","docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document","eot": "application/vnd.ms-fontobject","epub": "application/epub+zip","gz": "application/gzip","gif": "image/gif","htm": "text/html","ico": "image/vnd.microsoft.icon","ics": "text/calendar","jar": "application/java-archive","jpeg": "image/jpeg","js": "text/javascript","json": "application/json","jsonld": "application/ld+json","mjs": "text/javascript","mp3": "audio/mpeg","mp4": "video/mp4","mpeg": "video/mpeg","mpkg": "application/vnd.apple.installer+xml","odp": "application/vnd.oasis.opendocument.presentation","ods": "application/vnd.oasis.opendocument.spreadsheet","odt": "application/vnd.oasis.opendocument.text","oga": "audio/ogg","ogv": "video/ogg","ogx": "application/ogg","opus": "audio/opus","otf": "font/otf","png": "image/png","pdf": "application/pdf","php": "application/x-httpd-php","ppt": "application/vnd.ms-powerpoint","pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation","rar": "application/vnd.rar","rtf": "application/rtf","sh": "application/x-sh","svg": "image/svg+xml","tar": "application/x-tar","tif": "image/tiff","ts": "video/mp2t","ttf": "font/ttf","txt": "text/plain","vsd": "application/vnd.visio","wav": "audio/wav","weba": "audio/webm","webm": "video/webm","webp": "image/webp","woff": "font/woff","woff2": "font/woff2","xhtml": "application/xhtml+xml","xls": "application/vnd.ms-excel","xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet","xml": "application/xml","xul": "application/vnd.mozilla.xul+xml","zip": "application/zip","7z": "application/x-7z-compressed","tiff": "image/tiff","jpg": "image/jpeg","html": "text/html"}';
	public static Map<String, Object> mimeTypeMap = (Map<String, Object>) JSON.deserializeUntyped(mimeTypeJSON);
    
    public GoogleDriveController() {   CurrentUrl = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';//URL.getSalesforceBaseUrl().getHost();
    }
    
    @AuraEnabled
    public static MainWrapper ActiveUser() {          MainWrapper MWrap = new MainWrapper();  try{
            /* ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());  
if(FC==null) FC = ERP7__Functionality_Control__c.getInstance(); }
if(FC != null){ MWrap.functional.SynctoGDrive =FC.ERP7__Sync_to_Google_Drive__c; MWrap.functional.SynctoSalesforce = FC.ERP7__Sync_to_Salesforce__c;} */
            
            //if(MWrap.functional.SynctoGDrive == true){
            List<ERP7__GoogleCredentials__c> ActUser = new List<ERP7__GoogleCredentials__c>();  ActUser = [Select Id, Name, ERP7__UserName__c, ERP7__DriveEmail__c, ERP7__Active__c, ERP7__RefreshToken__c, ERP7__AccessToken__c From ERP7__GoogleCredentials__c Where ERP7__UserName__c = : UserInfo.getUserName() and ERP7__Active__c=true Limit 1];
            if(ActUser.size()>0){	MWrap.userDetail.accessToken = ActUser[0].ERP7__AccessToken__c;	MWrap.userDetail.refreshToken = ActUser[0].ERP7__RefreshToken__c;	MWrap.userDetail.userName = ActUser[0].Name;	MWrap.userDetail.Email = ActUser[0].ERP7__DriveEmail__c;  }  List<ERP7__Credentials__c> DriveDetails = new List<ERP7__Credentials__c>();   DriveDetails = [Select Id, Name, ERP7__Active__c, ERP7__Encrypted_Key__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Password_Transkey__c From ERP7__Credentials__c Where Name = 'GoogleDrive' And ERP7__Active__c = true And ERP7__Username_Login__c != null And ERP7__Password_Transkey__c != null Limit 1];
            
            if (DriveDetails.size()>0) {  Blob cryptoK, clientid, secret;   cryptoK = encodingUtil.convertFromHex(DriveDetails[0].ERP7__Encrypted_Key__c);   clientid = Crypto.decryptWithManagedIV('AES256', cryptoK, encodingUtil.convertFromHex(DriveDetails[0].ERP7__Username_Login__c)); secret = Crypto.decryptWithManagedIV('AES256', cryptoK, encodingUtil.convertFromHex(DriveDetails[0].ERP7__Password_Transkey__c));
                MWrap.GDetail.redirectUri = DriveDetails[0].ERP7__URL__c;  MWrap.GDetail.clientId = clientid.toString();  MWrap.GDetail.clientSecret = secret.toString();
            }
            // }
        }catch(Exception e){    MWrap.Error = 'Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage();
        }
        return MWrap;
    }
    
    @AuraEnabled
    public static MainWrapper uploadGFile(Id parent, List<Id> documentIds, boolean SyncSales, boolean SyncGDrive) {
        
        MainWrapper MWrap = new MainWrapper();
        try {   
            String objectName = parent.getSObjectType().getDescribe().getName();
            List<ERP7__GoogleCredentials__c> ActUser = new List<ERP7__GoogleCredentials__c>();
            ActUser = [Select Id, Name, ERP7__UserName__c, ERP7__DriveEmail__c, ERP7__Active__c, ERP7__RefreshToken__c, ERP7__AccessToken__c From ERP7__GoogleCredentials__c Where ERP7__UserName__c = : UserInfo.getUserName() and ERP7__Active__c=true Limit 1];                
            if(ActUser.size()>0){
                MWrap.userDetail.accessToken = ActUser[0].ERP7__AccessToken__c;
                MWrap.userDetail.refreshToken = ActUser[0].ERP7__RefreshToken__c;
                MWrap.userDetail.userName = ActUser[0].Name;
                MWrap.userDetail.Email = ActUser[0].ERP7__DriveEmail__c;
            }
            
            if(SyncGDrive == true && documentIds.size()>0) {
                List<ERP7__Credentials__c> DriveDetails = new List<ERP7__Credentials__c>();
                DriveDetails = [Select Id, Name, ERP7__Active__c, ERP7__Encrypted_Key__c, ERP7__Source_Drive_ID__c, ERP7__Bill_Drive_ID__c, ERP7__Logistic_Drive_ID__c, ERP7__PO_Drive_ID__c, ERP7__Payment_Drive_ID__c, ERP7__outbound_Drive_ID__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Password_Transkey__c From ERP7__Credentials__c Where Name = 'GoogleDrive' And ERP7__Active__c = true And ERP7__Username_Login__c != null And ERP7__Password_Transkey__c != null Limit 1];
                
                if(DriveDetails.size()>0){  
                    String LocationID, FileJSON, clientId, clientSecret;
                    if(objectName == 'ERP7__Logistic__c'){  ERP7__Logistic__c logistic = [Select Id, ERP7__Type__c From ERP7__Logistic__c where Id=: parent];    if(logistic.ERP7__Type__c=='Inbound' && DriveDetails[0].ERP7__Logistic_Drive_ID__c !=null){ LocationID = DriveDetails[0].ERP7__Logistic_Drive_ID__c; }  else if(logistic.ERP7__Type__c=='Outbound' && DriveDetails[0].ERP7__outbound_Drive_ID__c !=null){ LocationID = DriveDetails[0].ERP7__outbound_Drive_ID__c; }
                    }
                    else if(objectName == 'ERP7__PO__c' && DriveDetails[0].ERP7__PO_Drive_ID__c !=null){ LocationID = DriveDetails[0].ERP7__PO_Drive_ID__c; }
                    else if(objectName == 'ERP7__Bill__c' && DriveDetails[0].ERP7__Bill_Drive_ID__c !=null){ LocationID = DriveDetails[0].ERP7__Bill_Drive_ID__c; }
                    else if(objectName == 'ERP7__Payment__c' && DriveDetails[0].ERP7__Payment_Drive_ID__c !=null){ LocationID = DriveDetails[0].ERP7__Payment_Drive_ID__c; }
                    else if(DriveDetails[0].ERP7__Source_Drive_ID__c !=null) { LocationID = DriveDetails[0].ERP7__Source_Drive_ID__c; }                    
                    
                    Blob cryptoK, client, secret;
                    cryptoK = encodingUtil.convertFromHex(DriveDetails[0].ERP7__Encrypted_Key__c);
                    client = Crypto.decryptWithManagedIV('AES256', cryptoK, encodingUtil.convertFromHex(DriveDetails[0].ERP7__Username_Login__c));
                    secret = Crypto.decryptWithManagedIV('AES256', cryptoK, encodingUtil.convertFromHex(DriveDetails[0].ERP7__Password_Transkey__c));                
                    MWrap.GDetail.redirectUri = DriveDetails[0].ERP7__URL__c;
                    MWrap.GDetail.clientId = clientId = client.toString();
                    MWrap.GDetail.clientSecret = clientSecret = secret.toString();
                    HttpRequest accReq = new HttpRequest();
                    accReq.setMethod('POST');
                    accReq.setEndpoint('https://accounts.google.com/o/oauth2/token');
                    accReq.setHeader('content-type', 'application/x-www-form-urlencoded');
                    String messageBody = 'grant_type=refresh_token&client_id=' + clientId + '&client_secret=' + clientSecret + '&refresh_token=' + ActUser[0].ERP7__RefreshToken__c;
                    accReq.setHeader('Content-length', String.valueOf(messageBody.length()));
                    accReq.setBody(messageBody);
                    accReq.setTimeout(60 * 1000);
                    Http http = new Http();
                    HttpResponse accRes = new HttpResponse();
                    Integer resStatusCode = 0;
                    if(Test.isRunningTest()){
                        response_1 ='{"access_token":"ettete"}'; resStatusCode = 200;
                    }else{     accRes = http.send(accReq); response_1 = accRes.getBody(); resStatusCode = accRes.getStatusCode();
                        System.debug('res1'+accRes.getBody());
                    }
                    if(resStatusCode != 200){     Map<String, Object> errorInfo = (Map<String, Object>) JSON.deserializeUntyped(response_1);  Map<String, Object> errorMap = (Map<String, Object>)errorInfo.get('error');    MWrap.Error = (String)errorMap.get('message');
                    }
                    else if (resStatusCode == 200) {
                        Map<String, Object> tokenInfo = (Map<String, Object>) JSON.deserializeUntyped(response_1);
                        String accessToken = (String) tokenInfo.get('access_token');                       
                        
                        if(accessToken != null){
                            List<ERP7__Google_Drive__c> ListGDrive = new List<ERP7__Google_Drive__c>();
                            String FileSizeError;
							List<ContentVersion> fileList = new List<ContentVersion>();
                			fileList = [Select Id, Title, VersionData, ContentSize, FileType, FileExtension From ContentVersion where ContentDocumentId IN :documentIds and ContentSize < 6000000];
                            for(ContentVersion File: fileList){                              
                                blob blobData = File.VersionData;                                
                                String fileName = File.Title;
                                if(LocationID != null){ FileJSON = '{"name":"' + fileName + '","parents":["' + LocationID + '"]}\r\n'; }
                                else if(LocationID == null){ FileJSON = '{"name":"' + fileName + '"}\r\n'; }
                                resStatusCode = 0;
                                HttpRequest initReq = new HttpRequest();
                                initReq.setEndpoint('https://www.googleapis.com/upload/drive/v3/files?uploadType=resumable&supportsAllDrives=true');
                                initReq.setMethod('POST');
                                initReq.setHeader('Authorization', 'Bearer ' + accessToken);
                                initReq.setHeader('Content-Type', 'application/json');
                                initReq.setHeader('X-Upload-Content-Type', String.valueOf(mimeTypeMap.get(File.FileExtension)));
                                initReq.setHeader('X-Upload-Content-Length', String.valueOf(File.ContentSize));                                  initReq.setBody(FileJSON);  HttpResponse initRes = new HttpResponse();
                                
                                if(Test.isRunningTest()){ response_1 ='{"id":"ettete"}'; resStatusCode = 200;
                                }else{ initRes = http.send(initReq);   response_1 = initRes.getBody(); resStatusCode = initRes.getStatusCode();
                                    System.debug('res'+initRes.getBody());
                                    System.debug('resStatusCode'+resStatusCode);
                                }
                                if(resStatusCode != 200){   Map<String, Object> errorInfo = (Map<String, Object>) JSON.deserializeUntyped(response_1);   Map<String, Object> errorMap = (Map<String, Object>)errorInfo.get('error');  MWrap.Error = (String)errorMap.get('message');
                                }
                                else if (resStatusCode == 200) {
                                    
                                    // Get the resumable session URI from the response headers
                                    String resumableSessionUri;
                                    
                                    if(Test.isRunningTest()){  resumableSessionUri = 'https://test.com';
                                    }else{     resumableSessionUri = initRes.getHeader('Location');
                                    }
                                    
                                    HttpRequest uploadReq = new HttpRequest();   uploadReq.setEndpoint(resumableSessionUri);uploadReq.setMethod('PUT'); uploadReq.setHeader('Authorization', 'Bearer ' + accessToken);
                                    uploadReq.setHeader('Content-Type', String.valueOf(mimeTypeMap.get(File.FileExtension)));  uploadReq.setBodyAsBlob(File.VersionData);
                                    
                                    HttpResponse res = new HttpResponse();                                 
                                    
                                    if(Test.isRunningTest()){  response_1 ='{"id":"ettete"}'; resStatusCode = 200;
                                    }else{
                                        res = http.send(uploadReq);
                                        response_1 = res.getBody(); resStatusCode = res.getStatusCode();
                                        System.debug('res'+res.getBody());
                                        System.debug('resStatusCode'+resStatusCode);
                                    }
                                    if(resStatusCode != 200){
                                        Map<String, Object> errorInfo = (Map<String, Object>) JSON.deserializeUntyped(response_1);
                                        Map<String, Object> errorMap = (Map<String, Object>)errorInfo.get('error');
                                        MWrap.Error = (String)errorMap.get('message');
                                    }
                                    else if (resStatusCode == 200) {
                                        System.debug('resStatusCode2'+System.now());
                                        Map<String, Object> fileInfo = (Map<String, Object>) JSON.deserializeUntyped(response_1);
                                        String fileId = (String) fileInfo.get('id');
                                        fileId = 'https://drive.google.com/file/d/'+fileId;   
                                        Integer maxLength = 79;                         
                                        ERP7__Google_Drive__c GDrive = new ERP7__Google_Drive__c();                        
                                        GDrive.Name = fileName.length() > maxLength ? fileName.substring(0, maxLength) : fileName;
                                        if(objectName == 'ERP7__Logistic__c'){ GDrive.ERP7__Logistic__c = parent; }
                                        else if(objectName == 'ERP7__PO__c'){ GDrive.ERP7__Purchase_Orders__c = parent; }
                                        else if(objectName == 'ERP7__Bill__c'){ GDrive.ERP7__Bill__c = parent; }
                                        else if(objectName == 'ERP7__Payment__c'){ GDrive.ERP7__Payment__c = parent; }
                                        GDrive.ERP7__File_Link__c = fileId;
                                        if(LocationID != null){ String FolderLink = 'https://drive.google.com/drive/folders/'+LocationID; GDrive.ERP7__Folder_Link__c = FolderLink; }
                                        ListGDrive.add(GDrive);
                                    }
                                }                                
                            }
							List<ContentVersion> file2List = new List<ContentVersion>();
                            if(Test.isRunningTest()){
                                file2List = [Select Id, Title, VersionData, ContentSize, FileType, FileExtension From ContentVersion where ContentDocumentId IN :documentIds and ContentSize < 6000000];
                            }else{
                                file2List = [Select Id, Title, ContentSize, FileType, FileExtension From ContentVersion where ContentDocumentId IN :documentIds and ContentSize > 6000000];
                            }
                			
                            for(ContentVersion File: file2List){                                
                                String fileName = File.Title;
                                if(LocationID != null){ FileJSON = '{"name":"' + fileName + '","parents":["' + LocationID + '"]}\r\n'; }
                                else if(LocationID == null){ FileJSON = '{"name":"' + fileName + '"}\r\n'; }
                                resStatusCode = 0;
                                HttpRequest initReq = new HttpRequest();
                                initReq.setEndpoint('https://www.googleapis.com/upload/drive/v3/files?uploadType=resumable&supportsAllDrives=true');
                                initReq.setMethod('POST');
                                initReq.setHeader('Authorization', 'Bearer ' + accessToken);
                                initReq.setHeader('Content-Type', 'application/json');
                                initReq.setHeader('X-Upload-Content-Type', String.valueOf(mimeTypeMap.get(File.FileExtension)));//'application/octet-stream'
                                initReq.setHeader('X-Upload-Content-Length', String.valueOf(File.ContentSize));                                
                                initReq.setBody(FileJSON);
                                
                                HttpResponse initRes = new HttpResponse();
                                
                                if(Test.isRunningTest()){
                                    response_1 ='{"id":"ettete"}'; resStatusCode = 200;
                                }else{
                                    initRes = http.send(initReq);
                                    response_1 = initRes.getBody(); resStatusCode = initRes.getStatusCode();
                                    System.debug('res'+initRes.getBody());
                                    System.debug('resStatusCode'+resStatusCode);
                                }
                                if(resStatusCode != 200){
                                    Map<String, Object> errorInfo = (Map<String, Object>) JSON.deserializeUntyped(response_1);
                                    Map<String, Object> errorMap = (Map<String, Object>)errorInfo.get('error');
                                    MWrap.Error = (String)errorMap.get('message');
                                }
                                else if (resStatusCode == 200) {
                                    
                                    // Get the resumable session URI from the response headers
                                    String resumableSessionUri;
                                    
                                    if(Test.isRunningTest()){
                                        resumableSessionUri = 'https://test.com';
                                    }else{
                                        resumableSessionUri = initRes.getHeader('Location');
                                    }
                                    
                                    HttpRequest request = new HttpRequest();
                                    request.setEndpoint('https://reactorder.herokuapp.com/GoogleDriveUpload');
                                    request.setMethod('POST');
                                    request.setHeader('Content-Type', 'application/json');
                                    request.setBody('{ "Location": "'+ resumableSessionUri +'", "OrgId": "'+ UserInfo.getOrganizationId() +'", "Id": "'+ File.Id +'" }');
                                    request.setTimeout(120000);
                                    HttpResponse response = new HttpResponse();                             
                                    
                                    if(Test.isRunningTest()){
                                        response_1 ='{"id":"ettete"}'; resStatusCode = 200;
                                    }else{
                                        response = http.send(request);
                                        response_1 = response.getBody(); resStatusCode = response.getStatusCode();
                                    }
                                    if(resStatusCode != 200){
                                        Map<String, Object> errorInfo = (Map<String, Object>) JSON.deserializeUntyped(response_1);
                                        Map<String, Object> errorMap = (Map<String, Object>)errorInfo.get('error');
                                        MWrap.Error = (String)errorMap.get('message');
                                    }
                                    else if (resStatusCode == 200) {
                                        Map<String, Object> fileInfo = (Map<String, Object>) JSON.deserializeUntyped(response_1);
                                        String fileId = (String) fileInfo.get('id');
                                        fileId = 'https://drive.google.com/file/d/'+fileId;   
                                        Integer maxLength = 79;                         
                                        ERP7__Google_Drive__c GDrive = new ERP7__Google_Drive__c();                        
                                        GDrive.Name = fileName.length() > maxLength ? fileName.substring(0, maxLength) : fileName;
                                        if(objectName == 'ERP7__Logistic__c'){ GDrive.ERP7__Logistic__c = parent; }
                                        else if(objectName == 'ERP7__PO__c'){ GDrive.ERP7__Purchase_Orders__c = parent; }
                                        else if(objectName == 'ERP7__Bill__c'){ GDrive.ERP7__Bill__c = parent; }
                                        else if(objectName == 'ERP7__Payment__c'){ GDrive.ERP7__Payment__c = parent; }
                                        GDrive.ERP7__File_Link__c = fileId;
                                        if(LocationID != null){ String FolderLink = 'https://drive.google.com/drive/folders/'+LocationID; GDrive.ERP7__Folder_Link__c = FolderLink; }
                                        ListGDrive.add(GDrive);
                                    }
                                }                                
                            }                                                        
                            if(ListGDrive.size()>0){
                                insert ListGDrive;
                            }
                            if(SyncSales == false && documentIds.size()>0){ 
                                List<ContentDocument> CD = [Select Id From ContentDocument where Id IN :documentIds];
                                if(CD.size()>0) delete CD;
                            }
                        }                        
                    }
                }
            }  
        } catch (Exception e) {
            if(SyncSales == false && documentIds.size()>0){ 
                List<ContentDocument> CD = [Select Id From ContentDocument where Id IN :documentIds];
                if(CD.size()>0) delete CD;
            }
            system.debug('Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage());
            MWrap.Error = 'Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage();
        }
        return MWrap;
    }
    
    @AuraEnabled
    public static GDetails GoogleDriveDetails() {
        GDetails GDetail = new GDetails();    
        List<ERP7__Credentials__c> DriveDetails = new List<ERP7__Credentials__c>();
        DriveDetails = [Select Id, Name, ERP7__Active__c, ERP7__Encrypted_Key__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Password_Transkey__c From ERP7__Credentials__c Where Name = 'GoogleDrive' And ERP7__Active__c = true And ERP7__Username_Login__c != null And ERP7__Password_Transkey__c != null Limit 1];
        System.debug('DriveDetails' + DriveDetails);
        if (DriveDetails.size()>0) {
            Blob cryptoK, clientid, secret;
            cryptoK = encodingUtil.convertFromHex(DriveDetails[0].ERP7__Encrypted_Key__c);
            clientid = Crypto.decryptWithManagedIV('AES256', cryptoK, encodingUtil.convertFromHex(DriveDetails[0].ERP7__Username_Login__c));
            secret = Crypto.decryptWithManagedIV('AES256', cryptoK, encodingUtil.convertFromHex(DriveDetails[0].ERP7__Password_Transkey__c));
            GDetail.redirectUri = DriveDetails[0].ERP7__URL__c;
            GDetail.clientId = clientid.toString();
            GDetail.clientSecret = secret.toString();
        }
        return GDetail;
    }
    
    @AuraEnabled
    public static String GoogleDriveAuthUri() {  
        String authuri = '';
        GDetails GDetail = GoogleDriveDetails();
        authuri = authUrl + '?' +
            'client_id=' + GDetail.clientId +
            '&response_type=code' +
            '&include_granted_scopes=true' +
            '&state=state_parameter_passthrough_value' +
            '&scope=' + scope +
            '&redirect_uri=' + GDetail.redirectUri +
            '&access_type=offline' +
            '&prompt=consent';
        return authuri;
    }
    
    public static void AccessToken() {
        try{
            //Getting access token from google
            code = ApexPages.currentPage().getParameters().get('code');
            String ErrorCode = ApexPages.currentPage().getParameters().get('error');
            if(ErrorCode != 'access_denied'){
                GDetails GDetail = GoogleDriveDetails();  
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setEndpoint('https://accounts.google.com/o/oauth2/token');
                req.setHeader('content-type', 'application/x-www-form-urlencoded');
                String messageBody = 'code=' + code + '&client_id=' + GDetail.clientId + '&client_secret=' + GDetail.clientSecret + '&redirect_uri=' + GDetail.redirectUri + '&grant_type=authorization_code';
                req.setHeader('Content-length', String.valueOf(messageBody.length()));
                req.setBody(messageBody);
                req.setTimeout(60 * 1000);
                Http http = new Http();
                HttpResponse res = new HttpResponse();
                Integer resStatusCode = 0;
                if(Test.isRunningTest()){
                    response_1 ='{"access_token":"rwetyquiw","refresh_token":"qerwterytutyti"}'; resStatusCode = 200;
                }else{
                    res = http.send(req); response_1 = res.getBody(); resStatusCode = res.getStatusCode();
                    System.debug('response_1'+response_1);
                }
                
                if (resStatusCode == 200) {
                    //System.debug('res.getBody()'+res.getBody());
                    Map<String, Object> tokenInfo = (Map<String, Object>) JSON.deserializeUntyped(response_1);
                    String accessToken = (String) tokenInfo.get('access_token');
                    String refreshToken = (String) tokenInfo.get('refresh_token');
                    
                    if (accessToken != null && refreshToken != null) {
                        HttpRequest userInfoRequest = new HttpRequest();
                        userInfoRequest.setEndpoint('https://www.googleapis.com/oauth2/v1/userinfo');
                        userInfoRequest.setHeader('Authorization', 'Bearer ' + accessToken);
                        userInfoRequest.setMethod('GET');
                        HTTPResponse userInfoResponse = new HTTPResponse();
                        
                        if(Test.isRunningTest()){
                            response_1 ='{"email":"test@test.com","name":"test"}'; resStatusCode = 200;
                        }else{
                            userInfoResponse = http.send(userInfoRequest); response_1 = userInfoResponse.getBody(); resStatusCode = userInfoResponse.getStatusCode();
                            System.debug('response_1'+response_1);
                        }
                        
                        if (resStatusCode == 200) {
                            //System.debug('userInfoResponse.getBody()'+userInfoResponse.getBody());
                            Map < String, Object > userData = (Map < String, Object >) JSON.deserializeUntyped(response_1);
                            String userEmail = (String) userData.get('email');
                            String userName = (String) userData.get('name');
                            System.debug('User email: ' + userEmail);
                            System.debug('User name: ' + userName);
                            
                            if(userName == null || userEmail == null){
                                AuthError = 'Authoriztion failed';
                            }else{
                                List < ERP7__GoogleCredentials__c > ListOfUser = new List < ERP7__GoogleCredentials__c > ();
                                List < ERP7__GoogleCredentials__c > ListOfUserUpdate = new List < ERP7__GoogleCredentials__c > ();
                                ListOfUser = [Select Id, ERP7__UserName__c, ERP7__DriveEmail__c, ERP7__Active__c, ERP7__RefreshToken__c, ERP7__AccessToken__c From ERP7__GoogleCredentials__c Where ERP7__UserName__c = : UserInfo.getUserName() And ERP7__DriveEmail__c =: userEmail];
                                if(ListOfUser.size()==0){
                                    ERP7__GoogleCredentials__c UserCredential = new ERP7__GoogleCredentials__c();
                                    Integer maxLength = 33;
                                    String usrName = userName +'-'+Datetime.now();
                                    UserCredential.Name = usrName.length() > maxLength ? usrName.substring(0, maxLength) : usrName; 
                                    UserCredential.ERP7__DriveEmail__c = userEmail;
                                    UserCredential.ERP7__UserName__c = UserInfo.getUserName();
                                    UserCredential.ERP7__AccessToken__c = accessToken;
                                    UserCredential.ERP7__RefreshToken__c = refreshToken;
                                    UserCredential.ERP7__Active__c = true;
                                    insert UserCredential;
                                }
                                ListOfUser = [Select Id, ERP7__UserName__c, ERP7__DriveEmail__c, ERP7__Active__c, ERP7__RefreshToken__c, ERP7__AccessToken__c From ERP7__GoogleCredentials__c Where ERP7__UserName__c = : UserInfo.getUserName()];
                                if (ListOfUser.size() > 0) {
                                    for (ERP7__GoogleCredentials__c GC : ListOfUser) {
                                        ERP7__GoogleCredentials__c ExitUser = new ERP7__GoogleCredentials__c();
                                        if (GC.ERP7__DriveEmail__c == userEmail) {
                                            ExitUser.Id = GC.Id;
                                            ExitUser.ERP7__AccessToken__c = accessToken;
                                            ExitUser.ERP7__RefreshToken__c = refreshToken;
                                            ExitUser.ERP7__Active__c = true;
                                            ListOfUserUpdate.add(ExitUser);
                                        }
                                        if (GC.ERP7__DriveEmail__c != userEmail && GC.ERP7__Active__c == true) {
                                            ExitUser.Id = GC.Id;
                                            ExitUser.ERP7__Active__c = false;
                                            ListOfUserUpdate.add(ExitUser);
                                        }                        
                                    }
                                    if (ListOfUserUpdate.size() > 0) update ListOfUserUpdate;
                                    System.debug('ListOfUserUpdate'+ListOfUserUpdate);
                                }
                            }
                        } else {
                            System.debug('Error getting user info: ' + userInfoResponse.getStatusCode() + ' ' + userInfoResponse.getStatus());
                        }
                    }
                } else {
                    AuthError = 'Authoriztion failed';
                }
            }else{
                AuthError = 'Authoriztion failed';
            }
        }catch (Exception e) {
            system.debug('Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage());
        }
    }
    
    @future (callout=true)
    Public static void ShopifyProduct(Set<Id> productIds){
        List<Product2> ListofProducts = [Select Id, Name, ERP7__Description__c, Description, ERP7__Shopify_Id__c, ProductCode, StockKeepingUnit, ERP7__SKU__c, ERP7__Price_Entry_Amount__c, ERP7__Manufacturer__c, ERP7__Picture__c, ERP7__Category__c from Product2 where Id IN :productIds];
        List<Product2> productsToUpdate = new List<Product2>();
		List<pricebookentry> pricebookstocreate = new List<pricebookentry>();
        Id standardPricebookId;
        List<Pricebook2> standardPricebooks = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        
        if (!standardPricebooks.isEmpty()) {
            standardPricebookId = standardPricebooks[0].Id;
        } else if(Test.isRunningTest()){
            standardPricebookId = Test.getStandardPricebookId();
        }
        for(Product2 Prod : ListofProducts){
            if(Prod.ERP7__Shopify_Id__c == null){
                if(Prod.ERP7__Price_Entry_Amount__c != null){
                    pricebookentry pricebooktocreate = new pricebookentry();
                    pricebooktocreate.IsActive = true;
                    pricebooktocreate.Pricebook2Id = standardPricebookId;
                    pricebooktocreate.Product2Id = Prod.Id;
                    pricebooktocreate.UnitPrice = Prod.ERP7__Price_Entry_Amount__c;
                    pricebookstocreate.add(pricebooktocreate);
                }
                HttpRequest request = new HttpRequest();
                request.setEndpoint('https://7e28-49-205-143-17.ngrok-free.app/salesforceProductWebhooks');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                request.setBody('{ "Product": ' + JSON.serialize(Prod) + ', "OrgId": "' + UserInfo.getOrganizationId() + '" }');
                request.setTimeout(120000);
                
                HttpResponse response = new HttpResponse();
                Http http = new Http();
                Integer resStatusCode = 0;
                if(Test.isRunningTest()){
                    response_1 ='{"ShopifyId":"test@test.com","ProductCode":"test"}'; resStatusCode = 200;
                }else{
                    response = http.send(request); response_1 = response.getBody(); resStatusCode = response.getStatusCode();
                    System.debug('response_1'+response_1);
                }
                
                try {
                    
                    if (resStatusCode == 200) {
                        // Parse the JSON response
                        Map<String, Object> respInfo = (Map<String, Object>) JSON.deserializeUntyped(response_1);
                        String ShopifyId = String.valueOf(respInfo.get('ShopifyId'));
                        String ProductCode = String.valueOf(respInfo.get('ProductCode'));
                        
                        // Update the product record based on the received data
                        if (respInfo != null && ShopifyId != null && ProductCode != null) {
                            Product2 productToUpdate = new Product2();
                            productToUpdate.Id = Prod.Id;
                            productToUpdate.ERP7__Shopify_Id__c = ShopifyId;
                            productToUpdate.ProductCode = ProductCode;
                            productsToUpdate.add(productToUpdate);
                        }
                    } else {
                        Map<String, Object> errorInfo = (Map<String, Object>) JSON.deserializeUntyped(response_1);
                        Map<String, Object> errorMap = (Map<String, Object>)errorInfo.get('error');
                        String ErrMsg= String.valueOf(errorMap.get('message'));
                        System.debug('ErrMsg -> '+ErrMsg);
                        throw new AuraHandledException(ErrMsg);
                    }
                } catch (Exception e) {
                    System.debug('Exception ~> ' + e + '; at line ~> ' + e.getStackTraceString());
                    throw new AuraHandledException(e.getMessage());
                }
            }
        }
        if (!pricebookstocreate.isEmpty() && !Test.isRunningTest()) {
            insert pricebookstocreate;
        }  
        if (!productsToUpdate.isEmpty()) {
            update productsToUpdate;
        }        
    }
        
    public class MainWrapper {
        @AuraEnabled public GDetails GDetail { get; set; }
        @AuraEnabled public functionality functional { get; set; }
        @AuraEnabled public userDetails userDetail { get; set; }
        @AuraEnabled public String Error                { get; set; }
        @AuraEnabled public String fileId                { get; set; }
        @AuraEnabled public Attachment Attach                { get; set; }
        @AuraEnabled public ERP7__Google_Drive__c GDrive                { get; set; }
        public MainWrapper(){
            GDetail = new GDetails();
            functional = new functionality();
            userDetail = new userDetails();
            Error = '';
            fileId = '';
            Attach = new Attachment();
            GDrive = new ERP7__Google_Drive__c();
        }
    }
    
    public class GDetails {
        @AuraEnabled public String clientId                   { get; set; }
        @AuraEnabled public String clientSecret                 { get; set; }
        @AuraEnabled public String redirectUri                { get; set; }
        @AuraEnabled public String Error                { get; set; }
        public GDetails() {
            clientId = '';
            clientSecret = '';
            redirectUri = '';
            Error = '';
        }    
    }
    
    public class functionality {
        @AuraEnabled public Boolean SynctoGDrive                { get; set; }
        @AuraEnabled public Boolean SynctoSalesforce                { get; set; }
        public functionality() {
            SynctoGDrive = false;
            SynctoSalesforce = false;
        }    
    }
    
    public class userDetails {
        @AuraEnabled public String accessToken                   { get; set; }
        @AuraEnabled public String refreshToken                 { get; set; }
        @AuraEnabled public String userName                { get; set; }
        @AuraEnabled public String Email                { get; set; }
        @AuraEnabled public String Error                { get; set; }
        
        public userDetails() {
            accessToken = '';
            refreshToken = '';
            userName = '';
            Email = '';
            Error = '';
        }    
    }
}