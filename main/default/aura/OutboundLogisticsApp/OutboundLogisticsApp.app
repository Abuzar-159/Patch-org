<aura:application access="GLOBAL" extends="ltng:outApp" implements="ltng:allowGuestAccess">
	<aura:attribute name="loId" type="String" access="global"/>
    <c:OutboundLogistics logisticId="{!v.loId}"/>
</aura:application>