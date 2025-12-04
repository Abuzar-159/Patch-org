global with sharing class ManageMaintenanceWOs {
    @RemoteAction
    global static List<Product_Service__c> searchProducts(String searchString) {
        return null;
    }
    
    @RemoteAction
    global static List<ERP7__WO__c> searchProductsP(String searchString) {
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