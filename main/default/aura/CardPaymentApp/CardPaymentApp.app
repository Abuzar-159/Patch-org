<aura:application implements="ltng:allowGuestAccess" access="GLOBAL" extends="ltng:outApp">
	<!--<aura:attribute name="son" type="String" access="global"/>
   <ERP7:CardPayment SON="{!v.son}"/>-->
    <aura:dependency resource="c:CardPayment"/>
</aura:application>