public interface AQBarcode {
  
  Boolean isValid(String brcd);
  String drawBarcode(String brcd, String BarcdHeight);
}