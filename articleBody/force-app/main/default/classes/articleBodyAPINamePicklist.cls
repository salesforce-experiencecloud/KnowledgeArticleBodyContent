global class articleBodyAPINamePicklist extends VisualEditor.DynamicPickList{
    
    VisualEditor.DesignTimePageContext context;

    global articleBodyAPINamePicklist(VisualEditor.DesignTimePageContext context) {
        this.context = context;
     }

     global override VisualEditor.DataRow getDefaultValue(){
        
        VisualEditor.DynamicPickListRows rowList =  getPicklistRows();
        if(rowList.size() > 0) 
        {
            return rowList.get(0);
        }

        return null;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        
        return getPicklistRows();
    }

    private static VisualEditor.DynamicPickListRows getPicklistRows() {
        
        List<EntityDefinition> entityDefinitionList = [SELECT DurableId,QualifiedApiName FROM EntityDefinition 
                                                        WHERE QualifiedApiName LIKE '%__kav' ORDER BY QualifiedApiName ASC];
        Set<Id> entityDefinitionIdSet = new Set<Id>();
        for(EntityDefinition entDef : entityDefinitionList)
        {
            entityDefinitionIdSet.add(entDef.DurableId);
        }

        List<FieldDefinition> fieldDefinitionList = [SELECT Id, QualifiedApiName FROM FieldDefinition WHERE EntityDefinitionId IN :entityDefinitionIdSet 
                                                    AND IsHtmlFormatted = true AND ExtraTypeInfo = 'richtextarea' ORDER BY DeveloperName ASC];

        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();        
        
        for(FieldDefinition f : fieldDefinitionList)
        {
            VisualEditor.DataRow value = new VisualEditor.DataRow(f.QualifiedApiName,f.QualifiedApiName);
            myValues.addRow(value);
        }
        
        return myValues;

    }
    
}