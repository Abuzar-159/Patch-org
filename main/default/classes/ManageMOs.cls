global with sharing class ManageMOs { 
    @RemoteAction
    global static List<Product_Service__c> searchProducts(String searchString) {
        return null;
    }
    
    @RemoteAction
    global static List<ERP7__Manufacturing_Order__c> searchProductsP(String searchString) {
        return null;
    }
    
    @RemoteAction
    global static List<WO__c> searchWOs(String searchString) {
        return null;
    }
    
   
    @RemoteAction
    global static List<Work_Station__c> searchWSs(String searchString) {
        return null;
    }
   
    
    @RemoteAction
    global static List<Work_Center__c> searchWSss(String searchString) {
        return null;
    }
    
}