public With Sharing class BrcdHelperLightning {
    
    @AuraEnabled
    public static Boolean patterMatcher(String regExp,String value){
        Pattern patObj = Pattern.compile(regExp);
        Matcher matObj = patObj.matcher(value);
        return matObj.matches();  
    }
    
}