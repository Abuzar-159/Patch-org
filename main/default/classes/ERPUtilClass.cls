public with sharing class ERPUtilClass {
    public static String formatTime(Time times){
        String sTime = '';
        Integer iHour = 0, iMin=0;
        if(times.hour() >= 12){
             if(! (times.hour() == 12)){  iHour = times.hour() - 12;  }
             if(iHour == 0){  iHour = 12;  }
             iMin = times.minute();
             if(iHour < 10){  sTime = String.valueOf(iHour) + ':';//10
             }
             else{
                sTime =  String.valueOf(iHour)  + ':';
             }
             if(iMin < 10){  sTime += '0' + String.valueOf(iMin)  + ' PM';//10
             }
             else{
                sTime +=  String.valueOf(iMin) + ' PM';
             }
            
            
        }
        else{
             iHour = times.hour();
             iMin = times.minute();
             if(iHour < 10){ sTime = '0' + String.valueOf(iHour) + ':'; }
             else{ sTime =  String.valueOf(iHour)  + ':'; }
             if(iMin < 10){ sTime += '0' + String.valueOf(iMin)  + ' AM'; }
             else{
                sTime +=  String.valueOf(iMin) + ' AM';
             }
        }
        return sTime;
    }
    
    public static String formatTime24Hours(Time times){
        String sTime = '';
        //String sTime = '';
        Integer iHour = 0, iMin=0;
		     iHour = times.hour();
             iMin = times.minute();
             if(iHour < 10){//10
                 sTime = '0' + String.valueOf(iHour) + ':';
             }
             else{
                sTime =  String.valueOf(iHour)  + ':';
             }
             if(iMin < 10){  sTime += '0' + String.valueOf(iMin)  ;
             }
             else{
                sTime +=  String.valueOf(iMin) ;
             }
        return sTime;
    }
    
    
}