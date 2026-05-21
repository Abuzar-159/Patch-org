<aura:application access="GLOBAL" extends="ltng:outApp" implements="ltng:allowGuestAccess">
	<aura:attribute name="loId" type="String" access="global"/>
    <c:InboundLogistics logisticId="{!v.loId}"/>
</aura:application>