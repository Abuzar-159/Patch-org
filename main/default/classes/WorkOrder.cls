global with sharing class WorkOrder {
    
    global class selectOptions {
        @AuraEnabled global String label     { get; set; }
        @AuraEnabled global String value     { get; set; }
        
        global selectOptions(String lab, string val) {
            label = lab;
            value = val;
        } 
    }
}