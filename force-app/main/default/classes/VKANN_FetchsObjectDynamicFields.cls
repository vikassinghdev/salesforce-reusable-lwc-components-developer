public class VKANN_FetchsObjectDynamicFields {
    
    // get sobject name...
    @AuraEnabled
    public static String getsObjectName(){
        try{
            Map<String, Schema.SObjectType> sObjectMap = Schema.getGlobalDescribe();
            Map<String,IgnoreNonRequiredsObject__mdt> ignoreNonReuiredsObjectMdtMap = new Map<String,IgnoreNonRequiredsObject__mdt>();
            List<sObjectWrapper> sobjectList = new List<sObjectWrapper>();
            
            for(IgnoreNonRequiredsObject__mdt sObjectMdt : [SELECT Id, ApiName__c, IsVisible__c FROM IgnoreNonRequiredsObject__mdt WHERE IsVisible__c = true]){
                if(!ignoreNonReuiredsObjectMdtMap.containskey(sObjectMdt.ApiName__c)){
                    ignoreNonReuiredsObjectMdtMap.put(sObjectMdt.ApiName__c,sObjectMdt);
                }
            }
            
            for(String sObjectName : sObjectMap.keySet()){
                Schema.DescribeSObjectResult describeResult = sObjectMap.get(sObjectName).getDescribe();
                String label = describeResult.getLabel();
                String apiName = describeResult.getName();
                if((!ignoreNonReuiredsObjectMdtMap.isEmpty() && ignoreNonReuiredsObjectMdtMap.containsKey(apiName) && ignoreNonReuiredsObjectMdtMap.get(apiName).IsVisible__c)
                    && (describeResult.isAccessible() && describeResult.isQueryable() && !describeResult.isCustomSetting() && describeResult.isCreateable()) 
                    && (VKANN_FetchsObjectDynamicFields.ignoreNonRequiredsObject(apiName))) {
                        sObjectWrapper sObjWrap = new sObjectWrapper();
                        sObjWrap.label = label;
                        sObjWrap.apiName = apiName;
                        sobjectList.add(sObjWrap);
                }
            }
            
            if(!sobjectList.isEmpty()) {
                return JSON.serialize(sobjectList);
            }
        }
        catch(Exception ex){
            System.debug('Class Name : BulkRecordInsert -> Method Name : getsObjectName  Message : '+ex.getMessage()+' Line No : '+ex.getLineNumber());
        }
        return null;
    }
    
    // Ignore the Custom or Standard Sharing, Custom metadata, Tag, Platform, or ChageEvent sObject...
    public static Boolean ignoreNonRequiredsObject(String apiName){
        Boolean notSobject = true;
        if(apiName.endsWithIgnoreCase('__mdt') || apiName.endsWithIgnoreCase('__Tag') || apiName.endsWithIgnoreCase('__ChangeEvent') 
             || apiName.endsWithIgnoreCase('__e') || apiName.endsWithIgnoreCase('__Share') || apiName.endsWithIgnoreCase('Tag') || apiName.endsWithIgnoreCase('Share')) {
                 notSobject = false;
             }
        return notSobject;
    }
    
    
    // get required or non required fields of object....
    @AuraEnabled
    public static String getsObjectFieldSchmea(String objectApiName) {
        try{
            Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(objectApiName);
            Map<String,Schema.SObjectField> fieldsMap =  sobjectType.getDescribe().fields.getMap();
            List<sObjectFieldWrapper> sObjectfieldWrapperObjList = new List<sObjectFieldWrapper>();
            
            for(String fieldApiName : fieldsMap.keySet()) {
                Schema.DescribeFieldResult field = fieldsMap.get(fieldApiName).getDescribe();
                Boolean isRequired = field.isNillable();
                String fieldType = String.valueOf(field.getType());
                
                if(VKANN_FetchsObjectDynamicFields.ignoreAuditRequiredField(field.getName())){
                    sObjectFieldWrapper fieldWrapperObj = new sObjectFieldWrapper();
                    fieldWrapperObj.label = field.getLabel();
                    fieldWrapperObj.apiName = field.getName();
                    fieldWrapperObj.lenght = field.getLength();
                    fieldWrapperObj.fieldType = fieldType;
                    fieldWrapperObj.referanceObjectApiName = fieldType.equalsIgnoreCase('REFERENCE') ? field.getRelationshipName()?.replace('__r','__c') : '';
                    if(fieldType.contains('PICKLIST')){
                        fieldWrapperObj.options = VKANN_FetchsObjectDynamicFields.getPicklistOptions(sobjectType, field.getName());
                    }
                    
                    if((!isRequired && !fieldType.equalsIgnoreCase('BOOLEAN')) || (field.isNameField() && field.isCreateable())){
                        fieldWrapperObj.required = field.isNameField() ? isRequired : !isRequired;
                    }
                    else{
                        fieldWrapperObj.required = fieldType.equalsIgnoreCase('BOOLEAN') ? false : !isRequired;
                    }
                    sObjectfieldWrapperObjList.add(fieldWrapperObj);  
                }
            }
            
            if(!sObjectfieldWrapperObjList.isEmpty()){
                return JSON.serialize(sObjectfieldWrapperObjList);
            }
        }
        catch(Exception ex){
            System.debug('Class Name : BulkRecordInsert -> Method Name : getObjectSchmeaFields  Message : '+ex.getMessage()+' Line No : '+ex.getLineNumber());
        }
        return null;
    }
    
    // ignore standard fields of sObject....
    public static Boolean ignoreAuditRequiredField(String fieldApiName) {
        Boolean isRequired = true;
        if(fieldApiName.equalsIgnoreCase('Id') || fieldApiName.equalsIgnoreCase('IsDeleted') || fieldApiName.equalsIgnoreCase('CreatedDate') || fieldApiName.equalsIgnoreCase('OwnerId')
             || fieldApiName.equalsIgnoreCase('CreatedById') || fieldApiName.equalsIgnoreCase('LastModifiedDate') || fieldApiName.equalsIgnoreCase('LastModifiedById') || fieldApiName.equalsIgnoreCase('LastActivityDate') ||
             fieldApiName.equalsIgnoreCase('SystemModstamp') || fieldApiName.equalsIgnoreCase('LastViewedDate') || fieldApiName.equalsIgnoreCase('LastReferencedDate')){ 
                 isRequired = false;
             }
        return isRequired;
    }
	
    // get picklist value from the sObject....
    public static List<Map<String,String>> getPicklistOptions(Schema.SObjectType sobjectType, String fieldApiName) {
        List<Map<String,String>> picklistOptions = new List<Map<String,String>>(); 
        try{
            Map<String,Schema.SObjectField> fields = sobjectType.getDescribe().fields.getMap() ;
            for(Schema.PicklistEntry field : fields.get(fieldApiName).getDescribe().getPicklistValues()){
                picklistOptions.add(new Map<String,String>{'label'=>field.getLabel(), 'value'=>field.getValue()});
            }
        }
        catch(Exception ex){
            System.debug('Class Name : BulkRecordInsert -> Method Name : getPicklistOptions  Message : '+ex.getMessage()+' Line No : '+ex.getLineNumber());
        }
        return picklistOptions;
    }    
    
    // sObjectWrapper - Warpper Class to wrap Label and API Name...
    public class sObjectWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String apiName;
    }
    
    // sObjectFieldWrapper - Wrapper Class to wrap schema field and their options...
    public class sObjectFieldWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String apiName;
        @AuraEnabled public String fieldType;
        @AuraEnabled public Boolean required;
        @AuraEnabled public Integer lenght;
        @AuraEnabled public String referanceObjectApiName;
        @AuraEnabled public List<Map<String,String>> options;
    }
}