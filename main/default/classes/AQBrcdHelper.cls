public with sharing class AQBrcdHelper {

public static Boolean patterMatcher(String regExp,String value){
try{
    Pattern patObj = Pattern.compile(regExp);
    Matcher matObj = patObj.matcher(value);
    return matObj.matches(); } catch(Exception e) {  } return null;    
}

}