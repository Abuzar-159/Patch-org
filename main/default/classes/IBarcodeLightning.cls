public interface IBarcodeLightning {
    
    Boolean isValid(String brcd);   
    String drawBarcode(String Brcd, String BarcdHeight, String BarWidth, Boolean brcdValHide);
}